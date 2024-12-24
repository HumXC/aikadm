[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/wallpaper.ui")]
public class Aikadm.Wallpaper : Gtk.Box {
  [GtkChild]
  private unowned Gtk.Picture picture;
  public void set_wallpaper (Gdk.Display display, int monitor, string wallpaper) {
    ListModel monitors = display.get_monitors ();
    Gdk.Monitor m = (Gdk.Monitor) monitors.get_item (monitor);
    var rect = m.get_geometry ();
    var scale = m.get_scale ();
    var width = (int) (rect.width * scale);
    var height = (int) (rect.height * scale);
    var img = Common.get_wallpaper (wallpaper, monitor);
    if (img == "")return;
    try {
      var pixbuf = new Gdk.Pixbuf.from_file (img);
      if (pixbuf == null)return;
      picture.set_paintable (Gdk.Texture.for_pixbuf (scale_and_center (pixbuf, width, height)));
    } catch (Error e) {
      log (e.message, GLib.LogLevelFlags.LEVEL_CRITICAL, "");
    }
  }

  public Gdk.Paintable get_paintable () {
    return this.picture.get_paintable ();
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