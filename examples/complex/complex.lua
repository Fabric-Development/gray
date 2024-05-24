local gi = require "lgi"
local Gtk = gi.require("Gtk", "3.0")
local GdkPixbuf = gi.require("GdkPixbuf", "2.0")
local Gray = gi.require("Gray", "0.1")

local function bake_item_button(item)
    local button =
        Gtk.Button {
        on_button_press_event = function(_, event)
            item:get_menu():popup_at_pointer(event)
        end
    }

    local pixmap = Gray.get_pixmap_for_pixmaps(item:get_icon_pixmaps(), 24)

    local pixbuf = nil
    if (pixmap ~= nil) then
        pixbuf = pixmap:as_pixbuf(32, GdkPixbuf.InterpType.HYPER)
    else
        pixbuf = Gtk.IconTheme():load_icon(item:get_icon_name(), 36, Gtk.IconLookupFlags.FORCE_SIZE)
    end
    pixbuf:scale_simple(36 * 3, 36 * 3, GdkPixbuf.InterpType.HYPER)

    image = Gtk.Image {pixbuf = pixbuf}

    button:set_image(image)
    return button
end

local function main()
    local window =
        Gtk.Window {
        on_destroy = function(_)
            Gtk.main_quit()
        end
    }
    local box = Gtk.Box {}

    window:add(box)

    Gray.Watcher {
        on_item_added = function(watcher, identifier)
            local item = watcher:get_item_for_identifier(identifier)
            local item_button = bake_item_button(item)
            box:add(item_button)
            item_button:show_all()
        end
    }
    window:show_all()
    Gtk.main()
end

main()
