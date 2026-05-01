function nav_show_arg {
	local file; file="$(args_plain | sed -n "${NAV_CURSOR}p" | sed 's/ *#.*//' | strip)"

	other_keymap_k
	magenta_fg "\"${file##*/}\""

	case "$file" in
		${~NAV_RENDER_AS_TEXT}) echo; cat "$file" ;;
		${~NAV_RENDER_AS_MARKDOWN}) zsh_keymap_z "$file" ;;
		*) red_bar 'Unsupported file type' ;;
	esac
}
