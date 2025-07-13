## Motivation

When I transitioned from web development to infrastructure engineering, I started living in the terminal.

Every day brought the minor annoyance of constructing long commands and scrolling through pages of documentation I've already visited countless times before.

During one Christmas break, I built this hobby project: A fast-loading zsh keymap system that reduces cognitive load and keystrokes for heavy command line users.

### Testimonial

> *"I got to see first-hand how your shell shortcuts really save time during critical moments. Magic."*
> 
> — Another Infrastructure Engineer

## Overview

This project organizes my favorite and most frequently used 1) shell commands and 2) keyboard shortcuts into namespaced keymaps.

For shell commands, it has keymaps for **AWS, Git, Kubectl, Terraform, etc**. It also has keymaps for my custom workflows like cherry-picking a line from the previous output to pass to the next command.

For keyboard shortcuts, it catalogs default keymaps for **MacOS, Gmail, Slack, Notion, etc**. It also catalogs my custom keymaps for **IntelliJ and Vimium**. 

### Features

- **Namespace Isolation**: Each keymap gets its own namespace and a 1-letter alias
- **Fast Discovery**: Type any alias to see its available commands and search them
- **Keymap Invocation**: Type `<alias><key>` (2-3 letters) to invoke a key mapping
- **Conflict Prevention**: Conflicts with reserved keywords require explicit overwrite

## Installation

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

1. Restart your terminal or source the config:
   ```
   source ~/.zshrc
   ```

### Dependencies

- Zsh shell
- Keymap specific tools: `aws`, `git`, `kubectl`, `terraform`, etc
- Various misc tools: `jq`, `pgrep`, `pcregrep`, `zprof`, etc

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

  $ a  # Custom aliases: args_keymap.zsh
  $ s  # Custom aliases: aws_keymap.zsh
  $ d  # Custom aliases: docker_keymap.zsh
  $ g  # Custom aliases: git_keymap.zsh
  $ h  # Custom aliases: github_keymap.zsh
  $ k  # Custom aliases: kubectl_keymap.zsh
  $ m  # Custom aliases: main_keymap.zsh
  $ n  # Custom aliases: nav_keymap.zsh
  $ o  # Custom aliases: other_keymap.zsh
  $ t  # Custom aliases: terraform_keymap.zsh
  $ z  # Custom aliases: zsh_keymap.zsh

  $ i  # Custom shortcuts: intellij_all.zsh
  $ ia # Custom shortcuts: intellij_alt_keymap.zsh
  $ ic # Custom shortcuts: intellij_cmd_keymap.zsh
  $ it # Custom shortcuts: intellij_ctrl_keymap.zsh
  $ vv # Custom shortcuts: vimium_keymap.zsh
  $ v  # Custom shortcuts: vimium_search_keymap.zsh

  $ mg # Default shortcuts: main_keymap.gmail.zsh
  $ mi # Default shortcuts: main_keymap.vi.zsh
  $ ml # Default shortcuts: main_keymap.less.zsh
  $ mm # Default shortcuts: main_keymap.textmate.zsh
  $ mn # Default shortcuts: main_keymap.notion.zsh
  $ mo # Default shortcuts: main_keymap.macos.zsh
  $ ms # Default shortcuts: main_keymap.slack.zsh
  $ mt # Default shortcuts: main_keymap.terminal.zsh
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
  $ t.h                       # Scratch
  $ t.n                       # Console
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

```
# Go to project folder
cd <project dir>

# Run all tests
zt

# Run a specific test section (1-5)
zt <num>

# Run tests matching a partial test name
zt <string>

# Enable profiling during tests
ZSHRC_TESTS_UNDER_PROFILING=1 zt
```

### Test Features
 
- **Framework Tests**: Keymap framework code is unit tested
- **Keymap Tests**: Complex key mappings are unit tested
- **Misc Verifications**: 
  - All tests defined are also invoked
  - Subjects and tests are defined in the same order
  - All keymap entries have corresponding key mapping functions
  - Key mapping functions are alphabetized

## Performance

This project was built with fast load time in mind. Load time is measured by how quickly a new terminal tab opens and becomes ready for use.

### Expected Performance

On a 2019 Intel MacBook Pro, typical load times range from 0.08s - 0.15s for opening a new terminal tab. Load time is displayed automatically when opening new tabs.

```
Last login: Sat Jul 12 16:10:06 on ttys003

`.zshrc` loaded in .10 seconds

~
$ 
```

### Debugging Performance Issues

If load times spike above the normal range, debug with `zprof`.

Go to `main.zsh`, follow instruction at the top of the file to uncomment `ZSHRC_UNDER_PROFILING=1`. Then open a new terminal tab, and `zprof` output will display automatically. Study the `zprof` output to identify:

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
├── _keymap/                # The underlying keymap framework code
├── _snapshots/             # Snapshots of usages for lookup outside of a shell
├── _tests/                 # Testing harness code and unit tests
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
├── colors.zsh              # Color definitions and helper functions
├── main.zsh                # The entry point to source keymaps
├── utils.zsh               # Helper functions used by multiple keymaps
└── zsh_*.zsh               # Zsh configuration tweaks
    ├── zsh_arrow_keys.zsh
    ├── zsh_history.zsh
    └── zsh_prompt.zsh

vimium/                     # Vimium keymaps for browser navigation
intellij_settings.zip       # IntelliJ settings export
*.txt                       # Non-zsh dotfiles
├── colordiffrc.txt
├── gitignore.txt
├── shellcheckrc.txt
├── terraformrc.txt
└── tm_properties.txt
```

### Adding New Keymaps

1. Create a new directory: `<example>_keymap/`
1. Add keymap definition file: `<example>_keymap.zsh`
1. Add corresponding tests in `_tests/<example>_keymap/`
1. Add corresponding entry in `main_keymap.all_namespaces.zsh`
1. Source it in `main.zsh`

### Keymap Template
```
<EXAMPLE>_EXAMPLESPACE='<example>_keymap'
<EXAMPLE>_ALIAS='<alias>'
<EXAMPLE>_DOT="${<EXAMPLE>_ALIAS}${KEYMAP_DOT}"

<EXAMPLE>_KEYMAP=(
	"${<EXAMPLE>_DOT}<key> # <description>"
)

keymap_init $<EXAMPLE>_EXAMPLESPACE $<EXAMPLE>_ALIAS "${<EXAMPLE>_KEYMAP[@]}"

function <example>_keymap {
	keymap_show $<EXAMPLE>_EXAMPLESPACE $<EXAMPLE>_ALIAS ${#<EXAMPLE>_KEYMAP} "${<EXAMPLE>_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function <example>_keymap_<key> {
	<...>
}
```

## Contributing

This is a personal dotfiles collection with no backward compatibility guarantees. Keymaps may change based on my workflow needs.

Feel free to fork and adapt for your own use, but expect this to remain a personal tool rather than a general-purpose framework.
