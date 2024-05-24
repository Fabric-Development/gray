local gi = require "lgi"
local Gtk = gi.require("Gtk", "3.0")
local Gray = gi.require("Gray", "0.1")

local function main()
    Gray.Watcher {
        on_item_added = function(watcher, identifier)
            local item = watcher:get_item_for_identifier(identifier)
            print(item:get_title())
        end
    }
    Gtk.main()
end

main()
