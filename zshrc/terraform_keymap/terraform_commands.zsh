# Extracted from `terraform -help`

# shellcheck disable=SC2034 # Used by `terraform_keymap.zsh`
TERRAFORM_COMMANDS=(
	init
	validate
	plan
	apply
	destroy

	console
	fmt
	force-unlock
	get
	graph
	import
	login
	logout
	metadata
	output
	providers
	refresh
	show
	state
	taint
	test
	untaint
	version
	workspace

	-chdir
	-help
	-version

	--help
)
