[GtkTemplate (ui = "/com/github/humxc/aikadm/ui/input-page.ui")]
public class Aikadm.InputPage : Gtk.Box {
    [GtkChild]
    private unowned Gtk.Picture avatar;
    [GtkChild]
    private unowned Gtk.Entry password;
    [GtkChild]
    private unowned Gtk.Label username;
    private Common.User[] users;
    private string current_user;
    public InputPage () {
    }

    // [GtkCallback]
    // public void on_user_changed() {
    // print("User changed to " + current_user);
    // }

    public void setup (Common.User[] users, string default_user) {
        this.users = users;
        foreach (var u  in users) {
            if (u.name == default_user) {
                current_user = u.name;
                break;
            }
        }
        if (users.length > 0 && current_user == null)
            current_user = users[0].name;
        username.set_text (current_user);
    }
}