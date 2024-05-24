#!/usr/bin/env gjs

imports.gi.versions.Gray = "0.1";
imports.gi.versions.Gtk = "3.0";
const { Gtk, Gray } = imports.gi;


function main() {
    Gtk.init(ARGV);

    let watcher = new Gray.Watcher();
    watcher.connect(
        "item-added",
        (self, identifier) => {
            item = watcher.get_item_for_identifier(identifier);
            print(item.get_title());
        }
    );

    Gtk.main();
}

main();
