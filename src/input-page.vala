[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/input-page.ui")]
public class Aikadm.InputPage : Gtk.Box {
    [GtkChild]
    private unowned Gtk.Picture avatar;
    [GtkChild]
    private unowned Gtk.PasswordEntry password;
    private Common.User[] users;
    private Common.Session[] sessions;
    int monitor;
    public bool is_busy { get; set; }
    public string username  { get; set; }
    public string message { get; set; }
    public string session_name { get; set; }
    public string session_comment { get; set; }
    construct {
        notify.connect ((spec) => {
            switch (spec.name) {
                case "username":
                    set_avatar (username);
                    break;
                case "session_name":
                    foreach (var s in sessions) {
                        if (s.name == session_name) {
                            session_comment = s.comment;
                            break;
                        }
                    }
                    break;
            }
        });
        password.activate.connect (() => {
            if (is_busy || password.get_text () == "")return;
            is_busy = true;
            this.message = "";
            Common.User user;
            Common.Session session;
            foreach (var u in users) {
                if (u.name == username)user = u;
            }
            foreach (var s in sessions) {
                if (s.name == this.session_name)session = s;
            }
            login_request (user, password.get_text (), session, (msg) => message = msg);
            if (message != "") {
                password.select_region (0, -1);
            }
            is_busy = message == "";
            if (!is_busy)password.grab_focus ();
        });
    }

    public void focus_password () {
        this.message = "";
        password.set_text ("");
        password.grab_focus ();
    }

    private void set_avatar (string username) {
        var path = Common.get_user_avatar (username);
        if (path == "")return;
        var monitors = Gdk.Display.get_default ().get_monitors ();
        var m = (Gdk.Monitor) monitors.get_item (monitor);
        var scale = m.get_scale ();
        int w = (int) (scale * 250);
        int h = (int) (scale * 250);
        var p = new Gdk.Pixbuf.from_file_at_scale (path, w, h, true);
        avatar.set_paintable (Gdk.Texture.for_pixbuf (p));
    }

    public delegate void LoginRequestCallback (string messgae);
    public signal void login_request (Common.User user, string password, Common.Session session, LoginRequestCallback callback);

    public void setup (int monitor, Common.User[] users, Common.Session[] sessions, string default_user, string default_session) {
        this.users = users;
        this.sessions = sessions;
        this.monitor = monitor;
        foreach (var u  in users) {
            if (u.name == default_user) {
                username = u.name;
                break;
            }
        }
        if (users.length > 0 && username == null)
            username = users[0].name;

        foreach (var s in sessions) {
            if (s.name == default_session) {
                session_name = s.name;
                session_comment = s.comment;
                break;
            }
        }
        if (sessions.length > 0 && session_name == null) {
            session_name = sessions[0].name;
            session_comment = sessions[0].comment;
        }
    }
}