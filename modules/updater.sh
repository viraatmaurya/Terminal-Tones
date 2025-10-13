#!/bin/bash

update_theme_repository() {
    git pull

    wget -q -O temp.json "https://raw.githubusercontent.com/Gogh-Co/Gogh/master/data/themes.json"
    
    # Check if input file exists
    if [ ! -f "temp.json" ]; then
        echo "   Error: Input file not found!"
        return 1
    fi
    
    if [ ! -f "update.py" ]; then
        echo "  update.py file not found!"
        return 1
    fi
    
    echo "  🔄 Update Started .."

    python3 update.py "temp.json" "themes.json"
    if [ $? -eq 0 ]; then
        echo -e "  ${COLOR_SUCCESS}[✔] Themes updation completed successfully!${COLOR_RESET}"
        echo ""
    else
        echo -e "${COLOR_ERROR}❌ Update failed!${COLOR_RESET}"
        return 1
    fi
    rm temp.json
    return 0
}

check_theme_file() {
    local json_file="$1"
    
    if [[ ! -f "$json_file" ]]; then
        echo -e "${COLOR_ERROR}[✘] Theme JSON file not found:${COLOR_RESET} $json_file"
        echo ""
        echo "Downloading Theme file from Github."
        wget -q -O temp.json "https://raw.githubusercontent.com/Gogh-Co/Gogh/master/data/themes.json"
        
        if [[ ! -f "update.py" ]]; then
            echo -e "${COLOR_ERROR}[✘] update.py not found, cannot process theme file${COLOR_RESET}"
            rm -f temp.json
            return 1
        fi
        
        python3 update.py temp.json themes.json
        rm temp.json
        
        if [[ $? -ne 0 ]]; then
            echo -e "${COLOR_ERROR}[✘] Failed to download themes.json from Github${COLOR_RESET}"
            return 1
        fi
        
        echo -e "${COLOR_SUCCESS}[✔] Theme file downloaded successfully!${COLOR_RESET}"
        echo ""
    fi
    
    # Verify the downloaded file is valid JSON
    if ! jq empty "$json_file" 2>/dev/null; then
        echo -e "${COLOR_ERROR}[✘] Downloaded file is not valid JSON${COLOR_RESET}"
        rm -f "$json_file"
        return 1
    fi
    
    return 0
}
