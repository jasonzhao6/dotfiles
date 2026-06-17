function nav_helpers_copied_file_path {
	# When a file path is copied as plain text
	local file; file=$(pbpaste | strip)

	# When a file path is copied as a Finder file reference
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

function nav_helpers_extract_frontmatter {
	# Extract frontmatter block with `---` delimiters included; guard against unclosed blocks
	awk '
		NR==1 && !/^---$/ { exit }
		NR==1             { buf=$0 ORS; next }
		/^---$/           { printf "%s%s", buf, $0; exit }
		                  { buf=buf $0 ORS }
	' "$1"
}

function nav_helpers_strip_frontmatter {
	# Strip frontmatter block if present
	awk '
		NR==1 && /^---$/ { infm=1; buf=$0 ORS; next }
		infm && /^---$/  { infm=0; next }
		infm             { buf=buf $0 ORS; next }
		{ print }
		END { if (infm) printf "%s", buf }
	' "$1"
}

function nav_helpers_render_frontmatter {
	local frontmatter; frontmatter=$(nav_helpers_extract_frontmatter "$1")
	[[ -z $frontmatter ]] && return

	# Customize how frontmatter is rendered
	print -r -- "$frontmatter" | fold -s -w 80 | perl -pe '
		s/^---$/\e[32m───\e[0m/;				 # Color delimiters green (32), replace "-" with "─"
		s/^([\w-]+)(:)/\e[32m$1\e[0m$2/; # Color keys green (32)
	'
	echo
}

function nav_helpers_dedent_tables {
	# mdcat 2.7.1 (its final release; the formula is deprecated) panics on a table
	# nested inside a list item, taking the rest of the document down with it. Dedent
	# table rows (lines starting with `|`, outside code fences) to the margin so mdcat
	# renders them as top-level tables it can handle.
	perl -ne '
		if (/^\s*```/) { $fence = !$fence; print; next }
		s/^\s+(\|)/$1/ unless $fence;
		print;
	'
}

function nav_helpers_render_markdown {
	# Customize how markdown is rendered
	nav_helpers_strip_frontmatter "$1" | nav_helpers_dedent_tables | mdcat --columns 80 | perl -pe '
		s/\xe2\x94\x84/#/g;      # Replace "┄" heading with "#"
		s/(#+)\e\[0m/$1 \e[0m/g; # Add a space after "#" headings
		s/\e\[34m/\e[36m/g;      # Color "#" headings cyan (36), was blue (34)

		# Shorten code delimiter length to 3; identify code delimiter via color green (32)
		s/\e\[32m(?:\xe2\x94\x80)+\e\[0m/\e[32m───\e[0m/g;

		# Color code body green (32), was yellow (33)
		if (/\e\[32m───\e\[0m/) { $in = !$in } elsif ($in) { s/\e\[33m/\e[32m/g }
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
	if [[ "$file" == ${~NAV_MD_FILE_EXTENSION} ]]; then
		nav_helpers_render_frontmatter "$file"
		nav_helpers_render_markdown "$file"
	else
		cat "$file"
	fi
}

function nav_helpers_render_cursor_as_file {
	local file; file="$(args_helpers_plain | sed -n "${NAV_CURSOR}p" | sed 's/ *#.*//' | strip)"

	nav_helpers_render_file "$file"
}
