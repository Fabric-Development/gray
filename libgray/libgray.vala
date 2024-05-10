// !/usr/bin/env -S vala --pkg gtk+-3.0 --pkg gio-2.0 --pkg Dbusmenu-0.4 --pkg DbusmenuGtk3-0.4 --pkg gdk-pixbuf-2.0
using Gdk;
using GLib;
using DbusmenuGtk;

namespace Gray {
    //  TODO: document the namespace and later generate docs using valadoc
    public struct Pixmap {
        public int width;
        public int height;
        public uint8[] data;

        public Gdk.Pixbuf? as_pixbuf(
            int size = 0,
            Gdk.InterpType resize_method = Gdk.InterpType.NEAREST
        ) {
            if (this.width < 1 || this.height < 1 || this.data.length < 1) {
                return null; // how?
            }

            uint8[] data_bytearray = this.data.copy();
    
            // RGBA -> ARGB
            for (int i = 0; i < this.width * this.height * 4; i += 4) {
                uint8 alpha = data_bytearray[i];
                data_bytearray[i] = data_bytearray[i + 1];
                data_bytearray[i + 1] = data_bytearray[i + 2];
                data_bytearray[i + 2] = data_bytearray[i + 3];
                data_bytearray[i + 3] = alpha;
            }
        
            Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_bytes(
                new Bytes(data_bytearray),
                Gdk.Colorspace.RGB,
                true,
                8,
                (int)this.width,
                (int)this.height,
                (int)(this.width * 4)
            );

            if (size > 0 && size != this.width && pixbuf != null) {
                return pixbuf.scale_simple(size, size, resize_method);
            }
            return pixbuf;
        }
    }

    public Pixmap? get_pixmap_for_pixmaps(Pixmap?[] pixmaps, int target_size = 24) {
        foreach (Pixmap pm in pixmaps) {
            if (pm.width >= target_size && pm.height >= target_size) {
                return pm;
			}
		}
        return null;
    }

    public struct Tooltip {
        string icon_name;
        Pixmap?[] icon_pixmaps;
        string text;
        string markup;
        public string? get_text_or_markup() {
            if (this.text != null && this.markup != null) return this.markup;
            else if (this.text != null) return this.text;
            else if (this.markup != null) return this.markup;
            return null;
        }
    }

    [DBus (name = "org.kde.StatusNotifierItem")]
    public interface ItemProxy : DBusProxy {
        /* signals */
        [DBus (name = "NewTitle")]
        public signal void new_title();
        [DBus (name = "NewIcon")]
        public signal void new_icon();
        [DBus (name = "NewAttentionIcon")]
        public signal void new_attention_icon();
        [DBus (name = "NewOverlayIcon")]
        public signal void new_overlay_icon();
        [DBus (name = "NewToolTip")]
        public signal void new_tooltip();
        [DBus (name = "NewStatus")]
        public signal void new_status(string status);

        /* properties */
        [DBus (name = "Category")]
        public abstract string category { owned get; }
        [DBus (name = "Id")]
        public abstract string id { owned get; }
        [DBus (name = "Title")]
        public abstract string title { owned get; }
        [DBus (name = "Status")]
        public abstract string status { owned get; }
        [DBus (name = "WindowId")]
        public abstract int window_id { get; }
        [DBus (name = "IconThemePath")]
        public abstract string icon_theme_path { owned get; }
        [DBus (name = "ItemIsMenu")]
        public abstract bool item_is_menu { get; }
        [DBus (name = "Menu")]
        public abstract ObjectPath menu_path { owned get; }
        [DBus (name = "IconName")]
        public abstract string icon_name { owned get; }
        [DBus (name = "IconPixmap")]
        public abstract Pixmap?[] icon_pixmaps { owned get; }
        [DBus (name = "AttentionIconName")]
        public abstract string attention_icon_name { owned get; }
        [DBus (name = "AttentionIconPixmap")]
        public abstract Pixmap?[] attention_icon_pixmaps { owned get; }
        [DBus (name = "ToolTip")]
        public abstract Tooltip tooltip { owned get; }

        /* methods */
        [DBus (name = "ContextMenu")]
        public abstract void context_menu(int x, int y) throws DBusError, IOError;
        [DBus (name = "Activate")]
        public abstract void activate(int x, int y) throws DBusError, IOError;
        [DBus (name = "SecondaryActivate")]
        public abstract void secondary_activate(int x, int y) throws DBusError, IOError;
        [DBus (name = "Scroll")]
        public abstract void scroll(int delta, string orientation) throws DBusError, IOError;
    }

    public class Item : Object {
        public signal void ready();
        public signal void error();
        public signal void removed();
        public signal void changed();
        public signal void icon_changed();

        public string bus_name { get; private set; }
        public string bus_path { get; private set; }
        public string identifier { get; private set; }
        public ItemProxy? proxy { get; private set; }
        public DbusmenuGtk.Menu? menu { get; set; }

        public string category { owned get { return this.proxy.category; } }
        public string id { owned get { return this.proxy.id; } }
        public string title { owned get { return this.proxy.title; } }
        public string status { owned get { return this.proxy.status; } }
        public int window_id {  get { return this.proxy.window_id; } }
        public string icon_theme_path { owned get { return this.proxy.icon_theme_path; } }
        public bool item_is_menu {  get { return this.proxy.item_is_menu; } }
        public string menu_path { owned get { return this.proxy.menu_path.to_string(); } }
        public string icon_name { owned get { return this.proxy.icon_name; } }
        public Pixmap?[] icon_pixmaps { owned get { return this.proxy.icon_pixmaps; } }
        public string attention_icon_name { owned get { return this.proxy.attention_icon_name; } }
        public Pixmap?[] attention_icon_pixmaps { owned get { return this.proxy.attention_icon_pixmaps; } }
        public Tooltip tooltip { owned get { return this.proxy.tooltip; } }

        public Item(string bus_name, string bus_path) {
            this.bus_name = bus_name;
            this.bus_path = bus_path;
            this.identifier = bus_name + bus_path;

            Bus.get_proxy.begin<ItemProxy>(
                GLib.BusType.SESSION,
                bus_name, 
                bus_path, 
                GLib.DBusProxyFlags.NONE, 
                null, 
                (_, result) => {
                    try{
                        this.proxy = Bus.get_proxy.end<ItemProxy>(result);
                        this.proxy.notify["g-name-owner"].connect(
                            () => {
                                if (this.proxy.g_name_owner == null) {
                                    this.removed();
                                }
                            }
                        );
                    } catch ( IOError e) {
                        warning(@"cannot register item with identifier $(this.identifier), error message $(e.message)");
                        return;
                    }
                    this.pre_ready();
                    // all aboard...
                    this.ready();
                }
            );
        }

        private void notify_for_icon() {
            this.icon_changed();
            this.changed();
        }

        private void notify_for_property(string prop_name) {
            this.notify_property(prop_name);
            this.changed();
        }

        private void pre_ready() {
            this.menu = this.create_menu();
            this.proxy.new_attention_icon.connect(() => { this.notify_for_icon(); });
            this.proxy.new_overlay_icon.connect(() => { this.notify_for_icon(); });
            this.proxy.new_icon.connect(() => { this.notify_for_icon(); });
            this.proxy.new_title.connect(() => { this.notify_for_property("title"); });
            this.proxy.new_tooltip.connect(() => { this.notify_for_property("tooltip"); });
            this.proxy.new_status.connect(() => { this.notify_for_property("status"); });
        }

        public void context_menu(int x, int y) throws DBusError, IOError {
            this.proxy.context_menu(x, y);
            return;
        }

        public void activate(int x, int y) throws DBusError, IOError {
            this.proxy.activate(x, y);
            return;
        }

        public void activate_for_event(Gdk.EventAny event) throws DBusError, IOError {
            double x, y; event.get_coords(out x, out y);
            this.activate((int)x, (int)y);
            return;
        }

        public void secondary_activate(int x, int y) throws DBusError, IOError {
            this.proxy.secondary_activate(x, y);
            return;
        }

        public void secondary_activate_for_event(Gdk.EventAny event) throws DBusError, IOError {
            double x, y; event.get_coords(out x, out y);
            this.secondary_activate((int)x, (int)y);
            return;
        }

        public void scroll(int delta, string orientation) throws DBusError, IOError {
            this.proxy.scroll(delta, orientation);
            return;
        }

        public void scroll_for_event(Gdk.EventAny event) throws DBusError, IOError {
            Gdk.ScrollDirection direction;
            event.get_scroll_direction(out direction);
            double delta_x, delta_y; event.get_scroll_deltas(out delta_x, out delta_y);
            switch (direction) {
                case Gdk.ScrollDirection.UP:
                case Gdk.ScrollDirection.DOWN:
                        this.scroll((int)delta_y, "vertical");
                    break;
                case Gdk.ScrollDirection.LEFT:
                case Gdk.ScrollDirection.RIGHT:
                        this.scroll((int)delta_x, "horizontal");
                    break;
                default:
                    break;
            }
            return;
        }
        
        public DbusmenuGtk.Menu? create_menu() {
            if (this.menu_path == "") {
                return null;
            }
            return new DbusmenuGtk.Menu(this.proxy.get_name_owner(), this.menu_path);
        }
    }

    [DBus (name = "org.kde.StatusNotifierWatcher")]
    public class Watcher : Object {
        /* dbus-hidden properties/signals */
        [DBus (visible = false)]
        private DBusConnection? connection;
        [DBus (visible = false)]
        public HashTable<string, Item> items { get; private set; }

        [DBus (visible = false)]
        public signal void item_added(string identifier);
        public signal void item_removed(string identifier);

        [DBus (visible = false)]
        public signal void name_owned();
        [DBus (visible = false)]
        public signal void name_own_error();

        /* dbus visible stuff */
        [DBus (name = "StatusNotifierItemRegistered")]
        public signal void status_notifier_item_registered(string service);
        [DBus (name = "StatusNotifierItemUnregistered")]
        public signal void status_notifier_item_unregistered(string service);
        [DBus (name = "StatusNotifierHostRegistered")]
        public signal void status_notifier_host_registered();
        [DBus (name = "StatusNotifierHostUnregistered")]
        public signal void status_notifier_host_unregistered();

        [DBus (name = "RegisteredStatusNotifierItems")]
        public string[] registered_status_notifier_items { owned get { return this.items.get_keys_as_array(); } }
        [DBus (name = "IsStatusNotifierHostRegistered")]
        public bool is_status_notifier_host_registered { default = true; get; }
        [DBus (name = "ProtocolVersion")]
        public int protocol_version { default = 3; get; }

        public Watcher() {
            this.items = new HashTable<string, Item> (str_hash, str_equal);
            this.register();
        }
        
        private void register() {
            Bus.own_name(
                BusType.SESSION, "org.kde.StatusNotifierWatcher",
                BusNameOwnerFlags.NONE,
                (conn) => {
                    this.connection = conn;
                    try {
                        conn.register_object ("/StatusNotifierWatcher", this);
                        this.status_notifier_host_registered();
                    } catch (Error e) {
                        this.name_own_error();
                    }
                },
                () => { this.name_owned(); },
                () => { this.name_own_error(); }
            );
        }

        [DBus (visible = false)]
        public Item? get_item_for_identifier(string identifier) {
            return this.items.get(identifier);
        }

        /* methods */
        [DBus (name = "RegisterStatusNotifierItem")]
        public void register_status_notifier_item(string path, BusName name) throws DBusError, IOError {
            if (!path.has_prefix("/")) {
                /* not a valid object path
                   probably a ":1.42"-like name instead */
                path = "/StatusNotifierItem";
            }
            var item = new Item(name.to_string(), path);
            item.ready.connect(
                () => {
                    this.items[item.identifier] = item;
                    this.item_added(item.identifier);
                    this.status_notifier_item_registered(item.identifier);
                }
            );
            item.removed.connect(
                () => {
                    this.items.remove(item.identifier);
                    this.item_removed(item.identifier);
                    this.status_notifier_item_unregistered(item.identifier);
                }
            );
        }

        [DBus (name = "RegisterStatusNotifierHost")]
        public void register_status_notifier_host(string service) throws DBusError, IOError { return; }

    }
}
