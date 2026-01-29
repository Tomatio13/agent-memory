#!/bin/bash
#
# long_term.sh - Manage long-term memory (MEMORY.md)
#
# Usage:
#   long_term.sh add "section" "title" "contents"  - Add a formatted entry
#   long_term.sh read                    - Read entire MEMORY.md
#   long_term.sh search "keyword"        - Search MEMORY.md
#   long_term.sh tree                    - Show heading tree of MEMORY.md
#   long_term.sh section "heading"       - Extract a section by heading
#

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$(dirname "$SCRIPT_DIR")/memory"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"

# Ensure directory exists
mkdir -p "$MEMORY_DIR"

# Create MEMORY.md with header if it doesn't exist
if [ ! -f "$MEMORY_FILE" ]; then
    cat > "$MEMORY_FILE" << 'EOF'
# Long-term Memory

## User Preferences
### Title: Example
- time: YYYY/MM/DD HH:MM
- Contents: details

## Project Context
### Title: Example
- time: YYYY/MM/DD HH:MM
- Contents: details
EOF
fi

# Parse command
COMMAND="$1"

case "$COMMAND" in
    add)
        if [ $# -lt 4 ]; then
            echo "Usage: long_term.sh add \"section\" \"title\" \"contents\"" >&2
            echo "Example: long_term.sh add \"Project Context\" \"Created memory skill\" \"Implemented 2-layer memory system.\"" >&2
            exit 1
        fi

        SECTION="$2"
        TITLE="$3"
        shift 3
        CONTENTS="$*"
        TIMESTAMP=$(date +%Y/%m/%d' '%H:%M)

        if grep -q "^## $SECTION$" "$MEMORY_FILE"; then
            TEMP_FILE=$(mktemp)
            awk -v section="$SECTION" -v title="$TITLE" -v contents="$CONTENTS" -v timestamp="$TIMESTAMP" '
                BEGIN { in_section=0; inserted=0 }
                $0 == "## " section {
                    print
                    in_section=1
                    next
                }
                /^## / && in_section && !inserted {
                    print ""
                    print "### Title: " title
                    print "- time: " timestamp
                    print "- Contents: " contents
                    print ""
                    inserted=1
                    in_section=0
                    print
                    next
                }
                { print }
                END {
                    if (in_section && !inserted) {
                        print ""
                        print "### Title: " title
                        print "- time: " timestamp
                        print "- Contents: " contents
                    }
                }
            ' "$MEMORY_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MEMORY_FILE"
        else
            {
                echo ""
                echo "## $SECTION"
                echo "### Title: $TITLE"
                echo "- time: $TIMESTAMP"
                echo "- Contents: $CONTENTS"
            } >> "$MEMORY_FILE"
        fi

        echo "✓ Added entry to [$SECTION]: $TITLE"
        ;;

    read)
        cat "$MEMORY_FILE"
        ;;

    search)
        if [ $# -lt 2 ]; then
            echo "Usage: long_term.sh search \"keyword\"" >&2
            exit 1
        fi

        KEYWORD="$2"
        rg -i "$KEYWORD" "$MEMORY_FILE" --no-ignore -A 2 -B 1 || echo "No matches found"
        ;;
    tree)
        python3 "$SCRIPT_DIR/md-index.py" --tree "$MEMORY_FILE"
        ;;

    section)
        if [ $# -lt 2 ]; then
            echo "Usage: long_term.sh section \"heading\"" >&2
            exit 1
        fi

        HEADING="$2"
        python3 "$SCRIPT_DIR/md-index.py" --section "$HEADING" "$MEMORY_FILE"
        ;;

    *)
        echo "Usage: long_term.sh {add|read|search|tree|section}" >&2
        echo "" >&2
        echo "Commands:" >&2
        echo "  add \"section\" \"content\"  - Add content to a section" >&2
        echo "  read                        - Read entire MEMORY.md" >&2
        echo "  search \"keyword\"          - Search MEMORY.md" >&2
        echo "  tree                        - Show heading tree of MEMORY.md" >&2
        echo "  section \"heading\"         - Extract a section by heading" >&2
        exit 1
        ;;
esac
