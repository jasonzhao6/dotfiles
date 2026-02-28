# shellcheck disable=SC2034 # Used by `main_keymap.zsh`
CLAUDE_CODE_KEYMAP=(
	'! # Run bash command'
	'& # Run prompt in the background'
	'/{skill}? # Invoke Claude command or skill'
	'@ # Reference a local file or folder'
	'ctrl-g # Compose prompt in editor'
	'ctrl-j # Add newline'
	'ctrl-v # Paste image'
	'shift-{tab} # Cycle permission modes'
)
