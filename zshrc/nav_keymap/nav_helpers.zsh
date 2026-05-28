function nav_helpers_pbpaste_file_path {
	# Try `pbpaste` first (works for paths copied as text)
	local file; file=$(pbpaste | strip)

	# Fall back to AppKit for Finder copies (which are URL references, not text)
	if [[ ! -f $file && -z $ZSHRC_UNDER_TESTING ]]; then
		file=$(osascript -e '
			use framework "AppKit"
			set pb to current application'\''s NSPasteboard'\''s generalPasteboard()
			set fileURLs to pb'\''s readObjectsForClasses:{current application'\''s NSURL} options:(missing value)
			if (count of fileURLs) > 0 then
				return ((item 1 of fileURLs)'\''s |path|()) as text
			end if
		' 2>/dev/null)
	fi

	echo "$file"
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

function nav_helpers_render_file {
	local file=$1

	other_keymap_k

	local name=${file##*/}
	local rule; rule=$(printf '%0.s─' $(seq 1 ${#name}))
	magenta_fg "$rule"
	magenta_fg "$name"
	magenta_fg "$rule"

	echo
	if [[ "$file" == ${~NAV_MD_FILE_EXTENSION} ]]; then
		mdcat --columns 80 "$file" | perl -pe '
			s/\xe2\x94\x84/#/g;        # Replace heading leading ┄ dashes with `#`
			s/(#+)\e\[0m/$1 \e[0m/g;   # Append trailing space after `#`
			s/\e\[34m/\e[36m/g;        # Swap heading dark blue (34) for cyan (36)
			s/(?:\xe2\x94\x80)+/```/g; # Replace code fence ─ rules with ```
			s/\e\[32m/\e[33m/g;        # Swap code fence green (32) for yellow (33)
		'
	else
		cat "$file"
	fi
}

function nav_helpers_render_cursor_as_file {
	local file; file="$(args_helpers_plain | sed -n "${NAV_CURSOR}p" | sed 's/ *#.*//' | strip)"

	nav_helpers_render_file "$file"
}
