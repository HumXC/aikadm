package main

import (
	"embed"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"github.com/urfave/cli/v2"
	"github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/options"
	"github.com/wailsapp/wails/v2/pkg/options/assetserver"
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
		Commands: []*cli.Command{
			{
				Name:   "wailsjs",
				Usage:  "Output wailsjs folder to current directory (defaulr: ./wailsjs)",
				Action: CmdWailsjs,
			}},
	}

}
func CmdMain(ctx *cli.Context) error {
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
	app := NewApp(sessionDir, env)

	err := wails.Run(&options.App{
		Title:      "html-greet",
		Width:      1024,
		Height:     768,
		Frameless:  true,
		Fullscreen: true,
		AssetServer: &assetserver.Options{
			Handler: NewAssetServer(ctx.String("assets")),
		},
		BackgroundColour: &options.RGBA{R: 27, G: 38, B: 54, A: 1},
		OnStartup:        app.startup,
		Bind: []any{
			app,
		},
	})

	return err
}

//go:embed all:frontend/wailsjs
var Wailsjs embed.FS

func CmdWailsjs(ctx *cli.Context) error {
	targetDir := "./wailsjs"
	if ctx.Args().Get(0) != "" {
		targetDir = ctx.Args().Get(0)
	}
	return fs.WalkDir(Wailsjs, "frontend/wailsjs", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if path == "frontend/wailsjs" {
			return nil
		}
		targetPath := filepath.Join(targetDir, strings.TrimPrefix(path, "frontend/wailsjs/"))
		if d.IsDir() {
			return os.MkdirAll(targetPath, os.ModePerm)
		}

		data, err := Wailsjs.ReadFile(path)
		if err != nil {
			return err
		}

		return os.WriteFile(targetPath, data, 0644)
	})
}
