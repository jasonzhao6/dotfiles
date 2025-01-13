# When profiling, set to 1; otherwise, set to <empty>
ZSHRC_UNDER_PROFILING=

# Profile loading time: Start
[[ -z $ZSHRC_UNDER_TESTING && -n $ZSHRC_UNDER_PROFILING ]] && zmodload zsh/zprof

# Track loading time: Start
[[ -z $ZSHRC_UNDER_TESTING ]] && ZSHRC_LOAD_TIME_START=$(gdate +%s.%2N)

export DOTFILES_DIR="$HOME/gh/jasonzhao6/dotfiles"
export ZSHRC_DIR="$DOTFILES_DIR/zshrc"
export ZSHRC_SECRETS="$HOME/.zshrc.secrets"

# Set color aliases early so they can expand in subsequent function definitions
source "$ZSHRC_DIR/colors.zsh"; color

# Load helpers
source "$ZSHRC_DIR/_utils.zsh" # Load general utils first
source "$ZSHRC_DIR/_keymap.zsh"
source "$ZSHRC_DIR/_reserved_keywords.zsh"

# Load keymaps
source "$ZSHRC_DIR/args_keymap.zsh"
source "$ZSHRC_DIR/aws_keymap.zsh"
source "$ZSHRC_DIR/git_keymap.zsh"
source "$ZSHRC_DIR/github_keymap.zsh"
source "$ZSHRC_DIR/main_keymap.zsh"
source "$ZSHRC_DIR/nav_keymap.zsh" # Has extended `<namespace>` function
source "$ZSHRC_DIR/other_keymap.zsh" # Has extended `<namespace>` function
source "$ZSHRC_DIR/terraform_keymap.zsh"
source "$ZSHRC_DIR/zsh_keymap.zsh"

# Load non-keymaps
source "$ZSHRC_DIR/kubectl.zsh"
source "$ZSHRC_DIR/terraform.zsh"
source "$ZSHRC_DIR/zsh_arrow_keys.zsh"
source "$ZSHRC_DIR/zsh_history.zsh"
source "$ZSHRC_DIR/zsh_prompt.zsh"

# Overwrite placeholders with secret values from `ZSHRC_SECRETS`
[[ -z $ZSHRC_UNDER_TESTING && -f $ZSHRC_SECRETS ]] && source "$ZSHRC_SECRETS"

# Track loading time: Finish
[[ -z $ZSHRC_UNDER_TESTING ]] && gray_fg "\n\`.zshrc\` loaded in $(echo "$(gdate +%s.%2N) - $ZSHRC_LOAD_TIME_START" | bc) seconds"

# Profile loading time: Finish
[[ -z $ZSHRC_UNDER_TESTING && -n $ZSHRC_UNDER_PROFILING ]] && echo && zprof
