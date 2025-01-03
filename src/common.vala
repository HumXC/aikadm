namespace Common {
    public class User {
        public string name;
        public string passwd;
        public int uid;
        public int gid;
        public string dir;
        public string shell;
    }
    public User[] get_users () {
        var users = new Array<User> ();
        for (var i = 1000; i <= 2000; i++) {
            unowned var u = Posix.getpwuid (i);
            if (u != null) {
                var copied = new User () {
                    name = u.pw_name,
                    passwd = u.pw_passwd,
                    uid = (int) u.pw_uid,
                    gid = (int) u.pw_gid,
                    dir = u.pw_dir,
                    shell = u.pw_shell
                };
                users.append_val (copied);
            }
        }
        var result = new User[users.length] {};
        for (uint i = 0; i < users.length; i++)
            result[i] = users.index (i);
        return result;
    }

    public class Session {
        public string name;
        public string exec;
        public string comment;
    }
    public Session[] get_sessions (string[] dirs) {
        var sessions = new Array<Session> ();
        foreach (var dir in dirs) {
            var d = Dir.open (dir);
            var f = d.read_name ();
            while (f != null) {
                if (f != null && !f.has_suffix (".desktop"))continue;
                f = dir + "/" + f;
                var s = new GLib.KeyFile ();
                s.load_from_file (f, GLib.KeyFileFlags.NONE);
                if (!s.has_group (GLib.KeyFileDesktop.GROUP))continue;
                var session = new Session ();
                session.name = s.get_string (GLib.KeyFileDesktop.GROUP, GLib.KeyFileDesktop.KEY_NAME);
                session.exec = s.get_string (GLib.KeyFileDesktop.GROUP, GLib.KeyFileDesktop.KEY_EXEC);
                session.comment = s.get_string (GLib.KeyFileDesktop.GROUP, GLib.KeyFileDesktop.KEY_COMMENT);
                sessions.append_val (session);
                f = d.read_name ();
            }
        }
        var result = new Session[sessions.length] {};
        for (uint i = 0; i < sessions.length; i++)
            result[i] = sessions.index (i);
        return result;
    }

    public string get_wallpaper (string wallpaper, int monitor) {
        string get_ext (string f) {
            int dot_index = f.last_index_of (".", 0);
            if (dot_index >= 0)return f.substring (dot_index + 1);
            return "";
        }

        string get_name (string f) {
            int dot_index = f.last_index_of (".", 0);
            if (dot_index >= 0)return f.substring (0, dot_index);
            return "";
        }

        var allowedImage = new string[] { "png", "jpg", "jpeg" };
        bool isImg (string f) {
            for (var i = 0; i < allowedImage.length; i++) {
                if (allowedImage[i] == f)return true;
            }
            return false;
        }

        var file = File.new_for_path (wallpaper);
        if (!file.query_exists (null) || file.query_file_type (GLib.FileQueryInfoFlags.NONE, null) != GLib.FileType.DIRECTORY) {
            return "";
        }
        if (file.query_file_type (GLib.FileQueryInfoFlags.NONE, null) != GLib.FileType.DIRECTORY) {
            return wallpaper;
        }
        var dir = Dir.open (wallpaper, 0);
        var images = new Array<string> ();
        while (true) {
            var base_name = dir.read_name ();
            if (base_name == null)break;
            var file_name = Path.build_path ("/", wallpaper, base_name);
            var f = File.new_for_path (file_name);
            if (f.query_file_type (GLib.FileQueryInfoFlags.NONE, null) == GLib.FileType.DIRECTORY) {
                continue;
            }
            if (!isImg (get_ext (file_name))) {
                continue;
            }
            if (get_name (file_name) == monitor.to_string ()) {
                return file_name;
            }
            images.append_val (file_name);
            file_name = dir.read_name ();
        }
        if (images.length == 0)return "";
        var index = Random.int_range (0, (int32) images.length - 1);
        return images.index (index);
    }

    public string ? get_user_avatar (string user) {
        var path = "/var/lib/AccountsService/icons/" + user;
        var file = File.new_for_path (path);
        if (file.query_exists (null)) {
            return path;
        }
        return null;
    }

    public class TempData {
        public int user = 0;
        public int session = 0;
        public int monitor = 0;
        public void load () {
            var f = GLib.File.new_for_path ("/var/tmp/aikadm");
            if (!f.query_exists (null))return;
            var temp = f.read (null);
            uint8[] buffer = new uint8[3];
            size_t bytes_read;
            temp.read_all (buffer, out bytes_read, null);
            user = buffer[0] - 1;
            session = buffer[1] - 1;
            monitor = buffer[2] - 1;
            temp.close (null);
        }

        public void save () {
            var f = GLib.File.new_for_path ("/var/tmp/aikadm");
            if (f.query_exists (null))f.delete (null);
            var temp = f.create (GLib.FileCreateFlags.NONE, null);
            uint8[] buffer = new uint8[3];
            buffer[0] = 1 + user;
            buffer[1] = 1 + session;
            buffer[2] = 1 + monitor;
            temp.write (buffer, null);
            temp.close (null);
        }
    }
}