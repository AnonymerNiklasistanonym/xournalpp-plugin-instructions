# ExampleSharedLibraryObject

This plugin links to Cairo and LibrSVG to load a vector image (`.svg`) and rasterizes it with a much higher resolution than GTK normally does.
Then it stores it in the `/temp`/`%TEMP%` directory and tells Xournal++ via it's API `app.addImages` to add this image to the document.

> [!WARNING]
>
> This only works on the Xournal++ nightly build at the moment since it makes use of the plugin API `app.addImages`.
