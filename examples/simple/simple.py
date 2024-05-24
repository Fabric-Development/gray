import gi

gi.require_version("Gray", "0.1")
from gi.repository import Gray, Gtk


def main():
    watcher = Gray.Watcher()
    watcher.connect(
        "item-added",
        lambda _, identifier: print(
            watcher.get_item_for_identifier(identifier).get_title()
        ),
    )

    Gtk.main()


if __name__ == "__main__":
    main()
