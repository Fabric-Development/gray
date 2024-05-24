// !/usr/bin/env -S vala --pkg gtk+-3.0 --pkg gio-2.0 --pkg Dbusmenu-0.4 --pkg DbusmenuGtk3-0.4 --pkg gdk-pixbuf-2.0 --pkg Gray-0.1
using Gtk;
using Gdk;
using Gray;

Gtk.Button bake_item_button(Gray.Item item) {
    var button = new Gtk.Button();

    button.button_press_event.connect(
        (_, event) => { item.menu.popup_at_pointer(event); return true; }
    );

    var pixmap = Gray.get_pixmap_for_pixmaps(item.icon_pixmaps, 24);

    Gdk.Pixbuf? pixbuf;
    if (pixmap != null) {
        pixbuf = pixmap.as_pixbuf(32, Gdk.InterpType.HYPER);
    } else {
        pixbuf = new Gtk.IconTheme().load_icon(
            item.icon_name,
            36,
            Gtk.IconLookupFlags.FORCE_SIZE
        );
    }

    pixbuf.scale_simple(36 * 3, 36 * 3, Gdk.InterpType.HYPER);

    var image = new Gtk.Image.from_pixbuf(pixbuf);

    button.set_image(image);
    return button;
}

void main(string[] argv) {
    Gtk.init(ref argv);

    var window = new Gtk.Window();
    var items_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
    window.add(items_box);

    var watcher = new Gray.Watcher();
    watcher.item_added.connect(
        (identifier) => {
            var item = watcher.get_item_for_identifier(identifier);
            var item_button = bake_item_button(item);
            item_button.show_all();
            items_box.add(item_button);
            item_button.show_all();
        }
    );

    window.show_all();
    window.destroy.connect(
        (_) => { Gtk.main_quit(); }
    );

    Gtk.main();
}
