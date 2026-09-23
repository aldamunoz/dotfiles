##
## Third-party tool shell integrations
##

## zoxide: smarter cd, adds `z`/`zi` commands (frecency-based directory jump)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
