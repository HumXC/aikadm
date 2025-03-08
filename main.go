package main

import (
	"embed"
	"flag"
	"strings"

	"github.com/wailsapp/wails/v2"
	"github.com/wailsapp/wails/v2/pkg/options"
	"github.com/wailsapp/wails/v2/pkg/options/assetserver"
)

//go:embed all:index.html
var assets embed.FS
var SessionDir = flag.String("d", "/usr/share/xsessions;/usr/share/wayland-sessions/", "Session directories to search for, use ; as separator")
var Env = flag.String("e", "", "Environment to run in, use ; as separator")

func init() {
	flag.Parse()
}
func main() {
	var sessionDir []string
	var env []string
	for _, dir := range strings.Split(*SessionDir, ";") {
		triped := strings.TrimSpace(dir)
		if triped != "" {
			sessionDir = append(sessionDir, triped)
		}
	}
	for _, envVar := range strings.Split(*Env, ";") {
		triped := strings.TrimSpace(envVar)
		if triped != "" {
			env = append(env, triped)
		}
	}
	app := NewApp(sessionDir, env)

	err := wails.Run(&options.App{
		Title:  "html-greet",
		Width:  1024,
		Height: 768,
		AssetServer: &assetserver.Options{
			Assets: assets,
		},
		BackgroundColour: &options.RGBA{R: 27, G: 38, B: 54, A: 1},
		OnStartup:        app.startup,
		Bind: []any{
			app,
		},
	})

	if err != nil {
		println("Error:", err.Error())
	}
}
