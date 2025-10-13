#!/bin/bash

setup_logging() {
    local theme_name="$1"
    local log_dir="$LOG_DIR"
    local log_file="$LOG_FILE"

    mkdir -p "$log_dir"
    echo "$(date): Theme changed to $theme_name" >> "$log_file"
}

calculate_columns() {
    local themes_count="$1"
    local -n cols_ref="$2"
    local -n col_width_ref="$3"

    # Get terminal dimensions with fallbacks
    local term_width
    if command -v tput >/dev/null 2>&1; then
        term_width=$(tput cols 2>/dev/null || echo 80)
    else
        term_width=80
    fi

    # Validate terminal width
    if [[ ! "$term_width" =~ ^[0-9]+$ ]] || [[ $term_width -lt 20 ]]; then
        term_width=80
    fi

    local max_cols=3
    local min_col_width=25

    # Calculate optimal columns
    local calculated_cols=$(( term_width / min_col_width ))
    calculated_cols=$(( calculated_cols < 1 ? 1 : calculated_cols ))
    calculated_cols=$(( calculated_cols > max_cols ? max_cols : calculated_cols ))

    # Adjust based on actual theme count
    if [[ $themes_count -lt $calculated_cols ]]; then
        calculated_cols=$themes_count
    fi

    # Calculate column width
    local calculated_col_width=$(( term_width / calculated_cols ))

    # Ensure minimum padding
    calculated_col_width=$(( calculated_col_width > min_col_width ? calculated_col_width : min_col_width ))

    cols_ref=$calculated_cols
    col_width_ref=$calculated_col_width

    return 0
}

confirm_application() {
    local theme_name="$1"
    
    read -p "   Apply this theme? (Y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "  ↩️  Let's try another theme..."
        return 1
    else
        echo -e "  ${COLOR_SUCCESS}✨ Applying theme: ${COLOR_PRIMARY}$theme_name${COLOR_RESET}"
        return 0
    fi
}
