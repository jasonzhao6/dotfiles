# TODO: Keymap refactors

From a full keymap review (2026-07-03). Work top to bottom; run `zt <keymap>` after each.

## Shortlist (in order)

1. **usage: dedupe `ud`/`udd`/`uh`/`uhh`** — four byte-identical scaffolds (filter → stats → chart), differing only in chart function + respect/ignore arg. Extract `usage_helpers_chart <chart> <zone_mode> <num_days>`; keys become one-liners. ~−28 lines. (`usage_keymap.zsh:172-222`)
2. **args: have `all`/`each` delegate to `ab`/`af`** — `all` = `args_keymap_b 1 $(args_helpers_size)`, `each` = `args_keymap_f 1 $(args_helpers_size)`. First drop the stray per-iteration `echo` in `ab`'s loop (prints blank lines detached from the collected output; `all` already omits it). ~−16 lines. (`args_enumerators.zsh`, `args_keymap.zsh:84-133`)
3. **aws: fix stale `AWS_URL`** — computed at load time, but region setters (`ae1`/`aw2`/...) re-export `AWS_DEFAULT_REGION`, so `open` URLs mix old host with new `region=` param. Compute at call time (helper), delete the constant. 4 sites. (`aws_keymap.zsh:82,93,154,207,285`)
4. **kubectl/docker/terraform: shared pass-through dispatcher** — identical loop in all three keymap dispatchers. Add `keymap_passthrough <COMMANDS_ARRAY_NAME> "$@"` to `keymap_base.zsh`; keep `<binary> "$@"` at call sites. ~−10 lines.
5. **terraform: `th` delegates to `tn`** — `th` is `tn`'s body wrapped in pushd/popd. ~−5 lines. (`terraform_keymap.zsh:118-130`)
6. **usage: delete dead `num_days` guards in `ua`/`un`/`uu`** — `usage_helpers_filter_by_calendar_days` already treats empty/zero as "all days"; three siblings guard three different ways, four don't guard at all. (`usage_keymap.zsh:51,245,387`)
7. **usage: dedupe numeric-vs-match arg parse in `ua`/`un`** — identical 9-line block; extract `usage_helpers_days_or_match`. ~−8 lines. (`usage_keymap.zsh:40-48,234-242`)
8. **q: `qj`/`qk` delegate to `qc`** — both re-inline `q_keymap_4 --agent code` after cd. (`q_keymap.zsh:61-81`)
9. **Convention sweep (one pass):**
   - `github_keymap_p`: name `local pr=$1` (keep empty-arg → PR-list behavior)
   - `github_helpers_is_delimited`: name `$2` as a local
   - `args_history_decrement`: unused `local index`, raw `$1`, local shadows function name
   - `args_history_entries`: magic `-1` → `$ARGS_HISTORY_TAIL_NOT_SET`
   - `args_helpers.zsh:124,133`: stale comments naming nonexistent `nn`
   - `terraform_helpers_init`: checks `$1` right after `local options=$1`
   - `other_keymap_ii`: three dead top-of-function locals (match `oi`'s style)
   - `main_keymap.zsh:70,73`: `ZSHRC_LINES_OF_CODE`/`ZSHRC_LINE_COUNT` should be locals
   - `main_helpers.zsh:8`: `${(P)$(echo "$namespace")[@]}` → `"${(P@)namespace}"` (tested; `${(P)namespace[@]}` breaks, expanding to one empty element; correct idiom per `usage_keymap.zsh:84`)
   - `q_keymap_p`/`q_keymap_P`: plain `echo` for success/error → `green_bar`/`red_bar`

## Needs a decision first

- **aws: drop 17 redundant `--region "$AWS_DEFAULT_REGION"` flags?** The var is always exported and the CLI reads it. Risk: `AWS_REGION` (if exported by mqc/Britive tooling) outranks `AWS_DEFAULT_REGION`; the explicit flags are what pin the region. Confirm no tooling sets `AWS_REGION` before doing this.
- **q: `qp`/`qP` push/pull asymmetry** — push mirrors deletions (wipes scratch dir first); pull leaves orphaned subfolders in config. Make pull mirror, or document the difference. Optional: dedupe the shared copy-loop skeleton (~−8, needs a new q helpers file).
- **claude: `cu`/`cU` sync dedup** — same push/pull shape as q. Full merge would obscure a real intent difference (push wipes whole dir, pull per-folder); extract only the symmetric file+mcp copy loop if at all. Note `CLAUDE_KEYMAP_FOLDERS` is empty scaffolding, kept deliberately.
- **kubectl: `kh`/`kt` bail on empty args, `khh` lists all** — annotations say all three take optional `<match>*`. Probably drop the guards; confirm intended behavior.
- **claude: `cs`/`css` tab-color osascript dup** — tiny helper centralizes the RGB literals. Marginal; do if touching the file anyway.

## Reviewed, not worth doing

- github `domain`/`org` extractor dedup (~−2 lines, below bar)
- Wrapping `cd X && nav_keymap_n || true` one-liners; tiny pipeline extractions; test fixture dedup
- args undo/redo error-bar merge (needs `${(P)}` indirection, costs clarity)
- main_keymap dispatcher boilerplate (required by the framework's name-based dispatch)
