namespace Utils {
    public class User {
        public string name;
        public string passwd;
        public int uid;
        public int gid;
        public string dir;
        public string shell;
    }
    public List<User> get_users() {
        var users = new List<User> ();
        for (var i = 1000; i <= 2000; i++) {
            unowned var u = Posix.getpwuid(i);
            if (u != null) {
                var copied = new User() {
                    name = u.pw_name,
                    passwd = u.pw_passwd,
                    uid = (int) u.pw_uid,
                    gid = (int) u.pw_gid,
                    dir = u.pw_dir,
                    shell = u.pw_shell
                };
                users.append(copied);
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

    public string get_wallpaper(string wallpaper, int monitor) {
        string get_ext(string f) {
            int dot_index = f.last_index_of(".", 0);
            if (dot_index >= 0)return f.substring(dot_index + 1);
            return "";
        }

        string get_name(string f) {
            int dot_index = f.last_index_of(".", 0);
            if (dot_index >= 0)return f.substring(0, dot_index);
            return "";
        }

        var allowedImage = new string[] { "png", "jpg", "jpeg" };
        bool isImg(string f) {
            for (var i = 0; i < allowedImage.length; i++) {
                if (allowedImage[i] == f)return true;
            }
            return false;
        }

        var file = File.new_for_path(wallpaper);
        if (!file.query_exists(null) || file.query_file_type(GLib.FileQueryInfoFlags.NONE, null) != GLib.FileType.DIRECTORY) {
            return "";
        }
        if (file.query_file_type(GLib.FileQueryInfoFlags.NONE, null) != GLib.FileType.DIRECTORY) {
            return wallpaper;
        }
        var dir = Dir.open(wallpaper, 0);
        var images = new Array<string> ();
        while (true) {
            var base_name = dir.read_name();
            if (base_name == null)break;
            var file_name = Path.build_path("/", wallpaper, base_name);
            var f = File.new_for_path(file_name);
            if (f.query_file_type(GLib.FileQueryInfoFlags.NONE, null) == GLib.FileType.DIRECTORY) {
                continue;
            }
            if (!isImg(get_ext(file_name))) {
                continue;
            }
            if (get_name(file_name) == monitor.to_string()) {
                return file_name;
            }
            images.append_val(file_name);
            file_name = dir.read_name();
        }
        if (images.length == 0)return "";
        var index = Random.int_range(0, (int32) images.length - 1);
        return images.index(index);
    }
}