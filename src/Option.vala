public struct  Option {
    string defaultUser;
    string defaultSession;
    int defaultMonitor;
    string wallpaper;
    bool debug;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] sessionDirs;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] env;
    public string to_string () {
        var str = "";
        str += "[debug: " + debug.to_string () + "]\n";
        str += "[defaultUser: " + defaultUser + "]\n";
        str += "[defaultSession: " + defaultSession + "]\n";
        str += "[defaultMonitor: " + defaultMonitor.to_string () + "]\n";
        str += "[wallpaper: " + wallpaper + "]\n";
        str += "[sessionDirs: ";
        for (var i = 0; i < sessionDirs.length; i++) {
            str += "\"" + sessionDirs[i] + "\" ";
        }
        str += "]\n";
        str += "[env: ";
        for (var i = 0; i < env.length; i++) {
            str += "\"" + env[i] + "\" ";
        }
        str += "]\n";
        return str;
    }

    public Option (string[] args) {
        var ctx = new GLib.OptionContext ();
        ctx.add_main_entries ({
            {
                "wallpaper",
                'w',
                GLib.OptionFlags.NONE,
                GLib.OptionArg.STRING,
                ref defaultUser,
                "A file path or a directory path to set as wallpaper",
                "DIR|FILE"
            },
            {
                "default-user",
                'u',
                GLib.OptionFlags.NONE,
                GLib.OptionArg.STRING,
                ref defaultUser,
                "Default selected user",
                "USER"
            },
            {
                "default-session",
                's',
                GLib.OptionFlags.NONE,
                GLib.OptionArg.STRING,
                ref defaultSession,
                "Default selected session",
                "SESSION"
            },
            {
                "default-monitor",
                'm',
                GLib.OptionFlags.NONE,
                GLib.OptionArg.INT,
                ref defaultSession,
                "Default display monitor",
                "INTEGER"
            },
            {
                "session-dirs",
                'd',
                GLib.OptionFlags.NONE,
                GLib.OptionArg.STRING_ARRAY,
                ref sessionDirs,
                "Looks for sessions in the specified directories",
                "DIRECTORY..."
            },
            {
                "env",
                'e',
                GLib.OptionFlags.NONE,
                GLib.OptionArg.STRING_ARRAY,
                ref env,
                "Environment variables to set for the session",
                "KEY=VALUE..."
            },
            {
                "debug",
                '\0',
                GLib.OptionFlags.NONE,
                GLib.OptionArg.STRING_ARRAY,
                ref debug,
                "Enable debug mode",
                null
            },
            { null },
        }, "-");
        ctx.parse (ref args);
    }
}