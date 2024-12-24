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
    public string username  { get; set; default = "**没有找到任何用户**"; }
    public string message { get; set; }
    public string session_name { get; set; default = "没有找到任何会话，请检查 -d 选项"; }
    public string session_comment { get; set; }
    public int user_index { get; set; default = -1; }
    public int session_index { get; set; default = -1; }
    construct {
        notify.connect ((spec) => {
            switch (spec.name) {
                case "user-index":
                    username = users[user_index].name;
                    set_avatar (user_index);
                    break;
                case "session-index":
                    session_name = sessions[session_index].name;
                    session_comment = sessions[session_index].comment;
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
        if (users.length == 0)return;
        if (forward) {
            user_index = (user_index + 1) % users.length;
        } else {
            user_index = (user_index + users.length - 1) % users.length;
        }
    }

    private void select_session (bool forward) {
        if (sessions.length == 0)return;
        if (forward) {
            session_index = (session_index + 1) % sessions.length;
        } else {
            session_index = (session_index + sessions.length - 1) % sessions.length;
        }
    }

    public void focus_password () {
        this.message = "";
        password.set_text ("");
        password.grab_focus ();
    }

    private void set_avatar (int user_index) {
        var monitors = Gdk.Display.get_default ().get_monitors ();
        var m = (Gdk.Monitor) monitors.get_item (monitor);
        var scale = m.get_scale ();
        var iconSize = (int) (scale * 252);
        Gdk.Paintable icon = null;
        if (users.length != 0) {
            var path = Common.get_user_avatar (users[user_index].name);
            if (path != null) {
                var p = new Gdk.Pixbuf.from_file_at_scale (path, iconSize, iconSize, true);
                icon = Gdk.Texture.for_pixbuf (p);
            }
        }
        if (icon == null) {
            var iconTheme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
            icon = iconTheme.lookup_icon ("people", null, iconSize, 1, Gtk.TextDirection.NONE, Gtk.IconLookupFlags.PRELOAD);
        }
        avatar.set_paintable (icon);
        avatar.queue_draw ();
    }

    public delegate void LoginRequestCallback (string messgae);
    public signal void login_request (Common.User user, string password, Common.Session session, LoginRequestCallback callback);

    public void setup (int monitor, Common.User[] users, Common.Session[] sessions, int default_user, int default_session) {
        this.users = users;
        this.sessions = sessions;
        this.monitor = monitor;
        if (default_user >= 0 && default_user < users.length)
            user_index = default_user;
        if (default_session >= 0 && default_session < sessions.length)
            session_index = default_session;
        if (users.length > 0 && user_index == -1)
            user_index = 0;
        if (sessions.length > 0 && session_index == -1)
            session_index = 0;
    }
}