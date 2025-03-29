package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"log"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"sort"
	"strconv"
	"strings"

	"github.com/HumXC/aikadm/greetd"
	"github.com/godbus/dbus/v5"
	"github.com/rkoesters/xdg/desktop"
	"github.com/rkoesters/xdg/keyfile"
)

type Aikadm struct {
	env        []string
	sessionDir []string
	logger     *log.Logger
	execCmds   []*exec.Cmd
}

func NewAikadm(sessionDir, env []string) *Aikadm {
	app := &Aikadm{
		sessionDir: sessionDir,
		env:        env,
		logger:     log.New(os.Stdout, "aikadm: ", log.LstdFlags),
	}
	return app
}
func (a *Aikadm) stop() {
	for _, cmd := range a.execCmds {
		_ = cmd.Process.Kill()
	}
}

// Login logs in the user with the given username and password.
// sessionIndex specifies the index of the session to start, use GetSessions to get the list of available sessions.
func (a *Aikadm) Login(username, password string, sessionIndex int) error {
	sessions, err := a.GetSessions()
	if err != nil {
		return err
	}
	if sessionIndex < 0 || sessionIndex >= len(sessions) {
		return fmt.Errorf("invalid session index %d", sessionIndex)
	}
	session := sessions[sessionIndex]
	cmd := []string{session.Exec}
	env := a.env
	if session.SessionType == "xorg" {
		// https://github.com/apognu/tuigreet/blob/master/src/greeter.rs#L40
		cmd = []string{fmt.Sprintf("startx /usr/bin/env %s", session.Exec)}
	}
	return greetd.Login(username, password, cmd, env)
}

type SessionEntry struct {
	desktop.Entry
	Type        string
	SessionType string
}

func (a *Aikadm) GetSessions() ([]SessionEntry, error) {
	result := []SessionEntry{}
	for _, dir := range a.sessionDir {
		err := filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
			if err != nil {
				a.logger.Println(err)
				return nil
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
	sort.Slice(result, func(i, j int) bool {
		return result[i].Name < result[j].Name
	})
	return result, nil
}
func (a *Aikadm) GetUsers() ([]user.User, error) {
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

// Find the avatar file in the user's home directory, with priority:
// 1. /var/lib/AccountsService/icons/username
// 2. ~/.face
// Return the base64-encoded image data.
// If no avatar is found, return an empty string and an error.
func (a *Aikadm) GetUserAvatar(username string) (string, error) {
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

func (a *Aikadm) Shutdown() error {
	conn, err := dbus.SystemBus()
	if err != nil {
		return err
	}
	obj := conn.Object("org.freedesktop.login1", "/org/freedesktop/login1")
	call := obj.Call("org.freedesktop.login1.Manager.PowerOff", 0, true)
	return call.Err
}

func (a *Aikadm) Reboot() error {
	conn, err := dbus.SystemBus()
	if err != nil {
		return err
	}
	obj := conn.Object("org.freedesktop.login1", "/org/freedesktop/login1")
	call := obj.Call("org.freedesktop.login1.Manager.Reboot", 0, true)
	return call.Err
}

const ConfigPath = "/var/tmp/aikadm-config.json"

// ReadConfig reads the configuration file and returns the parsed JSON object.
// The returned object is of type any, which means that the caller must type-assert it to the actual type.
// The error is returned if the config file is not found or cannot be opened.
func (a *Aikadm) ReadConfig() (any, error) {
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

func (a *Aikadm) SaveConfig(config any) error {
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

func (a *Aikadm) exec(command []string) *exec.Cmd {
	cmd := exec.Command(command[0], command[1:]...)
	a.execCmds = append(a.execCmds, cmd)
	a.logger.Printf("executed command: [%s]", strings.Join(cmd.Args, " "))
	return cmd
}

func (a *Aikadm) Exec(command []string) (pid int, err error) {
	cmd := a.exec(command)
	err = cmd.Start()
	if err != nil {
		return 0, fmt.Errorf("failed to execute command: [%s] : %s", strings.Join(cmd.Args, " "), err.Error())
	}
	pid = cmd.Process.Pid
	return
}

func (a *Aikadm) KillProcess(pid int) {
	for i, cmd := range a.execCmds {
		if cmd.Process.Pid == pid {
			_ = cmd.Process.Kill()
			a.execCmds = append(a.execCmds[:i], a.execCmds[i+1:]...)
			return
		}
	}
	return
}

// ExecOutput executes the given command and returns the combined output.
func (a *Aikadm) ExecOutput(command []string) (result string, err error) {
	cmd := a.exec(command)
	defer a.KillProcess(cmd.Process.Pid)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("failed to execute command: [%s] : %s %s", strings.Join(cmd.Args, " "), err.Error(), string(output))
	}
	return string(output), nil
}

// If an error is returned, it means that the current mode is demo mode.
// The demo mode is triggered when the GREETD_SOCK environment variable is not set or the wails backend cannot be connected to.
func (a *Aikadm) TestDemoMode() error {
	if os.Getenv("GREETD_SOCK") == "" {
		return fmt.Errorf("GREETD_SOCK not set, running in demo mode")
	}
	return nil
}
