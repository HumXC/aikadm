package main

/*
#cgo pkg-config: gtk+-3.0 webkit2gtk-4.1

#include <gtk/gtk.h>
#include <webkit2/webkit2.h>
*/
import "C"
import (
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"reflect"
	"strings"
	"unsafe"

	"github.com/mholt/archiver/v3"
	"github.com/urfave/cli/v2"
	"github.com/wailsapp/wails/v3/pkg/application"
	"github.com/wailsapp/wails/v3/pkg/events"
)

const DEFAULT_ASSETS_DIR = "/usr/share/aikadm"

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
				Value:   DEFAULT_ASSETS_DIR,
				Usage:   "Set of assets to serve",
			},
		},
		Commands: []*cli.Command{
			{
				Name:   "install",
				Usage:  "Install frontend assets to the specified directory, which can be a compressed file, directory or a link to a compressed file. If directory is not exists, it will be created.",
				Action: CmdInstall,
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
	aikadm := NewAikadm(sessionDir, env)
	app := application.New(application.Options{
		Name: "aikadm",
		Assets: application.AssetOptions{
			Handler: NewAssetServer(ctx.String("assets")),
		},
		Services: []application.Service{
			application.NewService(aikadm),
		},
		OnShutdown: aikadm.stop,
	})
	app.OnApplicationEvent(events.Common.ApplicationStarted, func(event *application.ApplicationEvent) {
		window := app.NewWebviewWindowWithOptions(application.WebviewWindowOptions{
			Frameless: true,
			Title:     "aikadm",
			MaxWidth:  0,
			MaxHeight: 0,
			Hidden:    true,
		})
		window.OnWindowEvent(events.Common.WindowRuntimeReady, func(event *application.WindowEvent) {
			window.Show()
		})
		impl := reflect.ValueOf(window).Elem().FieldByName("impl").Elem().Elem()
		windowPtr := (*C.GtkWindow)(unsafe.Pointer(impl.FieldByName("window").Pointer()))
		webviewPtr := (*C.WebKitWebView)(unsafe.Pointer(impl.FieldByName("webview").Pointer()))
		C.gtk_window_set_geometry_hints(windowPtr, nil, nil, 0)
		// 设置背景透明
		rgba := C.GdkRGBA{C.double(0), C.double(0), C.double(0), C.double(0)}
		C.webkit_web_view_set_background_color(webviewPtr, &rgba)
	})
	return app.Run()
}

func CmdInstall(ctx *cli.Context) error {
	if ctx.Args().Len() != 1 {
		return fmt.Errorf("invalid arguments")
	}
	src := ctx.Args().First()
	if url, err := url.Parse(src); err == nil && url.Scheme != "" {
		getFilenameFromHeader := func(resp *http.Response) string {
			contentDisposition := resp.Header.Get("Content-Disposition")
			if contentDisposition == "" {
				return ""
			}

			parts := strings.Split(contentDisposition, ";")
			for _, part := range parts {
				part = strings.TrimSpace(part)
				if strings.HasPrefix(part, "filename=") {
					filename := strings.TrimPrefix(part, "filename=")
					filename = strings.Trim(filename, `"`)
					return filename
				}
			}
			return ""
		}
		resp, err := http.DefaultClient.Get(src)
		if err != nil {
			return fmt.Errorf("failed to download: %s", err)
		}

		filename := getFilenameFromHeader(resp)

		if filename == "" {
			filename = filepath.Base(url.Path)
		}
		f, err := os.CreateTemp("", "aikadm-*"+filename)
		if err != nil {
			return fmt.Errorf("failed to create temporary file: %s", err)
		}
		defer os.Remove(f.Name())
		_, err = f.ReadFrom(resp.Body)
		f.Close()
		if err != nil {
			return fmt.Errorf("failed to write to temporary file: %s", err)
		}
		src = f.Name()
	}
	assets := ctx.String("assets")

	if _, err := os.Stat(src); errors.Is(err, os.ErrNotExist) {
		return fmt.Errorf("source not found: %s", src)
	}

	if stat, err := os.Stat(assets); errors.Is(err, os.ErrNotExist) {
		if err := os.MkdirAll(assets, 0755); err != nil {
			return fmt.Errorf("failed to create assets directory: %s", err)
		}
	} else if !stat.IsDir() {
		return fmt.Errorf("assets path is not a directory: %s", assets)
	}

	if stat, err := os.Stat(src); err == nil && stat.IsDir() {
		srcFs := os.DirFS(src)
		err = os.CopyFS(assets, srcFs)
		if err != nil {
			return fmt.Errorf("failed to copy directory: %s", err)
		}
		return nil
	}
	err := archiver.Unarchive(src, assets)
	if err != nil {
		return fmt.Errorf("failed to unarchive: %s", err)
	}
	return nil
}
