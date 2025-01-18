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
source "$ZSHRC_DIR/keymap_helpers.zsh"
source "$ZSHRC_DIR/reserved_keywords.zsh"

# Load keymaps
source "$ZSHRC_DIR/args_keymap.zsh" # Overwrote `<namespace>` to invoke `args_keymap_a` TODO | a; if not key, filter
source "$ZSHRC_DIR/aws_keymap.zsh"
source "$ZSHRC_DIR/git_keymap.zsh" # Overwrote `<namespace>` to invoke `git_keymap_c` TODO g -> gc
source "$ZSHRC_DIR/github_keymap.zsh" # Overwrote `<namespace>` to invoke `github_keymap_h` TODO h -> hh
source "$ZSHRC_DIR/intellij_cmd_keymap.zsh"
source "$ZSHRC_DIR/kubectl_keymap.zsh"
source "$ZSHRC_DIR/main_keymap.zsh"
source "$ZSHRC_DIR/nav_keymap.zsh" # Overwrote `<namespace>` to invoke `nav_keymap_n`
source "$ZSHRC_DIR/other_keymap.zsh" # Overwrote `<namespace>` to invoke `other_keymap_o`
source "$ZSHRC_DIR/terraform_keymap.zsh"
source "$ZSHRC_DIR/vimium_keymap.zsh"
source "$ZSHRC_DIR/zsh_keymap.zsh"

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
