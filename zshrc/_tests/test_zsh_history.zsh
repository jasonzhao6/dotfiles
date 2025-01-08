function test__hr {
	local history; history=$(
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

	# shellcheck disable=SC2030
	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test__hr'
		echo "$history" > $HISTFILE

		hr

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
}; run_with_filter test__hr

function test__hc {
	# shellcheck disable=SC2031
	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test__h'
		touch $HISTFILE

		hc
		[[ -e $HISTFILE ]] && echo present || echo absent

		HISTFILE=$histfile
	)" 'absent'
}; run_with_filter test__hc
