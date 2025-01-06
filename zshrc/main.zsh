export DOTFILES_DIR="$HOME/gh/jasonzhao6/dotfiles"
export ZSHRC_DIR="$DOTFILES_DIR/zshrc"
export ZSHRC_SECRETS="$HOME/.zshrc.secrets"

# Set color aliases early so they can expand in subsequent function definitions
source "$ZSHRC_DIR/colors.zsh"; color

# Include helper functions to be used by all keymap namespaces
source "$ZSHRC_DIR/_keymap.zsh"

# Load keymaps
source "$ZSHRC_DIR/lists_keymap.zsh"
source "$ZSHRC_DIR/opens_keymap.zsh"
source "$ZSHRC_DIR/numbers_keymap.zsh"

# Load non-keymaps
source "$ZSHRC_DIR/args.zsh"
source "$ZSHRC_DIR/aws.zsh"
source "$ZSHRC_DIR/cd.zsh"
source "$ZSHRC_DIR/git.zsh"
source "$ZSHRC_DIR/git_info.zsh"
source "$ZSHRC_DIR/kubectl.zsh"
source "$ZSHRC_DIR/terraform.zsh"
source "$ZSHRC_DIR/util.zsh"
source "$ZSHRC_DIR/zsh_arrow_keys.zsh"
source "$ZSHRC_DIR/zsh_history.zsh"
source "$ZSHRC_DIR/zsh_prompt.zsh"
source "$ZSHRC_DIR/zshrc.zsh"

# Overwrite placeholders with secret values from `ZSHRC_SECRETS`
[[ -z $ZSHRC_UNDER_TEST && -f $ZSHRC_SECRETS ]] && source "$ZSHRC_SECRETS"
