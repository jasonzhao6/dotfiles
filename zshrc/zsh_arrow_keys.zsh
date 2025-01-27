# History search (up / down)
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end

# Word separators (left / right)
WORDCHARS=${WORDCHARS/\.} # Exclude .
WORDCHARS=${WORDCHARS/\/} # Exclude /
WORDCHARS=${WORDCHARS/\=} # Exclude =
WORDCHARS+='|'
