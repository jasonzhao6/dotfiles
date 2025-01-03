function test__z__when_args_history_is_not_initialized {
	args_init
	local args_history_max=$ARGS_HISTORY_MAX

	assert "$(
		ARGS_HISTORY_MAX=
		z
		echo "$ARGS_HISTORY_MAX"
	)" "$args_history_max"

	args_reset
}; run_with_filter test__z__when_args_history_is_not_initialized

function test__z__when_args_history_is_already_initialized {
	local overwrite='<overwrite>'

	assert "$(
		ARGS_HISTORY_MAX=$overwrite
		z
		echo $ARGS_HISTORY_MAX
	)" "$overwrite"

	args_reset
}; run_with_filter test__z__when_args_history_is_already_initialized
