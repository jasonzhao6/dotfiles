USAGE_NAMESPACE='usage_keymap'
USAGE_ALIAS='u'
USAGE_DOT="${USAGE_ALIAS}${KEYMAP_DOT}"

USAGE_KEYMAP=(
	"${USAGE_DOT}u <n>? # Usage overview, for last <n> calendar days (Default: All)"
	"${USAGE_DOT}d <n>? # Usage by day of week, for last <n> calendar days (Default: All)"
	"${USAGE_DOT}h <n>? # Usage by hour of day, for last <n> calendar days (Default: All)"
	''
	"${USAGE_DOT}n <n OR match>? # Top namespaces, for last <n> calendar days (Default: All)"
	"${USAGE_DOT}a <n OR match>? # Top aliases, for last <n> calendar days (Default: All)"
	''
	"${USAGE_DOT}m # Open usage file in TextMate"
	"${USAGE_DOT}c # Clear usage file"
	''
	"${USAGE_DOT}t <n> # Back up real data, generate test data for <n> calendar days"
	"${USAGE_DOT}tt # Restore real data from backup"
)

keymap_init $USAGE_NAMESPACE $USAGE_ALIAS "${USAGE_KEYMAP[@]}"

function usage_keymap {
	keymap_show $USAGE_NAMESPACE $USAGE_ALIAS ${#USAGE_KEYMAP} "${USAGE_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_SRC_DIR/$USAGE_NAMESPACE/usage_helpers.zsh"
source "$ZSHRC_SRC_DIR/$USAGE_NAMESPACE/usage_zsh_hook.zsh"

USAGE_KEYMAP_A_MAX_ROWS=15

function usage_keymap_a {
	# If numeric, treat as days; if string, treat as match
	local match='' num_days=0
	if [[ -n $1 ]]; then
		if [[ $1 =~ ^[0-9]+$ ]]; then
			num_days=$1
		else
			match=$1
		fi
	fi

	# Filter data
	local filtered; filtered=$(usage_helpers_filter_by_calendar_days "$([[ $num_days -gt 0 ]] && echo "$num_days")")

	# First pass: Collect counts and label widths
	local awk_counts
	awk_counts=$(echo "$filtered" | gawk -F'\t' \
		'{total[$2]++} END {for (a in total) printf "%s\t%d\n", a, total[a]}' \
		| sort -t$'\t' -k2 -rn)

	local grand_total=0
	local rows=()
	local max_alias_len=0
	local max_desc_len=0
	local max_count_len=0
	local a ns_alias key ns display_alias upper_ns desc entry entries count_len

	while IFS=$'\t' read -r a count; do
		ns_alias="${a:0:1}"
		key="${a:1}"
		ns="${aliases[$ns_alias]}"
		if [[ -n $key ]]; then
			display_alias="${ns_alias}.${key}"
		else
			display_alias="${ns_alias}"
		fi

		# Filter by match if specified
		if [[ -n $match ]]; then
			[[ "$a" != *"$match"* && "$display_alias" != *"$match"* ]] && continue
		fi

		# Look up description from the keymap array
		upper_ns="${ns:u}"
		entries=("${(P@)upper_ns}")
		desc=''
		if [[ -z $key ]]; then
			desc="Show this keymap: ${ns%%_*}"
		else
			for entry in "${entries[@]}"; do
				if [[ $entry == *"${KEYMAP_DOT}${key} "* && $entry == *" # "* ]]; then
					desc="${entry#*# }"
					break
				fi
			done
		fi
		grand_total=$((grand_total + count))
		[[ ${#rows} -ge $USAGE_KEYMAP_A_MAX_ROWS ]] && continue
		rows+=("${a}	${display_alias}	${desc}	${count}")

		[[ ${#display_alias} -gt $max_alias_len ]] && max_alias_len=${#display_alias}
		[[ ${#desc} -gt $max_desc_len ]] && max_desc_len=${#desc}
		count_len=${#count}
		[[ $count_len -gt $max_count_len ]] && max_count_len=$count_len
	done <<< "$awk_counts"

	[[ ${#rows} -eq 0 ]] && { red_bar "No alias matching \`$match\`"; return; }

	# Second pass: Compute sparkline width and generate sparklines
	local label_width=$(( 2 + max_alias_len + 2 + max_desc_len + 2 + max_count_len + 2 ))
	local sparkline_width=$(( COLUMNS - label_width - 1 ))
	[[ $sparkline_width -lt 1 ]] && sparkline_width=1
	local sparkline_output
	sparkline_output=$(echo "$filtered" | usage_helpers_sparklines "$sparkline_width" alias)

	# Parse sparklines into a map: alias -> sparkline
	local -A sparkline_map
	local label_line
	while IFS=$'\t' read -r group_key sparkline_str; do
		sparkline_map[$group_key]="$sparkline_str"
	done <<< "$sparkline_output"
	label_line="${sparkline_map[_labels]}"
	local gran_line="${sparkline_map[_gran]}"
	unset 'sparkline_map[_labels]' 'sparkline_map[_gran]'

	echo
	echo "$filtered" | usage_helpers_stats

	# Print rows with sparklines
	echo
	local rest is_first=1
	for row in "${rows[@]}"; do
		a="${row%%	*}"
		rest="${row#*	}"
		display_alias="${rest%%	*}"
		rest="${rest#*	}"
		desc="${rest%%	*}"
		count="${rest#*	}"

		# Print label above first row if rows exceed screen height
		if [[ $is_first -eq 1 ]]; then
			if [[ ${#rows} -ge $LINES ]]; then
				printf "  %-*s  %-*s  %*s  %s\n" \
					"$max_alias_len" "" "$max_desc_len" "" "$max_count_len" "" "$label_line"
			fi
			is_first=0
		fi

		printf "  %-*s  %-*s  %*s  %s\n" \
			"$max_alias_len" "$display_alias" \
			"$max_desc_len" "$desc" \
			"$max_count_len" "$count" \
			"${sparkline_map[$a]}"
	done

	# Print date range and granularity below last row
	printf "  %-*s  %-*s  %*s  %s\n" \
		"$max_alias_len" "" "$max_desc_len" "" "$max_count_len" "" "$label_line"
	printf "  %-*s  %-*s  %*s  %s\n" \
		"$max_alias_len" "" "$max_desc_len" "" "$max_count_len" "" "$gran_line"
}

function usage_keymap_c {
	if [[ ! -f $KEYMAP_USAGE_FILE ]]; then
		red_bar 'No usage file to clear'
		return
	fi

	local count; count=$(wc -l < "$KEYMAP_USAGE_FILE" | tr -d ' ')
	: > "$KEYMAP_USAGE_FILE"
	green_bar "Cleared $count entries"
}

function usage_keymap_d {
	local num_days=$1
	local filtered; filtered=$(usage_helpers_filter_by_calendar_days "$num_days")

	echo
	echo "$filtered" | usage_helpers_stats
	echo

	local day_names=('Mon' 'Tue' 'Wed' 'Thu' 'Fri' 'Sat' 'Sun')
	echo "$filtered" | gawk -F'\t' '
	{
		dow = strftime("%u", $1)
		counts[dow]++
	}
	END {
		for (i = 1; i <= 7; i++) {
			printf "%d: %d\n", i, counts[i] + 0
		}
	}' | while IFS=':' read -r dow count; do
		printf "%s: %s\n" "${day_names[$dow]}" "${count# }"
	done | usage_helpers_horizontal_bars
}

function usage_keymap_h {
	local num_days=$1
	local filtered; filtered=$(usage_helpers_filter_by_calendar_days "$num_days")

	echo
	echo "$filtered" | usage_helpers_stats
	echo

	echo "$filtered" | gawk -F'\t' '
	{
		hour = strftime("%H", $1)
		counts[hour]++
	}
	END {
		for (i = 0; i < 24; i++) {
			printf "%02d: %d\n", i, counts[sprintf("%02d", i)] + 0
		}
	}' | usage_helpers_horizontal_bars
}

function usage_keymap_m {
	if [[ ! -f $KEYMAP_USAGE_FILE ]]; then
		red_bar 'No usage file'
		return
	fi

	mate "$KEYMAP_USAGE_FILE"
}

function usage_keymap_n {
	# If numeric, treat as days; if string, treat as match
	local match='' num_days=0
	if [[ -n $1 ]]; then
		if [[ $1 =~ ^[0-9]+$ ]]; then
			num_days=$1
		else
			match=$1
		fi
	fi

	# Filter data
	local filtered; filtered=$(usage_helpers_filter_by_calendar_days "$([[ $num_days -gt 0 ]] && echo "$num_days")")

	# First pass: Collect counts and label widths
	local awk_counts
	awk_counts=$(echo "$filtered" | gawk -F'\t' \
		'{total[substr($2,1,1)]++} END {for (a in total) printf "%s\t%d\n", a, total[a]}' \
		| sort -t$'\t' -k2 -rn)

	local grand_total=0
	local rows=()
	local max_name_len=0
	local max_count_len=0

	local display_name count_len
	while IFS=$'\t' read -r ns_alias count; do
		display_name="${aliases[$ns_alias]%%_*}"

		# Filter by match if specified
		if [[ -n $match ]]; then
			[[ $display_name != *"$match"* ]] && continue
		fi

		rows+=("${ns_alias}	${display_name}	${count}")
		grand_total=$((grand_total + count))
		[[ ${#display_name} -gt $max_name_len ]] && max_name_len=${#display_name}
		count_len=${#count}
		[[ $count_len -gt $max_count_len ]] && max_count_len=$count_len
	done <<< "$awk_counts"

	[[ ${#rows} -eq 0 ]] && { red_bar "No namespace matching \`$match\`"; return; }

	# Second pass: Compute sparkline width and generate sparklines
	local label_width=$(( 2 + max_name_len + 2 + max_count_len + 2 ))
	local sparkline_width=$(( COLUMNS - label_width - 1 ))
	[[ $sparkline_width -lt 1 ]] && sparkline_width=1
	local sparkline_output
	sparkline_output=$(echo "$filtered" | usage_helpers_sparklines "$sparkline_width" namespace)

	# Parse sparklines into a map: ns_alias -> sparkline
	local -A sparkline_map
	local label_line
	while IFS=$'\t' read -r group_key sparkline_str; do
		sparkline_map[$group_key]="$sparkline_str"
	done <<< "$sparkline_output"
	label_line="${sparkline_map[_labels]}"
	local gran_line="${sparkline_map[_gran]}"
	unset 'sparkline_map[_labels]' 'sparkline_map[_gran]'

	echo
	echo "$filtered" | usage_helpers_stats

	# Print rows with sparklines
	echo
	local ns_alias count rest is_first=1
	for row in "${rows[@]}"; do
		ns_alias="${row%%	*}"
		rest="${row#*	}"
		display_name="${rest%%	*}"
		count="${rest#*	}"

		# Print label above first row if rows exceed screen height
		if [[ $is_first -eq 1 ]]; then
			if [[ ${#rows} -ge $LINES ]]; then
				printf "  %-*s  %*s  %s\n" "$max_name_len" "" "$max_count_len" "" "$label_line"
			fi
			is_first=0
		fi

		printf "  %-*s  %*s  %s\n" "$max_name_len" "$display_name" "$max_count_len" "$count" "${sparkline_map[$ns_alias]}"
	done

	# Print date range and granularity below last row
	printf "  %-*s  %*s  %s\n" "$max_name_len" "" "$max_count_len" "" "$label_line"
	printf "  %-*s  %*s  %s\n" "$max_name_len" "" "$max_count_len" "" "$gran_line"
}

function usage_keymap_t {
	local days=$1

	if [[ -z $days ]]; then
		red_bar 'Required: <n> days'
		return
	fi

	# Back up real data (skip if backup already exists from a previous run)
	local backup_msg
	if [[ -f ${KEYMAP_USAGE_FILE}.bak ]]; then
		backup_msg='Kept backup'
	elif [[ ! -s $KEYMAP_USAGE_FILE ]]; then
		red_bar 'No usage data to back up'
		return
	else
		cp "$KEYMAP_USAGE_FILE" "${KEYMAP_USAGE_FILE}.bak"
		backup_msg='Backed up'
	fi

	# Collect all real keymap aliases
	local real_aliases=()
	local a
	for a in "${(@k)aliases}"; do
		[[ ${aliases[$a]} == *_keymap* ]] && real_aliases+=("$a")
	done

	local now; now=$(gdate +%s)
	local day_seconds=86400
	local midnight; midnight=$(gdate -d "today 00:00:00" +%s)
	local seconds_today=$(( now - midnight ))
	local num_aliases=${#real_aliases}

	: > "$KEYMAP_USAGE_FILE"
	for (( day = days - 1; day >= 0; day-- )); do
		local base_ts=$(( midnight - day * day_seconds ))
		local range=$day_seconds
		[[ $day -eq 0 ]] && range=$seconds_today
		[[ $range -lt 1 ]] && range=1
		# Generate 0-30 entries per day
		local count=$(( RANDOM % 31 ))
		for (( j = 0; j < count; j++ )); do
			local ts=$(( base_ts + RANDOM % range ))
			local alias_pick=${real_aliases[$(( RANDOM % num_aliases + 1 ))]}
			printf '%s\t%s\n' "$ts" "$alias_pick" >> "$KEYMAP_USAGE_FILE"
		done
	done
	sort -t$'\t' -k1 -n -o "$KEYMAP_USAGE_FILE" "$KEYMAP_USAGE_FILE"

	local total; total=$(wc -l < "$KEYMAP_USAGE_FILE" | tr -d ' ')
	green_bar "${backup_msg}, generated $total entries for $days days"
}

function usage_keymap_tt {
	if [[ ! -f ${KEYMAP_USAGE_FILE}.bak ]]; then
		red_bar 'No backup to restore'
		return
	fi

	mv "${KEYMAP_USAGE_FILE}.bak" "$KEYMAP_USAGE_FILE"
	green_bar 'Restored real data from backup'
}

function usage_keymap_u {
	local num_days=$1
	[[ -n $num_days && $num_days -le 0 ]] && num_days=''

	local filtered; filtered=$(usage_helpers_filter_by_calendar_days "$num_days")
	local sparkline_width=$(( COLUMNS - 5 ))
	[[ $sparkline_width -lt 1 ]] && sparkline_width=1

	# Generate sparkline
	local sparkline_output
	sparkline_output=$(echo "$filtered" | usage_helpers_sparklines "$sparkline_width" all)
	# Parse: "all\tsparkline", "_labels\tdate_range", "_gran\tgranularity"
	local -A uu_map
	while IFS=$'\t' read -r key val; do
		uu_map[$key]="$val"
	done <<< "$sparkline_output"

	echo
	echo "$filtered" | usage_helpers_stats
	echo

	echo "  ${uu_map[all]}"
	printf "  %s\n" "${uu_map[_labels]}"
	printf "  %s\n" "${uu_map[_gran]}"
}
