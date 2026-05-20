# histcomplete — дополнение целой команды из истории
# source ~/.local/share/histcomplete/bash-integration.sh
#
# Alt+h      — 1-е: список; 2-е: [1] или номер + Alt+h (например 3 + Alt+h)
# Ctrl+Alt+h — интерактивный выбор (ввод номера в prompt)
# ↑ / ↓     — листать команды с тем же префиксом

_hc_bin() {
    command -v histcomplete 2>/dev/null || echo "${HOME}/.local/bin/histcomplete"
}

_hc_session_export() {
    history 512 2>/dev/null | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//' || true
}

_hc_expand_reset() {
    _HC_EXPAND_QUERY=
    _HC_MATCHES=()
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

# Alt+h: список → подстановка [1] или выбор по номеру
_histcomplete_expand() {
    local cur="${READLINE_LINE}"
    local matches=() count i m idx

    [[ -n "$cur" ]] || return 1

    # После списка: номер в строке (3) или тот же префикс (ls) → подстановка
    if [[ -n "${_HC_EXPAND_QUERY:-}" && ${#_HC_MATCHES[@]} -gt 0 ]]; then
        matches=("${_HC_MATCHES[@]}")

        if [[ "$cur" =~ ^[0-9]+$ ]]; then
            idx=$((10#${cur} - 1))
            if (( idx >= 0 && idx < ${#matches[@]} )); then
                READLINE_LINE=${matches[idx]}
                READLINE_POINT=${#READLINE_LINE}
                _hc_expand_reset
                return 0
            fi
            printf '\nНет пункта %s (в списке %d)\n' "$cur" "${#matches[@]}" >&2
            _hc_expand_reset
            return 1
        fi

        if [[ "$cur" == "$_HC_EXPAND_QUERY" ]]; then
            READLINE_LINE=${matches[0]}
            READLINE_POINT=${#READLINE_LINE}
            _hc_expand_reset
            return 0
        fi

        _hc_expand_reset
    fi

    mapfile -t matches < <(_hc_matches "$cur") || true
    count=${#matches[@]}
    (( count > 0 )) || return 1

    _HC_EXPAND_QUERY=$cur
    _HC_MATCHES=("${matches[@]}")

    printf '\n' >&2
    i=1
    for m in "${matches[@]}"; do
        printf '  %2d) %s\n' "$i" "$m" >&2
        ((i++)) || true
    done
    printf '\nAlt+h — [1]; цифра + Alt+h — выбрать пункт; ↑↓ — листать «%s»\n' "$cur" >&2
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
    _hc_expand_reset
}

hc() {
    local cmd
    HISTCOMPLETE_EXTRA="$(_hc_session_export)"
    export HISTCOMPLETE_EXTRA
    cmd=$("$(_hc_bin)" --prefix -i -p "$@" 2>/dev/null) || return 1
    READLINE_LINE=$cmd
    READLINE_POINT=${#cmd}
    _hc_expand_reset
}

if [[ -n "${BASH_VERSION}" ]]; then
    bind '"\e[A": history-search-backward' 2>/dev/null || true
    bind '"\e[B": history-search-forward' 2>/dev/null || true
    bind '"\e[C": forward-word' 2>/dev/null || true
    bind '"\e[D": backward-word' 2>/dev/null || true

    bind -r '\C-i' 2>/dev/null || true
    bind '"\t": complete' 2>/dev/null || true
    bind '"\C-i": complete' 2>/dev/null || true

    bind -x '"\eh": _histcomplete_expand' 2>/dev/null || true
    bind -x '"\e\C-h": _histcomplete_bind' 2>/dev/null || true
fi
