public class Aikadm : Gtk.Application {
    public Aikadm () {
        Object (application_id: "io.github.humxc.aikadm");
    }

    public override void activate () {
        var window = new Gtk.ApplicationWindow (this) {
            title = "Aikadm"
        };

        var button = new Gtk.Button.with_label ("Click me!");
        button.clicked.connect (() => {
            button.label = "Thank you";
        });

        window.child = button;
        window.present ();
    }

    public static int main (string[] args) {
        var app = new Aikadm ();
        return app.run (args);
    }
}