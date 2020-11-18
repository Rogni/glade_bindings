
/// import builder bindings module
import glade;

/// import gtk ui elements
import gtk.Label;
import gtk.Entry;
import gtk.ApplicationWindow;
import gtk.Button;
import gtk.Dialog;

import gtk.Main;

import std.array: empty;

private:

/// gresource path to glade file
@GUIPath("/gtk_helper/examples/builder_bindings/window.ui")
final class HelloUI
{
    @GObjectId("root_window")
    ApplicationWindow rootWindow;

    @GObjectId("name_entry")
    Entry nameEntry;

    @GObjectId("hello_label")
    Label helloLabel;

    @GObjectId("hello_dialog")
    Dialog helloDialog;


    /// called after all ui elements binded to struct
    void did_load() {
        /// close app if closed window
        rootWindow.addOnHide( (Widget) { 
                                    Main.quit();
                                });

        /// show root window
        rootWindow.show();  
    }

    @GCallbackId("say_hello_button", "clicked")
    void onHelloClicked() {
        auto name = nameEntry.getText();
            
        if (!name.empty) {
            helloLabel.setText("Hello, " ~ name ~ "!");
        } else {
            helloLabel.setText("Who are you ?");
        }
        /// show hello dialog 
        helloDialog.show();
    }

    @GCallbackId("close_button", "clicked")
    void onCloseDialogClicked() {
        helloDialog.hide();
    }
}

void main(string[] args)
{
    /// init gtk application
    Main.init(args);

    auto ui = load_ui!HelloUI();

    Main.run();
}


