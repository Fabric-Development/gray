using Gtk;
using Gray;

namespace simple {
    public void main(string[] argv) {
        var app = new Gtk.Application("libgray.example.simple", GLib.ApplicationFlags.FLAGS_NONE);

        app.activate.connect (() => {
            var window = new Gtk.ApplicationWindow(app);
            window.present();
        });

        var item = new Gray.StatusNotifierItem() {
            id = "libgray.example.simple.indicator",
            title = "libgray.example.simple.title",
            icon_name = "face-angel",
            category = "ApplicationStatus",
            status = "Active",
            is_menu = true,
        };

        item.notify["host-registered"].connect (() => {
            if (item.host_registered) {
                item.register();
            }
        });

        item.init();

        var menu = new Menu();
        menu.append_item(
            new MenuItem("no function", "no-function")
        );
        item.menu_model = menu;

        app.run(argv);
    }
}