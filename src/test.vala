#! /usr/bin/env -S vala --pkg gtk4
public class App : Gtk.Application {
    public App () {
        Object (application_id: "com.example");
    }

    public override void activate () {
        var window = new Window ();
        window.show ();
        this.hold ();
    }

    public static int main (string[] args) {
        var app = new App ();
        return app.run (args);
    }
}
private class Window : Gtk.Window {
    public Window () {
        var tri = Gtk.ShortcutTrigger.parse_string ("q");
        var act = Gtk.ShortcutAction.parse_string ("nothing");
        var sh = new Gtk.Shortcut (tri, act);

        var shctl = new Gtk.ShortcutController ();
        shctl.add_shortcut (sh);
        this.add_controller (shctl);
    }
}