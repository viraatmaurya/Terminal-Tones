#!/bin/bash

show_banner() {
	echo ""
	echo ""
	echo -e "
                ░▀█▀░█▀▀░█▀▄░█▄█░▀█▀░█▀█░█▀█░█░░░░░▀█▀░█▀█░█▀█░█▀▀░█▀▀
                ░░█░░█▀▀░█▀▄░█░█░░█░░█░█░█▀█░█░░░░░░█░░█░█░█░█░█▀▀░▀▀█
                ░░▀░░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀░▀░▀░▀▀▀░░░░▀░░▀▀▀░▀░▀░▀▀▀░▀▀▀
    "
	echo -e "$banner"

}

show_help() {
	cat <<EOF
    Usage: ./$(basename "$0") [OPTIONS]


    ./$(basename "$0")     Interactive theme selection

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

show_version() {
	echo ""
	echo "      Terminal Tones Version : $VERSION "
	echo ""
}

color_circle() {
	local hex=$1
	hex=${hex#"#"}
	if [[ ${#hex} -eq 6 ]]; then
		local r=$((16#${hex:0:2}))
		local g=$((16#${hex:2:2}))
		local b=$((16#${hex:4:2}))
		printf "\033[38;2;%d;%d;%dm●\033[0m" "$r" "$g" "$b"
	else
		printf "?"
	fi
}

print_theme_names_list() {
	local themes=("$@")

	# Calculate items per column
	local total_items=${#themes[@]}
	local items_per_col=$(((total_items + 2) / 3))

	# Print in 3 columns
	for ((i = 0; i < items_per_col; i++)); do
		# Column 1
		local index1=$i
		if ((index1 < total_items)); then
			printf "  ( ${COLOR_INFO}%3d${COLOR_RESET} ) %-25s" "$((index1 + 1))" "${themes[index1]}"
		else
			printf "  %33s" ""
		fi

		# Column 2
		local index2=$((i + items_per_col))
		if ((index2 < total_items)); then
			printf "  ( ${COLOR_INFO}%3d${COLOR_RESET} ) %-25s" "$((index2 + 1))" "${themes[index2]}"
		else
			printf "  %33s" ""
		fi

		# Column 3
		local index3=$((i + 2 * items_per_col))
		if ((index3 < total_items)); then
			printf "  ( ${COLOR_INFO}%3d${COLOR_RESET} ) %-25s" "$((index3 + 1))" "${themes[index3]}"
		else
			printf "  %33s" ""
		fi

		echo
	done
}

show_theme_preview() {
	local theme_name="$1"
	local json_file="$2"

	echo ""
	echo -e "  ${COLOR_SUCCESS}✅ Selected theme: ${COLOR_PRIMARY}$theme_name${COLOR_RESET}"

	# Show theme preview
	echo -n "  🎨 Colors: "
	local palettes=()
	mapfile -t palettes < <(get_theme_colors "$theme_name" "$json_file" "palette")

	for c in "${palettes[@]}"; do
		printf "%s " "$(color_circle "$c")"
	done

	# Print other colors
	printf " "
	get_theme_colors "$theme_name" "$json_file" "all" | while IFS="=" read -r key val; do
		local hex=$(echo "$val" | grep -oE '#[0-9A-Fa-f]{6}')
		if [[ -n "$hex" ]]; then
			printf "%s " "$(color_circle "$hex")"
		fi
	done
	printf "\n"
	echo ""
}
