# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A fast-loading zsh keymap system that catalogs and simplifies complex shell commands via short 2-3 letter aliases. Uses a Dvorak keyboard layout for key assignments.

## Running Tests

Tests require the dotfiles to be sourced. The `zt` alias (from `zsh_keymap`) runs the test suite:

```bash
# Run all 5 test sections
zt

# Run a specific section (1-5)
zt <num>

# Run tests matching a partial name
zt <string>

# Enable profiling during testing
ZSHRC_TESTS_UNDER_PROFILING=1 zt
```

The test entry point is `zshrc/_tests.zsh`. Tests run with `ZSHRC_UNDER_TESTING=1` set, which suppresses load-time output and secrets sourcing.

## Architecture

### Entry Points
- `zshrc/main.zsh` — Sources all keymaps and zsh configs in order. Also handles load-time measurement and optional profiling (`ZSHRC_UNDER_PROFILING=1`).

### Keymap Framework (`zshrc/_keymap/`)
- `keymap_base.zsh` — Core framework: `keymap_init`, `keymap_show`, `keymap_print_help`, alias management, duplicate detection.
- `is_reserved.zsh` — Prevents keymaps from overwriting reserved shell keywords.

Each keymap calls `keymap_init <NAMESPACE> <ALIAS> "${KEYMAP_ARRAY[@]}"` on load, which sets up:
- A top-level alias (e.g. `g` → `git_keymap`) that prints usage or searches when called
- Dot aliases for each key (e.g. `gd` → `git_keymap_d`) that invoke the corresponding function

### Keymap Pattern

Every `*_keymap.zsh` file follows this exact template:

```zsh
FOO_NAMESPACE='foo_keymap'
FOO_ALIAS='f'
FOO_DOT="${FOO_ALIAS}${KEYMAP_DOT}"

FOO_KEYMAP=(
    "${FOO_DOT}<key> # <description>"
)

keymap_init $FOO_NAMESPACE $FOO_ALIAS "${FOO_KEYMAP[@]}"

function foo_keymap {
    keymap_show $FOO_NAMESPACE $FOO_ALIAS ${#FOO_KEYMAP} "${FOO_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function foo_keymap_<key> {
    <implementation>
}
```

Key conventions:
- The dot (`.`) in keymap entries is documentation-only; omit it when invoking (e.g. `t.iu` → type `tiu`)
- Key mapping functions must be **alphabetized**
- Multi-character keys like `bb`, `iu` map to functions named `namespace_bb`, `namespace_iu`
- Joint duplicates (same key with different args) are allowed; disjoint duplicates (same key, different purpose) are detected and reported as errors
- Avoid chars `'`, `,`, `.`, `;`, `[`, `/`, `=`, `\` as key initials
- Parameter annotations in keymap entries:
  - `<var>` — takes exactly one variable
  - `<var>?` — takes zero or one variable (optional)
  - `<var>*` — takes zero or multiple variables
  - `(1-10)` — takes an exact value from the list

### App Defaults (`main_keymap.*.zsh`)
Non-zsh shortcut reference files for external apps (e.g. Gmail, Terminal, Claude Code). Format:
- Modifiers are lowercase and hyphen-separated: `cmd-shift-f`, `ctrl-g`, `alt-shift-{up}`
- Special keys use braces: `{tab}`, `{left}`, `{up}`, `{page up}`
- Regular keys are bare: `cmd-k`, `ctrl-c`, `r`

### Test Framework (`zshrc/_tests/`)
- `_test_harness.zsh` — `init`, `assert`, `pass`, `fail`, `execute_tests`, `print_summary`
- Test files live in `_tests/<namespace>/test_<name>.zsh`
- Tests are shuffled before execution to catch ordering dependencies
- 5 test sections:
  1. Unit tests (`_run_all_test_cases.zsh`)
  2. Verify every defined test is invoked (`_verify_test_invocations.zsh`)
  3. Verify subjects and tests are defined in the same order (`_verify_test_ordering.zsh`)
  4. Verify each keymap entry has a corresponding implementation function (`_verify_keymap_definitions.zsh`)
  5. Verify all implementation functions are alphabetized (`_verify_keymap_ordering.zsh`)

### Adding a New Keymap

1. Create `zshrc/<new>_keymap/<new>_keymap.zsh` following the template above
2. Create `zshrc/_tests/<new>_keymap/test_<new>_keymap.zsh`
3. Add `source "$ZSHRC_SRC_DIR/<new>_keymap/<new>_keymap.zsh"` in `zshrc/main.zsh`

### Helper Files
- `zshrc/utils.zsh` — Shared utilities: `bw` (strip ANSI), `strip`, `upcase`, `paste_when_empty`, `echo_eval`, etc.
- `zshrc/colors.zsh` — Color helpers: `gray_fg`, `cyan_fg`, `red_bar`, `red_bg`, etc.
- `zshrc/zsh_*.zsh` — Zsh config: arrow key bindings, history settings, prompt
