function test--zz--when-args-history-is-not-initialized {
	args-init
	local args_history_max=$ARGS_HISTORY_MAX

	assert "$(
		ARGS_HISTORY_MAX=
		zz
		echo $ARGS_HISTORY_MAX
	)" "$args_history_max"

}; run-with-filter test--zz--when-args-history-is-not-initialized

function test--zz--when-args-history-is-already-initialized {
	local overwrite='<overwrite>'

	assert "$(
		ARGS_HISTORY_MAX=$overwrite
		zz
		echo $ARGS_HISTORY_MAX
	)" "$overwrite"
}; run-with-filter test--zz--when-args-history-is-already-initialized
