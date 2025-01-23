# shellcheck disable=SC2034 # Used by `main_keymap.zsh`
TEXTMATE_KEYMAP=(
	'cmd-ctrl-alt-d # Toggle file browser'
	'cmd-alt-<tab> # Toggle file browser focus'
	'cmd-a alt-<left> # Collapse file browser'
	'cmd-ctrl-r # Locate the current file'
	'cmd-<left> # Go back'
	'cmd-<right> # Go forward'
	'cmd-<up> # Go up'
	'cmd-<down> # Go into/open (cmd-o)'
	'cmd-alt-i # Toggle invisible files'
	'<enter> # Rename'
	''
	'cmd-t # Jump to file'
	'cmd-shift-t # Jump to symbol'
	'cmd-alt-<0-9> # Toggle each folding level'
	''
	'cmd-f # Search this file'
	'cmd-shift-f # Search this project'
	'cmd-alt-f # Find all'
	'cmd-alt-r # Toggle regex'
	'cmd-alt-c # Toggle ignore case'
	'cmd-alt-a # Toggle wrap around'
	'cmd-<number> # Go to search result by number'
	''
	'alt # Multi-select'
	'ctrl-w # Select this word'
	'ctrl-w # Select next match'
	'shift-shift # Unselect last match'
	'cmd-e cmd-alt-f # Select all matches'
	''
	'ctrl-shift-d # Duplicate line'
	'ctrl-shift-k # Delete line'
	'cmd-shift-l # Select line'
	'cmd-shift-b # Select parent block'
	''
	'ctrl-g # Toggle case'
	'ctrl-u # Upcase'
	'ctrl-shift-u # Downcase'
	'ctrl-shift-c # Do math'
	'ctrl-shift-{ # Toggle `{}` and `do; end`'
	'cmd-alt-] # Align variable assignments'
	'cmd-alt-i # Toggle invisible characters'
	'ctrl-q # Align comment line lengths'
	''
	'cmd-ctrl-<tab> # Change file type'
	'cmd-r # Run file'
	''
	'cmd-ctrl-w # Close other tabs'
	'cmd-ctrl-alt-w # Close all tabs'
	'cmd-shift-w # Close project'
)
