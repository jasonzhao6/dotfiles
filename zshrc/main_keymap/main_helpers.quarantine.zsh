# The code blocks in this file were originally inlined in bigger methods. They were extracted and
# "quarantined" here b/c they were causing IntelliJ to get confused about how to parse the original
# methods. This broke syntax highlighting and file structure navigation.
#
# One thing that these methods have in common is the presence of `**`. It may be the culprit to
# IntelliJ's parsing confusion.

function main_keymap_grep_keymap_names {
	pgrep --only-matching "^[A-Z_]+_KEYMAP(?==\($)" "$ZSHRC_SRC_DIR"/**/*_keymap*.zsh |
		bw |
		sed 's/^[^:]*://'
}

function main_keymap_count_lines_of_code {
	egrep --invert-match '^\s*(#|$)' "$ZSHRC_SRC_DIR"/**/*.zsh | wc -l | strip_left
}

function main_keymap_count_lines {
	cat "$ZSHRC_SRC_DIR"/**/*.zsh | wc -l | strip_left
}
