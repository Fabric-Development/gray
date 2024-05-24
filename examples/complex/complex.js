#!/usr/bin/env gjs

imports.gi.versions.Gray = "0.1";
imports.gi.versions.Gtk = "3.0";
const { Gtk, Gray, GdkPixbuf } = imports.gi;


function bake_item_button(item) {
    let button = new Gtk.Button();

    button.connect(
        "button-press-event",
        (_, event) => { item.get_menu().popup_at_pointer(event); },
    );
    let pixmap = Gray.get_pixmap_for_pixmaps(item.get_icon_pixmaps(), 24);

    let pixbuf = null;
    if (pixmap != null) {
        pixbuf = pixmap.as_pixbuf(32, GdkPixbuf.InterpType.HYPER);
    } else {
        pixbuf = new Gtk.IconTheme().load_icon(
            item.get_icon_name(),
            36,
            Gtk.IconLookupFlags.FORCE_SIZE,
        );
    }
    pixbuf.scale_simple(36 * 3, 36 * 3, GdkPixbuf.InterpType.HYPER);

    let image = Gtk.Image.new_from_pixbuf(pixbuf);

    button.set_image(image);
    return button;
}

function main() {
    Gtk.init(ARGV);
    
    let window = new Gtk.Window();
    let items_box = new Gtk.Box();
    window.add(items_box);

    let watcher = new Gray.Watcher();
    watcher.connect(
        "item-added",
        (self, identifier) => {
            item = watcher.get_item_for_identifier(identifier);

            let item_button = bake_item_button(item);
            item_button.show_all();
            items_box.add(item_button);
            item_button.show_all();
        }
    );

    window.show_all();
    window.connect(
        "destroy", (_) => { Gtk.main_quit(); }
    );

    Gtk.main();
}

main();
