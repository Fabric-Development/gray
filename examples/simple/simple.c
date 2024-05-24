/* cc simple.c `pkg-config --libs --cflags gray` */
#include <libgray.h>
#include <gtk/gtk.h>
#include <glib-object.h>

void on_new_item(
    GrayWatcher* self,
    gchar* item_identifier[],
    gpointer data
) {
    GrayItem* item = gray_watcher_get_item_for_identifier(self, item_identifier);
    if (!item) {
        return;
    }
    g_print("%s \n", gray_item_get_title(item));
}

int main(int argc, char** argv) {
    gtk_init(&argc, &argv);

    GrayWatcher* watcher = gray_watcher_new();
    g_signal_connect(watcher, "item-added", G_CALLBACK(on_new_item), NULL);

    gtk_main();
    return 0;
}
