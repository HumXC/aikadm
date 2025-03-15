package main

import (
	"context"
	"fmt"
	"os/user"
)

type MookApp struct {
	ctx        context.Context
	env        []string
	sessionDir []string
}

func (m *MookApp) GetSessions() ([]SessionEntry, error) {
	panic("unimplemented")
}

func (m *MookApp) GetUserAvatar(username string) (string, error) {
	panic("unimplemented")
}

func (m *MookApp) GetUsers() ([]user.User, error) {
	panic("unimplemented")
}

func (m *MookApp) ReadConfig() (any, error) {
	panic("unimplemented")
}

func (m *MookApp) SaveConfig(config any) error {
	panic("unimplemented")
}

func NewMookApp(sessionDir, env []string) *MookApp {
	return &MookApp{
		env:        env,
		sessionDir: sessionDir,
	}
}

func (m *MookApp) Login(username string, password string, session string) error {
	if password == "password" {
		return nil
	}
	return fmt.Errorf("development mode, password is hardcoded to 'password'")
}

func (m *MookApp) Reboot() error {
	return fmt.Errorf("development mode, cannot reboot")
}

func (m *MookApp) Shutdown() error {
	return fmt.Errorf("development mode, cannot shutdown")
}

func (m *MookApp) startup(ctx context.Context) {
	m.ctx = ctx
}

var _ IHtmlGreet = (*MookApp)(nil)
