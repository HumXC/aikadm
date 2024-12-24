[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/window.ui")]
public class Aikadm.Window : Gtk.Window  {
    public bool isInput { get; set; }
    public int animationDuration  { get; set; default = 500; }
    public int monitor { get; set; }
    [GtkChild]
    private unowned Aikadm.Wallpaper wallpaper;
    [GtkChild]
    private unowned Aikadm.BlurCanvas bluredWallpaper;
    [GtkChild]
    public unowned Aikadm.InputPage inputPage;
    [GtkChild]
    private unowned Gtk.Revealer mask;
    public bool isDebug { get; set; }
    public Window (int monitor, Option option, Common.Session[] sessions, Common.User[] users, int defaultUser, int defaultSession) {
        Object (
                title: "aikadm",
                css_name: "window",
                name: "aikadm"
        );
        this.monitor = monitor;
        this.isDebug = option.debug;
        set_key_bind ();
        set_layer (monitor);
        wallpaper.set_wallpaper (this.display, monitor, option.wallpaper);

        bluredWallpaper.set_texture
        (
         ((Gdk.Texture) this.wallpaper.get_paintable ()),
         0.3, 30, 0.8
        );
        bluredWallpaper.draw (0, 0, 0, 0);

        inputPage.setup (monitor, users, sessions, defaultUser, defaultSession);
        inputPage.login_request.connect ((user, password, session, message) => {
            var cmd = @"$(user.shell) -c \"$(session.exec)\"";
            print (cmd);
            if (option.debug) {
                if (password == "debug") {
                    need_close ();
                    return;
                }
                message ("Debug mode, no login. Password: debug");
                return;
            }
            AstalGreet.login_with_env.begin (user.name, password, cmd, option.env, (_, res) => {
                try {
                    AstalGreet.login_with_env.end (res);
                    need_close ();
                } catch (Error e) {
                    message (e.message);
                }
            });
        });
        notify.connect ((spec) => {
            if (spec.name != "isInput" || !isInput)return;
            inputPage.focus_password ();
        });

        mask.transition_duration = animationDuration * 2;
        Timeout.add_once (200, () => mask.reveal_child = false);
        this.close_request.connect (() => {
            if (mask.reveal_child)return false;
            mask.reveal_child = true;
            Timeout.add_once (mask.transition_duration, () => this.close ());
            return true;
        });
    }

    public signal void need_close ();

    private void set_layer (int monitor) {
        ListModel monitors = display.get_monitors ();
        Gdk.Monitor m = (Gdk.Monitor) monitors.get_item (monitor);
        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_keyboard_mode (this, GtkLayerShell.KeyboardMode.ON_DEMAND);
        GtkLayerShell.set_monitor (this, m);
        GtkLayerShell.set_layer (this, GtkLayerShell.Layer.TOP);
        if (isDebug)GtkLayerShell.set_layer (this, GtkLayerShell.Layer.BACKGROUND);
        GtkLayerShell.set_exclusive_zone (this, -1);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.LEFT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.TOP, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.RIGHT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.BOTTOM, true);
    }

    private void set_key_bind () {
        var action_group = new SimpleActionGroup ();
        action_group.add_action_entries ({
            { "escape", () => {
                  if (isDebug && !this.isInput) {
                      this.need_close ();
                      return;
                  }
                  this.set_focus (null);
                  this.isInput = false;
              } },
            { "enter", () => {
                  if (!this.isInput)this.isInput = true;
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