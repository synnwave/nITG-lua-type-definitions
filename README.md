# nITG-lua-type-definitions

This script will generate NotITG Lua types for autocompletion.

This is meant to be used with the [Mirin Template](https://github.com/XeroOl/notitg-mirin)

## Credits

XeroOl, for their [nITG XML to Emmylua script](https://github.com/XeroOl/notitg-xml-to-emmylua/blob/main/converter.lua)

CraftedCart, for their [nITG Documentation Files](https://gitlab.com/CraftedCart/notitg_docs/-/tree/master/lua)

## Instructions

1. Drag and drop `scripts` into your template.

2. Install [Lune](https://lune-org.github.io/docs/getting-started/1-installation) and [luadoc](https://github.com/boolangery/py-lua-doc)

3. Run the following:

```bash
lune run scripts/generate
```

## NOTES

If you're using Luau LSP, please use the following configuration:

```json
"luau-lsp.platform.type": "standard",
"luau-lsp.sourcemap.enabled": false,
"luau-lsp.types.definitionFiles": [
    "./scripts/_nITG-luau-defs.d.luau"
],
```
