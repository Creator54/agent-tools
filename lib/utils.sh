#!/usr/bin/env bash

# Utility module for qwen-tools
# Contains common utility functions

print_header() {
    local bg="  "
    echo
    echo -e "${BLUE}${BOLD}▶ qwen-tools Setup${NC}"
    echo -e "${DIM}  Version 1.0.0${NC}"
    echo
}

print_status() {
    echo -e "${BLUE}${BOLD}▶${NC} $1"
}

print_info() {
    echo -e "${DIM}  $1${NC}"
}

print_success() {
    echo -e "${GREEN}${BOLD}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}${BOLD}✗${NC} $1" >&2
}

ensure_global_commands_dir() {
    if [[ ! -d "$GLOBAL_COMMANDS_DIR" ]]; then
        mkdir -p "$GLOBAL_COMMANDS_DIR"
        print_info "Created global commands directory: $GLOBAL_COMMANDS_DIR"
    fi
}

show_help() {
    echo -e "${BOLD}qwen-tools Setup${NC}"
    echo
    echo -e "${DIM}USAGE:${NC}"
    echo "  $0 [options] <command>"
    echo
    echo -e "${DIM}COMMANDS:${NC}"
    echo "  install      Install qwen-tools commands"
    echo "  uninstall    Remove qwen-tools commands"
    echo "  help         Show this help message"
    echo
    echo -e "${DIM}OPTIONS:${NC}"
    echo "  --local      Force local mode (uses files from current directory)"
    echo "  --remote     Force remote mode (fetches files from GitHub)"
    echo "  -h, --help   Show this help message"
    echo
    echo -e "${DIM}EXAMPLES:${NC}"
    echo "  $0 install                  # Auto-detect mode and install"
    echo "  curl -fsSL <url> | bash -s -- install  # Remote install"
    echo "  $0 uninstall                # Remove commands"
    echo
}