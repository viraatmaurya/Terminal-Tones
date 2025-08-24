#!/bin/bash

set -e



AUTHOR="Viraat Maurya"
VERSION="1.0.0"
LICENSE="MIT"

echo ""
echo ""
echo -e "
                ░▀█▀░█▀▀░█▀▄░█▄█░▀█▀░█▀█░█▀█░█░░░░░▀█▀░█▀█░█▀█░█▀▀░█▀▀
                ░░█░░█▀▀░█▀▄░█░█░░█░░█░█░█▀█░█░░░░░░█░░█░█░█░█░█▀▀░▀▀█
                ░░▀░░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀░▀░▀░▀▀▀░░░░▀░░▀▀▀░▀░▀░▀▀▀░▀▀▀
"

banner=$(cat <<'EOF'
\e[1;36m
      ╔══════════════════════════════════════════════════════════════════════╗
      ║           \e[1;31mT\e[1;32mE\e[1;33mR\e[1;34mM\e[1;35mI\e[1;36mN\e[1;91mA\e[1;92mL\e[1;93m \e[1;94mT\e[1;95mO\e[1;96mN\e[1;97mE\e[1;96mS\e[1;97m - \e[1;92mColor Themes for Ghostty Terminal\e[1;36m         ║
      ╚══════════════════════════════════════════════════════════════════════╝
\e[0m

\e[1;33m
            ┌────────────────────────────────────────────────────────────┐
            │   \e[1;36mCreated by: \e[1;93mViraat Maurya\e[1;33m                                │
            │   \e[1;36mInstagram: \e[1;95mhttps://www.instagram.com/viraat_maurya/\e[1;33m      │
            │   \e[1;36mGithub: \e[1;95mhttps://www.github.com/viraatmaurya/\e[1;33m             │
            │   \e[1;36mColor palettes courtesy of: \e[1;35mGogh Theme Manager\e[1;33m           │
            └────────────────────────────────────────────────────────────┘
\e[0m
EOF
)


show_version(){
    echo ""
    echo "      Terminal Tones Version : "$VERSION" "
    echo ""
}



setup_logging() {
    local theme_name="$1"
    local log_dir="$HOME/.local/share/ghostty-themes"
    local log_file="$log_dir/theme_changes.log"

    mkdir -p "$log_dir"
    echo "$(date): Theme changed to $theme_name" >> "$log_file"
}

show_help() {
    cat << EOF
    Usage: $(basename "$0") [OPTIONS]

    Color Themes Manager for Ghostty Terminal

    $(basename "$0")                 Interactive theme selection

    Options:
      -v, --version        Show program version
      -h, --help           Show this help message
      -s, --search TERM    Search for themes containing TERM
      -r, --random         Apply a random theme
      -l, --list           List all available themes
      -u, --update         Update themes from GitHub
      -q, --quit           No banner

    Examples:
      
      $(basename "$0") -s "dark"       Search for dark themes
      $(basename "$0") -r              Apply random theme
      $(basename "$0") -l              List all themes without selection

EOF
echo ""
}



update_themes(){

    git pull

    wget -q -O temp.json "https://raw.githubusercontent.com/Gogh-Co/Gogh/master/data/themes.json"
    
    # Check if input file exists
    if [ ! -f "temp.json" ]; then
        echo "   Error: Input file  not found!"
        return 1
    fi
    if [ ! -f "update.py" ]; then
        echo "  update.py file not found!"
        exit 1
    fi
    echo "  🔄 Update Started .."
    python3 update.py "temp.json" "themes.json"
    if [ $? -eq 0 ]; then
        echo "  [✔  ]Themes updation completed successfully!"
        echo ""
    else
        echo "❌ Update failed!"
        exit 1
    fi
    rm temp.json

}


search_themes() {
    local search_term="$1"
    local found_themes=()
    local found_indexes=()
    local lowercase_search="${search_term,,}"  # Convert to lowercase for case-insensitive matching
    local counter=1
    
    for i in "${!themes[@]}"; do
        local theme="${themes[$i]}"
        local lowercase_theme="${theme,,}"  # Convert theme to lowercase for comparison
        
        # Check for partial match (case-insensitive)
        if [[ "$lowercase_theme" == *"$lowercase_search"* ]]; then
            found_themes+=("$counter: $theme")
            found_indexes+=("$i")  # Store the actual array index
            ((counter++))
        fi
    done
    
    if [[ ${#found_themes[@]} -gt 0 ]]; then
        echo "  Found ${#found_themes[@]} theme(s) matching '$search_term':"
        echo "────────────────────────────────────────────────────────────"
        printf '    %s\n' "${found_themes[@]}"
        echo "────────────────────────────────────────────────────────────"
        
        # Ask user if they want to set one of the found themes
        echo ""
        while true; do
            read -p "   ↩️ Did  you found the theme in this list? (y/N): " -n 1 -r
            echo ""
            
            case $REPLY in
                [Yy])
                    echo ""
                    echo "  🎨 Available themes:"
                    echo "────────────────────"
                    
                    # Show first 10 themes with preview option
                    for ((i=0; i<${#found_themes[@]} && i<10; i++)); do
                        echo "   ${found_themes[$i]}"
                    done
                    
                    if [[ ${#found_themes[@]} -gt 10 ]]; then
                        echo "   ... and $(( ${#found_themes[@]} - 10 )) more themes"
                    fi
                    
                    echo ""
                    
                    # Theme selection loop
                    while true; do
                        read -p "   Enter theme number (1-${#found_themes[@]}) or 'a/A' to see all themes or 'q' to quit: " selection
                        
                        case $selection in
                            [Qq])
                                echo "  🚫 Search cancelled."
                                exit 0
                                ;;
                            [Aa])
                                echo ""
                                echo "  📋 All matching themes:"
                                echo "───────────────────────"
                                printf '    %s\n' "${found_themes[@]}"
                                echo "───────────────────────"
                                echo ""
                                continue
                                ;;
                            *)
                                if [[ "$selection" =~ ^[0-9]+$ ]]; then
                                    if (( selection >= 1 && selection <= ${#found_themes[@]} )); then
                                        local actual_index=${found_indexes[$((selection-1))]}
                                        theme_name="${themes[$actual_index]}"
                                        echo ""
                                        echo "  ✅ Selected theme: $theme_name"
                                        
                                        # Show theme preview
                                        echo -n "   🎨 Colors: "
                                        local palettes=()
                                        mapfile -t palettes < <(jq -r --arg name "$theme_name" \
                                            '.[] | select(has($name))[$name] | to_entries[] | select(.key|test("palette")) | .value' "$json_file")
                                        
                                        for c in "${palettes[@]}"; do
                                            printf "%s " "$(color_circle "$c")"
                                        done
                                        echo ""
                                        echo ""
                                        
                                        # Final confirmation
                                        read -p "   Apply this theme? (Y/n): " -n 1 -r
                                        echo ""
                                        if [[ $REPLY =~ ^[Nn]$ ]]; then
                                            echo "  ↩️  Let's try another theme..."
                                            continue
                                        else
                                            echo "  ✨ Applying theme: $theme_name"
                                            break 2  # Break out of both loops
                                        fi
                                    else
                                        echo "  ❌ Please enter a number between 1 and ${#found_themes[@]}"
                                    fi
                                else
                                    echo "  ❌ Please enter a valid number, 'A/a' to see all themes, or 'q' to quit"
                                fi
                                ;;
                        esac
                    done
                    ;;
                [Nn]|"")
                    echo "  👋 Search completed. No theme selected."
                    exit 0
                    ;;
                *)
                    echo "  ❌ Please answer 'y' for yes or 'n' for no"
                    ;;
            esac
        done
    else
        echo "  ❌ No themes found matching '$search_term'"
        echo "  💡 Try a broader search term or use -l to list all available themes."
        exit 1
    fi
}


convert_ghogh_to_ghostty() {
    local input="$1"
    local output="$2"

    if [ ! -f "$input" ]; then
        echo "Error: input file not found: $input"
        exit 1
    fi

    jq '
      # helper function to zero-pad single-digit numbers
      def lpad:
        if (.|length) == 1 then "0"+. else . end;

      [ .[] |
        {
          (.name): (
            reduce range(0;16) as $i ({}; 
              .["palette = \($i)"] = .["color_" + ($i|tostring|lpad)]
            )
            + (if .background then {background: "background = \(.background)"} else {} end)
            + (if .foreground then {foreground: "foreground = \(.foreground)"} else {} end)
            + (if .cursor then {"cursor-color": "cursor-color = \(.cursor)"} else {} end)
          )
        }
      ]
    ' "$input" > "$output"

    echo "✓ Done  $input → $output"
}





random_theme() {
    local random_index=$((RANDOM % ${#themes[@]}))
    theme_name="${themes[$random_index]}"
    echo "Randomly selected: $theme_name"
}


verify_ghostty_install() {
    if ! command -v ghostty >/dev/null 2>&1; then
        echo "Error: Ghostty terminal is not installed"
        echo "Please install Ghostty first: https://ghostty.org/"
        exit 1
    fi
    
    if [[ ! -d "$HOME/.config/ghostty" ]]; then
        mkdir -p "$HOME/.config/ghostty"
        echo "Created Ghostty config directory"
    fi
} 

check_theme_file(){
    local json_file="$1"
    
    if [[ ! -f "$json_file" ]]; then
        echo -e "\e[1;31m[✘] Theme JSON file not found:\e[0m $json_file"
        echo ""
        echo "Downloading Theme file from Github."
        wget -q -O temp.json "https://raw.githubusercontent.com/Gogh-Co/Gogh/master/data/themes.json"
        python3 update.py temp.json themes.json
        rm temp.json
        
        if [[ $? -ne 0 ]]; then
            echo -e "\e[1;31m[✘] Failed to download themes.json from Github\e[0m"
            return 1
        fi
        
        echo -e "\e[1;32m[✔ ] Theme file downloaded successfully!\e[0m"
        echo ""
    fi
    
    # Verify the downloaded file is valid JSON
    if ! jq empty "$json_file" 2>/dev/null; then
        echo -e "\e[1;31m[✘] Downloaded file is not valid JSON\e[0m"
        rm -f "$json_file"
        return 1
    fi
    
    return 0
}

install_deps() {
    # Detect OS
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        os=$ID
    elif [[ $(uname) == "Darwin" ]]; then
        os="macos"
    else
        echo "Unsupported OS"
        return 1
    fi

    # Detect WSL
    if grep -qi "microsoft" /proc/version 2>/dev/null || [[ -n "$WSL_DISTRO_NAME" ]]; then
        os="wsl-$os"
    fi

    # Collect missing deps
    missing=()
    for dep in "$@"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    # Nothing to install
    [[ ${#missing[@]} -eq 0 ]] && return 0

    echo -e "\033[0;32mInstalling dependencies: ${missing[*]}\033[0m"

    case $os in
        ubuntu|debian|linuxmint|wsl-ubuntu|wsl-debian)
            sudo apt update -y
            sudo apt install -y "${missing[@]}"
            ;;
        centos|rhel|fedora|wsl-centos|wsl-rhel|wsl-fedora)
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y "${missing[@]}"
            else
                sudo yum install -y "${missing[@]}"
            fi
            ;;
        arch|manjaro|wsl-arch|wsl-manjaro)
            sudo pacman -Sy --noconfirm "${missing[@]}"
            ;;
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                echo "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install "${missing[@]}"
            ;;
        *)
            echo "Unsupported OS: $os"
            return 1
            ;;
    esac
}

get_missing_dependencies() {
    local missing=()
    
    for dep in "$@"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠️  The following required dependencies are missing:"
        for dep in "${missing[@]}"; do
            echo "   - $dep"
        done
        echo ""
    
        # Ask user for confirmation
        read -p "Do you want to install these dependencies? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_deps "${missing[@]}"
        else
            echo "❌ Installation cancelled. Some features may not work without these dependencies."
            exit 1
        fi
    fi
}

export_theme_colors() {
    local theme_name="$1"
    local out_dir="$2"
    local json_file="$3"

    local out_file="$out_dir/$theme_name"
    
    if [[ -z "$theme_name" ]]; then
        echo -e "\e[1;31m[✘] No theme name provided.\e[0m"
        return 1
    fi

    if [[ ! -d "$out_dir" ]]; then
        echo -e "\e[1;33m[ℹ] Output directory not found, creating:\e[0m $out_dir"
        mkdir -p "$out_dir"
        if [[ $? -ne 0 ]]; then
            echo -e "\e[1;31m[✘] Failed to create directory: $out_dir\e[0m"
            return 1
        fi
    fi

    # Check if theme exists in JSON file (case-insensitive search)
    local actual_theme_name
    actual_theme_name=$(jq -r --arg name "$theme_name" '
        .[] | to_entries[] | select(.key | ascii_downcase == ($name | ascii_downcase)) | .key
    ' "$json_file")
    
    if [[ -z "$actual_theme_name" ]]; then
        echo -e "\e[1;31m[✘] Theme '$theme_name' not found in the JSON file\e[0m"
        echo -e "\e[1;33m[ℹ] Available themes with similar names:\e[0m"
        
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
        echo -e "\e[1;31m[✘] Failed to extract theme colors from JSON file\e[0m"
        return 1
    fi

    echo ""
    echo -e "   \e[1;32m[✔  ] Theme '\e[1;97m$theme_name\e[1;32m' exported to:\e[36m $out_file\e[0m"
    echo ""
    echo -e "   \e[1;32m[✔  ] Please restart or reload your terminal configuration to see the applied theme.\e[0m"
    echo ""
    echo -e "   \e[1;32m[ℹ  ] To reload in Ghostty, press \e[1;97m[Shift] + [Ctrl] + [,]\e[1;32m.\e[0m"
    echo ""
}

set_theme() {
    local config_file="$1"
    local new_theme="$2"
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
        sed -i -E "s/^(theme[[:space:]]*=[[:space:]]*).*/\1$new_theme/" "$config_file"
    else
        # If theme setting doesn't exist, add it
        echo "theme = $new_theme" >> "$config_file"
    fi

    export_theme_colors "$new_theme" "$theme_dir" "$json_file"
}

calculate_columns() {
    local themes_count="$1"
    local -n cols_ref="$2"  # Nameref to return values
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

get_themes_list() {
    local file="$1"
    local -n themes_ref="$2"  # Nameref to return array to caller

    # Basic checks
    if [[ ! -f "$file" ]]; then
        echo "Error: Themes file not found: $file" >&2
        return 1
    fi

    # Read theme names
    if ! mapfile -t themes_ref < <(jq -r '.[] | keys[]' "$file" 2>/dev/null); then
        echo "Error: Failed to read themes from JSON file" >&2
        return 1
    fi

    # Check if we got any themes
    if [[ ${#themes_ref[@]} -eq 0 ]]; then
        echo "Error: No themes found in the file" >&2
        return 1
    fi

    return 0
}

color_circle() {
    hex=$1
    hex=${hex#"#"}
    if [[ ${#hex} -eq 6 ]]; then
        r=$((16#${hex:0:2}))
        g=$((16#${hex:2:2}))
        b=$((16#${hex:4:2}))
        printf "\033[38;2;%d;%d;%dm●\033[0m" "$r" "$g" "$b"
    else
        printf "?"
    fi
}

print_theme_names_list() {
    # Calculate items per column
    total_items=${#themes[@]}
    items_per_col=$(( (total_items + 2) / 3 ))

    # Print in 3 columns
    for ((i=0; i<items_per_col; i++)); do
        # Column 1
        index1=$i
        if (( index1 < total_items )); then
            printf "  ( \e[34m%3d\e[0m ) %-25s" "$((index1+1))" "${themes[index1]}"
        else
            printf "  %33s" ""
        fi
        
        # Column 2
        index2=$((i + items_per_col))
        if (( index2 < total_items )); then
            printf "  ( \e[34m%3d\e[0m ) %-25s" "$((index2+1))" "${themes[index2]}"
        else
            printf "  %33s" ""
        fi
        
        # Column 3
        index3=$((i + 2 * items_per_col))
        if (( index3 < total_items )); then
            printf "  ( \e[34m%3d\e[0m ) %-25s" "$((index3+1))" "${themes[index3]}"
        else
            printf "  %33s" ""
        fi
        
        echo
    done
}

select_theme() {
    local file=$1
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
            theme_name="${themes[$((selection-1))]}"
            echo
            echo " Theme : $selection : $theme_name "
            break
        else
            echo -n "   Invalid input. Please enter a number between 1 and ${#themes[@]}: "
        fi
    done

    # Extract palettes separately
    local palettes=()
    mapfile -t palettes < <(jq -r --arg name "$theme_name" \
        '.[] | select(has($name))[$name] | to_entries[] | select(.key|test("palette")) | .value' "$file")

    # Print palette preview
    echo -n " Palette : "
    for c in "${palettes[@]}"; do
        printf "%s " "$(color_circle "$c")"
    done
    echo -e ""

    # Print rest of the colors
    printf "           "
    jq -r --arg name "$theme_name" \
        '.[] | select(has($name))[$name] | to_entries[] | select(.key|test("palette")|not) | "\(.key)=\(.value)"' "$file" \
    | while IFS="=" read -r key val; do
        hex=$(echo "$val" | grep -oE '#[0-9A-Fa-f]{6}')
        if [[ -n "$hex" ]]; then
            printf "%s " "$(color_circle "$hex")"
        fi
    done
    printf "\n"
}

main() {

     verify_ghostty_install

    local config_file="$HOME/.config/ghostty/config" 
    local theme_dir="$HOME/.config/ghostty/themes"
    local json_file="$(dirname "$0")/themes.json"
    local dependencies="git jq sed wget python3"

    #TODO: logic if q found in args donot print banner

    echo -e "$banner"
    sleep 2

    # Ensure required tools first
    get_missing_dependencies jq sed wget python3

    # Ensure theme file is present or downloaded
    check_theme_file "$json_file" || exit 1

    # Load themes FIRST
    local themes=()
    if ! get_themes_list "$json_file" themes; then
        exit 1
    fi

    # Process command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) 
                show_help
                exit 0
                ;;

            -v|--version) 
                show_version
                exit 0
                ;;

            -s|--search) 
                search_themes "$2"
                # set_theme "$config_file" "$theme_name" "$theme_dir" "$json_file"
                # setup_logging "$theme_name"
                break
                ;;
            -r|--random) 
                random_theme
                break
                ;;
            -u|--update) 
                update_themes
                exit 0
                ;;
            -l|--list) 
                print_theme_names_list
                exit 0
                ;;
            *) 
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    # If random was selected, theme_name is already set
    if [[ -z "$theme_name" ]]; then
        # Interactive selection
        print_theme_names_list
        select_theme "$json_file"
    fi

    set_theme "$config_file" "$theme_name" "$theme_dir" "$json_file"
    setup_logging "$theme_name"
}

main "$@"