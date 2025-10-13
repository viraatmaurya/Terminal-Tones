#!/bin/bash

search_themes() {
    local search_term="$1"
    local json_file="$2"
    
    # Use nameref to pass arrays back to caller
    local -n found_themes_ref="$3"
    local -n found_indexes_ref="$4"
    
    local lowercase_search="${search_term,,}"
    local counter=1
    
    local themes=()
    if ! load_themes_list "$json_file" themes; then
        return 1
    fi
    
    for i in "${!themes[@]}"; do
        local theme="${themes[$i]}"
        local lowercase_theme="${theme,,}"

        # Check for partial match (case-insensitive)
        if [[ "$lowercase_theme" == *"$lowercase_search"* ]]; then
            found_themes_ref+=("$counter: $theme")
            found_indexes_ref+=("$i")
            ((counter++))
        fi
    done
    
    return 0
}

interactive_theme_selection() {
    local json_file="$1"
    
    # Use nameref to pass theme name back to caller
    local -n theme_name_ref="$2"
    
    local themes=()
    if ! load_themes_list "$json_file" themes; then
        return 1
    fi
    
    echo ""
    echo ""
    echo "   Usage : Enter Desired Themes Numbers which you want to apply to Ghostty Terminal."
    echo ""
    
    while true; do
        echo
        echo -n "   Enter ONE theme number (or ENTER to quit): "
        read -r selection
        
        if [[ -z "$selection" ]]; then
            exit 0
        elif [[ "$selection" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#themes[@]} )); then
            theme_name_ref="${themes[$((selection-1))]}"
            echo
            echo -e " ${COLOR_SUCCESS}Theme : $selection : $theme_name_ref ${COLOR_RESET}"
            break
        else
            echo -n "   ${COLOR_ERROR}Invalid input. Please enter a number between 1 and ${#themes[@]}: ${COLOR_RESET}"
        fi
    done

    show_theme_preview "$theme_name_ref" "$json_file"
    return 0
}
