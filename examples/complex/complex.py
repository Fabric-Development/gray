import gi

gi.require_version("Gray", "0.1")
from gi.repository import Gray, Gtk, GdkPixbuf


class SystemTrayWidget(Gtk.Box):
    def __init__(self, **kwargs) -> None:
        super().__init__()
        self.watcher = Gray.Watcher()
        self.watcher.connect("item-added", self.on_item_added)

    def on_item_added(self, _, identifier: str):
        item = self.watcher.get_item_for_identifier(identifier)
        item_button = self.do_bake_item_button(item)
        item_button.show_all()
        self.add(item_button)

    def do_bake_item_button(self, item) -> Gtk.Button:
        button = Gtk.Button()

        # context menu handler
        button.connect(
            "button-press-event",
            lambda _, event: item.get_menu().popup_at_pointer(event),
        )

        # get pixel map of item's icon
        pixmap = Gray.get_pixmap_for_pixmaps(item.get_icon_pixmaps(), 24)

        # convert the pixmap to a pixbuf
        pixbuf: GdkPixbuf.Pixbuf = (
            pixmap.as_pixbuf(32, GdkPixbuf.InterpType.HYPER)
            if pixmap is not None
            else Gtk.IconTheme().load_icon(
                item.get_icon_name(),
                36,
                Gtk.IconLookupFlags.FORCE_SIZE,
            )
        )

        # resize/scale the pixbuf
        pixbuf.scale_simple(36 * 3, 36 * 3, GdkPixbuf.InterpType.HYPER)

        image = Gtk.Image(pixbuf=pixbuf, pixel_size=36 * 3)
        button.set_image(image)

        return button


if __name__ == "__main__":
    window = Gtk.Window()

    window.add(SystemTrayWidget())

    window.show_all()

    window.connect("destroy", Gtk.main_quit)
    Gtk.main()
