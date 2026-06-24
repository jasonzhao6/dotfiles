# shellcheck disable=SC2030,SC2031 # Tests override COLUMNS inside each $(...) for isolation; subshell-local is intended
function test__usage_keymap {
	assert "$(
		local show_this_help; show_this_help=$(usage_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $USAGE_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__usage_keymap_a {
	assert "$(
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_a | bw | awk '/g\./ {print $1}'
	)" "$(
		cat <<-eof
			g.d
			g.c
		eof
	)"
}

function test__usage_keymap_a__with_match {
	assert "$(
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tnn\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# Match 'nn' should only show nav_keymap n
		local lines; lines=$(usage_keymap_a nn | bw | grep --count 'n\.n')
		echo "$lines"
	)" '1'
}

function test__usage_keymap_a__with_n_days {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Create data spanning 10 days
		printf '%s\tgc\n' "$(( now - 9 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=5, should only count 1 entry (today's)
		usage_keymap_a 5 | bw | grep 'Total' | awk '{print $2}'
	)" '1'
}

function test__usage_keymap_a__with_no_match {
	assert "$(
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_a zzz | bw | ruby_strip
	)" 'No alias matching `zzz`'
}

function test__usage_keymap_a__top_level_alias {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Top-level alias (no key)
		printf '%s\tu\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_a | bw | awk '/^  u / {print $1, $2}'
	)" 'u Show'
}

function test__usage_keymap_a__row_limit {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Generate USAGE_KEYMAP_A_MAX_ROWS + 1 distinct aliases
		: > "$KEYMAP_USAGE_FILE"
		local i
		for (( i = 1; i <= USAGE_KEYMAP_A_MAX_ROWS + 1; i++ )); do
			printf '%s\tg%s\n' "$now" "$i" >> "$KEYMAP_USAGE_FILE"
		done

		# Should show at most USAGE_KEYMAP_A_MAX_ROWS alias rows
		local alias_rows; alias_rows=$(usage_keymap_a | bw | grep --count '^ *g\.')
		echo "$alias_rows"
	)" "$USAGE_KEYMAP_A_MAX_ROWS"
}

function test__usage_keymap_a__sorted_by_count {
	assert "$(
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# First alias row should be gc (2), then gd (1)
		usage_keymap_a | bw | awk '/g\./ {print $1}' | head -1
	)" 'g.c'
}

function test__usage_keymap_c {
	assert "$(
		printf '1000000000\tgd\n' > "$KEYMAP_USAGE_FILE"
		printf '1000000001\tgc\n' >> "$KEYMAP_USAGE_FILE"

		usage_keymap_c | bw | ruby_strip
		wc -c < "$KEYMAP_USAGE_FILE" | tr -d ' '
	)" "$(
		cat <<-eof
			Cleared 2 entries
			0
		eof
	)"
}

function test__usage_keymap_c__when_no_file {
	assert "$(
		rm -f "$KEYMAP_USAGE_FILE"

		usage_keymap_c | bw | ruby_strip
	)" 'No usage file to clear'
}

function test__usage_keymap_d {
	assert "$(

		# 2026-03-01 20:00 UTC is a Sunday; +0900 shifts it to Mon 05:00 at capture.
		# UTC-anchored so the expected weekday is independent of the test machine's zone.
		local utc; utc=$(gdate -u -d '2026-03-01 20:00:00' +%s)
		printf '%s\tgd\t+0900\n' "$utc" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\t+0900\n' "$utc" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_d | bw | awk '$1 ~ /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)$/ && $2 > 0 {print $1, $2}'
	)" 'Mon 2'
}

function test__usage_keymap_d__falls_back_when_no_zone {
	assert "$(

		# Pre-offset row (no third column) renders in the current zone.
		# Epoch generated as a local Monday, so it renders as Mon on any machine.
		local mon; mon=$(gdate -d '2026-03-02 12:00:00' +%s)
		printf '%s\tgd\n' "$mon" > "$KEYMAP_USAGE_FILE"

		usage_keymap_d | bw | awk '$1 ~ /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)$/ && $2 > 0 {print $1, $2}'
	)" 'Mon 1'
}

function test__usage_keymap_d__with_n_days {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Today and 5 days ago
		printf '%s\tgc\n' "$(( now - 5 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=1, should only count today's entry
		usage_keymap_d 1 | bw | grep 'Total' | awk '{print $2}'
	)" '1'
}

function test__usage_keymap_d__shows_all_7_days {
	assert "$(

		# Single entry on a Monday
		local mon; mon=$(gdate -d '2026-03-02 12:00:00' +%s)
		printf '%s\tgd\n' "$mon" > "$KEYMAP_USAGE_FILE"

		# Should still show all 7 day rows
		usage_keymap_d | bw | grep --count '^\s*\(Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Sun\)'
	)" '7'
}

function test__usage_keymap_dd {
	assert "$(

		# Offset column present, but `dd` ignores it and uses the current zone:
		# epochs generated as a local Monday / Friday render as Mon / Fri despite +0900.
		local mon; mon=$(gdate -d '2026-03-02 12:00:00' +%s)
		local fri; fri=$(gdate -d '2026-03-06 12:00:00' +%s)
		printf '%s\tgd\t+0900\n' "$mon" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\t+0900\n' "$mon" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\t+0900\n' "$fri" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_dd | bw | awk '$1 ~ /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)$/ && $2 > 0 {print $1, $2}'
	)" "$(
		cat <<-eof
			Mon 2
			Fri 1
		eof
	)"
}

function test__usage_keymap_h {
	assert "$(

		# 00:00 UTC stamped with a +0900 offset => 09:00 wall-clock at capture.
		# Anchored in UTC so the expected hour is independent of the test machine's zone.
		local utc0; utc0=$(gdate -u -d '2026-03-02 00:00:00' +%s)
		printf '%s\tgd\t+0900\n' "$utc0" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\t+0900\n' "$utc0" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_h | bw | awk '$1 ~ /^[0-9][0-9]$/ && $2 > 0 {print $1, $2}'
	)" '09 2'
}

function test__usage_keymap_h__falls_back_when_no_zone {
	assert "$(

		# Pre-offset row (no third column) renders in the current zone.
		# Epoch generated as local 09:00, so it renders as 09 on any machine.
		local h09; h09=$(gdate -d '2026-03-02 09:00:00' +%s)
		printf '%s\tgd\n' "$h09" > "$KEYMAP_USAGE_FILE"

		usage_keymap_h | bw | awk '$1 ~ /^[0-9][0-9]$/ && $2 > 0 {print $1, $2}'
	)" '09 1'
}

function test__usage_keymap_h__with_n_days {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Today and 5 days ago
		printf '%s\tgc\n' "$(( now - 5 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=1, should only count today's entry
		usage_keymap_h 1 | bw | grep 'Total' | awk '{print $2}'
	)" '1'
}

function test__usage_keymap_h__shows_all_24_hours {
	assert "$(

		# Single entry at 9am
		local h09; h09=$(gdate -d '2026-03-02 09:00:00' +%s)
		printf '%s\tgd\n' "$h09" > "$KEYMAP_USAGE_FILE"

		# Should still show all 24 hour rows
		usage_keymap_h | bw | grep --count '^\s*[0-9][0-9]\s'
	)" '24'
}

function test__usage_keymap_hh {
	assert "$(

		# Offset column present, but `hh` ignores it and uses the current zone:
		# epochs generated as local 09:00 / 14:00 render as 09 / 14 despite +0900.
		local h09; h09=$(gdate -d '2026-03-02 09:00:00' +%s)
		local h14; h14=$(gdate -d '2026-03-02 14:00:00' +%s)
		printf '%s\tgd\t+0900\n' "$h09" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\t+0900\n' "$h09" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\t+0900\n' "$h14" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_hh | bw | awk '$1 ~ /^[0-9][0-9]$/ && $2 > 0 {print $1, $2}'
	)" "$(
		cat <<-eof
			09 2
			14 1
		eof
	)"
}

function test__usage_keymap_m__when_no_file {
	assert "$(
		rm -f "$KEYMAP_USAGE_FILE"

		usage_keymap_m | bw | ruby_strip
	)" 'No usage file'
}

function test__usage_keymap_n {
	assert "$(
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tnn\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_n | bw | grep 'Total' | awk '{print $2}'
	)" '3'
}

function test__usage_keymap_n__with_match {
	assert "$(
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tnn\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_n nav | bw | grep --count 'nav'
	)" '1'
}

function test__usage_keymap_n__with_n_days {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Create data spanning 10 days
		printf '%s\tnn\n' "$(( now - 9 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=5, should only count 1 entry (today's, git namespace)
		usage_keymap_n 5 | bw | grep 'Total' | awk '{print $2}'
	)" '1'
}

function test__usage_keymap_n__with_no_match {
	assert "$(
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_n zzz | bw | ruby_strip
	)" 'No namespace matching `zzz`'
}

function test__usage_keymap_n__sorted_by_count {
	assert "$(
		local now; now=$EPOCHSECONDS

		# nav: 1, git: 2
		printf '%s\tnn\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# First namespace row should be git (2)
		usage_keymap_n | bw | awk '$1 == "git" || $1 == "nav" {print $1; exit}'
	)" 'git'
}

function test__usage_keymap_t {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Reset the backup precondition (tests share one tmp path, run shuffled)
		rm -f "${KEYMAP_USAGE_FILE}.bak"

		# Create a small real data file
		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		# Verify message
		usage_keymap_t 3 | bw | ruby_strip | grep --count 'Backed up, generated .* for 3 days'

		# Verify backup was created
		[[ -f ${KEYMAP_USAGE_FILE}.bak ]] && echo 'backup exists'
	)" "$(
		cat <<-eof
			1
			backup exists
		eof
	)"
}

function test__usage_keymap_t__repeated {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Reset the backup precondition (tests share one tmp path, run shuffled)
		rm -f "${KEYMAP_USAGE_FILE}.bak"

		# Create real data and run ut once
		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		usage_keymap_t 3 > /dev/null

		# Run ut again; backup should not be overwritten
		usage_keymap_t 5 | bw | ruby_strip | grep --count 'Kept backup, generated .* for 5 days'

		# Verify backup still contains original real data
		grep --count 'gd' "${KEYMAP_USAGE_FILE}.bak"
	)" "$(
		cat <<-eof
			1
			1
		eof
	)"
}

function test__usage_keymap_t__when_no_arg {
	assert "$(
		usage_keymap_t | bw | ruby_strip
	)" 'Required: <n> days'
}

function test__usage_keymap_t__when_no_data {
	assert "$(
		rm -f "$KEYMAP_USAGE_FILE" "${KEYMAP_USAGE_FILE}.bak"

		usage_keymap_t 3 | bw | ruby_strip
	)" 'No usage data to back up'
}

function test__usage_keymap_tt {
	assert "$(
		# Create a backup file
		printf '1000000000\tgd\n' > "${KEYMAP_USAGE_FILE}.bak"
		# Create a different current file
		printf '2000000000\tnn\n' > "$KEYMAP_USAGE_FILE"

		usage_keymap_tt | bw | ruby_strip

		# Verify backup was consumed
		[[ ! -f ${KEYMAP_USAGE_FILE}.bak ]] && echo 'backup removed'

		# Verify real data was restored
		grep --count 'gd' "$KEYMAP_USAGE_FILE"
	)" "$(
		cat <<-eof
			Restored real data from backup
			backup removed
			1
		eof
	)"
}

function test__usage_keymap_tt__when_no_backup {
	assert "$(
		rm -f "${KEYMAP_USAGE_FILE}.bak"

		usage_keymap_tt | bw | ruby_strip
	)" 'No backup to restore'
}

function test__usage_keymap_u {
	assert "$(
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | grep 'Total' | awk '{print $2}'
	)" '3'
}

function test__usage_keymap_u__stats {
	assert "$(
		local now; now=$EPOCHSECONDS

		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgc\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | grep --count 'Namespaces: 1  |  Aliases: 2'
	)" '1'
}

function test__usage_keymap_u__with_n_days {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Create data spanning 10 days
		printf '%s\tgc\n' "$(( now - 9 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		# With n=5, should only count 1 entry (today's)
		usage_keymap_u 5 | bw | grep 'Total' | awk '{print $2}'
	)" '1'
}

function test__usage_keymap_u__auto_granularity_daily {
	assert "$(
		local now; now=$EPOCHSECONDS

		# Create data spanning 1 day; should auto-pick daily (/day)
		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | grep --count '/day'
	)" '1'
}

function test__usage_keymap_u__granularity_line_singular {
	assert "$(
		local now; now=$EPOCHSECONDS

		# 1 day of data = 1 bucket
		printf '%s\tgd\n' "$now" > "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | tail -1 | ruby_strip
	)" '(1 daily bucket)'
}

function test__usage_keymap_u__granularity_line_plural {
	assert "$(
		local now; now=$EPOCHSECONDS

		# 5 days of data = 5 buckets
		export COLUMNS=80
		printf '%s\tgd\n' "$(( now - 4 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		usage_keymap_u | bw | tail -1 | ruby_strip
	)" '(5 daily buckets)'
}

function test__usage_keymap_u__auto_granularity_weekly {
	assert "$(
		local now; now=$EPOCHSECONDS

		# 10 days of data with COLUMNS=12 (width=8); 10 > 8 forces weekly
		export COLUMNS=12
		printf '%s\tgd\n' "$(( now - 9 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		local sparkline_len; sparkline_len=$(usage_keymap_u | bw | grep -v '^ *$' | tail -3 | head -1 | sed 's/^ *//' | wc -m | tr -d ' ')
		[[ $sparkline_len -lt 10 ]] && echo 1
	)" '1'
}

function test__usage_keymap_u__auto_granularity_monthly {
	assert "$(
		local now; now=$EPOCHSECONDS

		# 60 days of data with COLUMNS=10 (width=6); 60 days > 6, ~9 weeks > 6, but ~2 months <= 6
		export COLUMNS=10
		printf '%s\tgd\n' "$(( now - 59 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		local sparkline_len; sparkline_len=$(usage_keymap_u | bw | grep -v '^ *$' | tail -3 | head -1 | sed 's/^ *//' | wc -m | tr -d ' ')
		[[ $sparkline_len -le 6 ]] && echo 1
	)" '1'
}

function test__usage_keymap_u__auto_granularity_quarterly {
	assert "$(
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
	)" '1'
}

function test__usage_keymap_u__auto_granularity_yearly {
	assert "$(
		local now; now=$EPOCHSECONDS

		# 400 days of data with COLUMNS=5 (width=1); forces yearly
		export COLUMNS=5
		printf '%s\tgd\n' "$(( now - 399 * 86400 ))" > "$KEYMAP_USAGE_FILE"
		printf '%s\tgd\n' "$now" >> "$KEYMAP_USAGE_FILE"

		local sparkline_len; sparkline_len=$(usage_keymap_u | bw | grep -v '^ *$' | tail -3 | head -1 | sed 's/^ *//' | wc -m | tr -d ' ')
		[[ $sparkline_len -le 4 ]] && echo 1
	)" '1'
}
