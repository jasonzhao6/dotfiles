## Motivation

When I transitioned from web development to infrastructure engineering, I started living in the terminal.

Every day brought the minor annoyance of constructing long commands by scrolling through endless pages of documentation I've already visited countless times before.

During one Christmas break, I built this hobby project: A fast-loading zsh keymap system that reduces cognitive load and simplifies complex commands, mostly for me to recall my own knowledge.

## Testimonial

> *"I got to see first-hand how your shell shortcuts really save time during critical moments. Magic."*
>
> — Another Infrastructure Engineer

## Overview

This project organizes my favorite and most frequently used 1) shell commands and 2) keyboard shortcuts into namespaced keymaps.

For shell commands, it has keymaps for **[AWS](./zshrc/_snapshots/aws_keymap.txt), [Git](./zshrc/_snapshots/git_keymap.txt), [Kubectl](./zshrc/_snapshots/kubectl_keymap.txt), [Terraform](./zshrc/_snapshots/terraform_keymap.txt), etc**. It also has keymaps for my custom workflows like cherry-picking a line from the previous output as **[Args](./zshrc/_snapshots/args_keymap.txt)** to pass to the next command.

For keyboard shortcuts, it catalogs default keymaps for **[MacOS](./zshrc/_snapshots/main_keymap.macos.txt), [Gmail](./zshrc/_snapshots/main_keymap.gmail.txt), [Slack](./zshrc/_snapshots/main_keymap.slack.txt), [Notion](./zshrc/_snapshots/main_keymap.notion.txt), etc**. It also catalogs my custom keymaps for **IntelliJ** ([cmd](./zshrc/_snapshots/intellij_cmd_keymap.txt), [ctrl](./zshrc/_snapshots/intellij_ctrl_keymap.txt), [alt](./zshrc/_snapshots/intellij_alt_keymap.txt)) and **Vimium** ([nav](./zshrc/_snapshots/vimium_keymap.txt), [search](./zshrc/_snapshots/vimium_search_keymap.txt)).

## Features

- **Namespace Isolation**: Each keymap gets its own namespace with a [1-letter alias](#example-1-list-all-keymap-namespaces-with-ma)
- **Fast Discovery**: Type any alias to [print its available commands](#example-2-print-the-terraform-keymap-usage-with-t), or [search them](#example-3-search-the-terraform-keymap-usage-with-t-ini)
- **Keymap Invocation**: Type `<ALIAS><KEY>` (2-3 letters) to [invoke a key mapping](#example-5-invoke-the-terraform-init--upgrade-mapping-with-tiu)
- **Conflict Prevention**: Conflicts with standard commands require explicit overwrite

## Installation

**Note:** You could also browse [snapshots](./zshrc/_snapshots) of keymaps without installation.

1. Clone this repository:
   ```
   git clone https://github.com/jasonzhao6/dotfiles.git <project dir>
   ```

1. Source `main.zsh` in your `~/.zshrc`:
   ```
   echo "source <project dir>/zshrc/main.zsh" >> ~/.zshrc
   ```

1. (Optional) Create a secrets file for sensitive keymaps:
   ```
   touch ~/.zshrc.secrets
   ```

1. Restart your terminal, or re-source your `~/.zshrc`:
   ```
   source ~/.zshrc
   ```

## Dependencies

- Zsh shell
- Keymap specific tools: `aws`, `git`, `gh`, `kubectl`, `terraform`, etc
- Various misc tools: `colordiff`, `jq`, `pgrep`, `pcregrep`, `zprof`, etc

## Usage

### Example #1: List all keymap namespaces with `ma`

```
$ ma

Keymap: main_keymap.all_namespaces.zsh

  `   1   2   3   4   5   |   6   7   8   9   0   [   ]
      '   ,   .   p   y   |   f  <g>  c   r   l   /   =   \
     <a> <o>  e   u  (i)  |  <d> <h> <t> <n> <s>  -
      ;   q   j  <k>  x   |   b  (m)  w  (v) <z>

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
  $ t  # Keymap: terraform_keymap.zsh
  $ z  # Keymap: zsh_keymap.zsh

  $ i  # Keyboard shortcuts: intellij_all.zsh
  $ ia # Keyboard shortcuts: intellij_alt_keymap.zsh
  $ ic # Keyboard shortcuts: intellij_cmd_keymap.zsh
  $ it # Keyboard shortcuts: intellij_ctrl_keymap.zsh
  $ vv # Keyboard shortcuts: vimium_keymap.zsh
  $ v  # Keyboard shortcuts: vimium_search_keymap.zsh

  $ mg # Default keyboard shortcuts: main_keymap.gmail.zsh
  $ mi # Default keyboard shortcuts: main_keymap.vi.zsh
  $ ml # Default keyboard shortcuts: main_keymap.less.zsh
  $ mm # Default keyboard shortcuts: main_keymap.textmate.zsh
  $ mn # Default keyboard shortcuts: main_keymap.notion.zsh
  $ mo # Default keyboard shortcuts: main_keymap.macos.zsh
  $ ms # Default keyboard shortcuts: main_keymap.slack.zsh
  $ mt # Default keyboard shortcuts: main_keymap.terminal.zsh
```

**Note:** My keyboard layout may look different than yours. I'm using the [Dvorak keyboard layout](https://en.wikipedia.org/wiki/Dvorak_keyboard_layout).

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

  $ t                         # Show this help
  $ t {regex}                 # Filter key mappings

  $ t.{key}                   # Invoke a {key} mapping
  $ t.{key} {arg}             # Invoke a {key} mapping with {arg}

     ^                        # The `.` is only for documentation
                              # Omit it when invoking a mapping

Keymap List

  $ t {terraform command}

  $ t.w                       # List manifests
  $ t.w {match}* {-mismatch}* # Filter manifests

  $ t.i                       # Init
  $ t.iu                      # Init & upgrade
  $ t.ir                      # Init & reconfigure
  $ t.im                      # Init & migrate state
  $ t.e                       # Load secret env vars

  $ t.v {i,iu,ir,im,e}?       # Validate
  $ t.p {i,iu,ir,im,e}?       # Plan
  $ t.g                       # Upload gist
  $ t.z                       # Unlock
  $ t.a                       # Apply
  $ t.d                       # Destroy
  $ t.o                       # Show output

  $ t.l {name}                # List states
  $ t.s {name}                # Show state
  $ t.t {name}                # Taint state
  $ t.u {name}                # Untaint state
  $ t.m {before} {after}      # Move state
  $ t.rm {name}               # Remove state

  $ t.f                       # Format
  $ t.h {var name}?           # Scratch
  $ t.n {var name}?           # Console
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

**Note:** Unlike `t ini`, `t init` would recognize `init` as a native `terraform` command and pass it along instead of searching for "init" as a partial string in the keymap usage.

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

On a 2019 Intel MacBook Pro, typical load times range from 0.08s - 0.15s. Load time is displayed automatically when opening new tabs.

```
Last login: Sat Jul 12 16:10:06 on ttys003

`.zshrc` loaded in .10 seconds

~
$
```

### Debugging Performance Issues

If load times spike above the normal range, debug with `zprof`.

Go to [main.zsh](./zshrc/main.zsh), follow instruction at the top of the file to uncomment `ZSHRC_UNDER_PROFILING=1`. Then open a new terminal tab, and `zprof` output will display automatically. Study the `zprof` output to identify:

- Functions consuming the most time
- Number of calls per function
- Cumulative time spent in each component

```
Last login: Sat Jul 12 16:10:07 on ttys004

`.zshrc` loaded in .11 seconds

num  calls                time                       self            name
-----------------------------------------------------------------------------------
 1)   17          12.13     0.71   30.90%     12.13     0.71   30.90%  keymap_has_disjoint_dups
 2)   11          16.26     1.48   41.44%      8.38     0.76   21.35%  keymap_set_dot_aliases
 3)   17           7.23     0.43   18.41%      7.23     0.43   18.41%  keymap_has_dot_alias
 4)  252           8.72     0.03   22.23%      6.54     0.03   16.65%  keymap_set_alias
 5)   17          39.15     2.30   99.74%      2.69     0.16    6.85%  keymap_init
 6)  252           2.19     0.01    5.57%      2.19     0.01    5.57%  is_reserved
 7)    1           0.04     0.04    0.10%      0.04     0.04    0.10%  gray_fg
 8)    1           0.03     0.03    0.07%      0.03     0.03    0.07%  color
 9)    1           0.03     0.03    0.07%      0.01     0.01    0.04%  args_history_init
10)    1           0.01     0.01    0.03%      0.01     0.01    0.03%  args_history_reset
11)    1           0.01     0.01    0.02%      0.01     0.01    0.02%  other_keymap_k_reset
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

1. Add keymap definition file: `<example>_keymap/<example>_keymap.zsh`
1. Add corresponding tests in `_tests/<example>_keymap/test_<example>_keymap.zsh`
1. Source it in [main.zsh](./zshrc/main.zsh)

### Keymap Template
```
<EXAMPLE>_NAMESPACE='<example>_keymap'
<EXAMPLE>_ALIAS='<alias>'
<EXAMPLE>_DOT="${<EXAMPLE>_ALIAS}${KEYMAP_DOT}"

<EXAMPLE>_KEYMAP=(
	"${<EXAMPLE>_DOT}<key> # <description>"
)

keymap_init $<EXAMPLE>_NAMESPACE $<EXAMPLE>_ALIAS "${<EXAMPLE>_KEYMAP[@]}"

function <example>_keymap {
	keymap_show $<EXAMPLE>_NAMESPACE $<EXAMPLE>_ALIAS ${#<EXAMPLE>_KEYMAP} "${<EXAMPLE>_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function <example>_keymap_<key> {
	<...>
}
```

## Caveat

This is a personal dotfiles collection that evolves with my workflow needs. It does not have any guarantee of backward compatibility.
