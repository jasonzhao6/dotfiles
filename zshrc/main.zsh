# When profiling, set to 1; otherwise, set to <empty>
ZSHRC_UNDER_PROFILING=

# Profile `.zshrc` loading time: Start here
[[ -z $ZSHRC_UNDER_TESTING && -n $ZSHRC_UNDER_PROFILING ]] && zmodload zsh/zprof

# Track `.zshrc` loading time: Start here
[[ -z $ZSHRC_UNDER_TESTING ]] && ZSHRC_START_TIME=$(gdate +%s.%2N)

DOTFILES_DIR="$HOME/github/jasonzhao6/dotfiles"
ZSHRC_DIR="$DOTFILES_DIR/zshrc"
ZSHRC_SECRETS="$HOME/.zshrc.secrets"

# Set color aliases early so that they can expand in function definitions
source "$ZSHRC_DIR/colors.zsh"; color

# Load general utils early so that they can be used in function definitions
source "$ZSHRC_DIR/utils.zsh"

# Load keymap helpers
source "$ZSHRC_DIR/_keymap/keymap_base.zsh"
source "$ZSHRC_DIR/_keymap/is_reserved.zsh"

# The "zsh keymaps" and "non-zsh keymaps" lists below could be generated
# But having them listed explicitly makes debugging individual keymap easier

# Load zsh keymaps (These mappings invoke zsh functions)
source "$ZSHRC_DIR/args_keymap/args_keymap.zsh"
source "$ZSHRC_DIR/aws_keymap/aws_keymap.zsh"
source "$ZSHRC_DIR/docker_keymap/docker_keymap.zsh"
source "$ZSHRC_DIR/git_keymap/git_keymap.zsh"
source "$ZSHRC_DIR/github_keymap/github_keymap.zsh"
source "$ZSHRC_DIR/kubectl_keymap/kubectl_keymap.zsh"
source "$ZSHRC_DIR/main_keymap/main_keymap.zsh"
source "$ZSHRC_DIR/nav_keymap/nav_keymap.zsh"
source "$ZSHRC_DIR/other_keymap/other_keymap.zsh"
source "$ZSHRC_DIR/terraform_keymap/terraform_keymap.zsh"
source "$ZSHRC_DIR/zsh_keymap/zsh_keymap.zsh"

# Load non-zsh keymaps (These mappings are used outside of zsh)
source "$ZSHRC_DIR/intellij_keymaps/intellij_all_keymap.zsh"
source "$ZSHRC_DIR/intellij_keymaps/intellij_alt_keymap.zsh"
source "$ZSHRC_DIR/intellij_keymaps/intellij_cmd_keymap.zsh"
source "$ZSHRC_DIR/intellij_keymaps/intellij_ctrl_keymap.zsh"
source "$ZSHRC_DIR/vimium_keymaps/vimium_keymap.zsh"
source "$ZSHRC_DIR/vimium_keymaps/vimium_search_keymap.zsh"

# Load zsh configs
source "$ZSHRC_DIR/zsh_arrow_keys.zsh"
source "$ZSHRC_DIR/zsh_history.zsh"
source "$ZSHRC_DIR/zsh_prompt.zsh"

# Source secrets
[[ -z $ZSHRC_UNDER_TESTING && -f $ZSHRC_SECRETS ]] && source "$ZSHRC_SECRETS"

# Track `.zshrc` loading time: Finish here
if [[ -z $ZSHRC_UNDER_TESTING ]]; then
	gray_fg "\n\`.zshrc\` loaded in $(echo "$(gdate +%s.%2N) - $ZSHRC_START_TIME" | bc) seconds"
fi

# Profile `.zshrc` loading time: Finish here
[[ -z $ZSHRC_UNDER_TESTING && -n $ZSHRC_UNDER_PROFILING ]] && echo && zprof
