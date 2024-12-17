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
            this.add_window (window);
            ((Gtk.Widget) window).destroy.connect (() => {
                this.quit ();
            });
            window.show ();
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