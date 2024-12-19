[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/window.ui")]
public class Aikadm.Window : Gtk.Window  {
    public Option option;
    public List<Common.Session> sessions;
    public List<Common.User> users;
    public AstalIO.Variable currentMonitor;
    public int monitor;
    public AstalIO.Variable isInput = new AstalIO.Variable (false);
    [GtkChild]
    private unowned Gtk.Picture background;
    [GtkChild]
    private unowned Gtk.Revealer dateTimeRevealer;
    public Window (AstalIO.Variable currentMonitor, int monitor, Option option, List<Common.Session> sessions, List<Common.User> users) {
        Object (title: "aikadm", css_name: "window", name: "aikadm");
        this.option = option;
        this.sessions = sessions.copy_deep ((s) => s);
        this.users = users.copy_deep ((u) => u);
        this.currentMonitor = currentMonitor;
        this.monitor = monitor;
        keyBind ();
        setLayer ();
        setWallpaper ();
        Idle.add_once (() => dateTimeRevealer.set_reveal_child (true));
        isInput.changed.connect (() => {
            dateTimeRevealer.set_reveal_child (!isInput.value.get_boolean ());
        });
    }

    private void setWallpaper () {
        ListModel monitors = display.get_monitors ();
        Gdk.Monitor m = (Gdk.Monitor) monitors.get_item (monitor);
        var rect = m.get_geometry ();
        var scale = 1;
        var width = (int) (rect.width * scale);
        var height = (int) (rect.height * scale);
        var img = Common.get_wallpaper (option.wallpaper, 0);
        if (img == "")return;
        var pixbuf = new Gdk.Pixbuf.from_file (img);
        background.set_paintable (Gdk.Texture.for_pixbuf (scale_and_center (pixbuf, width, height)));
    }

    private void setLayer () {
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

    private void keyBind () {
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