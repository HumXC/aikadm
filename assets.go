package main

import (
	"embed"
	"net/http"
)

//go:embed all:index.html
var DefaultAssets embed.FS

func NewAssetServer(assetsPath string) http.Handler {
	if assetsPath == "" {
		return http.FileServer(http.FS(DefaultAssets))
	} else {
		return http.FileServer(http.Dir(assetsPath))
	}
}
