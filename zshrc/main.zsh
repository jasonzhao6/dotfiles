export DOTFILES_DIR="$HOME/gh/jasonzhao6/dotfiles"
export ZSHRC_DIR="$DOTFILES_DIR/zshrc"
export ZSH_SECRETS="$HOME/.zshrc.secrets"

# Set color aliases early so they can expand in subsequent function definitions
source "$ZSHRC_DIR/colors.zsh"; color

# Load helpers
source "$ZSHRC_DIR/_keymap.zsh"
source "$ZSHRC_DIR/_reserved_keywords.zsh"
source "$ZSHRC_DIR/_utils.zsh"

# Load keymaps
source "$ZSHRC_DIR/args_keymap.zsh"
source "$ZSHRC_DIR/aws_keymap.zsh"
source "$ZSHRC_DIR/git_keymap.zsh"
source "$ZSHRC_DIR/main_keymap.zsh"
source "$ZSHRC_DIR/open_keymap.zsh"
source "$ZSHRC_DIR/zsh_keymap.zsh"

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

# Overwrite placeholders with secret values from `ZSH_SECRETS`
[[ -z $ZSHRC_UNDER_TEST && -f $ZSH_SECRETS ]] && source "$ZSH_SECRETS"
