#!/bin/bash

apply_random_theme() {
    local json_file="$1"
    
    # Use nameref to pass theme name back to caller
    local -n theme_name_ref="$2"
    
    local themes=()
    if load_themes_list "$json_file" themes; then
        local random_index=$((RANDOM % ${#themes[@]}))
        theme_name_ref="${themes[$random_index]}"
        echo -e "${COLOR_SUCCESS}Randomly selected: ${COLOR_PRIMARY}$theme_name_ref${COLOR_RESET}"
        return 0
    else
        return 1
    fi
}

# ... rest of the file remains the same ...
export_theme_colors() {
    local theme_name="$1"
    local theme_dir="$2"
    local json_file="$3"

    local out_file="$theme_dir/$theme_name"
    
    if [[ -z "$theme_name" ]]; then
        echo -e "${COLOR_ERROR}[✘] No theme name provided.${COLOR_RESET}"
        return 1
    fi

    if [[ ! -d "$theme_dir" ]]; then
        echo -e "${COLOR_WARNING}[ℹ] Output directory not found, creating: $theme_dir${COLOR_RESET}"
        mkdir -p "$theme_dir"
        if [[ $? -ne 0 ]]; then
            echo -e "${COLOR_ERROR}[✘] Failed to create directory: $theme_dir${COLOR_RESET}"
            return 1
        fi
    fi

    # Check if theme exists
    local actual_theme_name
    actual_theme_name=$(check_theme_exists "$theme_name" "$json_file")
    
    if [[ -z "$actual_theme_name" ]]; then
        echo -e "${COLOR_ERROR}[✘] Theme '$theme_name' not found in the JSON file${COLOR_RESET}"
        echo -e "${COLOR_WARNING}[ℹ] Available themes with similar names:${COLOR_RESET}"
        
        # Show similar theme names
        jq -r '.[] | keys[]' "$json_file" | grep -i "$theme_name" | head -5 | while read -r similar; do
            echo "   - $similar"
        done
        
        return 1
    fi

    # Use the actual theme name from the JSON file
    theme_name="$actual_theme_name"

    # Extract all color values (palette + others) and remove quotes
    if ! jq -r --arg name "$theme_name" '
        .[] | select(has($name))[$name] | to_entries[] | .value
    ' "$json_file" > "$out_file"; then
        echo -e "${COLOR_ERROR}[✘] Failed to extract theme colors from JSON file${COLOR_RESET}"
        return 1
    fi

    echo ""
    echo -e "   ${COLOR_SUCCESS}[✔] Theme '${COLOR_PRIMARY}$theme_name${COLOR_SUCCESS}' exported to:${COLOR_INFO} $out_file${COLOR_RESET}"
    echo ""
    echo -e "   ${COLOR_SUCCESS}[✔] Please restart or reload your terminal configuration to see the applied theme.${COLOR_RESET}"
    echo ""
    echo -e "   ${COLOR_SUCCESS}[ℹ] To reload in Ghostty, press ${COLOR_PRIMARY}[Shift] + [Ctrl] + [,]${COLOR_SUCCESS}.${COLOR_RESET}"
    echo ""
    
    return 0
}

set_ghostty_theme() {
    local config_file="$1"
    local theme_name="$2"
    local theme_dir="$3"
    local json_file="$4"

    if [[ ! -f "$config_file" ]]; then
        echo "Config file not found: $config_file"
        echo "Creating default config file..."
        mkdir -p "$(dirname "$config_file")"
        touch "$config_file"
    fi

    # Replace 'theme = oldvalue' with 'theme = NewThemeName'
    if grep -q "^theme[[:space:]]*=" "$config_file"; then
        sed -i -E "s/^(theme[[:space:]]*=[[:space:]]*).*/\1$theme_name/" "$config_file"
    else
        # If theme setting doesn't exist, add it
        echo "theme = $theme_name" >> "$config_file"
    fi

    export_theme_colors "$theme_name" "$theme_dir" "$json_file"
}
