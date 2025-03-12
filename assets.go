package main

import (
	"embed"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"
)

//go:embed all:index.html
var DefaultAssets embed.FS

func NewAssetServer(assetsPath string) http.Handler {
	if assetsPath == "" {
		return http.FileServer(http.FS(DefaultAssets))
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
	return http.FileServer(http.Dir(assetsPath))
}
