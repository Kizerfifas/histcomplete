# histcomplete — дополнение целой команды из истории
# source ~/.local/share/histcomplete/bash-integration.sh
#
# Alt+h      — 1-е: список (строка очищается); 2-е: номер+Alt+h или Alt+h = [1]
# Ctrl+Alt+h — интерактивный выбор (ввод номера в prompt)
# ↑ / ↓     — листать команды с тем же префиксом
#
# bind -x выполняется в подоболочке — состояние списка хранится в файле.

_hc_bin() {
    command -v histcomplete 2>/dev/null || echo "${HOME}/.local/bin/histcomplete"
}

_hc_state_file() {
    printf '%s/histcomplete/pending' "${XDG_CACHE_HOME:-${HOME}/.cache}"
}

_hc_session_export() {
    history 512 2>/dev/null | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//' || true
}

_hc_expand_reset() {
    rm -f "$(_hc_state_file)"
}

_hc_state_save() {
    local query="$1"
    shift
    local f matches=("$@") m
    f=$(_hc_state_file)
    mkdir -p "$(dirname "$f")"
    {
        printf '%s\0' "$query"
        for m in "${matches[@]}"; do
            printf '%s\0' "$m"
        done
    } >"$f"
}

_hc_state_load() {
    local f parts
    f=$(_hc_state_file)
    [[ -f "$f" ]] || return 1
    mapfile -d '' -t parts <"$f"
    ((${#parts[@]} >= 2)) || return 1
    _HC_EXPAND_QUERY=${parts[0]}
    _HC_MATCHES=("${parts[@]:1}")
    ((${#_HC_MATCHES[@]} > 0)) || return 1
}

_hc_matches() {
    local query="$1"
    local bin
    bin=$(_hc_bin)
    [[ -x "$bin" && -n "$query" ]] || return 1
    HISTCOMPLETE_EXTRA="$(_hc_session_export)"
    export HISTCOMPLETE_EXTRA
    "$bin" --prefix -n 50 "$query" 2>/dev/null
}

_histcomplete_expand() {
    local cur="${READLINE_LINE}"
    local matches=() count i m idx query

    if _hc_state_load; then
        matches=("${_HC_MATCHES[@]}")
        query=$_HC_EXPAND_QUERY

        if [[ "$cur" =~ ^[0-9]+$ ]]; then
            idx=$((10#${cur} - 1))
            if (( idx >= 0 && idx < ${#matches[@]} )); then
                READLINE_LINE=${matches[idx]}
                READLINE_POINT=${#READLINE_LINE}
                _hc_expand_reset
                return 0
            fi
            printf '\nНет пункта %s (в списке %d, искали «%s»)\n' "$cur" "${#matches[@]}" "$query" >&2
            _hc_expand_reset
            READLINE_LINE=
            READLINE_POINT=0
            return 1
        fi

        if [[ -z "$cur" ]]; then
            READLINE_LINE=${matches[0]}
            READLINE_POINT=${#READLINE_LINE}
            _hc_expand_reset
            return 0
        fi

        _hc_expand_reset
    fi

    [[ -n "$cur" ]] || return 1

    mapfile -t matches < <(_hc_matches "$cur") || true
    count=${#matches[@]}
    if (( count == 0 )); then
        printf '\nНет команд в истории с префиксом «%s»\n' "$cur" >&2
        return 1
    fi

    _hc_state_save "$cur" "${matches[@]}"

    printf '\n' >&2
    i=1
    for m in "${matches[@]}"; do
        printf '  %2d) %s\n' "$i" "$m" >&2
        ((i++)) || true
    done
    printf '\nНомер + Alt+h — выбрать; Alt+h без номера — [1]  (префикс: %s)\n' "$cur" >&2

    READLINE_LINE=
    READLINE_POINT=0
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
