namespace Utils {
    public List<Passwd?> get_users() {
        var users = new List<Passwd?> ();
        for (var i = 1000; i <= 2000; i++) {
            var u = getpwuid(i);
            if (u != null) {
                users.append(*u);
            }
        }
        return users;
    }

    public class Session {
        public string name;
        public string exec;
        public string comment;
    }
    public List<Session> get_sessions(string[] dirs) {
        var sessions = new List<Session> ();
        foreach (var dir in dirs) {
            var d = Dir.open(dir);
            var f = d.read_name();
            while (f != null) {
                if (f != null && !f.has_suffix(".desktop"))continue;
                f = dir + "/" + f;
                var s = new GLib.KeyFile();
                s.load_from_file(f, GLib.KeyFileFlags.NONE);
                if (!s.has_group(GLib.KeyFileDesktop.GROUP))continue;
                var session = new Session();
                session.name = s.get_string(GLib.KeyFileDesktop.GROUP, GLib.KeyFileDesktop.KEY_NAME);
                session.exec = s.get_string(GLib.KeyFileDesktop.GROUP, GLib.KeyFileDesktop.KEY_EXEC);
                session.comment = s.get_string(GLib.KeyFileDesktop.GROUP, GLib.KeyFileDesktop.KEY_COMMENT);
                sessions.append(session);
                f = d.read_name();
            }
        }
        return sessions;
    }
}