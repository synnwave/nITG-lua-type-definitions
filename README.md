# nITG-lua-type-definitions

This script will generate NotITG Lua types for autocompletion.

This is meant to be used with the [Mirin Template](https://github.com/XeroOl/notitg-mirin)

## Credits

XeroOl, for their [nITG XML to Emmylua script](https://github.com/XeroOl/notitg-xml-to-emmylua/blob/main/converter.lua)

CraftedCart, for their [nITG Documentation Files](https://gitlab.com/CraftedCart/notitg_docs/-/tree/master/lua)

## Instructions

Drag and drop `.vscode` and `scripts` into your template.

Install [Lune](https://lune-org.github.io/docs/getting-started/1-installation) and [luadoc](https://github.com/boolangery/py-lua-doc)

Run the following:

```bash
lune setup # you will only need to run this once per project 
lune run scripts/generate
```

## NOTES

If you're using a text editor that isn't Visual Studio Code, you'll need to configure your LSP to load one of the following type definition files:

```lua
"./scripts/_nITG-luau-defs.d.luau" -- for Luau LSP
"./scripts/_nITG-emmylua-defs.lua" -- for Lua LSP (Emmylua)
```

See how [the visual studio code settings file](.vscode/settings.json) is set up.
