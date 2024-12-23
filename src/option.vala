public struct  Option {
    string wallpaper;
    bool debug;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] sessionDirs;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] env;
    public string to_string () {
        var str = "";
        str += "[debug: " + debug.to_string () + "]\n";
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
        wallpaper = "";
        var ctx = new GLib.OptionContext ();
        ctx.add_main_entries ({
            {
                "wallpaper",
                'w',
                GLib.OptionFlags.NONE,
                GLib.OptionArg.STRING,
                ref wallpaper,
                "A file path or a directory path to set as wallpaper",
                "DIR|FILE"
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
            { null },
        }, "-");
        ctx.parse (ref args);
    }
}