
public class Aikadm.App : Gtk.Application {
    public App () {
        Object (application_id: "com.github.humxc.aikadm");
    }

    public Option option;
    public override void activate () {
        base.activate ();
        Gtk.CssProvider provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/humxc/aikadm/style.css");
        Gtk.StyleContext.add_provider_for_display (
                                                   Gdk.Display.get_default (),
                                                   provider,
                                                   Gtk.STYLE_PROVIDER_PRIORITY_USER);
        var users = Common.get_users ();
        foreach (var u in users)print ("User: %s\n", u.name);
        var sessions = Common.get_sessions ({ "/nix/store/p0aydfnn5bq4slmjl8v7pbskgxxwn4bi-desktops/share/wayland-sessions" });
        foreach (var u in sessions)print ("Session: %s\n", u.name);
        var currentMonitor = new AstalIO.Variable (0);
        var monitors = Gdk.Display.get_default ().get_monitors ();
        bool is_quit = false;
        for (var i = 0; i < monitors.get_n_items (); i++) {
            var window = new Aikadm.Window (currentMonitor, i, option, sessions, users);
            window.close_request.connect (() => {
                if (is_quit)return false;
                is_quit = true;
                this.quit ();
                return false;
            });
            window.need_close.connect (() => window.close ());
            window.present ();
        }
        this.hold ();
    }

    public static int main (string[] args) {
        ensure_types ();
        var option = Option (args);
        print ("Option:\n%s", option.to_string ());
        if (GLib.Environment.get_variable ("GREETD_SOCK") == null)
            option.debug = true;
        var app = new Aikadm.App ();
        app.option = option;
        return app.run (args);
    }
}