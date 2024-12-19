[GtkTemplate(ui = "/com/github/humxc/aikadm/ui/date-time.ui")]
public class Aikadm.DateTime : Gtk.Box {
  [GtkChild]
  private unowned Gtk.Label time;
  [GtkChild]
  private unowned Gtk.Label date;
  public uint interval_id;
  private void update_clock() {
    GLib.DateTime now = new GLib.DateTime.now_local();
    this.time.label = now.format("%H:%M");
    this.date.label = now.format("%Y年%m月%d日 %A");
  }

  construct {
    this.interval_id = GLib.Timeout.add(15000, () => {
      this.update_clock();
      return GLib.Source.CONTINUE;
    });
    this.update_clock();
    this.destroy.connect(() => dispose());
  }

  public override void dispose() {
    GLib.Source.remove(this.interval_id);
    base.dispose();
  }
}