# When profiling, set to 1; otherwise, set to <empty>
ZSHRC_UNDER_PROFILING=

# Profile the load time: Start
[[ -z $ZSHRC_UNDER_TESTING && -n $ZSHRC_UNDER_PROFILING ]] && zmodload zsh/zprof

# Track the load time: Start
[[ -z $ZSHRC_UNDER_TESTING ]] && ZSHRC_LOAD_TIME_START=$(gdate +%s.%2N)

DOTFILES_DIR="$HOME/gh/jasonzhao6/dotfiles"
ZSHRC_DIR="$DOTFILES_DIR/zshrc"
ZSHRC_SECRETS="$HOME/.zshrc.secrets"

# Set color aliases early so they can expand in subsequent function definitions
source "$ZSHRC_DIR/colors.zsh"; color

# Load helpers
source "$ZSHRC_DIR/_utils.zsh" # Load general utils first
source "$ZSHRC_DIR/_keymap.zsh"
source "$ZSHRC_DIR/_reserved_keywords.zsh"

# Load keymaps
source "$ZSHRC_DIR/args_keymap.zsh" # Overwrote `<namespace>` to invoke `args_keymap_a` TODO | a; if not key, filter
source "$ZSHRC_DIR/aws_keymap.zsh"
source "$ZSHRC_DIR/git_keymap.zsh" # Overwrote `<namespace>` to invoke `git_keymap_c` TODO g -> gc
source "$ZSHRC_DIR/github_keymap.zsh" # Overwrote `<namespace>` to invoke `github_keymap_h` TODO h -> hh
source "$ZSHRC_DIR/kubectl_keymap.zsh"
source "$ZSHRC_DIR/main_keymap.zsh"
source "$ZSHRC_DIR/nav_keymap.zsh" # Overwrote `<namespace>` to invoke `nav_keymap_n`
source "$ZSHRC_DIR/other_keymap.zsh" # Overwrote `<namespace>` to invoke `other_keymap_o`
source "$ZSHRC_DIR/terraform_keymap.zsh"
source "$ZSHRC_DIR/zsh_keymap.zsh"

# Load zsh configs
source "$ZSHRC_DIR/zsh_arrow_keys.zsh"
source "$ZSHRC_DIR/zsh_history.zsh"
source "$ZSHRC_DIR/zsh_prompt.zsh"

# Source secrets
[[ -z $ZSHRC_UNDER_TESTING && -f $ZSHRC_SECRETS ]] && source "$ZSHRC_SECRETS"

# Track the load time: Finish
[[ -z $ZSHRC_UNDER_TESTING ]] && gray_fg "\n\`.zshrc\` loaded in $(echo "$(gdate +%s.%2N) - $ZSHRC_LOAD_TIME_START" | bc) seconds"

# Profile the load time: Finish
[[ -z $ZSHRC_UNDER_TESTING && -n $ZSHRC_UNDER_PROFILING ]] && echo && zprof
