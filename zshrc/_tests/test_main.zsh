function test--z--when-args-history-is-not-initialized {
	args-init
	local args_history_max=$ARGS_HISTORY_MAX

	assert "$(
		ARGS_HISTORY_MAX=
		z
		echo $ARGS_HISTORY_MAX
	)" "$args_history_max"

	args-init
}; run-with-filter test--z--when-args-history-is-not-initialized

function test--z--when-args-history-is-already-initialized {
	local overwrite='<overwrite>'

	assert "$(
		ARGS_HISTORY_MAX=$overwrite
		z
		echo $ARGS_HISTORY_MAX
	)" "$overwrite"

	args-init
}; run-with-filter test--z--when-args-history-is-already-initialized

function test--h {
	local history=$(
		cat <<-eof
			: 1735711246:0;echo 5
			: 1735711248:0;echo 1
			: 1735711249:0;echo 3
			: 1735711249:0;echo 3
			: 1735711250:0;echo 3
			: 1735711251:0;echo 4
			: 1735711252:0;echo 2
		eof
	)

	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test--h'
		echo $history > $HISTFILE

		h

		rm $HISTFILE
		HISTFILE=$histfile
	)" "$(
		cat <<-eof
		     1	echo 1
		     2	echo 2
		     3	echo 3
		     4	echo 4
		     5	echo 5
		eof
	)"
}; run-with-filter test--h

function test--hc {
	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test--h'
		touch $HISTFILE

		hc
		[[ -e $HISTFILE ]] && echo present || echo absent

		HISTFILE=$histfile
	)" 'absent'
}; run-with-filter test--hc
