# A Fast-Loading Zsh Keymap System

## Table of Contents

- [Motivation](#motivation)
- [Feedback](#feedback)
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Dependencies](#dependencies)
- [Usage](#usage)
- [Testing](#testing)
- [Load Time](#load-time)
- [Customization](#customization)
- [Caveat](#caveat)

## Motivation

When I transitioned from web development to infrastructure engineering, I started living full time in the terminal.

Every day, I felt the minor annoyance of constructing the same long commands and revisiting the same documentation I've done countless times before.

So one Christmas break, I built this as a hobby project: A fast-loading zsh keymap system that **catalogs and simplifies complex commands** frequently used in my workflow.

## Feedback

> *"I got to see first-hand how your shell shortcuts really **save time during critical moments**. Magic."*
>
> — An Infrastructure Engineer

## Overview

This project organizes my favorite and most frequently used 1) shell commands and 2) keyboard shortcuts into namespaced keymaps.

**For shell commands**, it has keymaps for **[AWS](./zshrc/_snapshots/aws_keymap.txt)**, **[Git](./zshrc/_snapshots/git_keymap.txt)**, **[Kubectl](./zshrc/_snapshots/kubectl_keymap.txt)**, **[Terraform](./zshrc/_snapshots/terraform_keymap.txt)**, etc. It also has keymaps for my custom workflows like cherry-picking a line from the previous output as **[Args](./zshrc/_snapshots/args_keymap.txt)** to pass to the next command.

**For keyboard shortcuts**, it catalogs default keymaps for **[MacOS](./zshrc/_snapshots/main_keymap.macos.txt)**, **[Gmail](./zshrc/_snapshots/main_keymap.gmail.txt)**, **[Slack](./zshrc/_snapshots/main_keymap.slack.txt)**, **[Notion](./zshrc/_snapshots/main_keymap.notion.txt)**, etc. It also catalogs my custom keymaps for **IntelliJ** ([cmd](./zshrc/_snapshots/intellij_cmd_keymap.txt), [ctrl](./zshrc/_snapshots/intellij_ctrl_keymap.txt), [alt](./zshrc/_snapshots/intellij_alt_keymap.txt)) and **Vimium** ([nav](./zshrc/_snapshots/vimium_keymap.txt), [search](./zshrc/_snapshots/vimium_search_keymap.txt)).

## Features

- **Namespace Isolation**: Each keymap gets its own namespace with a [1-letter alias](#example-1-list-all-keymap-namespaces-with-ma)
- **Fast Discovery**: Type any alias to [print its available commands](#example-2-print-the-terraform-keymap-usage-with-t), or [search them](#example-3-search-the-terraform-keymap-usage-with-t-ini)
- **Keymap Invocation**: Type `<ALIAS><KEY>` (2-3 letters) to [invoke a key mapping](#example-5-invoke-the-terraform-init--upgrade-mapping-with-tiu)
- **Conflict Prevention**: Conflicts with standard commands require explicit overwrite

## Installation

**Note:** You can also preview [snapshots](./zshrc/_snapshots) of keymaps without installation.

1. **Clone this repository**:
   ```bash
   git clone https://github.com/jasonzhao6/dotfiles.git <project dir>
   ```

1. **Source `main.zsh` in your `~/.zshrc`**:
   ```bash
   echo "source <project dir>/zshrc/main.zsh" >> ~/.zshrc
   ```

1. **(Optional) Create a secrets file for sensitive keymaps**:
   ```bash
   touch ~/.zshrc.secrets
   ```

1. **Restart your terminal, or re-source your `~/.zshrc`**:
   ```bash
   source ~/.zshrc
   ```

## Dependencies

- **Zsh shell**
- **Main GUIs**:
  [Docker Desktop](https://www.docker.com/products/docker-desktop/) (`docker`),
  [GitHub Desktop](https://desktop.github.com/download/)
- **Main CLIs**:
  [awscli](https://formulae.brew.sh/formula/awscli) (`aws`),
  [`gh`](https://formulae.brew.sh/formula/gh),
  [`kubectl`](https://formulae.brew.sh/formula/kubernetes-cli),
  [`tfenv`](https://formulae.brew.sh/formula/tfenv) (`terraform`)
- **Helper CLIs**:
  [`colordiff`](https://formulae.brew.sh/formula/colordiff),
  [coreutils](https://formulae.brew.sh/formula/coreutils) (`gdate`),
  [pcre](https://formulae.brew.sh/formula/pcre) (`pcregrep`)

## Usage

### Example #1: List all keymap namespaces with `ma`

```
$ ma

Keymap: main_keymap.all_namespaces.zsh

  `   1   2   3   4   5   |   6   7   8   9   0   [   ]
      '   ,   .   p   y   |   f  <g>  c   r   l   /   =   \
     <a> <o>  e   u  (i)  |  <d> <h> <t> <n> <s>  -
      ;  <q>  j  <k>  x   |   b  (m)  w  (v) <z>

  `<>` key initials have one mapping
  `()` key initials have multiple mappings

All Namespaces

  $ a  # Keymap: args_keymap.zsh
  $ s  # Keymap: aws_keymap.zsh
  $ d  # Keymap: docker_keymap.zsh
  $ g  # Keymap: git_keymap.zsh
  $ h  # Keymap: github_keymap.zsh
  $ k  # Keymap: kubectl_keymap.zsh
  $ m  # Keymap: main_keymap.zsh
  $ n  # Keymap: nav_keymap.zsh
  $ o  # Keymap: other_keymap.zsh
  $ q  # Keymap: q_keymap.zsh
  $ t  # Keymap: terraform_keymap.zsh
  $ z  # Keymap: zsh_keymap.zsh

  $ i  # Keyboard shortcuts: intellij_all.zsh
  $ ia # Keyboard shortcuts: intellij_alt_keymap.zsh
  $ ic # Keyboard shortcuts: intellij_cmd_keymap.zsh
  $ it # Keyboard shortcuts: intellij_ctrl_keymap.zsh
  $ vv # Keyboard shortcuts: vimium_keymap.zsh
  $ v  # Keyboard shortcuts: vimium_search_keymap.zsh

  $ mg # Default keyboard shortcuts: main_keymap.gmail.zsh
  $ mh # Default keyboard shortcuts: main_keymap.github_desktop.zsh
  $ mi # Default keyboard shortcuts: main_keymap.vi.zsh
  $ ml # Default keyboard shortcuts: main_keymap.less.zsh
  $ mm # Default keyboard shortcuts: main_keymap.textmate.zsh
  $ mn # Default keyboard shortcuts: main_keymap.notion.zsh
  $ mo # Default keyboard shortcuts: main_keymap.macos.zsh
  $ ms # Default keyboard shortcuts: main_keymap.slack.zsh
  $ mt # Default keyboard shortcuts: main_keymap.terminal.zsh
```

**Note:** My keyboard layout may look different from yours. I'm using [Dvorak](https://en.wikipedia.org/wiki/Dvorak_keyboard_layout) instead of [QWERTY](https://en.wikipedia.org/wiki/QWERTY).

### Example #2: Print the Terraform keymap usage with `t`

```
$ t

Keymap: terraform_keymap.zsh

  `   1   2   3   4   5   |   6   7   8   9   0   [   ]
      '   ,   .  <p>  y   |  <f> <g> (c) <r> <l>  /   =   \
     <a> <o> <e> <u> (i)  |  <d> <h> (t) <n> <s>  -
      ;  <q>  j   k   x   |   b  <m> (w) <v> <z>

  `<>` key initials have one mapping
  `()` key initials have multiple mappings

Keymap Usage

  $ t                         # Show this keymap
  $ t <regex>                 # Search this keymap

  $ (|)? t.<key>              # This mapping can be invoked after a `|`
  $ t.<key>                   # This mapping takes no variable
  $ t.<key> <var>             # This mapping takes one variable
  $ t.<key> <var>?            # This mapping takes zero or one variable
  $ t.<key> <var>*            # This mapping takes zero or multiple variables
  $ t.<key> (1-10)            # This mapping takes an exact value from the list

     ^                        # The `.` is only for documentation
                              # Omit it when invoking a mapping

Keymap List

  $ t <terraform command>

  $ t.w                       # List manifests
  $ t.w <match>* <-mismatch>* # Filter manifests

  $ t.i                       # Init
  $ t.iu                      # Init & upgrade
  $ t.ir                      # Init & reconfigure
  $ t.im                      # Init & migrate state
  $ t.e                       # Load secret env vars

  $ t.v (i,iu,ir,im,e)?       # Validate
  $ t.p (i,iu,ir,im,e)?       # Plan
  $ t.g                       # Upload gist
  $ t.z                       # Unlock
  $ t.a                       # Apply
  $ t.d                       # Destroy
  $ t.o                       # Show output

  $ t.l <name>                # List states
  $ t.s <name>                # Show state
  $ t.t <name>                # Taint state
  $ t.u <name>                # Untaint state
  $ t.m <before> <after>      # Move state
  $ t.rm <name>               # Remove state

  $ t.f                       # Format
  $ t.h <var name>?           # Scratch
  $ t.n <var name>?           # Console
  $ t.c                       # Clean
  $ t.cc                      # Clean & clear plugin cache
  $ t.qa                      # Apply & auto-approve
```

### Example #3: Search the Terraform keymap usage with `t ini`

```
$ t ini

  $ t.i  # Init
  $ t.iu # Init & upgrade
  $ t.ir # Init & reconfigure
  $ t.im # Init & migrate state
```

**Note:** Unlike `t ini`, `t init` would have recognized `init` as a native `terraform` command and passed it along instead of searching for "init" as a partial string in the keymap usage.

### Example #4: Inspect the definition of `tiu` with `zz tiu`

```
$ zz tiu

  # `tiu` is aliased to `terraform_keymap_iu`

  $ t.iu # Init & upgrade

     1	terraform_keymap_iu () {
     2		terraform init -upgrade
     3	}
```

### Example #5: Invoke the `terraform init -upgrade` mapping with `tiu`

```
$ tiu

Initializing the backend...
Upgrading modules...

Terraform has been successfully initialized!
```

## Testing

- **Framework Tests**: Keymap framework code is unit tested
- **Keymap Tests**: Complex key mappings are unit tested
- **Misc Tests**:
  - Every test that is defined is actually invoked
  - Subjects and tests are defined in the same order
  - Each keymap entry has a corresponding implementation
  - All key mapping implementation functions are alphabetized

```
# Go to project folder
cd <project dir>

# Run all test sections
zt

# Run a specific test section (1-5)
zt <num>

# Run tests matching a partial test name
zt <string>

# Enable profiling during testing
ZSHRC_TESTS_UNDER_PROFILING=1 zt
```

## Load Time

### Expected Performance

This project was built with fast load time in mind. Load time is measured by how quickly a new terminal tab opens and becomes ready for use.

On a **2023 M3 MacBook Pro**, typical load time is between **0.04s - 0.05s**. Look for load time when opening a new terminal tab:

```
Last login: Thu Jul 24 18:32:47 on ttys011

`.zshrc` loaded in .04 seconds

~
$
```

### Debugging Performance Issues

If load times are consistently above the normal range, debug with `zprof`.

Go to [main.zsh](./zshrc/main.zsh), follow instruction at the top of the file to uncomment `ZSHRC_UNDER_PROFILING=1`. Then open a new terminal tab, and `zprof` output will display automatically. Study the `zprof` output to identify:

- Functions consuming the most time
- Number of calls per function
- Cumulative time spent in each component

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
11)    1           0.00     0.00    0.01%      0.00     0.00    0.01%  other_keymap_k_reset
```

## Customization

### Project Structure

```
zshrc/
├── _keymap/                # The keymap framework
├── _tests/                 # The testing framework + unit tests
├── _snapshots/             # Snapshots of keymap usages (for lookup outside of a shell)
├── *_keymap/               # Keymaps organized by namespaces
│   ├── args_keymap/
│   ├── aws_keymap/
│   ├── docker_keymap/
│   ├── git_keymap/
│   ├── github_keymap/
│   ├── intellij_keymaps/
│   ├── kubectl_keymap/
│   ├── main_keymap/
│   ├── nav_keymap/
│   ├── other_keymap/
│   ├── q_keymap/
│   ├── terraform_keymap/
│   ├── vimium_keymaps/
│   └── zsh_keymap/
├── _tests.zsh              # The entry point to run unit tests
├── main.zsh                # The entry point to source keymaps
├── utils.zsh               # Helper functions used by multiple keymaps
├── colors.zsh              # Color-specific helper functions
└── zsh_*.zsh               # Zsh configuration tweaks
    ├── zsh_arrow_keys.zsh
    ├── zsh_history.zsh
    └── zsh_prompt.zsh

vimium/                     # Vimium keymaps for browser navigation

*.txt                       # Non-zsh dotfiles
├── colordiffrc.txt
├── gitignore.txt
├── shellcheckrc.txt
├── terraformrc.txt
└── tm_properties.txt

README.md                   # This file
```

### Adding New Keymaps

1. **Add keymap definition file**: `<new>_keymap/<new>_keymap.zsh`
1. **Add keymap test file**: `_tests/<new>_keymap/test_<new>_keymap.zsh`
1. **Add this line in [main.zsh](./zshrc/main.zsh)**: `source "$ZSHRC_DIR/<new>_keymap/<new>_keymap.zsh"`
1. **Update this README**: E.g [Usage](#usage) and [Project Structure](#project-structure) sections

### Keymap Template
```
<NEW>_NAMESPACE='<new>_keymap'
<NEW>_ALIAS='<alias>'
<NEW>_DOT="${<NEW>_ALIAS}${KEYMAP_DOT}"

<NEW>_KEYMAP=(
	"${<NEW>_DOT}<key> # <description>"
)

keymap_init $<NEW>_NAMESPACE $<NEW>_ALIAS "${<NEW>_KEYMAP[@]}"

function <new>_keymap {
	keymap_show $<NEW>_NAMESPACE $<NEW>_ALIAS ${#<NEW>_KEYMAP} "${<NEW>_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function <new>_keymap_<key> {
	<...>
}
```

## Caveat

This is a personal dotfiles collection that evolves with my workflow needs. It does not have any guarantee of backward compatibility.
