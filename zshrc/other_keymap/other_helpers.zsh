function other_helpers_reset_terminal_dump_dir {
	# shellcheck disable=SC2034 # Used by `other_keymap.zsh`
	OTHER_TERMINAL_DUMP_DIR="$ZSHRC_DATA_DIR/other.terminal-dump.d"
}; other_helpers_reset_terminal_dump_dir

# Strip content that is slow or useless to hear, e.g. urls, before piping into `say`
function other_helpers_speakable {
	perl -CSD -0777 -pe '
		# Fenced code blocks -> spoken placeholder
		s/^[ \t]*(`{3,}|~{3,}).*?^[ \t]*\1[ \t]*$/code block./gms;

		# Markdown links and images -> keep the label only
		s/!?\[([^\]]*)\]\([^)]*\)/$1/g;

		# Bare urls -> spoken placeholder
		s{(?:https?://|www\.)\S+}{link}g;

		# UUIDs and long hex hashes -> spoken placeholders
		# Hashes must contain a digit and a hex letter to spare words and plain numbers
		s/\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b/ID/gi;
		s/\b(?=[0-9a-f]*\d)(?=[0-9a-f]*[a-f])[0-9a-f]{7,}\b/hash/gi;

		# File paths -> basename
		# Relative paths need 2+ slashes and a letter to spare fractions and dates
		s{(?<![\w.@+-])(?:~|\.{1,2})?/(?:[\w.@+-]+/)+([\w.@+-]+)/?}{$1}g;
		s{\b(?=\S*[a-z])(?:[\w.@+-]+/){2,}([\w.@+-]+)}{$1}gi;

		# Markdown table divider rows, then pipes -> comma pauses
		s/^[ \t]*\|[ \t:|-]*\|[ \t]*$//gm;
		s/^[ \t]*\|[ \t]*//gm;
		s/[ \t]*\|[ \t]*$//gm;
		s/[ \t]*\|[ \t]*/, /g;

		# Separator lines, e.g. `===` and `---`
		s/^[ \t]*[-=_*~#]{3,}[ \t]*$//gm;

		# Markdown syntax: headers, blockquotes, bullets, emphasis, inline code
		s/^[ \t]*#{1,6}[ \t]+//gm;
		s/^[ \t]*(?:>[ \t]?)+//gm;
		s/^([ \t]*)[-*+][ \t]+/$1/gm;
		s/[*`]//g;

		# Emoji, arrows, dingbats, and other pictographs
		s/[\x{1F000}-\x{1FAFF}\x{2190}-\x{21FF}\x{2300}-\x{27BF}\x{2B00}-\x{2BFF}\x{FE00}-\x{FE0F}\x{200D}\x{20E3}\x{2022}]//g;

		# Box drawing and block elements
		s/[\x{2500}-\x{259F}]//g;

		# Collapse leftover whitespace
		s/[ \t]{2,}/ /g;
		s/^[ \t]+//gm;
		s/[ \t]+$//gm;
		s/\n{3,}/\n\n/g;
	'
}
