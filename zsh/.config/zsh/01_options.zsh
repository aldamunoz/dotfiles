##
## Options
##
## History behavior (HISTFILE/HISTSIZE/hist_ignore_dups/share_history/etc.)
## is already set by Oh My Zsh's lib/history.zsh - only add what it doesn't
## cover here.

## Navigation
setopt AUTO_CD              # `foo` cds into ./foo instead of "command not found"
setopt AUTO_PUSHD           # every cd pushes the old dir onto the stack (see `dirs -v`, `cd -2`)
setopt PUSHD_IGNORE_DUPS    # don't push duplicates onto the directory stack

## Misc quality-of-life
setopt EXTENDED_GLOB        # enables ^, ~, # in globs (e.g. rm ^*.txt)
setopt INTERACTIVE_COMMENTS # allow `# comment` in interactive shell, useful when pasting snippets
setopt NO_BEEP              # no terminal bell on error
