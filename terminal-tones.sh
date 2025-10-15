#!/bin/bash
set -e

# Determine script directory and set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"
CONFIG_DIR="$SCRIPT_DIR/config"
DATA_DIR="$SCRIPT_DIR/data"
JSON_FILE="$SCRIPT_DIR/themes.json"

CONFIG_DIR="$HOME/.config/ghostty"
THEME_DIR="$CONFIG_DIR/themes"
LOG_DIR="$HOME/.local/share/ghostty-themes"
MODULES_DIR="$SCRIPT_DIR/modules"

JSON_FILE="$SCRIPT_DIR/themes.json"
CONFIG_FILE="$CONFIG_DIR/config"
LOG_FILE="$LOG_DIR/theme_changes.log"

# Source all modules
source "$MODULES_DIR/dependencies.sh"
source "$MODULES_DIR/ui_renderer.sh"
source "$MODULES_DIR/theme_loader.sh"
source "$MODULES_DIR/theme_applier.sh"
source "$MODULES_DIR/search_handler.sh"
source "$MODULES_DIR/updater.sh"
source "$MODULES_DIR/utils.sh"

source "$SCRIPT_DIR/config/defaults.conf"

main() {
	local theme_name=""
	local show_banner_flag=1

	# Check for --quit flag first
	for arg in "$@"; do
		if [[ "$arg" == "-q" || "$arg" == "--quit" ]]; then
			show_banner_flag=0
			# Remove -q from arguments
			set -- "${@/-q/}"
			break
		fi
	done

	verify_ghostty_install

	# Check dependencies
	if ! check_dependencies; then
		local missing_deps=()
		for dep in "${REQUIRED_DEPS[@]}"; do
			if ! command -v "$dep" >/dev/null 2>&1; then
				missing_deps+=("$dep")
			fi
		done
		prompt_install_dependencies "${missing_deps[@]}" || exit 1
	fi

	# Ensure theme file is present
	check_theme_file "$JSON_FILE" || exit 1

	# Load themes list
	local themes=()
	if ! load_themes_list "$JSON_FILE" themes; then
		exit 1
	fi

	# Show banner unless --quit flag is set
	if [[ $show_banner_flag -eq 1 ]]; then
		show_banner
		sleep 1
	fi

	# Process command line arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
		-h | --help)
			show_help
			exit 0
			;;
		-v | --version)
			show_version
			exit 0
			;;
		-s | --search)
			if [[ -z "$2" ]]; then
				echo -e "${COLOR_ERROR}Error: Search term required${COLOR_RESET}"
				show_help
				exit 1
			fi

			local found_themes=()
			local found_indexes=()
			search_themes "$2" "$JSON_FILE" found_themes found_indexes

			if [[ ${#found_themes[@]} -eq 0 ]]; then
				echo -e "${COLOR_ERROR}❌ No themes found matching '$2'${COLOR_RESET}"
				echo -e "${COLOR_WARNING}💡 Try a broader search term or use -l to list all available themes.${COLOR_RESET}"
				exit 1
			fi

			# Interactive selection from search results
			echo ""
			echo -e "${COLOR_SUCCESS}🎨 Found ${#found_themes[@]} themes matching '$2':${COLOR_RESET}"
			echo "────────────────────"

			for ((i = 0; i < ${#found_themes[@]} && i < 10; i++)); do
				echo "   ${found_themes[$i]}"
			done

			if [[ ${#found_themes[@]} -gt 10 ]]; then
				echo "   ... and $((${#found_themes[@]} - 10)) more themes"
			fi

			while true; do
				echo ""
				read -p "   Enter theme number (1-${#found_themes[@]}) or 'q' to quit: " selection

				case $selection in
				[Qq])
					echo "  🚫 Search cancelled."
					exit 0
					;;
				*)
					if [[ "$selection" =~ ^[0-9]+$ ]]; then
						if ((selection >= 1 && selection <= ${#found_themes[@]})); then
							local actual_index=${found_indexes[$((selection - 1))]}
							theme_name="${themes[$actual_index]}"
							show_theme_preview "$theme_name" "$JSON_FILE"
							if confirm_application "$theme_name"; then
								set_ghostty_theme "$CONFIG_FILE" "$theme_name" "$THEME_DIR" "$JSON_FILE"
								setup_logging "$theme_name"
							fi
							exit 0
						else
							echo -e "${COLOR_ERROR}❌ Please enter a number between 1 and ${#found_themes[@]}${COLOR_RESET}"
						fi
					else
						echo -e "${COLOR_ERROR}❌ Please enter a valid number or 'q' to quit${COLOR_RESET}"
					fi
					;;
				esac
			done
			;;
		-r | --random)
			if apply_random_theme "$JSON_FILE" theme_name; then
				show_theme_preview "$theme_name" "$JSON_FILE"
				if confirm_application "$theme_name"; then
					set_ghostty_theme "$CONFIG_FILE" "$theme_name" "$THEME_DIR" "$JSON_FILE"
					setup_logging "$theme_name"
				fi
			fi
			exit 0
			;;
		-u | --update)
			update_theme_repository
			exit 0
			;;
		-l | --list)
			print_theme_names_list "${themes[@]}"
			exit 0
			;;
		-q | --quit)
			# Already handled above, just skip
			shift
			continue
			;;
		*)
			echo -e "${COLOR_ERROR}Unknown option: $1${COLOR_RESET}"
			show_help
			exit 1
			;;
		esac
		shift
	done

	# Interactive mode (no arguments)
	print_theme_names_list "${themes[@]}"
	if interactive_theme_selection "$JSON_FILE" theme_name; then
		if confirm_application "$theme_name"; then
			set_ghostty_theme "$CONFIG_FILE" "$theme_name" "$THEME_DIR" "$JSON_FILE"
			setup_logging "$theme_name"
		else
			echo "  Exiting......."
		fi
	fi
}

# Run main function with all arguments
main "$@"
