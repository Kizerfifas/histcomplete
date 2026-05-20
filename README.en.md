# histcomplete

**English** · [Русский](README.md)

Repository: [github.com/Kizerfifas/histcomplete](https://github.com/Kizerfifas/histcomplete)

```bash
git clone https://github.com/Kizerfifas/histcomplete.git
cd histcomplete
./install.sh
source ~/.bashrc
```

A **bash** utility for Ubuntu/Linux: searches commands you have already run and inserts the full line. For example, type `ls` and use **Alt+h** to get `ls -la ~/projects` if you ran that command before.

**Tab is not overridden** — normal path and filename completion still works.

---

## Table of contents

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Bash history setup](#bash-history-setup)
4. [Terminal usage](#terminal-usage)
5. [`histcomplete` CLI](#histcomplete-cli)
6. [`hc` command](#hc-command)
7. [Examples](#examples)
8. [How it works](#how-it-works)
9. [Troubleshooting](#troubleshooting)
10. [Uninstall](#uninstall)
11. [Limitations and alternatives](#limitations-and-alternatives)

---

## Requirements

| Component | Version / notes |
|-----------|-----------------|
| OS | Ubuntu or other Linux with bash |
| Shell | **bash** (readline integration) |
| Python | **3.6+** (`python3` on PATH) |
| History | `~/.bash_history` (created automatically when using bash) |

Interactive key bindings need a normal terminal (GNOME Terminal, Konsole, Cursor/VS Code integrated terminal, etc.) in **emacs** mode (bash default).

**zsh / fish:** the CLI can read `~/.zsh_history`, but hotkeys from `bash-integration.sh` work only in bash.

---

## Installation

### Automatic (recommended)

```bash
cd /path/to/histcomplete
chmod +x install.sh
./install.sh
```

The script:

1. Copies `histcomplete` to `~/.local/bin/histcomplete`
2. Copies `bash-integration.sh` to `~/.local/share/histcomplete/bash-integration.sh`
3. Appends a `source` line to `~/.bashrc` (if missing)

Activate:

```bash
source ~/.bashrc
```

or open a **new** terminal window.

Verify:

```bash
command -v histcomplete
# expected: /home/YOUR_USER/.local/bin/histcomplete
```

Ensure `~/.local/bin` is on `PATH`. If the command is not found, add to `~/.bashrc`:

```bash
export PATH="${HOME}/.local/bin:${PATH}"
```

### Manual installation

```bash
mkdir -p ~/.local/bin ~/.local/share/histcomplete

cp histcomplete ~/.local/bin/
chmod +x ~/.local/bin/histcomplete

cp bash-integration.sh ~/.local/share/histcomplete/

# Append to ~/.bashrc:
cat >> ~/.bashrc <<'EOF'

# histcomplete — command history autocomplete
[[ -f "${HOME}/.local/share/histcomplete/bash-integration.sh" ]] && \
  source "${HOME}/.local/share/histcomplete/bash-integration.sh"
EOF

source ~/.bashrc
```

### Updating an existing install

Files are installed only under `~/.local/bin` and `~/.local/share/histcomplete`.  
`~/.bashrc` is modified **once** on first install — updates do not touch it again.

**If you already cloned the repo** (recommended):

```bash
cd ~/projects/histcomplete   # or your clone path
git pull
./install.sh
source ~/.bashrc
```

**If you installed without git:**

```bash
cd /tmp
git clone git@github.com:Kizerfifas/histcomplete.git
cd histcomplete
./install.sh
source ~/.bashrc
```

**Updated files:**

| File | Destination |
|------|-------------|
| `histcomplete` | `~/.local/bin/histcomplete` |
| `bash-integration.sh` | `~/.local/share/histcomplete/bash-integration.sh` |
| `README.md` / `README.en.md` | `~/.local/share/histcomplete/` |

**After updating**, use a new terminal or run `source ~/.bashrc` in each open one — old sessions keep previous key bindings until reloaded.

---

## Bash history setup

The tool does **not** invent commands — it only recalls what is already in history. To get suggestions in the current session and persist them across sessions, add to `~/.bashrc` (if not already there):

```bash
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups
shopt -s histappend
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND:-:}"
```

Then:

```bash
source ~/.bashrc
```

**First time:** run the command you want once manually, for example:

```bash
ls -la ~/projects
```

After that, `ls` + **Alt+h** can expand to the full line.

---

## Terminal usage

### Key bindings

| Action | Keys | Description |
|--------|------|-------------|
| History list | **Alt+h** (1st press) | Show numbered matches |
| Insert item [1] | **Alt+h** on empty line | After the list, the input line is cleared — Alt+h inserts the newest match |
| Pick by number | **2** + **Alt+h** | After the list, type only the index (prefix was cleared) |
| Interactive pick | **Ctrl+Alt+h** | Numbered menu (like `histcomplete -i`) |
| Prefix browsing | **↑** / **↓** | Only commands **starting with** what you typed |
| Paths and files | **Tab** | Standard bash completion (**unchanged**) |

> **Alt+h** is **h** with **Alt** (Meta). Some terminals insert special characters instead — enable “Meta sends Escape” in terminal settings, or use **Ctrl+Alt+h** / the `hc` command.

### Typical flow

1. Type: `ls`
2. **Alt+h** — list appears, e.g.  
   `1) ls -la ~/projects`  
   `2) ls -l`
3. Input line is **cleared** — type **`2`** and **Alt+h** (item 2), or **Alt+h** immediately (item 1)
4. Edit if needed, then **Enter**

**↑** / **↓** browse commands with the same prefix without showing the list.

### `hc` command

Wrapper for interactive search:

```bash
hc docker
hc git
```

Same interactive picker as **Ctrl+Alt+h**; inserts into the current line without running the command.

---

## `histcomplete` CLI

Runs from any directory if `~/.local/bin` is on `PATH`.

### Syntax

```text
histcomplete [options] [query]
```

### Options

| Option | Description |
|--------|-------------|
| `query` | Search string (optional) |
| `-n`, `--limit N` | Max results (default 25) |
| `--prefix` | Only commands **starting with** query (Alt+h mode) |
| `-i`, `--interactive` | Interactive pick by number |
| `-p`, `--pick` | Print one chosen command to stdout |
| `-c`, `--complete` | Common prefix of all matches |
| `--suffix` | With `-c`: only the part after `query` (for scripts) |

### CLI examples

```bash
histcomplete docker
histcomplete --prefix git
histcomplete --prefix -i git
cmd=$(histcomplete --prefix -p -i "rails s")
histcomplete --prefix -c "git sta"
```

### `HISTCOMPLETE_EXTRA`

Bash integration passes the **current session** (last 512 lines from `history`). For debugging:

```bash
export HISTCOMPLETE_EXTRA=$'ls -la ~/projects\nls -l\nls'
histcomplete --prefix ls
```

---

## Examples

### Directory listing

```bash
ls -la ~/projects    # run once
ls                   # type
# Alt+h → list; 2 + Alt+h or Alt+h for [1]
```

### Git

```bash
git status           # run once
git                  # type
# Alt+h → pick from list

histcomplete --prefix git pull
```

### Docker

```bash
hc docker
```

### In a script

```bash
#!/usr/bin/env bash
chosen=$(histcomplete --prefix -p -i "$1") || exit 1
echo "Would run: $chosen"
# eval "$chosen"   # only if you trust your history
```

---

## How it works

```text
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  bash input     │────▶│ bash-integration.sh  │────▶│  histcomplete   │
│  (readline)     │     │ Alt+h, Ctrl+Alt+h, hc │     │  (Python 3)     │
└─────────────────┘     └──────────────────────┘     └────────┬────────┘
                                                                │
                    ┌───────────────────────────────────────────┴──────────┐
                    │  Sources (newest first, deduplicated):               │
                    │  1. HISTCOMPLETE_EXTRA — current session             │
                    │  2. ~/.bash_history                                  │
                    │  3. ~/.zsh_history (if present, CLI only)            │
                    └──────────────────────────────────────────────────────┘
```

1. **Search:** default — substring anywhere; with `--prefix` — match at line **start** only.
2. **Sort:** prefix matches first, then by length.
3. **Integration:** `bind -x` updates `READLINE_LINE` / `READLINE_POINT`; it does not execute commands.
4. **Pending list:** saved in `~/.cache/histcomplete/pending` because `bind -x` runs in a subshell.

### Installed paths

| Path | Purpose |
|------|---------|
| `~/.local/bin/histcomplete` | Python executable |
| `~/.local/share/histcomplete/bash-integration.sh` | Key bindings and `hc` |
| `~/.bashrc` | `source ... bash-integration.sh` |

---

## Troubleshooting

### “No matches” / Alt+h does nothing

- The full command was **never run** — execute it once first.
- History not written to disk — see [Bash history setup](#bash-history-setup).
- `source ~/.bashrc` not run after install.
- Alt+h uses **prefix** mode; for substring search in CLI use `histcomplete docker` without `--prefix`.

### Typed a list index (e.g. 31) and still get “No matches”

Update to the latest version (`git pull && ./install.sh`). Older builds lost the list between Alt+h presses. The list is now stored in `~/.cache/histcomplete/pending`.

Flow: `cd` → **Alt+h** (list, line cleared) → `3` → **Alt+h** (picks item **3** in the list, not history line number 31).

### `histcomplete: command not found`

```bash
export PATH="${HOME}/.local/bin:${PATH}"
source ~/.bashrc
which histcomplete
```

### Alt+h inserts odd characters

Enable **Alt as Meta** in the terminal, or use **Ctrl+Alt+h** / `hc query`.

### Tab no longer completes paths

Update `bash-integration.sh` and run `source ~/.bashrc`. Check:

```bash
bind -p | grep '\\C-i'
# should show: "\C-i": complete
```

### Keys do not work in Cursor / VS Code

Use **bash** in the integrated terminal. Check the editor is not stealing the shortcut.

### Stale or duplicate entries

Use `HISTCONTROL=ignoredups` or `erasedups`.

### Non-interactive check

```bash
histcomplete --prefix ls | head
bind -X 2>/dev/null | grep -E 'histcomplete|\\\\eh'
```

Expected:

```text
"\eh": "_histcomplete_expand"
"\e\C-h": "_histcomplete_bind"
```

---

## Uninstall

```bash
rm -f ~/.local/bin/histcomplete
rm -rf ~/.local/share/histcomplete
# Remove the source block from ~/.bashrc manually
source ~/.bashrc
```

---

## Limitations and alternatives

| Limitation | Explanation |
|------------|-------------|
| History only | Does not suggest syntax for commands you never ran |
| No ghost text | No fish-style gray suggestion while typing — use **Alt+h** or **↑** |
| Hotkeys bash-only | zsh/fish need their own plugins |
| Secrets in history | Passwords/tokens in history appear in suggestions — use `HISTCONTROL=ignorespace` and a leading space |

**Built into bash:**

- **Ctrl+r** — reverse history search
- **↑ / ↓** with `history-search-backward` (enabled by integration)

**Similar tools:**

- [hstr](https://github.com/dvorka/hstr)
- [fzf](https://github.com/junegunn/fzf) + history binding
- **fish** / **zsh** autosuggestions

---

## Repository layout

```text
histcomplete/
├── histcomplete           # Python search + CLI
├── bash-integration.sh    # bash readline bindings
├── install.sh             # install to ~/.local
├── README.md              # Russian docs
└── README.en.md           # English docs (this file)
```

---

## License

Provided as-is, without warranty. Use at your own risk, especially when inserting commands from history in production environments.
