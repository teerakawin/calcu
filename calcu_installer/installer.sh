#!/usr/bin/env bash

# Calcu Installer
REPO="teerakawin/calcu"
API_URL="https://api.github.com/repos/${REPO}/tags?per_page=100"

# Colors
BOLD='\e[1m'
CYAN='\e[36m'
GREEN='\e[32m'
RED='\e[31m'
RESET='\e[0m'

# Display the menu banner
banner() {
    printf "${CYAN}/==============================\\\\${RESET}\n"
    printf "${BOLD}|   Kawin's Calcu Installer    |${RESET}\n"
    printf "${CYAN}\\\\==============================/${RESET}\n"
    printf '\n'
}

# Return to the previous menu
press_back() {
    local opt

    while true; do
        read -r -p "Press B to go back: " opt

        case "$opt" in
            [Bb]) return 0 ;;
            *) printf '%s\n' "Invalid option."; sleep 1 ;;
        esac
    done
}

# Display version information
version() {
    clear
    banner

    printf 'Version 1.0.0 (cloned version)\n\n'

    press_back
}

# Fetch available GitHub tags and download them (scripts)
fetch() {
    local tags tag url dest

    clear
    banner

    if ! command -v curl >/dev/null 2>&1 ||
       ! command -v jq >/dev/null 2>&1; then
        printf 'Error: curl and jq are required.\n'
        press_back
        return
    fi

    mkdir -p scripts || {
        printf 'Error: Could not create scripts directory.\n'
        press_back
        return
    }

    printf 'Fetching available versions...\n\n'

    if ! tags=$(curl -fsSL "$API_URL" | jq -er '.[].name'); then
        printf 'Error: Could not fetch GitHub tags.\n'
        press_back
        return
    fi

    while IFS= read -r tag; do
        [[ -n "$tag" ]] || continue

        # Only accept simple version-style tag names.
        if [[ ! "$tag" =~ ^[A-Za-z0-9._-]+$ ]]; then
            printf 'Skipping unsupported tag: %s\n' "$tag"
            continue
        fi

        url="https://raw.githubusercontent.com/${REPO}/${tag}/scripts/${tag}.sh"
        dest="scripts/${tag}.sh"

        printf 'Downloading %s ... ' "$tag"

        if curl -fsSL "$url" -o "$dest"; then
            printf 'OK\n'
        else
            rm -f -- "$dest"
            printf 'Not available\n'
        fi
    done <<< "$tags"

    printf '\n'
    press_back
}


# Install a selected version
install() {
    local opt

    clear
    banner

    printf 'Please fetch the available versions first.\n'
    printf 'Enter the version you want to install.\n'
    printf 'Example: v1.0.0\n\n'

    read -r -p "Version: " opt

    if [[ -z "$opt" ]]; then
        printf '\nNo version entered.\n'
        sleep 1
        return
    fi

    # TODO: Validate the requested tag.
    # TODO: Download the selected release/source.
    # TODO: Install Calcu.

    printf '\nInstallation is not implemented yet.\n'
    press_back
}

# Main menu
main_menu() {
    local opt

    while true; do
        clear
        banner

        printf "${GREEN}1)${RESET} Version information\n"
        printf "${GREEN}2)${RESET} Fetch available versions\n"
        printf "${GREEN}3)${RESET} Install\n"
        printf "${RED}Q)${RESET} Quit\n\n"

        read -r -p "Select an option: " opt || break

        case "$opt" in
            1) version ;;
            2) fetch ;;
            3) install ;;
            [Qq]) break ;;
            *) printf 'Invalid option.\n'; sleep 1 ;;
        esac
    done
}

main_menu
