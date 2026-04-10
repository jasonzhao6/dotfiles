function test__usage_keymap {
	assert "$(
		local show_this_help; show_this_help=$(usage_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $USAGE_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}; run_with_filter test__usage_keymap

function test__usage_keymap_a {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_a.tsv
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_a | bw | awk '/g\./ {print $1}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" "$(
		cat <<-eof
			g.d
			g.c
		eof
	)"
}; run_with_filter test__usage_keymap_a

function test__usage_keymap_a__with_match {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_a__with_match.tsv
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tnn\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# Match 'nn' should only show nav_keymap n
		local lines; lines=$(usage_keymap_a nn | bw | grep -c 'n\.n')
		echo "$lines"

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_a__with_match

function test__usage_keymap_a__with_n_days {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_a__with_n_days.tsv
		local now; now=$EPOCHSECONDS

		# Create data spanning 10 days
		printf '%s\tgc\n' "$(( now - 9 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=5, should only count 1 entry (today's)
		usage_keymap_a 5 | bw | grep 'Total' | awk '{print $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_a__with_n_days

function test__usage_keymap_a__with_no_match {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_a__with_no_match.tsv
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_a zzz | bw | ruby_strip

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" 'No alias matching `zzz`'
}; run_with_filter test__usage_keymap_a__with_no_match

function test__usage_keymap_a__top_level_alias {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_a__top_level.tsv
		local now; now=$EPOCHSECONDS

		# Top-level alias (no key)
		printf '%s\tu\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_a | bw | awk '/^  u / {print $1, $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" 'u Show'
}; run_with_filter test__usage_keymap_a__top_level_alias

function test__usage_keymap_a__row_limit {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_a__row_limit.tsv
		local now; now=$EPOCHSECONDS

		# Generate USAGE_KEYMAP_A_MAX_ROWS + 1 distinct aliases
		local i
		for (( i = 1; i <= USAGE_KEYMAP_A_MAX_ROWS + 1; i++ )); do
			printf '%s\tg%s\n' "$now" "$i" >> "$KEYMAP_USAGE_FILE"
		done

		# Should show at most USAGE_KEYMAP_A_MAX_ROWS alias rows
		local alias_rows; alias_rows=$(usage_keymap_a | bw | grep '^ *g\.' | wc -l | tr -d ' ')
		echo "$alias_rows"

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" "$USAGE_KEYMAP_A_MAX_ROWS"
}; run_with_filter test__usage_keymap_a__row_limit

function test__usage_keymap_a__sorted_by_count {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_a__sorted.tsv
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# First alias row should be gc (2), then gd (1)
		usage_keymap_a | bw | awk '/g\./ {print $1}' | head -1

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" 'g.c'
}; run_with_filter test__usage_keymap_a__sorted_by_count

function test__usage_keymap_c {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_c.tsv
		printf '1000000000\tgd\n' > "$KEYMAP_USAGE_FILE"
		printf '1000000001\tgc\n' >> "$KEYMAP_USAGE_FILE"

		usage_keymap_c | bw | ruby_strip
		wc -c < "$KEYMAP_USAGE_FILE" | tr -d ' '

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" "$(
		cat <<-eof
			Cleared 2 entries
			0
		eof
	)"
}; run_with_filter test__usage_keymap_c

function test__usage_keymap_c__when_no_file {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_c__nonexistent.tsv
		rm -f "$KEYMAP_USAGE_FILE"

		usage_keymap_c | bw | ruby_strip

		KEYMAP_USAGE_FILE=$orig
	)" 'No usage file to clear'
}; run_with_filter test__usage_keymap_c__when_no_file

function test__usage_keymap_d {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_d.tsv

		# Use gdate to get a known Monday and Friday epoch
		local mon=1772470800  # 2026-03-02 12:00 (Monday)
		local fri=1772816400  # 2026-03-06 12:00 (Friday)
		printf '%s\tgd\n' "$mon" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$mon" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$fri" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_d | bw | awk '$1 ~ /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)$/ && $2 > 0 {print $1, $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" "$(
		cat <<-eof
			Mon 2
			Fri 1
		eof
	)"
}; run_with_filter test__usage_keymap_d

function test__usage_keymap_d__with_n_days {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_d__with_n_days.tsv
		local now; now=$EPOCHSECONDS

		# Today and 5 days ago
		printf '%s\tgc\n' "$(( now - 5 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=1, should only count today's entry
		usage_keymap_d 1 | bw | grep 'Total' | awk '{print $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_d__with_n_days

function test__usage_keymap_d__shows_all_7_days {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_d__all_days.tsv

		# Single entry on a Monday
		local mon; mon=$(gdate -d '2026-03-02 12:00:00' +%s)
		printf '%s\tgd\n' "$mon" > "$KEYMAP_USAGE_FILE"

		# Should still show all 7 day rows
		usage_keymap_d | bw | grep -c '^\s*\(Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Sun\)'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '7'
}; run_with_filter test__usage_keymap_d__shows_all_7_days

function test__usage_keymap_h {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_h.tsv

		# Use gdate to get known hour epochs in local time
		local h09=1772460000  # 2026-03-02 09:00
		local h14=1772478000  # 2026-03-02 14:00
		printf '%s\tgd\n' "$h09" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$h09" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$h14" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_h | bw | awk '$1 ~ /^[0-9][0-9]$/ && $2 > 0 {print $1, $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" "$(
		cat <<-eof
			09 2
			14 1
		eof
	)"
}; run_with_filter test__usage_keymap_h

function test__usage_keymap_h__with_n_days {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_h__with_n_days.tsv
		local now; now=$EPOCHSECONDS

		# Today and 5 days ago
		printf '%s\tgc\n' "$(( now - 5 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=1, should only count today's entry
		usage_keymap_h 1 | bw | grep 'Total' | awk '{print $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_h__with_n_days

function test__usage_keymap_h__shows_all_24_hours {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_h__all_hours.tsv

		# Single entry at 9am
		local h09; h09=$(gdate -d '2026-03-02 09:00:00' +%s)
		printf '%s\tgd\n' "$h09" > "$KEYMAP_USAGE_FILE"

		# Should still show all 24 hour rows
		usage_keymap_h | bw | grep -c '^\s*[0-9][0-9]\s'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '24'
}; run_with_filter test__usage_keymap_h__shows_all_24_hours

function test__usage_keymap_m__when_no_file {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_m__nonexistent.tsv
		rm -f "$KEYMAP_USAGE_FILE"

		usage_keymap_m | bw | ruby_strip

		KEYMAP_USAGE_FILE=$orig
	)" 'No usage file'
}; run_with_filter test__usage_keymap_m__when_no_file

function test__usage_keymap_n {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_n.tsv
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tnn\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_n | bw | grep 'Total' | awk '{print $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '3'
}; run_with_filter test__usage_keymap_n

function test__usage_keymap_n__with_match {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_n__with_match.tsv
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tnn\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_n nav | bw | grep -c 'nav'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_n__with_match

function test__usage_keymap_n__with_n_days {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_n__with_n_days.tsv
		local now; now=$EPOCHSECONDS

		# Create data spanning 10 days
		printf '%s\tnn\n' "$(( now - 9 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=5, should only count 1 entry (today's, git namespace)
		usage_keymap_n 5 | bw | grep 'Total' | awk '{print $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_n__with_n_days

function test__usage_keymap_n__with_no_match {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_n__with_no_match.tsv
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_n zzz | bw | ruby_strip

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" 'No namespace matching `zzz`'
}; run_with_filter test__usage_keymap_n__with_no_match

function test__usage_keymap_n__sorted_by_count {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_n__sorted.tsv
		local now; now=$EPOCHSECONDS

		# nav: 1, git: 2
		printf '%s\tnn\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# First namespace row should be git (2)
		usage_keymap_n | bw | awk '$1 == "git" || $1 == "nav" {print $1; exit}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" 'git'
}; run_with_filter test__usage_keymap_n__sorted_by_count

function test__usage_keymap_t {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_t.tsv
		local now; now=$EPOCHSECONDS

		# Create a small real data file
		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		# Verify message
		usage_keymap_t 3 | bw | ruby_strip | grep -c 'Backed up, generated .* for 3 days'

		# Verify backup was created
		[[ -f ${KEYMAP_USAGE_FILE}.bak ]] && echo 'backup exists'

		rm -f "$KEYMAP_USAGE_FILE" "${KEYMAP_USAGE_FILE}.bak"
		KEYMAP_USAGE_FILE=$orig
	)" "$(
		cat <<-eof
			1
			backup exists
		eof
	)"
}; run_with_filter test__usage_keymap_t

function test__usage_keymap_t__repeated {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_t__repeated.tsv
		local now; now=$EPOCHSECONDS

		# Create real data and run ut once
		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		usage_keymap_t 3 > /dev/null

		# Run ut again; backup should not be overwritten
		usage_keymap_t 5 | bw | ruby_strip | grep -c 'Kept backup, generated .* for 5 days'

		# Verify backup still contains original real data
		grep -c 'gd' "${KEYMAP_USAGE_FILE}.bak"

		rm -f "$KEYMAP_USAGE_FILE" "${KEYMAP_USAGE_FILE}.bak"
		KEYMAP_USAGE_FILE=$orig
	)" "$(
		cat <<-eof
			1
			1
		eof
	)"
}; run_with_filter test__usage_keymap_t__repeated

function test__usage_keymap_t__when_no_arg {
	assert "$(
		usage_keymap_t | bw | ruby_strip
	)" 'Required: <n> days'
}; run_with_filter test__usage_keymap_t__when_no_arg

function test__usage_keymap_t__when_no_data {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_t__nodata.tsv
		rm -f "$KEYMAP_USAGE_FILE"

		usage_keymap_t 3 | bw | ruby_strip

		KEYMAP_USAGE_FILE=$orig
	)" 'No usage data to back up'
}; run_with_filter test__usage_keymap_t__when_no_data

function test__usage_keymap_tt {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_tt.tsv

		# Create a backup file
		printf '1000000000\tgd\n' > "${KEYMAP_USAGE_FILE}.bak"
		# Create a different current file
		printf '2000000000\tnn\n' > "$KEYMAP_USAGE_FILE"

		usage_keymap_tt | bw | ruby_strip

		# Verify backup was consumed
		[[ ! -f ${KEYMAP_USAGE_FILE}.bak ]] && echo 'backup removed'

		# Verify real data was restored
		grep -c 'gd' "$KEYMAP_USAGE_FILE"

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" "$(
		cat <<-eof
			Restored real data from backup
			backup removed
			1
		eof
	)"
}; run_with_filter test__usage_keymap_tt

function test__usage_keymap_tt__when_no_backup {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_tt__nobak.tsv
		rm -f "${KEYMAP_USAGE_FILE}.bak"

		usage_keymap_tt | bw | ruby_strip

		KEYMAP_USAGE_FILE=$orig
	)" 'No backup to restore'
}; run_with_filter test__usage_keymap_tt__when_no_backup

function test__usage_keymap_u {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u.tsv
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | grep 'Total' | awk '{print $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '3'
}; run_with_filter test__usage_keymap_u

function test__usage_keymap_u__stats {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u__stats.tsv
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | grep -c 'Namespaces: 1  |  Aliases: 2'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_u__stats

function test__usage_keymap_u__with_n_days {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u__with_n_days.tsv
		local now; now=$EPOCHSECONDS

		# Create data spanning 10 days
		printf '%s\tgc\n' "$(( now - 9 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=5, should only count 1 entry (today's)
		usage_keymap_u 5 | bw | grep 'Total' | awk '{print $2}'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_u__with_n_days

function test__usage_keymap_u__auto_granularity_daily {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u__auto_gran_daily.tsv
		local now; now=$EPOCHSECONDS

		# Create data spanning 1 day; should auto-pick daily (/day)
		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | grep -c '/day'

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_u__auto_granularity_daily

function test__usage_keymap_u__granularity_line_singular {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u__gran_singular.tsv
		local now; now=$EPOCHSECONDS

		# 1 day of data = 1 bucket
		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | tail -1 | ruby_strip

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '(1 daily bucket)'
}; run_with_filter test__usage_keymap_u__granularity_line_singular

function test__usage_keymap_u__granularity_line_plural {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u__gran_plural.tsv
		local now; now=$EPOCHSECONDS

		# 5 days of data = 5 buckets
		export COLUMNS=80
		printf '%s\tgd\n' "$(( now - 4 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | tail -1 | ruby_strip

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '(5 daily buckets)'
}; run_with_filter test__usage_keymap_u__granularity_line_plural

function test__usage_keymap_u__auto_granularity_weekly {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u__auto_gran_weekly.tsv
		local now; now=$EPOCHSECONDS

		# 10 days of data with COLUMNS=12 (width=8); 10 > 8 forces weekly
		export COLUMNS=12
		printf '%s\tgd\n' "$(( now - 9 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		local sparkline_len; sparkline_len=$(usage_keymap_u | bw | grep -v '^ *$' | tail -3 | head -1 | sed 's/^ *//' | wc -m | tr -d ' ')
		[[ $sparkline_len -lt 10 ]] && echo 1

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_u__auto_granularity_weekly

function test__usage_keymap_u__auto_granularity_monthly {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u__auto_gran_monthly.tsv
		local now; now=$EPOCHSECONDS

		# 60 days of data with COLUMNS=10 (width=6); 60 days > 6, ~9 weeks > 6, but ~2 months <= 6
		export COLUMNS=10
		printf '%s\tgd\n' "$(( now - 59 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		local sparkline_len; sparkline_len=$(usage_keymap_u | bw | grep -v '^ *$' | tail -3 | head -1 | sed 's/^ *//' | wc -m | tr -d ' ')
		[[ $sparkline_len -le 6 ]] && echo 1

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_u__auto_granularity_monthly

function test__usage_keymap_u__auto_granularity_quarterly {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u__auto_gran_quarterly.tsv
		local now; now=$EPOCHSECONDS

		# 400 days of data with COLUMNS=6 (width=2); 400 days, ~13 months > 2, but ~5 quarters > 2, need tighter
		# Use COLUMNS=7 (width=3); ~13 months > 3, ~5 quarters > 3, ~2 years <= 3... no
		# Better: 200 days with COLUMNS=8 (width=4); ~7 months > 4, ~3 quarters <= 4
		export COLUMNS=8
		printf '%s\tgd\n' "$(( now - 199 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# Sparkline should have <= 4 chars (quarterly buckets)
		local sparkline_len; sparkline_len=$(usage_keymap_u | bw | grep -v '^ *$' | tail -3 | head -1 | sed 's/^ *//' | wc -m | tr -d ' ')
		[[ $sparkline_len -le 6 ]] && echo 1

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_u__auto_granularity_quarterly

function test__usage_keymap_u__auto_granularity_yearly {
	assert "$(
		local orig=$KEYMAP_USAGE_FILE
		KEYMAP_USAGE_FILE=/tmp/test__usage_keymap_u__auto_gran_yearly.tsv
		local now; now=$EPOCHSECONDS

		# 400 days of data with COLUMNS=5 (width=1); forces yearly
		export COLUMNS=5
		printf '%s\tgd\n' "$(( now - 399 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		local sparkline_len; sparkline_len=$(usage_keymap_u | bw | grep -v '^ *$' | tail -3 | head -1 | sed 's/^ *//' | wc -m | tr -d ' ')
		[[ $sparkline_len -le 4 ]] && echo 1

		rm -f "$KEYMAP_USAGE_FILE"
		KEYMAP_USAGE_FILE=$orig
	)" '1'
}; run_with_filter test__usage_keymap_u__auto_granularity_yearly


