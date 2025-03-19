package main

/*
#cgo linux pkg-config: gtk+-3.0
#include <gtk/gtk.h>
*/
import "C"
import (
	"fmt"
	"os"
	"os/exec"
	"reflect"
	"strings"
	"unsafe"

	"github.com/urfave/cli/v2"
	"github.com/wailsapp/wails/v3/pkg/application"
	"github.com/wailsapp/wails/v3/pkg/events"
)

func NewCli() *cli.App {
	return &cli.App{
		Name:   "aikadm",
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
	if os.Getenv("GREETD_SOCK") != "" && os.Getenv("HTML_GREET_USE_CAGE") == "" {
		os.Setenv("HTML_GREET_USE_CAGE", "1")
		exe, _ := os.Executable()
		args := append([]string{"-s", "--", exe}, os.Args[1:]...)
		cmd := exec.Command("cage", args...)
		out, err := cmd.CombinedOutput()
		if err != nil {
			return fmt.Errorf("failed to run [%s]: %s", strings.Join(cmd.Args, " "), string(out))
		}
		return nil
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
		Name: "aikadm",
		Assets: application.AssetOptions{
			Handler: NewAssetServer(ctx.String("assets")),
		},
		Services: []application.Service{
			application.NewService(NewApp(sessionDir, env)),
		},
	})
	app.OnApplicationEvent(events.Common.ApplicationStarted, func(event *application.ApplicationEvent) {
		window := app.NewWebviewWindowWithOptions(application.WebviewWindowOptions{
			Frameless: true,
			Title:     "aikadm",
			MaxWidth:  0,
			MaxHeight: 0,
		})
		_window := reflect.ValueOf(window).Elem()
		gtkWindowPtr := _window.FieldByName("impl").Elem().Elem().FieldByName("window")
		gtkWindow := (*C.GtkWindow)(unsafe.Pointer(gtkWindowPtr.Pointer()))
		C.gtk_window_set_geometry_hints(gtkWindow, nil, nil, 0)
	})
	return app.Run()
}
