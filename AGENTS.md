# AGENTS.md

Personal dotfiles repo (zsh + zimfw, Neovim, tmux). No build, no tests, no CI — changes are verified by sourcing the files in a shell.

## Layout

- `.zshrc` — sourced on every interactive zsh startup (repo filename; the live file is `~/.zshrc`).
- `.zimrc` — **not sourced at runtime**. It is the zimfw module list, only read when zim (re)generates `~/.zim/init.zsh` (e.g. `zimfw.zsh init`, `zimfw.zsh install`, `zimfw.zsh update`).
- `init.lua` — Neovim config, lives at `~/.config/nvim/init.lua`.
- `.tmux.conf` — lives at `~/.tmux.conf`.
- `.tool-versions` — asdf pin (`nodejs`), not part of the shell config.
- `setup.sh` — one-command bootstrap that clones/updates this repo into `~/.config/dotfiles` and symlinks the above files into their live `~` locations (backs up any pre-existing real files to `~/.dotfiles-backup`). Safe to re-run.

## zimfw gotchas

- Module order in `.zimrc` is load order and is load-bearing: `completion` must come after modules that add completions; `zsh-syntax-highlighting` after `completion`; `zsh-history-substring-search` after `zsh-syntax-highlighting`; `zsh-autosuggestions` last. Don't reorder modules carelessly.
- The `ZSH_AUTOSUGGEST_MANUAL_REBIND=1` env var in `.zshrc` only works because `zsh-autosuggestions` is the last module in `.zimrc`. If module order changes, this may need revisiting.
- The "Post-init module configuration" block in `.zshrc` (manual `bindkey` of up/down/`k`/`j` to `history-substring-search-*`) is a deliberate workaround so the arrow keys work both before and after `zle-line-init`. Don't remove it without re-testing history navigation.
- Custom modules are installed from URLs in `.zimrc` (e.g. `xaviSalazar/eriner`); stock modules are bare names.
- If the user changes modules, regeneration happens automatically at next shell start (`.zshrc` compares `~/.zim/init.zsh` mtime against `.zimrc`), or manually via `~/.zim/zimfw.zsh install|update|uninstall <module>`.

## Neovim config

- Uses the built-in `vim.pack` package manager (Neovim 0.11+), **not** lazy.nvim or vim-plug. Don't introduce a different manager.
- Treesitter setup is deferred to a `PackLoaded` autocmd and wrapped in `pcall` — keep new package setups similarly guarded (`pcall` / deferred) since plugins load asynchronously.
- LSP servers are configured via `vim.lsp.config` + `vim.lsp.enable` (0.11 API). Required binaries: `typescript-language-server`, `vscode-eslint-language-server`, `vscode-html-language-server`, `vscode-css-language-server`, `lua-language-server`, `clangd-22`, `bash-language-server`.
- Leader key is Space (`<leader>`).

## tmux

- `.tmux.conf` binds `h` to `$ZNT_REPO_DIR/doc/znt-tmux.zsh`, a helper from the `z-shell/zsh-navigation-tools` module. `ZNT_REPO_DIR` is set by that module at runtime, so the binding is a no-op until the shell loads it — don't "fix" the variable reference.

## Conventions

- Keep edits minimal and consistent with existing comment style (section banners like `# =================` in `init.lua`, `#`-comment blocks in zsh files).
- Verify shell changes with `zsh -n .zshrc` (syntax check) or by sourcing in a scratch shell; there is no other test harness.
