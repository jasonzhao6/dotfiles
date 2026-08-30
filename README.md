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

Moving from web development to infrastructure engineering put me in the terminal full time. I found myself retyping the same long commands and looking up the same reference material over and over.

So over one Christmas break, I built this: a zsh keymap system that puts those commands behind short aliases and loads fast enough to stay out of the way.

## Overview

Two kinds of things live here: shell commands I run constantly and keyboard shortcuts I want at a glance.

**For shell commands**, keymaps are available for tools like [AWS](./zshrc/_snapshots/aws_keymap.txt), [Git](./zshrc/_snapshots/git_keymap.txt), [Kubectl](./zshrc/_snapshots/kubectl_keymap.txt), and [Terraform](./zshrc/_snapshots/terraform_keymap.txt). I've also built custom workflows. For instance, [Args](./zshrc/_snapshots/args_keymap.txt) converts the previous output into a numbered list for quick referencing in subsequent commands, while [Nav](./zshrc/_snapshots/nav_keymap.txt) browses the filesystem and pretty-prints CSV, JSON, and Markdown files.

**For keyboard shortcuts**, it catalogs defaults for [MacOS](./zshrc/_snapshots/main_keymap.macos.txt), [Gmail](./zshrc/_snapshots/main_keymap.gmail.txt), [Slack](./zshrc/_snapshots/main_keymap.slack.txt), and more, alongside my bindings for IntelliJ ([cmd](./zshrc/_snapshots/intellij_cmd_keymap.txt), [ctrl](./zshrc/_snapshots/intellij_ctrl_keymap.txt), [alt](./zshrc/_snapshots/intellij_alt_keymap.txt)) and Vimium ([browser navigation](./zshrc/_snapshots/vimium_keymap.txt), [search](./zshrc/_snapshots/vimium_search_keymap.txt)).

## Features

- **Namespaced aliases**: Each keymap claims [one letter](#example-1-list-all-keymap-namespaces-with-ma), e.g. `t` for Terraform
- **Fast discovery**: Type an alias to [list its keys](#example-2-print-the-terraform-keymap-usage-with-t), or add a regex to [search them](#example-3-search-the-terraform-keymap-usage-with-t-ini)
- **Short invocation**: [`<ALIAS><KEY>`](#example-5-invoke-the-terraform-init--upgrade-mapping-with-tiu) is usually 2 to 3 letters
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

### Example #1: List all keymap namespaces with `ma`

(I use the [Dvorak](https://en.wikipedia.org/wiki/Dvorak_keyboard_layout#:~:text=August%20Dvorak%20studied%20letter%20frequencies%20and%20the%20physiology%20of%20the%20hand) layout rather than [QWERTY](https://en.wikipedia.org/wiki/QWERTY), so the key positions may look unfamiliar.)

```
$ ma

Keymap: main_keymap.all_namespaces.zsh

  `   1   2   3   4   5   |   6   7   8   9   0   [   ]
      '   ,   .   p   y   |   f  <g> <c> <r>  l   /   =   \
     <a> <o>  e  <u> (i)  |  <d> <h> <t> <n> <s>  -
      ;   q   j  <k>  x   |   b  (m)  w  (v) <z>

  `<>` initials have only one key mapping
  `()` initials have multiple key mappings

All Namespaces

  $ a   # Shell shortcuts: args_keymap.zsh
  $ s   # Shell shortcuts: aws_keymap.zsh
  $ c   # Shell shortcuts: claude_keymap.zsh
  $ d   # Shell shortcuts: docker_keymap.zsh
  $ g   # Shell shortcuts: git_keymap.zsh
  $ h   # Shell shortcuts: github_keymap.zsh
  $ r   # Shell shortcuts: kiro_keymap.zsh
  $ k   # Shell shortcuts: kubectl_keymap.zsh
  $ m   # Shell shortcuts: main_keymap.zsh
  $ n   # Shell shortcuts: nav_keymap.zsh
  $ o   # Shell shortcuts: other_keymap.zsh
  $ t   # Shell shortcuts: terraform_keymap.zsh
  $ u   # Shell shortcuts: usage_keymap.zsh
  $ z   # Shell shortcuts: zsh_keymap.zsh

  $ i   # App shortcuts: intellij_all.zsh
  $ ia  # App shortcuts: intellij_alt_keymap.zsh
  $ ic  # App shortcuts: intellij_cmd_keymap.zsh
  $ it  # App shortcuts: intellij_ctrl_keymap.zsh
  $ vv  # App shortcuts: vimium_keymap.zsh
  $ v   # App shortcuts: vimium_search_keymap.zsh

  $ mac # App defaults: main_keymap.macos.zsh
  $ mc  # App defaults: main_keymap.claude.zsh
  $ mg  # App defaults: main_keymap.gmail.zsh
  $ mh  # App defaults: main_keymap.github_desktop.zsh
  $ ml  # App defaults: main_keymap.less.zsh
  $ mm  # App defaults: main_keymap.textmate.zsh
  $ mn  # App defaults: main_keymap.notion.zsh
  $ ms  # App defaults: main_keymap.slack.zsh
  $ mt  # App defaults: main_keymap.terminal.zsh
  $ mvi # App defaults: main_keymap.vi.zsh
```

### Example #2: Print the Terraform keymap usage with `t`

```
$ t

Keymap: terraform_keymap.zsh

  `   1   2   3   4   5   |   6   7   8   9   0   [   ]
      '   ,   .  <p>  y   |  <f> <g> (c) <r>  l   /   =   \
     <a> <o> <e> <u> (i)  |  <d>  h  (t) (n) (s)  -
      ;   q   j   k   x   |   b  <m>  w  <v>  z

  `<>` initials have only one key mapping
  `()` initials have multiple key mappings

Keymap Usage

  $ t                         # Show this keymap
  $ t <regex>                 # Search this keymap

  $ t.<key>                   # Key takes no variable
  $ t.<key> <var>             # Key takes one variable
  $ t.<key> <var>?            # Key takes zero or one variable
  $ t.<key> <var>*            # Key takes zero or more variables
  $ t.<key> (1-10)            # Key takes a value from inside list
  $ t.<key> (^|)?             # Key can be piped to: ... | t.<key>

     ^                        # The `.` is for visual clarity
                              # Omit it when invoking a key

Keymap List

  $ t <terraform command>     # Pass through

  $ t.t <match>* <-mismatch>* # List manifests & filter

  $ t.i                       # Init
  $ t.iu                      # Init & upgrade
  $ t.ir                      # Init & reconfigure
  $ t.im                      # Init & migrate state
  $ t.e                       # Load secret env vars

  $ t.v (i,iu,ir,im,e)?       # Validate
  $ t.p (i,iu,ir,im,e)?       # Plan
  $ t.g                       # Upload 'tfplan' as a gist
  $ t.a <max age in min>?     # Apply 'tfplan' (Default: 5)

  $ t.s <match>* <-mismatch>* # List states & filter
  $ t.sd <state>              # Delete state
  $ t.sr <before> <after>     # Rename state
  $ t.ss <state>              # Show state
  $ t.st <state>              # Taint state
  $ t.su <state>              # Untaint state

  $ t.c                       # Clean
  $ t.cc                      # Clean & clear plugin cache
  $ t.d                       # Destroy
  $ t.f <path>?               # Format (Default: CWD)
  $ t.n <var name>?           # Start console or print var in CWD
  $ t.nn <var name>?          # Start console or print var in 'tf-debug'
  $ t.o                       # Show output
  $ t.u <lock id>?            # Unlock (Default: Pasteboard)

  $ t.m                       # Open diff from pasteboard in TextMate

  $ t.r                       # (Reserved: Translate chars)
```

### Example #3: Search the Terraform keymap usage with `t ini`

```
$ t ini

  $ t.i  # Init
  $ t.iu # Init & upgrade
  $ t.ir # Init & reconfigure
  $ t.im # Init & migrate state
```

**Note:** `t init` would behave differently. Since `init` is a real `terraform` command, it gets passed through rather than treated as a search term.

### Example #4: Inspect the definition of `tiu` with `zz tiu`

```
$ zz tiu

  $ t.iu # Init & upgrade

     1	terraform_keymap_iu () {
     2		terraform init -upgrade
     3	}
```

### Example #5: Invoke the `tiu` mapping

```
$ tiu

Initializing the backend...
Upgrading modules...

Terraform has been successfully initialized!
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

1. **Add keymap definition file**: `<my>_keymap/<my>_keymap.zsh`
1. **Add keymap test file**: `_tests/<my>_keymap/test_<my>_keymap.zsh`
1. **Add this line in [main.zsh](./zshrc/main.zsh)**: `source "$ZSHRC_SRC_DIR/<my>_keymap/<my>_keymap.zsh"`
1. **Update this README**: E.g [Usage](#usage) and [Project Structure](#project-structure) sections

### Keymap Template
```
<MY>_NAMESPACE='<my>_keymap'
<MY>_ALIAS='<alias>'
<MY>_DOT="${<MY>_ALIAS}${KEYMAP_DOT}"

<MY>_KEYMAP=(
	"${<MY>_DOT}<key1> # <description1>"
	"${<MY>_DOT}<key2> # <description2>"
)

keymap_init $<MY>_NAMESPACE $<MY>_ALIAS "${<MY>_KEYMAP[@]}"

function <my>_keymap {
	keymap_show $<MY>_NAMESPACE $<MY>_ALIAS ${#<MY>_KEYMAP} "${<MY>_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function <my>_keymap_<key1> {
	<...>
}

function <my>_keymap_<key2> {
	<...>
}
```

## Caveat

This is a personal setup. It evolves with my workflow and offers no guarantee of backward compatibility.
