# When profiling, set to 1; otherwise, set to <empty>
ZSHRC_UNDER_PROFILING=

# Profile `.zshrc` loading time: Start
[[ -z $ZSHRC_UNDER_TESTING && -n $ZSHRC_UNDER_PROFILING ]] && zmodload zsh/zprof

# Track `.zshrc` loading time: Start
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
source "$ZSHRC_DIR/_keymap/keymap_utils.zsh"
source "$ZSHRC_DIR/_keymap/is_reserved.zsh"

# Load zsh keymaps (These mappings invoke zsh functions)
source "$ZSHRC_DIR/args_keymap/args_keymap.zsh" # Overload `<namespace>` to invoke `args_keymap_a` TODO | a; if not key, filter
source "$ZSHRC_DIR/aws_keymap/aws_keymap.zsh"
source "$ZSHRC_DIR/git_keymap/git_keymap.zsh"
source "$ZSHRC_DIR/github_keymap/github_keymap.zsh"
source "$ZSHRC_DIR/kubectl_keymap/kubectl_keymap.zsh"
source "$ZSHRC_DIR/main_keymap/main_keymap.zsh"
source "$ZSHRC_DIR/nav_keymap/nav_keymap.zsh"
source "$ZSHRC_DIR/other_keymap/other_keymap.zsh"
source "$ZSHRC_DIR/terraform_keymap/terraform_keymap.zsh"
source "$ZSHRC_DIR/zsh_keymap/zsh_keymap.zsh"

# Load non-zsh keymaps (These mappings are for reference only)
source "$ZSHRC_DIR/intellij_keymaps/intellij_cmd_keymap.zsh"
source "$ZSHRC_DIR/vimium_keymaps/vimium_keymap.zsh"
source "$ZSHRC_DIR/vimium_keymaps/vimium_search_keymap.zsh"

# Load zsh configs
source "$ZSHRC_DIR/zsh_arrow_keys.zsh"
source "$ZSHRC_DIR/zsh_history.zsh"
source "$ZSHRC_DIR/zsh_prompt.zsh"

# Source secrets
[[ -z $ZSHRC_UNDER_TESTING && -f $ZSHRC_SECRETS ]] && source "$ZSHRC_SECRETS"

# Track `.zshrc` loading time: Finish
[[ -z $ZSHRC_UNDER_TESTING ]] && gray_fg "\n\`.zshrc\` loaded in $(echo "$(gdate +%s.%2N) - $ZSHRC_START_TIME" | bc) seconds"

# Profile `.zshrc` loading time: Finish
[[ -z $ZSHRC_UNDER_TESTING && -n $ZSHRC_UNDER_PROFILING ]] && echo && zprof
