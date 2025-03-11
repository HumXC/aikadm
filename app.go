package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/HumXC/html-greet/greetd"
	"github.com/godbus/dbus/v5"
	"github.com/rkoesters/xdg/desktop"
	"github.com/rkoesters/xdg/keyfile"
)

type IApp interface {
	startup(ctx context.Context)
	Login(username, password, session string) error
	GetSessions() ([]SessionEntry, error)
	GetUsers() ([]user.User, error)
	GetUserAvatar(username string) (string, error)
	Shutdown() error
	Reboot() error
	ReadConfig() (any, error)
	SaveConfig(config any) error
}
type App struct {
	ctx        context.Context
	env        []string
	sessionDir []string
	dev        bool
	mookApp    *MookApp
}

var _ IApp = (*App)(nil)

func NewApp(sessionDir, env []string) *App {
	app := &App{
		sessionDir: sessionDir,
		env:        env,
		mookApp: &MookApp{
			sessionDir: sessionDir,
			env:        env,
		},
	}
	if _, ok := os.LookupEnv("GREETD_SOCK"); !ok {
		app.dev = true
	}
	return app
}
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
	a.mookApp.startup(ctx)
}

func (a *App) Login(username, password, session string) error {
	if a.dev {
		return a.mookApp.Login(username, password, session)
	}
	sessions, err := a.GetSessions()
	if err != nil {
		return err
	}
	for _, s := range sessions {
		if s.Name == session {
			cmd := []string{s.Exec}
			env := a.env
			if s.SessionType == "xorg" {
				tty, err := os.ReadFile("/sys/class/tty/tty0/active")
				if err != nil {
					return err
				}
				// FIXME
				xorg := fmt.Sprintf("Xorg :0 vt%s", strings.TrimPrefix(string(tty), "tty"))
				fmt.Println(xorg)
				env = append(env, "DISPLAY=:0")
				cmd = append([]string{xorg}, cmd...)
			}
			return greetd.Login(username, password, cmd, env)
		}
	}
	return fmt.Errorf("session %s not found", session)
}

type SessionEntry struct {
	desktop.Entry
	Type        string
	SessionType string
}

func (a *App) GetSessions() ([]SessionEntry, error) {
	result := []SessionEntry{}
	for _, dir := range a.sessionDir {
		err := filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
			if err != nil {
				return err
			}
			if d.IsDir() {
				return nil
			}
			if filepath.Ext(path) != ".desktop" {
				return nil
			}
			f, err := os.Open(path)
			if err != nil {
				return err
			}
			defer f.Close()

			desktopEntry, err := desktop.New(f)
			if err != nil {
				return err
			}
			f.Seek(0, io.SeekStart)
			kf, err := keyfile.New(f)
			if err != nil {
				return err
			}
			typeStr := kf.Value("Desktop Entry", "Type")
			sessionType := ""
			baseDir := filepath.Base(filepath.Dir(path))
			if baseDir == "xsessions" {
				sessionType = "xorg"
			}
			if baseDir == "wayland-sessions" {
				sessionType = "wayland"
			}
			sessionEntry := SessionEntry{
				Entry:       *desktopEntry,
				Type:        typeStr,
				SessionType: sessionType,
			}
			result = append(result, sessionEntry)
			return nil
		})
		if err != nil {
			return nil, err
		}
	}
	return result, nil
}
func (a *App) GetUsers() ([]user.User, error) {
	result := []user.User{}
	for i := 1000; i < 60000; i++ {
		user, err := user.LookupId(strconv.Itoa(i))
		if err != nil {
			break
		}
		result = append(result, *user)
	}
	return result, nil
}
func (a *App) GetUserAvatar(username string) (string, error) {
	user, err := user.Lookup(username)
	if err != nil {
		return "", err
	}
	icons := []string{
		fmt.Sprintf("/var/lib/AccountsService/icons/%s", username),
		fmt.Sprintf("%s/.face", user.HomeDir),
	}
	for _, icon := range icons {
		f, err := os.Open(icon)
		if err != nil {
			fmt.Println("INFO: Can not open avatar file:", icon)
			continue
		}
		buf := strings.Builder{}
		encoder := base64.NewEncoder(base64.StdEncoding, &buf)
		io.Copy(encoder, f)
		f.Close()
		encoder.Close()
		return buf.String(), nil
	}
	return "", fmt.Errorf("no avatar found for user %s", username)
}
func (a *App) Shutdown() error {
	if a.dev {
		return a.mookApp.Shutdown()
	}
	conn, err := dbus.SystemBus()
	if err != nil {
		return err
	}
	obj := conn.Object("org.freedesktop.login1", "/org/freedesktop/login1")
	call := obj.Call("org.freedesktop.login1.Manager.PowerOff", 0, true)
	return call.Err
}

func (a *App) Reboot() error {
	if a.dev {
		return a.mookApp.Reboot()
	}
	conn, err := dbus.SystemBus()
	if err != nil {
		return err
	}
	obj := conn.Object("org.freedesktop.login1", "/org/freedesktop/login1")
	call := obj.Call("org.freedesktop.login1.Manager.Reboot", 0, true)
	return call.Err
}

const ConfigPath = "/var/tmp/html-greet-config.json"

func (a *App) ReadConfig() (any, error) {
	if _, err := os.Stat(ConfigPath); os.IsNotExist(err) {
		return nil, fmt.Errorf("config file not found: %s", ConfigPath)
	}
	f, err := os.Open(ConfigPath)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	var config any
	decoder := json.NewDecoder(f)
	err = decoder.Decode(&config)
	if err != nil {
		return nil, err
	}
	return config, nil
}
func (a *App) SaveConfig(config any) error {
	f, err := os.Create(ConfigPath)
	if err != nil {
		return err
	}
	defer f.Close()
	encoder := json.NewEncoder(f)
	err = encoder.Encode(config)
	if err != nil {
		return err
	}
	return nil
}

func (a *App) Exec(command []string) (result string, err error) {
	cmd := exec.Command(command[0], command[1:]...)
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return string(output), nil
}
