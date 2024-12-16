public class Aikadm : Gtk.Application {
    public Aikadm () {
        Object (application_id: "com.github.humxc.aikadm");
    }

    public Option option;
    public override void activate () {
        var users = Utils.get_users ();
        foreach (var u in users)print ("User: %s\n", u.pw_name);
        var sessions = Utils.get_sessions ({ "/nix/store/p0aydfnn5bq4slmjl8v7pbskgxxwn4bi-desktops/share/wayland-sessions" });
        foreach (var u in sessions)print ("Session: %s\n", u.name);
        var currentMonitor = new AstalIO.Variable (0);
        var monitors = Gdk.Display.get_default ().get_monitors ();
        for (var i = 0; i < monitors.get_n_items (); i++) {
            var window = new AikadmWindow (currentMonitor, i, option, sessions, users);
            window.show ();
            window.setKey ();
        }
        this.hold ();
    }

    public static int main (string[] args) {
        var option = Option (args);
        print ("Option:\n%s", option.to_string ());
        var app = new Aikadm ();
        app.option = option;
        return app.run (args);
    }
}
[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/Window.ui")]
private class AikadmWindow : Gtk.Window {
    public Option option;
    public List<Utils.Session> sessions;
    public List<Passwd?> users;

    [GtkChild]
    private unowned Gtk.Picture background;
    public AikadmWindow (AstalIO.Variable currentMonitor, int monitor, Option option, List<Utils.Session> sessions, List<Passwd?> users) {
        this.option = option;
        this.sessions = sessions.copy_deep ((s) => s);
        this.users = users.copy_deep ((u) => u);
        var display = Gdk.Display.get_default ();
        ListModel monitors = display.get_monitors ();
        Gdk.Monitor m = (Gdk.Monitor) monitors.get_item (monitor);
        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_keyboard_mode (this, GtkLayerShell.KeyboardMode.EXCLUSIVE);
        GtkLayerShell.set_monitor (this, m);
        GtkLayerShell.set_layer (this, GtkLayerShell.Layer.TOP);
        GtkLayerShell.set_exclusive_zone (this, 1);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.LEFT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.TOP, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.RIGHT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.BOTTOM, true);

        Timeout.add_seconds_once (5, () => {
            this.destroy ();
        });

        var rect = m.get_geometry ();
        var scale = 1;
        var width = (int) (rect.width * scale);
        var height = (int) (rect.height * scale);
        var img = Utils.get_wallpaper (option.wallpaper, 0);
        if (img == "")return;
        var pixbuf = new Gdk.Pixbuf.from_file (img);
        background.set_paintable (Gdk.Texture.for_pixbuf (scale_and_center (pixbuf, width, height)));
    }

    public void setKey () {
        // this: Gtk.Window
        var action_group = new SimpleActionGroup ();
        action_group.add_action_entries ({
            {
                "test", () => {
                    print ("Triggered test action\n");
                }
            },
        }, this);

        // this.insert_action_group ("win", action_group);

        var tri = Gtk.ShortcutTrigger.parse_string ("Escape");
        var act = Gtk.ShortcutAction.parse_string ("action(win.test)");
        var sh = new Gtk.Shortcut (tri, act);

        var shctl = new Gtk.ShortcutController ();
        shctl.add_shortcut (sh);
        this.add_controller (shctl);
    }
}

private Gdk.Pixbuf scale_and_center (Gdk.Pixbuf pixbuf, int target_width, int target_height) {
    int original_width = pixbuf.get_width ();
    int original_height = pixbuf.get_height ();
    double scale_x = (double) target_width / (double) original_width;
    double scale_y = (double) target_height / (double) original_height;
    double scale_factor = Math.fmax (scale_x, scale_y);
    int new_width = (int) Math.floor (original_width * scale_factor);
    int new_height = (int) Math.floor (original_height * scale_factor);
    if ((new_width - target_width).abs () <= 1)new_width = target_width;
    if ((new_height - target_height).abs () <= 1)new_height = target_height;

    var scaled_pixbuf = new Gdk.Pixbuf (Gdk.Colorspace.RGB, true, 8, new_width, new_height);
    pixbuf.scale (
                  scaled_pixbuf,
                  0, 0,
                  new_width,
                  new_height,
                  0, 0,
                  scale_factor,
                  scale_factor,
                  Gdk.InterpType.HYPER);

    var final_pixbuf = new Gdk.Pixbuf (Gdk.Colorspace.RGB, true, 8, target_width, target_height);

    int offset_x = (new_width - target_width) / 2;
    int offset_y = (new_height - target_height) / 2;
    scaled_pixbuf.copy_area (
                             offset_x,
                             offset_y,
                             target_width,
                             target_height,
                             final_pixbuf,
                             0, 0);
    return final_pixbuf;
}