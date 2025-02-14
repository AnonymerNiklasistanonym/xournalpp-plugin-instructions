# xournalpp-plugin-instructions

Summary on how to write [`xournalpp`](https://github.com/xournalpp/xournalpp/) plugins.

> In case you only want an icon for a color or more/other colors in general edit the text file `$HOME/.config/xournalpp/palette.gpl` (Linux) / `%AppData%\Local\xournalpp\plugins\palette.gpl` (Windows) and either update existing colors or add new lines with custom colors:
>
> ```gpl
> GIMP Palette
> Name: Xournal Default Palette
> #
> 0 0 0 Black
> 0 128 0 Green
> 0 192 255 Light Blue
> # ...
> ```
>
> The format being:
>
> ```gpl
> RED_VALUE[0-255] GREEN_VALUE[0-255] BLUE_VALUE[0-255] Color name
> ```
>
> To find a custom color either use the internal color picker, search for color picker on google or use https://htmlcolors.com/google-color-picker.

**Table of contents:**

- [Structure](#structure1)
- [Install](#install2)
- [Write](#write)
- [TODO](#todo)
- [More](#more)
  - [`.ini` Properties](#ini-properties)
  - [`.lua` Language](#lua-language)
  - [Icon IDs](#icon-ids)
  - [Run plugin copy scripts](#run-plugin-copy-scripts)

## Structure[^1]

```text
--+ PluginName
  |
  +--plugin.ini
  +--main.lua
```

A plugin is stored in a directory with the name of it and contains:

- a metadata file `plugin.ini`:

  ```ini
  [about]
  author=NAME OF THE AUTHOR
  description=DESCRIPTION OF THE PLUGIN
  version=VERSION NUMBER

  [default]
  # Disabled per default
  enabled=false

  [plugin]
  # The main script file
  mainfile=main.lua
  ```

- a main LUA script file (most commonly called `main.lua`) which denotes the plugin functionality

  ```lua
  -- Register plugin menu bar entries, toolbar icons and initialize stuff
  function initUi()
      -- e.g. register menu bar entry
      app.registerUi({
          ["menu"] = "Change tool to red pen", -- menu bar entry text
          ["callback"] = "run",                -- function to run on click
          ["accelerator"] = "<Alt>F1",         -- keyboard shortcut
      })
  end

  function run()
      -- e.g. switch action tool to pen and color to red
      app.uiAction({["action"]="ACTION_TOOL_PEN"})
      app.changeToolColor({["color"] = 0xff0000, ["selection"] = true})
  end
  ```

[^1]: https://xournalpp.github.io/guide/plugins/plugins/#plugin-structure

## Install[^2]

To add a plugin to the local `xournalpp` installation:

1. The directory needs to be copied to the [Config folder](https://xournalpp.github.io/guide/file-locations/#where-to-find-xournal-files):
   - `$HOME/.config/xournalpp/plugins` (Linux)
   - `%LOCALAPPDATA%\xournalpp\plugins` (Windows)
2. Now restart/open `xournalpp` to find the plugin listed in a popup window via the menu bar `Plugin` > `Plugin Manager`
   - If the plugin is not enabled per default, enable it by checking the checkbox and restart `xournalpp`
3. In case the plugin supports a toolbar icon shortcut you want to use read the next section on how to manually add it to your toolbar after the successful installation

[^2]: https://xournalpp.github.io/guide/plugins/plugins/#installation-folder

### Toolbar Shortcuts

> You first need to once select `View` > `Toolbars` > `Customize` in the menubar of `xournalpp` in order to automatically trigger the creation of a custom copy of the currently used toolbar layout.

To add toolbar shortcuts of plugins that register them you need to edit manually the `toolbar.ini` file found in the [Config folder](https://xournalpp.github.io/guide/file-locations/#where-to-find-xournal-files):

- `$HOME/.config/xournalpp` (Linux)
- `%LOCALAPPDATA%\xournalpp` (Windows)

This file lists the toolbar icons as their IDs like the following example:

```ini
[Portrait Copy]
toolbarTop1=SAVE,NEW,OPEN,SEPARATOR,SAVEPDF,PRINT
#...
```

To add a custom plugin registered toolbar icon add the registered ID to the list with the prefix `Plugin::` like (if the toolbarId in `main.lua` is `EXAMPLETOOLBARICON`):

```ini
[Portrait Copy]
toolbarTop1=SAVE,NEW,OPEN,SEPARATOR,SAVEPDF,PRINT,SEPARATOR,Plugin::EXAMPLETOOLBARICON
#...
```

After this manual step it can be moved around with the built in toolbar customizer (`View` > `Toolbars` > `Customize`).

## Write

- [Minimal](./examples/ExampleMinimal/)
- [Dialogs](./examples/ExampleDialogs/)
- [Global variables](./examples/ExampleGlobalVariables/)
- [Toolbar icon](./examples/ExampleToolbarIcon/)
- [Toolbar icon (Custom icon)](./examples/ExampleToolbarIconCustom/)
- [External commands](./examples/ExampleExternalCommands/)
- [Multiple scripts](./examples/ExampleMultipleScripts/)

A full list of all available `xournalpp` functions that can be used inside the plugin scripts can be found here: https://github.com/xournalpp/xournalpp/blob/master/plugins/luapi_application.def.lua

## TODO

- [ ] How to use custom lua libs like `lgi`
  - https://github.com/xournalpp/xournalpp/discussions/4522

## More

### `.ini` Properties

- allow no multiple line strings
  - but inserting literally `\n` in the description of a plugin adds a line break

### `.lua` Language

- Documentation: https://www.lua.org/pil/contents.html

### Icon IDs

- All `.svg` files seem to be useable by stripping their parent directory path and the file extension
  - `../document-revert-rtl-symbolic.svg` -> `document-revert-rtl`
  - `../nvtop.svg` -> `nvtop`
- (GTK) Icon directories for existing and custom icons:
  - **Linux:** `/usr/share/icons/` or `$HOME/.local/share/icons/`
  - **Windows:** `C:\Program Files\Xournal++\share\icons` or `%LOCALAPPDATA%/icons/`
- The default `xournalpp` icons can be found in:
  - **Linux:** `/usr/share/xournalpp/ui/iconsColor-dark/hicolor/scalable/actions/`
  - **Windows:** `C:\Program Files\Xournal++\share\xournalpp\ui\iconsColor-dark/hicolor/scalable/actions/`

### Run plugin copy scripts

There is a script for Linux and for Windows to easily copy the plugins to the right (default) directories:

#### Linux

```sh
cd examples
# When not using git to download the repository the copy script needs to be marked as executable
chmod +x copy_linux.sh
./copy_linux.sh
```

### Windows

```pwsh
cd examples
# > Per default you can't run Powershell scripts on Windows because 'CurrentUser' is set to Restricted
Get-ExecutionPolicy -List
#        Scope ExecutionPolicy
#        ----- ---------------
#MachinePolicy       Undefined
#   UserPolicy       Undefined
#      Process       Undefined
#  CurrentUser      Restricted
# LocalMachine      Restricted
# > When changing to Unrestricted any script can be run
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
# > There is an additional dialog where 'Run Once' is enough
.\copy_windows.ps1

Security warning
Run only scripts that you trust. While scripts from the internet can be useful, this script can potentially harm your
computer. If you trust this script, use the Unblock-File cmdlet to allow the script to run without this warning
message. Do you want to run
C:\Users\username\Downloads\xournalpp-plugin-instructions-main\xournalpp-plugin-instructions-main\examples\copy_windows.ps
1?
[D] Do not run  [R] Run once  [S] Suspend  [?] Help (default is "D"): R
# > After running the script it's possible to reset to default settings
$ Set-ExecutionPolicy -Scope CurrentUser Default
```
