package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/user"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/HumXC/html-greet/greetd"
	"github.com/rkoesters/xdg/desktop"
)

type App struct {
	ctx        context.Context
	env        []string
	sessionDir []string
}

func NewApp(sessionDir, env []string) *App {
	return &App{
		sessionDir: sessionDir,
		env:        env,
	}
}
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

func (a *App) Login(username, password, session string) error {
	sessions, err := a.GetSessions()
	if err != nil {
		return err
	}
	for _, s := range sessions {
		if s.Name == session {
			cmd := s.Exec
			env := a.env
			return greetd.Login(username, password, []string{cmd}, env)
		}
	}
	return fmt.Errorf("session %s not found", session)
}
func (a *App) GetSessions() ([]desktop.Entry, error) {
	result := []desktop.Entry{}
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
			result = append(result, *desktopEntry)
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
