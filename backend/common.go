package backend

type IBackend interface {
	Start([]string) error
}

func Get(name string) IBackend {
	switch name {
	case "cage":
		return &Cage{}
	case "hyprland":
		return &Hyprland{}
	default:
		return nil
	}
}

var _ IBackend = (*Cage)(nil)
var _ IBackend = (*Hyprland)(nil)
