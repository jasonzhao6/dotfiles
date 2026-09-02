function test__kubectl_keymap {
	assert "$(
		local show_this_help; show_this_help=$(kubectl_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $show_this_help =~ "^  \\$ $KUBECTL_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__kubectl_keymap_hd__with_confirmed {
	assert "$(
		function read { return 0; }
		function kubectl { echo "kubectl $*"; }

		kubectl_keymap_hd 'my-pod-123' 2>&1
	)" "$(
		echo
		echo
		echo
		echo 'kubectl delete pod my-pod-123'
	)"
}

function test__kubectl_keymap_hd__with_denied {
	assert "$(
		function read { return 1; }
		function kubectl { echo 'SHOULD NOT BE CALLED'; }

		kubectl_keymap_hd 'my-pod-123' 2>&1
	)" ''
}
