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
            new AikadmWindow (currentMonitor, i, option, sessions, users).show ();
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
    private unowned Gtk.Box background;
    [GtkChild]
    private unowned Gtk.Label name;

    public AikadmWindow (AstalIO.Variable currentMonitor, int monitor, Option option, List<Utils.Session> sessions, List<Passwd?> users) {
        this.option = option;
        this.sessions = sessions.copy_deep ((s) => s);
        this.users = users.copy_deep ((u) => u);

        ListModel monitors = Gdk.Display.get_default ().get_monitors ();
        Gdk.Monitor m = (Gdk.Monitor) monitors.get_item (monitor);
        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_monitor (this, m);
        GtkLayerShell.set_layer (this, GtkLayerShell.Layer.BACKGROUND);
        GtkLayerShell.set_exclusive_zone (this, 1);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.LEFT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.TOP, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.RIGHT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.BOTTOM, true);

        this.name.label = "DD";
    }

    [GtkCallback]
    public void test () {
        Timeout.add_seconds (1,
                             () => {
            print ("|||%s", name.label);
            name.label = "SSSS";
            return false;
        }, Priority.DEFAULT);
    }
}