package main

import (
	"embed"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"

	"github.com/wailsapp/wails/v3/pkg/application"
)

//go:embed all:frontend
var DefaultAssets embed.FS

func NewAssetServer(assetsPath string) http.Handler {
	if assetsPath == "" {
		return application.AssetFileServerFS(DefaultAssets)
	}

	if target, err := url.Parse(assetsPath); err == nil && target.Scheme != "" {
		proxy := httputil.NewSingleHostReverseProxy(target)
		base := proxy.Director
		proxy.Director = func(req *http.Request) {
			req.URL.Path = strings.TrimPrefix(req.URL.Path, target.Path)
			base(req)
			req.Host = target.Host
			req.Header.Set("X-Forwarded-Host", req.Header.Get("Host"))
		}
		return proxy
	}
	return application.AssetFileServerFS(os.DirFS(assetsPath))
}
