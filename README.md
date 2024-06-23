# nITG-lua-type-definitions

This script will generate NotITG Lua types for autocompletion (and type-checking if you're using Luau). 

This is meant to be used with the [Mirin Template](https://github.com/XeroOl/notitg-mirin)

## Credits

XeroOl, for their [nITG XML to Emmylua script](https://github.com/XeroOl/notitg-xml-to-emmylua/blob/main/converter.lua)

CraftedCart, for their [nITG Documentation Files](https://gitlab.com/CraftedCart/notitg_docs/-/tree/master/lua)

## Instructions

Drag and drop `.vscode` and `scripts` into your template.

[Install Lune](https://lune-org.github.io/docs/getting-started/1-installation)

[Install luadoc](https://github.com/boolangery/py-lua-doc)

Run the following:

```bash
lune setup
lune run scripts/generateDefs
```

## NOTES

If you're using a text editor that isn't Visual Studio Code, you'll need to configure Luau LSP to use the type definitions file.

These type definitions are only for [Luau LSP](https://github.com/JohnnyMorganz/luau-lsp).

### Emmylua support will be added soon!!

### Documentation will be added soon!!