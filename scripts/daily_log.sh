#!/bin/bash
#
# daily_log.sh - Append timestamped entries to today's daily log
#
# Usage: daily_log.sh "content to log"
#

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="$(dirname "$SCRIPT_DIR")/memory"

# Ensure directory exists
mkdir -p "$MEMORY_DIR"

# Get today's date and current time
TODAY=$(date +%Y-%m-%d)
NOW=$(date +%H:%M)
LOG_FILE="$MEMORY_DIR/$TODAY.md"

# Check argument
if [ $# -eq 0 ]; then
    echo "Usage: daily_log.sh \"content to log\"" >&2
    echo "Example: daily_log.sh \"Discussed API architecture, decided to use REST\"" >&2
    exit 1
fi

CONTENT="$*"

# Create file with header if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo "# $TODAY" > "$LOG_FILE"
    echo "" >> "$LOG_FILE"
fi

# Append entry with timestamp
echo "## $NOW - $CONTENT" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Success output
echo "✓ Logged to: $LOG_FILE"
