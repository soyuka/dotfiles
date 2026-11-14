#!/bin/bash
# One line: <vim mode> | <model> | <peer name> | effort:<level> | <used>/<total> <pct>%
# Vim mode, peer name and effort are omitted when absent; the token part is
# colored by context usage (green <50, orange 50-69, yellow 70-89, red >=90).
# Also refreshes the OAuth usage cache (60s TTL) that tmux-claude-usage reads
# for the tmux status bar; the cache path is overridable via CLAUDE_USAGE_CACHE.

set -f  # disable globbing

input=$(cat)

if [ -z "$input" ]; then
    printf "Claude"
    exit 0
fi

# ANSI colors matching oh-my-posh theme
blue='\033[38;2;0;153;255m'
orange='\033[38;2;255;176;85m'
green='\033[38;2;0;160;0m'
cyan='\033[38;2;46;149;153m'
red='\033[38;2;255;85;85m'
yellow='\033[38;2;230;200;0m'
white='\033[38;2;220;220;220m'
dim='\033[2m'
reset='\033[0m'

# Format token counts (e.g., 50k / 200k)
format_tokens() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fm\", $num / 1000000}"
    elif [ "$num" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fk\", $num / 1000}"
    else
        printf "%d" "$num"
    fi
}

# ===== Extract data from JSON =====
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
peer_name=""
if [ -n "$session_id" ]; then
    # find, not a glob: set -f above disables globbing.
    peer_name=$(find "${CLAUDE_SESSIONS_DIR:-$HOME/.claude/sessions}" -maxdepth 1 -name '*.json' -exec cat {} + 2>/dev/null | \
        jq -r --arg sid "$session_id" 'select(.sessionId == $sid) | .name // empty' 2>/dev/null | tail -n 1)
fi

# Context window
size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
[ "$size" -eq 0 ] 2>/dev/null && size=200000

# Token usage
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
current=$(( input_tokens + cache_create + cache_read ))

used_tokens=$(format_tokens $current)
total_tokens=$(format_tokens $size)

if [ "$size" -gt 0 ]; then
    pct_used=$(( current * 100 / size ))
else
    pct_used=0
fi

# Effort level color and label
effort_str=""
if [ -n "$effort_level" ]; then
    case "$effort_level" in
        low)    effort_str="${dim}effort:low${reset}" ;;
        medium) effort_str="${white}effort:medium${reset}" ;;
        high)   effort_str="${orange}effort:high${reset}" ;;
        xhigh)  effort_str="${red}effort:xhigh${reset}" ;;
        max)    effort_str="${red}effort:MAX${reset}" ;;
        *)      effort_str="${white}effort:${effort_level}${reset}" ;;
    esac
fi

# ===== Cross-platform OAuth token resolution (from statusline.sh) =====
# Tries credential sources in order: env var → macOS Keychain → Linux creds file → GNOME Keyring
get_oauth_token() {
    local token=""

    # 1. Explicit env var override
    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo "$CLAUDE_CODE_OAUTH_TOKEN"
        return 0
    fi

    # 2. macOS Keychain
    if command -v security >/dev/null 2>&1; then
        local blob
        blob=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        if [ -n "$blob" ]; then
            token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                echo "$token"
                return 0
            fi
        fi
    fi

    # 3. Linux credentials file
    local creds_file="${HOME}/.claude/.credentials.json"
    if [ -f "$creds_file" ]; then
        token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_file" 2>/dev/null)
        if [ -n "$token" ] && [ "$token" != "null" ]; then
            echo "$token"
            return 0
        fi
    fi

    # 4. GNOME Keyring via secret-tool
    if command -v secret-tool >/dev/null 2>&1; then
        local blob
        blob=$(timeout 2 secret-tool lookup service "Claude Code-credentials" 2>/dev/null)
        if [ -n "$blob" ]; then
            token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
            if [ -n "$token" ] && [ "$token" != "null" ]; then
                echo "$token"
                return 0
            fi
        fi
    fi

    echo ""
}

# ===== Usage cache refresh (read by tmux-claude-usage) =====
cache_file="${CLAUDE_USAGE_CACHE:-/tmp/claude/statusline-usage-cache.json}"
cache_max_age=60  # seconds between API calls
mkdir -p "$(dirname "$cache_file")"

needs_refresh=true
if [ -f "$cache_file" ]; then
    cache_mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)
    now=$(date +%s)
    if [ $(( now - cache_mtime )) -lt "$cache_max_age" ]; then
        needs_refresh=false
    fi
fi

if $needs_refresh; then
    token=$(get_oauth_token)
    if [ -n "$token" ] && [ "$token" != "null" ]; then
        response=$(curl -s --max-time 5 \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "User-Agent: claude-code/2.1.34" \
            "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
        if [ -n "$response" ] && echo "$response" | jq . >/dev/null 2>&1; then
            echo "$response" > "$cache_file"
        fi
    fi
fi

# ===== Output =====
if [ "$pct_used" -ge 90 ]; then tokens_color="$red"
elif [ "$pct_used" -ge 70 ]; then tokens_color="$yellow"
elif [ "$pct_used" -ge 50 ]; then tokens_color="$orange"
else tokens_color="$green"
fi

line=""
if [ -n "$vim_mode" ]; then
    case "$vim_mode" in
        NORMAL) vim_color="$yellow" ;;
        INSERT) vim_color="$green" ;;
        *)      vim_color="$white" ;;
    esac
    line+="${vim_color}${vim_mode}${reset} ${dim}|${reset} "
fi
line+="${blue}${model_name}${reset}"
[ -n "$peer_name" ] && line+=" ${dim}|${reset} ${cyan}${peer_name}${reset}"
[ -n "$effort_str" ] && line+=" ${dim}|${reset} ${effort_str}"
line+=" ${dim}|${reset} ${tokens_color}${used_tokens}/${total_tokens} ${pct_used}%${reset}"

printf "%b" "$line"

exit 0
