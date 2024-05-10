// !/usr/bin/env -S vala --pkg gtk+-3.0 --pkg gio-2.0 --pkg Dbusmenu-0.4 --pkg DbusmenuGtk3-0.4 --pkg gdk-pixbuf-2.0 --pkg Gray-0.1
using Gtk;
using Gray;

void main(string[] argv) {
    Gtk.init(ref argv);
    var watcher = new Gray.Watcher();
    watcher.item_added.connect(
        (identifier) => {
            var item = watcher.get_item_for_identifier(identifier);
            print(@"$(item.tooltip.text)");
        }
    );
    Gtk.main();
}
