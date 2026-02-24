# shellcheck disable=SC2034 # Used by `main_keymap.zsh`
CLAUDE_CODE_KEYMAP=(
	'! # Run bash command'
	'& # Queue instruction in the background'
	'/{skill}? # Invoke Claude command or skill'
	'@ # Reference a local file or folder'
	'ctrl-g # Interrupt and provide new instructions'
	'ctrl-j # Add newline'
	'ctrl-v # Paste image'
	'shift-{tab} # Cycle permission modes'
)
