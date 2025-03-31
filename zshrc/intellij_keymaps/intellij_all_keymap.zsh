# This keymap is the superset of IntelliJ's `cmd`, `ctrl`, and `alt` keymaps.
# It exists to allow filtering across the three subsets for convenience.
# The subsets are still needed to track their respective key mappings.
INTELLIJ_ALL_NAMESPACE='intellij_all'
INTELLIJ_ALL_ALIAS='i'

# Note: Intentionally dropping the `_KEYMAP` suffix from this name to avoid it getting picked up by
# meta programming regex. Otherwise, all the key mappings in this list getting included twice.
# Also note: This name in lower case must match `INTELLIJ_ALL_NAMESPACE='~'` and `function ~ {}`.
INTELLIJ_ALL=(
	${INTELLIJ_CMD_KEYMAP[@]}
	${INTELLIJ_CTRL_KEYMAP[@]}
	${INTELLIJ_ALT_KEYMAP[@]}
)

keymap_init $INTELLIJ_ALL_NAMESPACE $INTELLIJ_ALL_ALIAS "${INTELLIJ_ALL[@]}"

function intellij_all {
	keymap_show $INTELLIJ_ALL_NAMESPACE $INTELLIJ_ALL_ALIAS \
		${#INTELLIJ_ALL} "${INTELLIJ_ALL[@]}" "$@"
}
