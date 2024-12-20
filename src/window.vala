[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/window.ui")]
public class Aikadm.Window : Gtk.Window  {
    public Option option;
    public Common.Session[] sessions;
    public Common.User[] users;
    public AstalIO.Variable currentMonitor;
    public AstalIO.Variable isInput = new AstalIO.Variable (false);
    [GtkChild]
    private unowned Aikadm.Wallpaper wallpaper;
    [GtkChild]
    private unowned Gtk.Revealer dateTimeRevealer;
    public Window (AstalIO.Variable currentMonitor, int monitor, Option option, Common.Session[] sessions, Common.User[] users) {
        Object (title: "aikadm", css_name: "window", name: "aikadm");
        this.option = option;
        this.sessions = sessions;
        this.users = users;
        this.currentMonitor = currentMonitor;
        set_key_bind ();
        set_layer (monitor);
        wallpaper.set_wallpaper (this.display, monitor, option.wallpaper);
        Idle.add_once (() => dateTimeRevealer.set_reveal_child (true));
        isInput.changed.connect (() => {
            dateTimeRevealer.set_reveal_child (!isInput.value.get_boolean ());
        });
    }

    private void set_layer (int monitor) {
        ListModel monitors = display.get_monitors ();
        Gdk.Monitor m = (Gdk.Monitor) monitors.get_item (monitor);
        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_keyboard_mode (this, GtkLayerShell.KeyboardMode.ON_DEMAND);
        GtkLayerShell.set_monitor (this, m);
        GtkLayerShell.set_layer (this, GtkLayerShell.Layer.TOP);
        if (option.debug)GtkLayerShell.set_layer (this, GtkLayerShell.Layer.BACKGROUND);
        GtkLayerShell.set_exclusive_zone (this, 1);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.LEFT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.TOP, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.RIGHT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.BOTTOM, true);
    }

    private void set_key_bind () {
        var action_group = new SimpleActionGroup ();
        action_group.add_action_entries ({
            { "escape", () => {
                  if (this.option.debug && !this.isInput.value.get_boolean ()) {
                      this.destroy ();
                      return;
                  }
                  this.isInput.value = false;
              } },
            { "enter", () => {
                  if (!this.isInput.value.get_boolean ()) {
                      this.isInput.value = true;
                  }
              } },
        }, this);

        this.insert_action_group ("win", action_group);
        var binds = new Gtk.Shortcut[] {
            new Gtk.Shortcut (new Gtk.KeyvalTrigger (Gdk.Key.Escape, 0), new Gtk.NamedAction ("win.escape")),
            new Gtk.Shortcut (new Gtk.KeyvalTrigger (Gdk.Key.Return, 0), new Gtk.NamedAction ("win.enter")),
        };

        var shctl = new Gtk.ShortcutController ();
        foreach (var sh in binds) {
            shctl.add_shortcut (sh);
        }
        ((Gtk.Widget) this).add_controller (shctl);
    }
}