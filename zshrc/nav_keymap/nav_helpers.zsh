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
		NR==1 && /^---$/ { in_fm=1; buf=$0 ORS; next }
		in_fm && /^---$/  { in_fm=0; next }
		in_fm             { buf=buf $0 ORS; next }
		{ print }
		END { if (in_fm) printf "%s", buf }
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
	nav_helpers_strip_frontmatter "$1" | nav_helpers_dedent_tables | mdcat --columns 80 | PHYS_PWD=${PWD:A} perl -pe '
		s/\xe2\x94\x84/#/g;      # Replace "┄" heading with "#"
		s/(#+)\e\[0m/$1 \e[0m/g; # Add a space after "#" headings

		# Render links as "label <url>", label magenta (35) and url gray (90).
		# Drop the OSC 8 hyperlinks that Terminal.app ignores. Autolinks render as
		# just the gray URL (their text is the URL, modulo mdcat adding a trailing
		# slash), and file:// URLs (mdcat-resolved relative links) shorten back to
		# relative paths. rel() matches against PHYS_PWD (${PWD:A}) because mdcat
		# emits physical paths while $PWD stays logical under a symlinked cwd.
		# Links arrive blue (34) like headings, so recolor them before the heading
		# recolor below claims the remaining blues.
		sub rel { my ($u) = @_; $u =~ s,^file://[^/]*\Q$ENV{PHYS_PWD}\E/,,; $u }
		s{\e\]8;;([^\e]+)\e\\(.*?)\e\]8;;\e\\}{
			my ($u, $body) = ($1, $2); $u = rel($u); # copy $2 before rel() resets captures
			(my $plain = $body) =~ s/\e\[[0-9;]*m//g;
			if ($plain eq $u || "$plain/" eq $u) { $body =~ s/\e\[34m/\e[90m/g; $body }
			else { $body =~ s/\e\[34m/\e[35m/g; "$body \e[90m<$u>\e[0m" }
		}ge;

		# A link wrapped across lines leaves its OSC 8 open/close on different lines,
		# beyond the reach of the substitution above, so handle its tokens statefully.
		# (A wrapped autolink lands here too and renders its URL twice; rare, accepted.)
		$_ = join "", map {
			if (/^\e\]8;;([^\e]+)\e\\$/) { $url = rel($1); "" }
			elsif (/^\e\]8;;\e\\$/)      { my $t = " \e[90m<$url>\e[0m"; $url = ""; $t }
			else                         { s/\e\[34m/\e[35m/g if $url; $_ }
		} split /(\e\]8;;[^\e]*\e\\)/;

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
	if [[ "$file" == *.md ]]; then
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
