#!/bin/bash

load_themes_list() {
    local json_file="$1"
    local -n themes_ref="$2"
    
    if [[ ! -f "$json_file" ]]; then
        echo -e "${COLOR_ERROR}Error: Themes file not found: $json_file${COLOR_RESET}" >&2
        return 1
    fi

    if ! mapfile -t themes_ref < <(jq -r '.[] | keys[]' "$json_file" 2>/dev/null); then
        echo -e "${COLOR_ERROR}Error: Failed to read themes from JSON file${COLOR_RESET}" >&2
        return 1
    fi

    if [[ ${#themes_ref[@]} -eq 0 ]]; then
        echo -e "${COLOR_ERROR}Error: No themes found in the file${COLOR_RESET}" >&2
        return 1
    fi

    return 0
}

get_theme_colors() {
    local theme_name="$1"
    local json_file="$2"
    local color_type="$3"  # "palette", "all", or specific color
    
    if [[ "$color_type" == "palette" ]]; then
        jq -r --arg name "$theme_name" \
            '.[] | select(has($name))[$name] | to_entries[] | select(.key|test("palette")) | .value' "$json_file"
    elif [[ "$color_type" == "all" ]]; then
        jq -r --arg name "$theme_name" \
            '.[] | select(has($name))[$name] | to_entries[] | select(.key|test("palette")|not) | "\(.key)=\(.value)"' "$json_file"
    else
        jq -r --arg name "$theme_name" \
            --arg color "$color_type" \
            '.[] | select(has($name))[$name] | .[$color] // empty' "$json_file"
    fi
}

check_theme_exists() {
    local theme_name="$1"
    local json_file="$2"
    
    local actual_theme_name
    actual_theme_name=$(jq -r --arg name "$theme_name" '
        .[] | to_entries[] | select(.key | ascii_downcase == ($name | ascii_downcase)) | .key
    ' "$json_file")
    
    if [[ -n "$actual_theme_name" ]]; then
        echo "$actual_theme_name"
        return 0
    else
        return 1
    fi
}
