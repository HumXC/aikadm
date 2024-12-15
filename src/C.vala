[CCode (has_header = "pwd.h")]
public extern struct Passwd {
    public string pw_name;
    public string pw_passwd;
    public int pw_uid;
    public int pw_gid;
    public string pw_gecos;
    public string pw_dir;
    public string pw_shell;
}
[CCode (has_header = "pwd.h")]
public extern Passwd * getpwuid (int uid);