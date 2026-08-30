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

function nav_helpers_cd_if_only_match {
	if [[ $(args_history_current | wc -l | tr -d ' ') -eq 1 ]]; then
		echo; dashes 5
		cd "$(args_history_current | bw)" && nav_keymap_n || true
	fi
}

function nav_helpers_find_cursor {
	local file=$1

	args_helpers_plain | sed 's/ *#.*//' | strip | grep -nFx "$file" | head -1 | cut -d: -f1
}

function nav_helpers_history_add {
	local entry=$1

	# Skip if same as last entry
	if [[ -f "$NAV_HISTORY_FILE" ]]; then
		local last; last=$(tail -1 "$NAV_HISTORY_FILE")
		if [[ "$last" == "$entry" ]]; then
			return
		fi
	fi

	# Append entry
	echo "$entry" >> "$NAV_HISTORY_FILE"

	# Trim to max entries if needed (keep newest)
	if [[ -f "$NAV_HISTORY_FILE" ]]; then
		local count; count=$(wc -l < "$NAV_HISTORY_FILE" | tr -d ' ')
		if [[ $count -gt $NAV_HISTORY_MAX ]]; then
			local kept; kept=$(tail -n "$NAV_HISTORY_MAX" "$NAV_HISTORY_FILE")
			printf '%s\n' "$kept" > "$NAV_HISTORY_FILE"
		fi
	fi
}

function nav_helpers_shortlist_prune {
	[[ -f "$NAV_SHORTLIST_FILE" ]] || return

	local kept="" line
	while IFS= read -r line || [[ -n "$line" ]]; do
		[[ -d "$line" ]] && kept+="$line"$'\n'
	done < "$NAV_SHORTLIST_FILE"

	if [[ -n "$kept" ]]; then
		printf '%s' "$kept" > "$NAV_SHORTLIST_FILE"
	else
		rm -f "$NAV_SHORTLIST_FILE"
	fi
}

function nav_helpers_populate_args_when_empty {
	# In a fresh shell with no args yet, act as if `nn` had just run
	[[ $(args_helpers_size) -eq 0 ]] || return 0

	nav_keymap_n > /dev/null
}

function nav_helpers_render_csv {
	local file=$1

	perl -e '
		my (@rows, @width);

		# Bytes stay bytes, so a cell in a non-UTF-8 encoding renders as-is;
		# `width` counts characters instead, skipping the continuation bytes
		# (0x80-0xBF) that tail a multi-byte character rather than being one
		sub width { my $count = () = $_[0] =~ /[^\x80-\xBF]/g; $count }

		while (my $line = <STDIN>) {
			chomp $line;

			# Split on commas outside double quotes, unquoting a quoted cell
			my @cells;
			while ($line =~ /\G(?:"((?:[^"]|"")*)"|([^,]*))(,|\z)/gc) {
				push @cells, defined $1 ? $1 =~ s/""/"/gr : $2;
				last if $3 eq "";
			}

			for my $i (0 .. $#cells) {
				$width[$i] = width($cells[$i]) if width($cells[$i]) > ($width[$i] // 0);
			}

			push @rows, \@cells;
		}

		exit unless @rows;

		# Pad each cell to its column, so one holding spaces or commas still
		# reads as a single value; pad each row out to the widest, so a short
		# row still shows its empty cells
		my @padded = map {
			my @cells = @$_;
			push @cells, "" while @cells < @width;
			join " │ ", map { $cells[$_] . " " x ($width[$_] - width($cells[$_])) } 0 .. $#width;
		} @rows;

		my $rule = join "─┼─", map { "─" x $_ } @width;

		for my $i (0 .. $#padded) {
			my $line = $padded[$i];
			$line =~ s/ +$//;

			# Row 1 is the header: gray (90) cells and separators.
			# Every other row leaves its cells the terminal color
			if ($i == 0) {
				$line =~ s/│/\e[90m│\e[90m/g;
				print "\e[90m$line\e[0m\n\e[90m$rule\e[0m\n";
			} else {
				$line =~ s/│/\e[90m│\e[0m/g;
				print "$line\n";
			}
		}
	' < "$file"
}

function nav_helpers_render_markdown {
  # Render markdown via mdcat, with custom styling from `mdcat/config.toml`
	XDG_CONFIG_HOME="$NAV_MDCAT_CONFIG_HOME" mdcat --ansi "$1" | perl -pe '
		# Drop leading blank lines; also collapse consecutive blank lines to one
		if (/^$/) { $_ = "" if $blank || !$seen; $blank = 1 } else { $seen = 1; $blank = 0 }

		# `config.toml` can configure H2-H6 styles, but not H1
		# Convert H1 style from banner to a simple `# <heading>`
		s/\e\[104m//g if s/^\e\[94m\e\[104m \e\[0m\e\[1m\e\[35m\e\[104m(.*)\e\[0m\e\[94m\e\[104m \e\[0m$/\e[1m\e[35m# $1\e[0m/;
	'
}

function nav_helpers_scroll_to_top {
	# Simulates Cmd+Up (Cocoa's "scroll to top of document"), so long files
	# don't leave the terminal scrolled to their tail. Requires Terminal to
	# be granted Accessibility access under System Settings
	[[ -n $ZSHRC_UNDER_TESTING ]] && return

	if ! osascript -e 'tell application "System Events" to key code 126 using {command down}' &> /dev/null; then
		red_bar 'System Settings → Privacy & Security → Accessibility → Terminal: On'
	fi
}

# Uses NAV_CURSOR, instead of local arg, so nv/nj/nk/nr can navigate from the same position
function nav_helpers_render_cursor_as_file {
	local scroll_to_top=${1:-true}
	local file; file="$(args_helpers_plain | sed -n "${NAV_CURSOR}p" | sed 's/ *#.*//' | strip)"

	other_keymap_k

	local name=${file##*/}
	local rule; rule=$(printf '%0.s─' $(seq 1 ${#name}))
	magenta_fg "$rule"
	magenta_fg "$name"
	magenta_fg "$rule"

	echo
	if [[ "$file" == *.csv ]]; then
		nav_helpers_render_csv "$file"
	elif [[ "$file" == *.json ]]; then
		jq '.' "$file"
	elif [[ "$file" == *.md ]]; then
		nav_helpers_render_markdown "$file"
	else
		cat "$file"
	fi

	[[ $scroll_to_top == true ]] && nav_helpers_scroll_to_top
}
