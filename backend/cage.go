package backend

import (
	"os/exec"
	"strings"
)

type Cage struct{}

func (c *Cage) Start(args []string) error {
	cmd := exec.Command("cage", "-s", "--", strings.Join(args, " "))
	return cmd.Run()
}
