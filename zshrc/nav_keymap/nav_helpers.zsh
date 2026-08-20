function nav_helpers_copied_path {
	# When a path is copied as plain text
	# Note: Do not use `local path`- It will overwrite $PATH in subshell
	local target_path; target_path=$(pbpaste | strip)

	# Expand leading `~` to $HOME
	target_path=${target_path/#\~/$HOME}

	# Pasted paths can have trailing space-separated tokens (git branch, AWS
	# account, region, etc.). Strip the last token repeatedly until what remains
	# is a valid file or folder, or no valid path was found.
	local prev=''
	while [[ -n $target_path && ! -e $target_path && $target_path != "$prev" ]]; do
		prev=$target_path
		target_path=${target_path% *}
	done

	# When a file or folder is copied as a Finder reference
	if [[ ! -e $target_path && -z $ZSHRC_UNDER_TESTING ]]; then
		target_path=$(osascript -e '
			use framework "AppKit"
			set pb to current application'\''s NSPasteboard'\''s generalPasteboard()
			set fileURLs to pb'\''s readObjectsForClasses:{current application'\''s NSURL} options:(missing value)
			if (count of fileURLs) > 0 then
				return ((item 1 of fileURLs)'\''s |path|()) as text
			end if
		' 2>/dev/null)
	fi

	echo "$target_path"
}

function nav_helpers_list_siblings {
	local file=$1

	if [[ "$file" == .* ]]; then
		nav_keymap_a
	else
		nav_keymap_n
	fi
}

function nav_helpers_find_cursor {
	local file=$1

	args_helpers_plain | sed 's/ *#.*//' | strip | grep -nFx "$file" | head -1 | cut -d: -f1
}

function nav_helpers_mru_add {
	local entry=$1
	local existing=""

	if [[ -f "$NAV_MRU_FILE" ]]; then
		existing=$(grep -vFx "$entry" "$NAV_MRU_FILE" || true)
	fi

	if [[ -n "$existing" ]]; then
		printf '%s\n%s\n' "$entry" "$existing" > "$NAV_MRU_FILE"
	else
		echo "$entry" > "$NAV_MRU_FILE"
	fi
}

function nav_helpers_mru_prune {
	[[ -f "$NAV_MRU_FILE" ]] || return

	local kept="" line
	while IFS= read -r line || [[ -n "$line" ]]; do
		[[ -d "$line" ]] && kept+="$line"$'\n'
	done < "$NAV_MRU_FILE"

	if [[ -n "$kept" ]]; then
		printf '%s' "$kept" > "$NAV_MRU_FILE"
	else
		rm -f "$NAV_MRU_FILE"
	fi
}

function nav_helpers_populate_args_when_empty {
	# In a fresh shell with no args yet, act as if `nn` had just run
	[[ $(args_helpers_size) -eq 0 ]] || return 0

	nav_keymap_n > /dev/null
}

function nav_helpers_render_markdown {
	# Customize how markdown is rendered: `mdcat/config.toml` restyles headings
	# as magenta (35) `#` prefixes and link labels as cyan (36); perl handles the
	# rest. OSC 8 hyperlinks are kept: Terminal.app ignores them, hyperlink-
	# capable terminals make labels clickable
	# `--ansi` is required: mdcat sees the pipe to perl (not the terminal) as its
	# stdout and would otherwise emit plain text with no escapes for perl to match
	XDG_CONFIG_HOME="$NAV_MDCAT_CONFIG_HOME" mdcat --ansi "$1" | perl -pe '
		# Normalize vertical spacing: drop leading blank lines to avoid doubling
		# the banner/content separator `render_file` already printed, and
		# collapse blank runs to a single line
		if (/^$/) { $_ = "" if $blank || !$seen; $blank = 1 } else { $seen = 1; $blank = 0 }

		# H1 is the one heading `config.toml` cannot mark up, as mdcat takes a
		# marker for H2-H6 only. It renders a banner instead, padding the
		# heading with a space on either side of a background color (104).
		# Swap the leading pad for a `#` prefix, then drop the rest
		s/\e\[104m//g if s/^\e\[94m\e\[104m \e\[0m\e\[1m\e\[35m\e\[104m(.*)\e\[0m\e\[94m\e\[104m \e\[0m$/\e[1m\e[35m# $1\e[0m/;
	'
}

function nav_helpers_render_file {
	local file=$1

	other_keymap_k

	local name=${file##*/}
	local rule; rule=$(printf '%0.s─' $(seq 1 ${#name}))
	magenta_fg "$rule"
	magenta_fg "$name"
	magenta_fg "$rule"

	echo
	if [[ "$file" == *.md ]]; then
		nav_helpers_render_markdown "$file"
	else
		cat "$file"
	fi
}

function nav_helpers_render_cursor_as_file {
	local file; file="$(args_helpers_plain | sed -n "${NAV_CURSOR}p" | sed 's/ *#.*//' | strip)"

	nav_helpers_render_file "$file"
}
