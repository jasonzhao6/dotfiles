# Snapshot code stats
main_keymap_- | ruby_strip > "$ZSHRC_SRC_DIR"/_snapshots/_code_stats.txt

# Snapshot test stats
echo 'Test stats:' > "$ZSHRC_SRC_DIR"/_snapshots/_test_stats.txt

# Snapshot keymaps
main_keymap_a | grep '\$' | bw | while read -r line; do
  # Extract the command and the file name
  command=$(echo "$line" | awk '{print $2}')
  file=$(echo "$line" | awk '{print $NF}' | sed 's/\.zsh$/.txt/')

  # Execute the command and redirect output to the file
  if [[ -n $command && -n $file ]]; then
    eval "$command" | ruby_strip | bw > "$ZSHRC_SRC_DIR/_snapshots/$file"
  fi
done & # Run in the background so that testing can start right away
