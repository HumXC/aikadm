package main

import (
	"embed"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"path/filepath"
	"strings"

	"github.com/wailsapp/wails/v3/pkg/application"
)

//go:embed all:frontend
var DefaultAssets embed.FS

type responseWriterWrapper struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriterWrapper) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

type DefaultAssetsServer struct {
	embed  http.Handler
	assets http.Handler
}

func (s *DefaultAssetsServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	wrapper := &responseWriterWrapper{ResponseWriter: w, statusCode: http.StatusOK}

	s.embed.ServeHTTP(wrapper, r)

	if wrapper.statusCode == http.StatusNotFound {
		s.assets.ServeHTTP(w, r)
	}
}
func NewAssetServer(assetsPath string) http.Handler {
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
	if stat, err := os.Stat(filepath.Join(assetsPath, "index.html")); err == nil && !stat.IsDir() {
		return application.AssetFileServerFS(os.DirFS(assetsPath))
	}
	return &DefaultAssetsServer{
		embed:  application.AssetFileServerFS(DefaultAssets),
		assets: http.FileServer(http.Dir(assetsPath)),
	}
}
