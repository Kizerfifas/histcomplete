# histcomplete — дополнение целой команды из истории
# source ~/.local/share/histcomplete/bash-integration.sh
#
# Alt+h      — 1-е нажатие: список; 2-е: подставить [1] из списка
# Ctrl+Alt+h — интерактивный выбор по номеру
# ↑ / ↓     — листать команды с тем же префиксом

_hc_bin() {
    command -v histcomplete 2>/dev/null || echo "${HOME}/.local/bin/histcomplete"
}

_hc_session_export() {
    history 512 2>/dev/null | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//' || true
}

_hc_matches() {
    local query="$1"
    local bin
    bin=$(_hc_bin)
    [[ -x "$bin" && -n "$query" ]] || return 1
    HISTCOMPLETE_EXTRA="$(_hc_session_export)"
    export HISTCOMPLETE_EXTRA
    "$bin" --prefix -n 50 "$query"
}

# Alt+h: 1 — список, 2 — подставить первую строку (самую свежую)
_histcomplete_expand() {
    local cur="${READLINE_LINE}"
    local matches=() count i m

    [[ -n "$cur" ]] || return 1

    mapfile -t matches < <(_hc_matches "$cur") || true
    count=${#matches[@]}
    (( count > 0 )) || return 1

    # Второе Alt+h на той же строке — подставить [1]
    if [[ "${_HC_EXPAND_STATE:-}" == "$cur" ]]; then
        READLINE_LINE=${matches[0]}
        READLINE_POINT=${#READLINE_LINE}
        _HC_EXPAND_STATE=
        return 0
    fi

    # Первое Alt+h — только список (строку ввода не меняем)
    _HC_EXPAND_STATE=$cur
    printf '\n' >&2
    i=1
    for m in "${matches[@]}"; do
        printf '  %2d) %s\n' "$i" "$m" >&2
        ((i++)) || true
    done
    printf '\nAlt+h — подставить [1]; ↑↓ — листать по «%s»\n' "$cur" >&2
    return 0
}

_histcomplete_bind() {
    local bin cur cmd
    bin=$(_hc_bin)
    [[ -x "$bin" ]] || return 0
    cur=${READLINE_LINE}
    [[ -n "$cur" ]] || return 0
    HISTCOMPLETE_EXTRA="$(_hc_session_export)"
    export HISTCOMPLETE_EXTRA
    cmd=$("$bin" --prefix -i -p "$cur" 2>/dev/null) || return 1
    READLINE_LINE=$cmd
    READLINE_POINT=${#cmd}
}

hc() {
    local cmd
    HISTCOMPLETE_EXTRA="$(_hc_session_export)"
    export HISTCOMPLETE_EXTRA
    cmd=$("$(_hc_bin)" --prefix -i -p "$@" 2>/dev/null) || return 1
    READLINE_LINE=$cmd
    READLINE_POINT=${#cmd}
}

if [[ -n "${BASH_VERSION}" ]]; then
    bind '"\e[A": history-search-backward' 2>/dev/null || true
    bind '"\e[B": history-search-forward' 2>/dev/null || true
    bind '"\e[C": forward-word' 2>/dev/null || true
    bind '"\e[D": backward-word' 2>/dev/null || true

    # Снять старый перехват Tab (если обновлялись с прошлой версии)
    bind -r '\C-i' 2>/dev/null || true
    bind '"\t": complete' 2>/dev/null || true
    bind '"\C-i": complete' 2>/dev/null || true

    # Дополнение из истории — Alt+h (h = history)
    bind -x '"\eh": _histcomplete_expand' 2>/dev/null || true
    bind -x '"\e\C-h": _histcomplete_bind' 2>/dev/null || true
fi
