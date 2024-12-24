
public class Aikadm.App : Gtk.Application {
    public App () {
        Object (application_id: "com.github.humxc.aikadm");
    }

    bool is_quit = false;
    public Option option;
    public override void activate () {
        base.activate ();
        Gtk.CssProvider provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/humxc/aikadm/style.css");
        Gtk.StyleContext.add_provider_for_display (
                                                   Gdk.Display.get_default (),
                                                   provider,
                                                   Gtk.STYLE_PROVIDER_PRIORITY_USER);
        var temp = new Common.TempData ();
        temp.load ();

        var users = Common.get_users ();
        foreach (var u in users)print ("User: %s\n", u.name);
        var sessions = Common.get_sessions (option.sessionDirs);
        foreach (var u in sessions)print ("Session: %s\n", u.name);
        var monitors = Gdk.Display.get_default ().get_monitors ();
        for (var i = 0; i < monitors.get_n_items (); i++) {
            var window = new Aikadm.Window (i, option, sessions, users, temp.user, temp.session);
            this.add_window (window);
            window.close_request.connect (() => {
                this.close ();
                return false;
            });
            window.need_close.connect (() => window.close ());
            window.present ();
        }
        this.hold ();
    }

    public void close () {
        if (is_quit)return;
        is_quit = true;
        var currentMonitor = 0; // TODO: 支持多显示器
        unowned var windows = this.get_windows ();
        Aikadm.Window window = null;
        foreach (var w_ in windows) {
            var w = (Aikadm.Window) w_;
            if (w.monitor == currentMonitor) {
                window = w;
                break;
            }
        }

        var temp = new Common.TempData ();
        temp.monitor = currentMonitor;
        temp.user = window.inputPage.user_index;
        temp.session = window.inputPage.session_index;
        temp.save ();
        this.quit ();
    }

    public static int main (string[] args) {
        ensure_types ();
        var option = Option (args);
        if (GLib.Environment.get_variable ("GREETD_SOCK") == null)
            option.debug = true;
        print ("Option:\n%s", option.to_string ());
        var app = new Aikadm.App ();
        app.option = option;
        return app.run (args);
    }
}