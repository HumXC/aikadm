
[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/Window.ui")]
public class AikadmWindow : Gtk.Window  {
    public Option option;
    public List<Utils.Session> sessions;
    public List<Passwd?> users;
    public AstalIO.Variable currentMonitor;
    public AstalIO.Variable isInput = new AstalIO.Variable (false);
    [GtkChild]
    private unowned Gtk.Picture background;
    public AikadmWindow (AstalIO.Variable currentMonitor, int monitor, Option option, List<Utils.Session> sessions, List<Passwd?> users) {
        this.option = option;
        this.sessions = sessions.copy_deep ((s) => s);
        this.users = users.copy_deep ((u) => u);
        this.currentMonitor = currentMonitor;
        var display = Gdk.Display.get_default ();
        ListModel monitors = display.get_monitors ();
        Gdk.Monitor m = (Gdk.Monitor) monitors.get_item (monitor);
        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_keyboard_mode (this, GtkLayerShell.KeyboardMode.ON_DEMAND);
        GtkLayerShell.set_monitor (this, m);
        GtkLayerShell.set_layer (this, GtkLayerShell.Layer.TOP);
        // GtkLayerShell.set_layer (this, GtkLayerShell.Layer.BACKGROUND);
        GtkLayerShell.set_exclusive_zone (this, 1);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.LEFT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.TOP, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.RIGHT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.BOTTOM, true);
        Timeout.add_seconds_once (3, () => {
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

    construct  {
        var action_group = new SimpleActionGroup ();
        action_group.add_action_entries ({
            { "escape", () => {
                  if (this.option.debug && !this.isInput.value.get_boolean ())this.destroy ();
                  this.isInput.value.set_boolean (false);
              } },
            { "enter", () => {
                  if (!this.isInput.value.get_boolean ()) {
                      this.isInput.value.set_boolean (true);
                  }
              } },
        }, this);

        this.insert_action_group ("win", action_group);

        var tri = new Gtk.KeyvalTrigger (Gdk.Key.Escape, 0);
        var act = new Gtk.NamedAction ("win.escape");
        var sh = new Gtk.Shortcut (tri, act);
        var shctl = new Gtk.ShortcutController ();
        shctl.add_shortcut (sh);
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