GITHUB_DEFAULT_DOMAIN='github.com'
GITHUB_DEFAULT_ORG='jasonzhao6'

# Wrap `github_keymap_d` with `GITHUB_DEFAULT_DOMAIN` from `ZSHRC_SECRETS`
function github_keymap_domain {
	local domain
	domain="$(github_keymap_d 2> /dev/null)"
	domain="${domain:-$GITHUB_DEFAULT_DOMAIN}"

	echo "$domain"
}

# Wrap `github_keymap_o` with `GITHUB_DEFAULT_ORG` from `ZSHRC_SECRETS`
function github_keymap_org {
	local org
	org="$(github_keymap_oo 2> /dev/null)"
	org="${org:-$GITHUB_DEFAULT_ORG}"

	echo "$org"
}

function github_keymap_url {
	# In case the current repo was forked, prefer the upstream url
	git remote get-url upstream 2> /dev/null || git remote get-url origin
}
