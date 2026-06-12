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

function nav_helpers_extract_frontmatter {
	# The block, `---` delimiters included. Buffer and emit on the closing `---`,
	# so an unclosed opener yields nothing.
	awk '
		NR==1 && !/^---$/ { exit }
		NR==1             { buf=$0 ORS; next }
		/^---$/           { printf "%s%s", buf, $0; exit }
		                  { buf=buf $0 ORS }
	' "$1"
}

function nav_helpers_strip_frontmatter {
	# The body with a closed block removed; the whole file otherwise.
	awk '
		NR==1 && /^---$/ { infm=1; buf=$0 ORS; next }
		infm && /^---$/  { infm=0; next }
		infm             { buf=buf $0 ORS; next }
		{ print }
		END { if (infm) printf "%s", buf }
	' "$1"
}

function nav_helpers_render_frontmatter {
	# Render frontmatter as a metadata header: the `---` delimiters and each key
	# (text before the first `:`) in yellow, values reflowed to mdcat's width. We
	# render it ourselves rather than via mdcat, which draws ─ rules around code
	# blocks and turns a bare `---` into a heading. Fold before coloring so fold
	# ignores the escape bytes.
	local frontmatter; frontmatter=$(nav_helpers_extract_frontmatter "$1")
	[[ -z $frontmatter ]] && return

	print -r -- "$frontmatter" | fold -s -w 80 | perl -pe '
		s/^(---)$/\e[33m$1\e[0m/;         # delimiters
		s/^([\w-]+)(:)/\e[33m$1\e[0m$2/;  # keys
	'
	echo
}

function nav_helpers_render_markdown {
	# Render the body through mdcat, rewriting its box-drawing output back into
	# markdown-ish glyphs (┄ heading prefix -> #, ─ code-fence rules -> ```) and
	# recoloring headings cyan and code yellow.
	nav_helpers_strip_frontmatter "$1" | mdcat --columns 80 | perl -pe '
		s/\xe2\x94\x84/#/g;        # Replace heading leading ┄ dashes with `#`
		s/(#+)\e\[0m/$1 \e[0m/g;   # Append trailing space after `#`
		s/\e\[34m/\e[36m/g;        # Swap heading dark blue (34) for cyan (36)
		s/(?:\xe2\x94\x80)+/```/g; # Replace code fence ─ rules with ```
		s/\e\[32m/\e[33m/g;        # Swap code fence green (32) for yellow (33)
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
