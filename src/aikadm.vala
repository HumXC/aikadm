
public class Aikadm.App : Gtk.Application {
    public App () {
        Object (application_id: "com.github.humxc.aikadm");
    }

    public AstalIO.Variable currentMonitor = new AstalIO.Variable (0);
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
            var window = new Aikadm.Window (currentMonitor, i, option, sessions, users);
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
        var monitor = (uint8) currentMonitor.value.get_int ();
        var windows = this.get_windows ();
        windows.find (Gtk.Window data)
        var w = window;
        var temp = new Common.TempData ();
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