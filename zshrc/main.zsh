export ZSHRC_DIR="$HOME/gh/dotfiles/zshrc"

# Enable color aliases first to allow their expansion in subsequent function definitions
source "$ZSHRC_DIR/colors.zsh"; color

source "$ZSHRC_DIR/args.zsh"
source "$ZSHRC_DIR/aws.zsh"
source "$ZSHRC_DIR/cd.zsh"
source "$ZSHRC_DIR/git.zsh"
source "$ZSHRC_DIR/git_info.zsh"
source "$ZSHRC_DIR/kubectl.zsh"
source "$ZSHRC_DIR/o.zsh"
source "$ZSHRC_DIR/t.zsh"
source "$ZSHRC_DIR/terraform.zsh"
source "$ZSHRC_DIR/util.zsh"
source "$ZSHRC_DIR/z.zsh"
source "$ZSHRC_DIR/zsh_arrow_keys.zsh"
source "$ZSHRC_DIR/zsh_history.zsh"
source "$ZSHRC_DIR/zsh_prompt.zsh" # Depends on `git_info`
