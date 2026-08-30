function claude_helpers_move_local_to_global {
	local local_settings='.claude/settings.local.json'
	local global_settings="$CLAUDE_KEYMAP_CONFIG_DIR/settings.json"

	if [ ! -f "$local_settings" ]; then
		return 0
	fi

	# Extract local permissions
	local local_perms
	local_perms=$(jq -r '.permissions.allow // [] | .[]' "$local_settings" 2>/dev/null)

	if [ -z "$local_perms" ]; then
		return 0
	fi

	# Merge local permissions into global settings
	jq --argjson new "$(jq '.permissions.allow // []' "$local_settings")" \
		'.permissions.allow = ([.permissions.allow // [], $new] | flatten | unique | sort)' \
		"$global_settings" > "${global_settings}.tmp" &&
		mv "${global_settings}.tmp" "$global_settings"

	# Remove permissions from local settings
	local updated
	updated=$(jq 'del(.permissions.allow) | if .permissions == {} then del(.permissions) else . end' "$local_settings")

	if [ "$(echo "$updated" | jq 'length')" -eq 0 ]; then
		rm "$local_settings"
		green_bar "Moved local settings to global"
	else
		echo "$updated" > "$local_settings"
		green_bar "Moved local settings to global; kept remaining"
	fi
	echo
}
