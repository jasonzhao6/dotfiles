function test__za {
	assert "$(
		local count; count=$(za | wc -l)
		local min_count; min_count=$(grep --count '^\talias ' "$ZSHRC_DIR"/colors.zsh)

		[[ $count -ge $min_count ]] && echo 1
	)" '1'
}; run_with_filter test__za

function test__za__when_counting_greps {
	assert "$(
		local count; count=$(za grep | wc -l)
		local actual_count; actual_count=$(grep --count '^\talias.*grep' "$ZSHRC_DIR"/colors.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}; run_with_filter test__za__when_counting_greps

function test__zf {
	assert "$(
		[[ $(zf | wc -l) -gt 10 ]] && echo 1
	)" '1'
}; run_with_filter test__zf

function test__zf__when_counting_._functions {
	assert "$(
		local count; count=$(zf '^\.\.' | wc -l)
		local actual_count; actual_count=$(egrep --count '^function \.+ {' "$ZSHRC_DIR"/cd.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}; run_with_filter test__zf__when_counting_._functions

function test__zz__when_args_history_is_not_initialized {
	args_history_init
	local args_history_max=$ARGS_HISTORY_MAX

	assert "$(
		ARGS_HISTORY_MAX=
		zz
		echo "$ARGS_HISTORY_MAX"
	)" "$args_history_max"

	args_history_reset
}; run_with_filter test__zz__when_args_history_is_not_initialized

function test__zz__when_args_history_is_already_initialized {
	local overwrite='<overwrite>'

	assert "$(
		ARGS_HISTORY_MAX=$overwrite
		zz
		echo $ARGS_HISTORY_MAX
	)" "$overwrite"

	args_history_reset
}; run_with_filter test__zz__when_args_history_is_already_initialized
