# A Fast-Loading Zsh Keymap System

## Table of Contents

- [Motivation](#motivation)
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Dependencies](#dependencies)
- [Usage](#usage)
- [Testing](#testing)
- [Load Time](#load-time)
- [Development](#development)
- [Caveat](#caveat)

## Motivation

Moving from web development to infrastructure engineering put me in the terminal full time. I found myself looking up the same syntax and retyping similar sequences of commands over and over.

So over one Christmas break, I built this: a zsh keymap system that puts those commands behind short aliases.

## Overview

**For shell commands**, keymaps are available for tools like [AWS](./zshrc/_snapshots/aws_keymap.txt), [Git](./zshrc/_snapshots/git_keymap.txt), [Kubectl](./zshrc/_snapshots/kubectl_keymap.txt), and [Terraform](./zshrc/_snapshots/terraform_keymap.txt).

**For custom workflows**, [Args keymap](./zshrc/_snapshots/args_keymap.txt) converts the previous output into a numbered list for quick referencing in subsequent commands, while [Nav keymap](./zshrc/_snapshots/nav_keymap.txt) browses the filesystem and pretty-prints CSV, JSON, and Markdown files. See [Usage](#usage) for examples.

**For keyboard shortcuts**, it catalogs defaults for apps like [MacOS](./zshrc/_snapshots/main_keymap.macos.txt), [Gmail](./zshrc/_snapshots/main_keymap.gmail.txt), [Slack](./zshrc/_snapshots/main_keymap.slack.txt) alongside my bindings for IntelliJ ([cmd](./zshrc/_snapshots/intellij_cmd_keymap.txt), [ctrl](./zshrc/_snapshots/intellij_ctrl_keymap.txt), [alt](./zshrc/_snapshots/intellij_alt_keymap.txt)) and Vimium ([browser navigation](./zshrc/_snapshots/vimium_keymap.txt), [search](./zshrc/_snapshots/vimium_search_keymap.txt)).

## Features

- **Composability**: Every listing is numbered by Args, and that number becomes an argument to the next command
- **Namespaced aliases**: Each keymap claims [one letter](./zshrc/_snapshots), e.g. `n` for Nav
- **Short invocation**: `<ALIAS><KEY>` is usually 2 to 3 letters, e.g. `nn`
- **Fast discovery**: Type an alias to [list its keys](#syntax-reference), or add a regex to [search them](#example-3-search-the-nav-keymap-usage-with-n-dotfiles)
- **Conflict prevention**: Any alias that would overwrite a shell built-in or common CLI is rejected unless [explicitly allowed](./zshrc/_keymap/is_reserved.zsh)

## Installation

**Note:** You can preview the [keymap snapshots](./zshrc/_snapshots) without installing.

1. **Clone this repository**:
   ```bash
   git clone https://github.com/jasonzhao6/dotfiles.git <project dir>
   ```

1. **Source `main.zsh` in your `~/.zshrc`**:
   ```bash
   echo "source <project dir>/zshrc/main.zsh" >> ~/.zshrc
   ```

1. **(Optional) Create a secrets file for private keymaps or API keys**:
   ```bash
   touch ~/.zshrc.secrets
   ```

1. **Re-source your `~/.zshrc`, or restart your terminal**:
   ```bash
   source ~/.zshrc
   ```

## Dependencies

- **Zsh shell**
- **GUIs**:
  [Docker Desktop](https://www.docker.com/products/docker-desktop/),
  [GitHub Desktop](https://desktop.github.com/download/)
- **CLIs**:
  [awscli](https://formulae.brew.sh/formula/awscli),
  [gh](https://formulae.brew.sh/formula/gh),
  [helm](https://formulae.brew.sh/formula/helm),
  [kubectl](https://formulae.brew.sh/formula/kubernetes-cli),
  [tfenv](https://formulae.brew.sh/formula/tfenv)
- **Helper CLIs**:
  [colordiff](https://formulae.brew.sh/formula/colordiff),
  [coreutils](https://formulae.brew.sh/formula/coreutils) (`gdate`),
  [jq](https://formulae.brew.sh/formula/jq),
  [mdcat](https://formulae.brew.sh/formula/mdcat),
  [miller](https://formulae.brew.sh/formula/miller) (`mlr`),
  [pcre](https://formulae.brew.sh/formula/pcre) (`pcregrep`)

## Usage

### Example #1: Chain Nav and Args into a workflow with `nn` and `1 n`

`nn` lists the current directory, and every Nav listing is piped straight into Args, which numbers it. That numbering is what lets any command reach back and act on a listed entry, so `1 n` reads as "run `n` on arg #1":

```
$ nn

     1	CLAUDE.md
     2	colordiffrc.txt
     3	gitignore.txt
     4	README.md
     5	terraformrc.txt
     6	tm_properties.txt
     7	vimium
     8	zshrc
     9	zshrc.txt

$ 1 n

n "CLAUDE.md"
─────────
CLAUDE.md
─────────

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Alias Shorthand
...
```

`1 n` first echoes the command it resolved to, `n "CLAUDE.md"`, then runs it. Nav rendered the file through `mdcat` because of its extension; a `.csv` or `.json` arg would have rendered through Nav's own CSV parser or `jq` instead. The same `1 <command>` pattern works after any Args-backed listing, not just Nav's, e.g. `1 cat`, `1 rm`, or `1 open`.

### Example #2: Inspect why it composes with `zz nn`

```
$ zz nn

  $ n.n <match>* <-mismatch>* # List visible files & dirs

     1	nav_keymap_n () {
     2		local filters=("$@")
     3		NAV_CURSOR=0
     4		nav_helpers_history_add "$(pwd)"
     5		ls --color=always | args_keymap_s "${filters[@]}"
     6	}
```

This is the workflow from Example #1 laid bare: `nn` is just `ls` piped into Args keymap, which is why every Nav listing arrives pre-numbered and ready for a follow-up command like `1 n`.

### Example #3: Search the Nav keymap usage with `n dotfiles`

```
$ n dotfiles

  $ n.d  # Go to dotfiles
  $ n.dd # Go to dotfiles, open GitHub Desktop
```

**Note:** `n dotfiles` searches Nav's own keymap because no file or directory named `dotfiles` exists in the CWD. Had one existed, it would have taken precedence, since `n <file>` and `n <directory>` are real Nav commands, not search terms.

### Syntax Reference

(I use the [Dvorak](https://en.wikipedia.org/wiki/Dvorak_keyboard_layout#:~:text=August%20Dvorak%20studied%20letter%20frequencies%20and%20the%20physiology%20of%20the%20hand) layout rather than [QWERTY](https://en.wikipedia.org/wiki/QWERTY), so the key positions below may look unfamiliar.)

Run `ma` to list every keymap namespace, or run any single alias bare to print that keymap's own usage and syntax legend. Every keymap listed by `ma` has its own snapshot under [`_snapshots/`](./zshrc/_snapshots). Nav's, for example:

```
$ n

Keymap: nav_keymap.zsh

  `   1   2   3   4   5   |   6   7   8   9   0   [   ]
      '   ,   .  <p> <y>  |   f   g  <c> (r) <l>  /   =   \
     (a) (o) (e) (u)  i   |  (d) (h) (t) (n) (s)  -
      ;   q  <j> <k>  x   |  <b> <m> <w> <v> <z>

  `<>` initials have only one key mapping
  `()` initials have multiple key mappings

Keymap Usage

  $ n                          # Show this keymap
  $ n <regex>                  # Search this keymap

  $ n.<key>                    # Key takes no variable
  $ n.<key> <var>              # Key takes one variable
  $ n.<key> <var>?             # Key takes zero or one variable
  $ n.<key> <var>*             # Key takes zero or more variables
  $ n.<key> (1-10)             # Key takes a value from inside list
  $ n.<key> (^|)?              # Key can be piped to: ... | n.<key>

     ^                         # The `.` is for visual clarity
                               # Omit it when invoking a key

Keymap List

  $ n <directory>              # Go to directory
  $ n <file>                   # Clear screen, cd to folder & render file

  $ n.n <match>* <-mismatch>*  # List visible files & dirs
  $ n.nf <match>* <-mismatch>* # List visible files
  $ n.nd <match>* <-mismatch>* # List visible dirs

  $ n.a <match>* <-mismatch>*  # List hidden files & dirs
  $ n.af <match>* <-mismatch>* # List hidden files
  $ n.ad <match>* <-mismatch>* # List hidden dirs

  $ n.u <levels>?              # Go up 1+ directories (Default: 1)
  $ n.uu                       # Go up to git repo root

  $ n.b                        # Go to Desktop
  $ n.m                        # Go to Documents
  $ n.w                        # Go to Downloads

  $ n.d                        # Go to dotfiles
  $ n.dd                       # Go to dotfiles, open GitHub Desktop
  $ n.s                        # Go to scratch
  $ n.ss                       # Go to scratch, open GitHub Desktop
  $ n.z                        # Go to scratch/claude
  $ n.e <match>* <-mismatch>*  # List ephemeral dirs, `cd; cc` if 1 match
  $ n.ee <dir name>            # Create ephemeral dir, `cd; cc`

  $ n.y <path>?                # Copy path to pasteboard (Default: `pwd`)
  $ n.p                        # Go to dir from pasteboard path

  $ n.t <match>* <-mismatch>*  # Show shortlist, `cd` if 1 match
  $ n.tt <dir>?                # Add to shortlist, `cd` if not CWD
  $ n.td <dir>                 # Delete from shortlist
  $ n.tc                       # Clear shortlist

  $ n.h <match>* <-mismatch>*  # Show history, `cd` if 1 match
  $ n.hc                       # Clear history

  $ n.o                        # Order files and dirs chronologically
  $ n.of                       # Order files by size
  $ n.od <levels>?             # Order dirs by size

  $ n.j                        # Clear screen & render next file in args
  $ n.k                        # Clear screen & render prev file in args
  $ n.v                        # Clear screen & render file in pasteboard
  $ n.r                        # Clear screen & re-render last file
  $ n.rr                       # Same as `nr` without scrolling to top

  $ n.c                        # (Reserved: Netcat)
  $ n.l                        # (Reserved: Number lines)
```

## Testing

- **Framework Tests**: The keymap framework itself is unit tested
- **Keymap Tests**: Complex key mappings are unit tested
- **Misc Tests**:
  - Every keymap description is at most 40 characters
  - Each keymap entry has a corresponding implementation
  - All key mapping implementation functions are alphabetized
  - Implementations and tests are defined in the same order

```
# Run all test sections
zt

# Run a specific test section (1-5)
zt <num>

# Run tests matching a partial test name
zt <string>

# Run tests matching the test name in the pasteboard
ztt

# Enable profiling during testing
ZSHRC_TESTS_UNDER_PROFILING=1 zt
```

## Load Time

### Expected Performance

"Load time" refers to the delay before a new terminal tab becomes interactive.

On a **2023 M3 MacBook Pro**, initialization typically takes **0.04s to 0.05s**. Every new tab prints its load time on startup:

```
Last login: Thu Jul 24 18:32:47 on ttys011

`.zshrc` loaded in .04 seconds

~
$
```

### Debugging Performance Issues

If load times spike, profile with `zprof`. Uncomment `ZSHRC_UNDER_PROFILING=1` at the top of [main.zsh](./zshrc/main.zsh), then open a new terminal tab, and the profile prints automatically. Look for:

- **Top execution time**: Functions at the top of the table taking a high percentage of time indicate where the main bottlenecks live.
- **High call counts**: Functions invoked dozens or hundreds of times that might benefit from caching or reduced loop iterations.
- **Unexpected slow helpers**: External binary calls, complex regex lookups, or file I/O operations taking disproportionately long during initialization.

```
Last login: Thu Jul 24 18:34:32 on ttys011

`.zshrc` loaded in .05 seconds

num  calls                time                       self            name
-----------------------------------------------------------------------------------
 1)   17           4.58     0.27   32.21%      4.58     0.27   32.21%  keymap_has_disjoint_dups
 2)   17           2.95     0.17   20.75%      2.95     0.17   20.75%  keymap_has_dot_alias
 3)   11           5.39     0.49   37.93%      2.89     0.26   20.37%  keymap_set_dot_aliases
 4)  252           2.72     0.01   19.15%      1.98     0.01   13.94%  keymap_set_alias
 5)   17          14.16     0.83   99.68%      1.02     0.06    7.20%  keymap_init
 6)  252           0.74     0.00    5.20%      0.74     0.00    5.20%  is_reserved
 7)    1           0.02     0.02    0.15%      0.02     0.02    0.15%  gray_fg
 8)    1           0.01     0.01    0.07%      0.01     0.01    0.07%  color
 9)    1           0.01     0.01    0.05%      0.01     0.01    0.05%  args_history_reset
10)    1           0.01     0.01    0.09%      0.01     0.01    0.04%  args_history_init
11)    1           0.00     0.00    0.01%      0.00     0.00    0.01%  other_helpers_reset_terminal_dump_dir
```

## Development

### Project Structure

```
zshrc/
├── _keymap/                # The keymap framework
├── _tests/                 # The testing framework + unit tests
├── _snapshots/             # Keymap snapshots (for viewing outside a shell)
├── *_keymap/               # Keymaps organized by namespace
│   ├── args_keymap/
│   ├── aws_keymap/
│   ├── claude_keymap/
│   ├── docker_keymap/
│   ├── git_keymap/
│   ├── github_keymap/
│   ├── intellij_keymaps/
│   ├── kiro_keymap/
│   ├── kubectl_keymap/
│   ├── main_keymap/
│   ├── nav_keymap/
│   ├── other_keymap/
│   ├── terraform_keymap/
│   ├── usage_keymap/
│   ├── vimium_keymaps/
│   └── zsh_keymap/
├── _tests.zsh              # The entry point to run unit tests
├── main.zsh                # The entry point to source keymaps
├── utils.zsh               # Shared helpers
├── colors.zsh              # Color helpers
└── zsh_*.zsh               # Zsh settings
    ├── zsh_arrow_keys.zsh
    ├── zsh_history.zsh
    └── zsh_prompt.zsh

vimium/                     # Vimium keymaps for browser

*.txt                       # Backups of ~/ dotfiles
├── colordiffrc.txt
├── gitignore.txt
├── terraformrc.txt
├── tm_properties.txt
└── zshrc.txt

.shellcheckrc               # Shellcheck config for this project
CLAUDE.md                   # Guidance for Claude Code
README.md                   # This file
```

### Add a New Keymap

1. **Add keymap ([template](#keymap-template))**: `<my>_keymap/<my>_keymap.zsh`
1. **Add keymap test ([template](#keymap-test-template))**: `_tests/<my>_keymap/test_<my>_keymap.zsh`
1. **Add line in [main.zsh](./zshrc/main.zsh)**: `source "$ZSHRC_SRC_DIR/<my>_keymap/<my>_keymap.zsh"`
1. **Update README**: Keymap lists in [Usage](#usage) and [Project Structure](#project-structure) sections

### Keymap Template
```
<MY>_NAMESPACE='<my>_keymap'
<MY>_ALIAS='<alias>'
<MY>_DOT="${<MY>_ALIAS}${KEYMAP_DOT}"

<MY>_KEYMAP=(
	"${<MY>_DOT}<key1> # Say hello"
	"${<MY>_DOT}<key2> <name>? # Greet by name (Default: 'buddy')"
)

keymap_init $<MY>_NAMESPACE $<MY>_ALIAS "${<MY>_KEYMAP[@]}"

function <my>_keymap {
	keymap_show $<MY>_NAMESPACE $<MY>_ALIAS ${#<MY>_KEYMAP} "${<MY>_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function <my>_keymap_<key1> {
	echo 'Hello, world!'
}

function <my>_keymap_<key2> {
	local name=${1:-buddy}

	echo "Hey, $name!"
}
```

### Keymap Test Template
```
function test__<my>_keymap {
	assert "$(
		local show_this_help; show_this_help=$(<my>_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $show_this_help =~ "^  \\$ $<MY>_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__<my>_keymap_<key1> {
	assert "$(<my>_keymap_<key1>)" 'Hello, world!'
}

function test__<my>_keymap_<key1>__when_called_twice {
	assert "$(<my>_keymap_<key1>; <my>_keymap_<key1>)" "$(
		cat <<-eof
			Hello, world!
			Hello, world!
		eof
	)"
}

function test__<my>_keymap_<key2> {
	assert "$(<my>_keymap_<key2> 'Alice')" 'Hey, Alice!'
}

function test__<my>_keymap_<key2>__with_no_name {
	assert "$(<my>_keymap_<key2>)" 'Hey, buddy!'
}
```

## Caveat

This is a personal setup. It evolves with my workflow and offers no guarantee of backward compatibility.
