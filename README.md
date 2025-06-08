# szaldivar nvim config

## Environments

Environments are controlled via the `NVIM_SZ_ENVIRONMENT` env variable.
Supported values are `'WORK'` and `'PERSONAL'`.
This is used to enable/disable some plugins based on the environment.

### Requirements for all environments
I don't like using mason to automatically install binaries for dependencies so these have to be installed manually
- GitHub CLI: Get the latest version. Used by `octo.nvim` to do PR reviews.
- Lua Language Server: [Optional]
- StyLua: [Optional] for auto formatting Lua files.

### WORK requirements

- env `NVIM_SZ_CPP_DAP`: should point to the DAP adapter for CPP. You can get the binary from the Vscode CPP Tools extension
- env `NVIM_SZ_HTTP_PROXY`: HTTP proxy to use
- clangd: C++ language server
- clang_format
- nodejs >= 20: [Optional] for GitHub Copilot
- pyright: [Optional] Python LSP
- ruff_format

### PERSONAL requirements

- TODO
