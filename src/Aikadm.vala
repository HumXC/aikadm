public class Aikadm : Gtk.Application {
    public Aikadm () {
        Object (application_id: "com.github.humxc.aikadm");
    }

    private AikadmWindow window;
    public override void activate () {
        window = new AikadmWindow ();
        window.show ();
        this.hold ();
    }

    public static int main (string[] args) {
        var users = Utils.get_users ();
        foreach (var u in users)print ("User: %s\n", u.pw_name);
        var sessions = Utils.get_sessions ({ "/nix/store/p0aydfnn5bq4slmjl8v7pbskgxxwn4bi-desktops/share/wayland-sessions" });
        foreach (var u in sessions)print ("Session: %s\n", u.name);
        var option = Option (args);
        print ("Option:\n%s", option.to_string ());
        var app = new Aikadm ();
        return app.run (args);
    }
}
[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/Window.ui")]
private class AikadmWindow : Gtk.Window {
    public AikadmWindow (AstalIO.Variable currentMonitor) {
        void fn () {
            currentMonitor.value = 12;
        }

        var c = new GLib.Closure.simple (1, null);
        c.set_marshal (fn);
        AstalIO.Time.timeout (1000, c);
        currentMonitor.changed.connect ((v) => {
            var vv = (AstalIO.Variable) v;
            print ("啊啊啊啊 %d", vv.value.get_int ());
        });
        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_layer (this, GtkLayerShell.Layer.BACKGROUND);
        GtkLayerShell.set_exclusive_zone (this, 1);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.LEFT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.TOP, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.RIGHT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.BOTTOM, true);
    }
}