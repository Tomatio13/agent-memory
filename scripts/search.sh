#!/bin/bash
#
# search.sh - Unified search across all memory files
#
# Usage: search.sh "keyword" [--daily|--long|--all]
#

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$(dirname "$SCRIPT_DIR")/memory"
MD_INDEX="$SCRIPT_DIR/md-index.py"

# Ensure directory exists
if [ ! -d "$MEMORY_DIR" ]; then
    echo "Error: Memory directory not found: $MEMORY_DIR" >&2
    exit 1
fi

# Parse arguments
QUERY="$1"
SCOPE="${2:---all}"

# Validate arguments
if [ -z "$QUERY" ]; then
    echo "Usage: search.sh \"keyword\" [--daily|--long|--all]" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --daily    Search only daily logs (memory/*.md)" >&2
    echo "  --long     Search only long-term memory (MEMORY.md)" >&2
    echo "  --all      Search all memory files (default)" >&2
    exit 1
fi

# Perform search based on scope
case "$SCOPE" in
    --daily)
        # Search only daily log files (not MEMORY.md)
        rg -i "$QUERY" "$MEMORY_DIR"/*.md --no-ignore --hidden -A 2 -B 1 --ignore-case \
            --glob='!MEMORY.md' || echo "No matches found in daily logs"
        ;;

    --long)
        # Search only MEMORY.md
        if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
            if [ -f "$MD_INDEX" ]; then
                if python3 "$MD_INDEX" --section "$QUERY" "$MEMORY_DIR/MEMORY.md"; then
                    exit 0
                fi
                echo "No matching section found; falling back to keyword search." >&2
            fi
            rg -i "$QUERY" "$MEMORY_DIR/MEMORY.md" --no-ignore -A 2 -B 1 || echo "No matches found in long-term memory"
        else
            echo "Long-term memory file not found: $MEMORY_DIR/MEMORY.md" >&2
            exit 1
        fi
        ;;

    --all|*)
        # Search all memory files
        rg -i "$QUERY" "$MEMORY_DIR/" --no-ignore --hidden -A 2 -B 1 || echo "No matches found"
        ;;
esac
