#!/bin/bash
#
# long_term.sh - Manage long-term memory (MEMORY.md)
#
# Usage:
#   long_term.sh add "section" "content"  - Add content to a section
#   long_term.sh read                    - Read entire MEMORY.md
#   long_term.sh search "keyword"        - Search MEMORY.md
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
<!-- Add user preferences here -->

## Important Decisions
<!-- Add important decisions here -->

## Key Contacts
<!-- Add key contacts here -->

## Project Context
<!-- Add project context here -->

## Troubleshooting
<!-- Add troubleshooting notes here -->
EOF
fi

# Parse command
COMMAND="$1"

case "$COMMAND" in
    add)
        if [ $# -lt 3 ]; then
            echo "Usage: long_term.sh add \"section\" \"content\"" >&2
            echo "Example: long_term.sh add \"User Preferences\" \"Prefers TypeScript over JavaScript\"" >&2
            exit 1
        fi

        SECTION="$2"
        CONTENT="$3"
        TIMESTAMP=$(date +%Y-%m-%d)

        # Check if section exists
        if grep -q "^## $SECTION" "$MEMORY_FILE"; then
            # Section exists - append after it
            # Create temp file
            TEMP_FILE=$(mktemp)
            awk -v section="$SECTION" -v content="$CONTENT" -v timestamp="$TIMESTAMP" '
                $0 == "## " section {
                    print
                    # Find the next section or end of file
                    while ((getline line) > 0) {
                        if (line ~ /^## /) {
                            # Next section found, insert before it
                            print "- " timestamp ": " content
                            print line
                            # Print rest of file
                            while ((getline) > 0) print
                            exit
                        }
                        print line
                    }
                    # End of file, insert content
                    print "- " timestamp ": " content
                    exit
                }
                { print }
            ' "$MEMORY_FILE" > "$TEMP_FILE"
            mv "$TEMP_FILE" "$MEMORY_FILE"
        else
            # Section doesn't exist - create it at the end
            echo "" >> "$MEMORY_FILE"
            echo "## $SECTION" >> "$MEMORY_FILE"
            echo "- $TIMESTAMP: $CONTENT" >> "$MEMORY_FILE"
        fi

        echo "✓ Added to [$SECTION]: $CONTENT"
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

    *)
        echo "Usage: long_term.sh {add|read|search}" >&2
        echo "" >&2
        echo "Commands:" >&2
        echo "  add \"section\" \"content\"  - Add content to a section" >&2
        echo "  read                        - Read entire MEMORY.md" >&2
        echo "  search \"keyword\"          - Search MEMORY.md" >&2
        exit 1
        ;;
esac
