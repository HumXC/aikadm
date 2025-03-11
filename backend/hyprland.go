package backend

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type Hyprland struct{}

func (h *Hyprland) Start(args []string) error {
	tempFileName := "/var/tmp/html-greet-hyprland.conf"
	format := `
		exec-once = %s;hyprctl dispatch exit
		windowrule = fullscreen, title:html-greet
	`
	hyprConf := fmt.Sprintf(format, strings.Join(args, " "))
	err := os.WriteFile(tempFileName, []byte(hyprConf), 0644)
	if err != nil {
		return err
	}
	defer os.Remove(tempFileName)
	cmd := exec.Command("Hyprland", "-c", tempFileName)
	return cmd.Run()
}
