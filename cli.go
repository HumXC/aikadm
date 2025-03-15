package main

import (
	"os"
	"os/exec"
	"strings"

	"github.com/urfave/cli/v2"
	"github.com/wailsapp/wails/v3/pkg/application"
)

func NewCli() *cli.App {
	return &cli.App{
		Name:   "html-greet",
		Action: CmdMain,
		Flags: []cli.Flag{
			&cli.StringSliceFlag{
				Name:    "session-dir",
				Aliases: []string{"d"},
				Value:   cli.NewStringSlice("/usr/share/xsessions", "/usr/share/wayland-sessions/"),
				Usage:   "Session directories to search for",
			},
			&cli.StringSliceFlag{
				Name:    "env",
				Aliases: []string{"e"},
				Usage:   "Environment to run in, e.g. -e KEY1=VALUE1 -e KEY2=VALUE2",
			},
			&cli.StringFlag{
				Name:    "assets",
				Aliases: []string{"a"},
				Value:   "",
				Usage:   "Set of assets to serve",
			},
		},
	}

}
func CmdMain(ctx *cli.Context) error {
	if sock := os.Getenv("GREETD_SOCK"); sock != "" {
		cmd := exec.Command("cage", "-s", "--", strings.Join(os.Args, " "))
		return cmd.Run()
	}
	if os.Getenv("XDG_SESSION_TYPE") == "wayland" {
		os.Setenv("GDK_BACKEND", "wayland")
	}
	var sessionDir []string
	var env []string
	for _, dir := range ctx.StringSlice("session-dir") {
		triped := strings.TrimSpace(dir)
		if triped != "" {
			sessionDir = append(sessionDir, triped)
		}
	}
	for _, envVar := range ctx.StringSlice("env") {
		triped := strings.TrimSpace(envVar)
		if triped != "" {
			env = append(env, triped)
		}
	}

	app := application.New(application.Options{
		Name: "html-greet",
		Assets: application.AssetOptions{
			Handler: NewAssetServer(ctx.String("assets")),
		},
		Services: []application.Service{
			application.NewService(NewApp(sessionDir, env)),
		},
	})
	app.NewWebviewWindowWithOptions(application.WebviewWindowOptions{
		Frameless: true,
		Title:     "html-greet",
	})
	return app.Run()
}
