function nav_helpers_mru_add {
	local entry=$1
	local existing=""

	if [[ -f "$NAV_MRU_FILE" ]]; then
		existing=$(grep -vFx "$entry" "$NAV_MRU_FILE" || true)
	fi

	if [[ -n "$existing" ]]; then
		printf '%s\n%s\n' "$entry" "$existing" > "$NAV_MRU_FILE"
	else
		echo "$entry" > "$NAV_MRU_FILE"
	fi
}

function nav_helpers_show_arg {
	local file; file="$(args_helpers_plain | sed -n "${NAV_CURSOR}p" | sed 's/ *#.*//' | strip)"

	other_keymap_k
	magenta_fg "\"${file##*/}\""

	case "$file" in
		${~NAV_RENDER_AS_TEXT}) echo; cat "$file" ;;
		${~NAV_RENDER_AS_MARKDOWN}) zsh_keymap_v "$file" ;;
		*) red_bar 'Unsupported file type' ;;
	esac
}
