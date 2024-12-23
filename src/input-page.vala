[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/input-page.ui")]
public class Aikadm.InputPage : Gtk.Box {
    [GtkChild]
    private unowned Gtk.Picture avatar;
    [GtkChild]
    private unowned Gtk.PasswordEntry password;
    [GtkChild]
    private unowned Gtk.Label username_label;
    [GtkChild]
    private unowned Gtk.Label session_name_label;
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
        setup_username_label ();
        setup_session_comment_label ();
    }
    private void setup_username_label () {
        var ctl = new Gtk.EventControllerLegacy ();
        ctl.event.connect ((event) => {
            var type = event.get_event_type ();
            if (type == Gdk.EventType.BUTTON_PRESS) {
                var e = (Gdk.ButtonEvent) event;
                switch (e.get_button ()) {
                    case Gdk.BUTTON_PRIMARY:
                        select_ueser (true);
                        break;
                    case Gdk.BUTTON_SECONDARY:
                        select_ueser (false);
                        break;
                }
            }
            if (type == Gdk.EventType.SCROLL) {
                var e = (Gdk.ScrollEvent) event;
                select_ueser (e.get_direction () == Gdk.ScrollDirection.DOWN);
            }
            return true;
        });
        username_label.add_controller (ctl);
    }

    private void setup_session_comment_label () {
        var ctl = new Gtk.EventControllerLegacy ();
        ctl.event.connect ((event) => {
            var type = event.get_event_type ();
            if (type == Gdk.EventType.BUTTON_PRESS) {
                var e = (Gdk.ButtonEvent) event;
                switch (e.get_button ()) {
                    case Gdk.BUTTON_PRIMARY:
                        select_session (true);
                        break;
                    case Gdk.BUTTON_SECONDARY:
                        select_session (false);
                        break;
                }
            }
            if (type == Gdk.EventType.SCROLL) {
                var e = (Gdk.ScrollEvent) event;
                select_session (e.get_direction () == Gdk.ScrollDirection.DOWN);
            }
            return true;
        });
        session_name_label.add_controller (ctl);
    }

    private void select_ueser (bool forward) {
        int index = -1;
        for (int i = 0; i < users.length; i++) {
            if (users[i].name == username) {
                index = i;
                break;
            }
        }
        if (index == -1)return;
        if (forward) {
            index = (index + 1) % users.length;
        } else {
            index = (index + users.length - 1) % users.length;
        }
        username = users[index].name;
    }

    private void select_session (bool forward) {
        int index = -1;
        for (int i = 0; i < sessions.length; i++) {
            if (sessions[i].name == session_name) {
                index = i;
                break;
            }
        }
        if (index == -1)return;
        if (forward) {
            index = (index + 1) % sessions.length;
        } else {
            index = (index + sessions.length - 1) % sessions.length;
        }
        session_name = sessions[index].name;
    }

    public void focus_password () {
        this.message = "";
        password.set_text ("");
        password.grab_focus ();
    }

    private void set_avatar (string username) {
        var monitors = Gdk.Display.get_default ().get_monitors ();
        var m = (Gdk.Monitor) monitors.get_item (monitor);
        var scale = m.get_scale ();
        var iconSize = (int) (scale * 252);
        var path = Common.get_user_avatar (username);
        if (path != null) {
            var p = new Gdk.Pixbuf.from_file_at_scale (path, iconSize, iconSize, true);
            avatar.set_paintable (Gdk.Texture.for_pixbuf (p));
            avatar.queue_draw ();
            return;
        }
        var iconTheme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());

        var icon = iconTheme.lookup_icon ("people", null, iconSize, 1, Gtk.TextDirection.NONE, Gtk.IconLookupFlags.PRELOAD);
        avatar.set_paintable (icon);
        avatar.queue_draw ();
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
        if (session_name == null)session_name = "没有找到任何会话，请检查 -d 选项";
    }
}