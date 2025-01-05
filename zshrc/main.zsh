export DOTFILES_DIR="$HOME/gh/dotfiles"
export ZSHRC_DIR="$DOTFILES_DIR/zshrc"
export ZSHRC_TESTS_DIR="$DOTFILES_DIR/_tests"

# First, set color aliases so they expand in subsequent function definitions
source "$ZSHRC_DIR/colors.zsh"; color

source "$ZSHRC_DIR/args.zsh"
source "$ZSHRC_DIR/aws.zsh"
source "$ZSHRC_DIR/cd.zsh"
source "$ZSHRC_DIR/git.zsh"
source "$ZSHRC_DIR/git_info.zsh"
source "$ZSHRC_DIR/kubectl.zsh"
source "$ZSHRC_DIR/list.zsh"
source "$ZSHRC_DIR/open.zsh"
source "$ZSHRC_DIR/terraform.zsh"
source "$ZSHRC_DIR/util.zsh"
source "$ZSHRC_DIR/zsh_arrow_keys.zsh"
source "$ZSHRC_DIR/zsh_history.zsh"
source "$ZSHRC_DIR/zsh_prompt.zsh"
source "$ZSHRC_DIR/zshrc.zsh"

# Last, set secret values from `ZSHRC_SECRETS`
[[ -z $ZSHRC_UNDER_TEST && -f ~/.zshrc.secrets ]] && source ~/.zshrc.secrets
