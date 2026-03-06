#!/usr/bin/env bash

set -e

REPO_BASE="${QWEN_TOOLS_REPO:-https://raw.githubusercontent.com/Creator54/qwen-tools/main}"
MODE="auto"
CMD_ARGS=""

# Functions print_status and print_error are provided by lib/utils.sh.
# Since fetch_remote_files runs before utils.sh is available in remote mode,
# we use standard echo statements there.

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      --local) MODE="local" ;;
      --remote) MODE="remote" ;;
      -h|--help) CMD_ARGS="$1"; shift; break ;;
      *) break ;;
    esac
    shift
  done
  # if not explicitly set to help, capture the rest
  if [[ "$CMD_ARGS" != "-h" && "$CMD_ARGS" != "--help" ]]; then
      CMD_ARGS="$@"
  fi
}

detect_mode() {
  if [[ "$MODE" == "auto" ]]; then
    # If BASH_SOURCE is empty or bash/sh, it's being piped via standard input (e.g. curl | bash)
    if [[ -z "${BASH_SOURCE[0]}" || "${BASH_SOURCE[0]}" == "bash" || "${BASH_SOURCE[0]}" == "sh" ]]; then
      MODE="remote"
    else
      # It's a real file, verify it's inside a full clone
      SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
      if [[ -f "$SCRIPT_DIR/commands.json" && -d "$SCRIPT_DIR/lib" && -d "$SCRIPT_DIR/templates" ]]; then
        MODE="local"
      else
        # Standalone downloaded setup script
        MODE="remote"
      fi
    fi
  fi
}

fetch_remote_files() {
  TEMP_DIR=$(mktemp -d)
  trap "rm -rf $TEMP_DIR" EXIT

  # Hardcoded echoes since utils are not fetched yet
  echo "▶ Fetching qwen-tools from $REPO_BASE..."

  local FILES=(
    "lib/config.sh"
    "lib/utils.sh"
    "lib/installer.sh"
    "lib/registry.sh"
    "commands.json"
    "templates/management/add-command.template"
    "templates/management/main-management.template"
    "templates/utility/add-template.template"
    "templates/utility/update-readme.template"
    "templates/utility/update-setup.template"
    "templates/utility/manage-project.template"
    "templates/creation/create-command-local.template"
    "templates/creation/create-command-global.template"
  )

  for file in "${FILES[@]}"; do
    local dir
    dir=$(dirname "$TEMP_DIR/$file")
    mkdir -p "$dir"
    if ! curl -sSL "$REPO_BASE/$file" -o "$TEMP_DIR/$file" 2>/dev/null; then
      echo "✗ Failed to fetch: $file" >&2
      exit 1
    fi
  done

  LIB_DIR="$TEMP_DIR/lib"
  # Set these before sourcing config.sh so its defaults are skipped
  PROJECT_ROOT="$TEMP_DIR"
  TEMPLATES_DIR="$TEMP_DIR/templates"
  COMMANDS_REGISTRY="$TEMP_DIR/commands.json"
}

setup_local_mode() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  LIB_DIR="$SCRIPT_DIR/lib"
  PROJECT_ROOT="$SCRIPT_DIR"
}

source_libs() {
  source "$LIB_DIR/config.sh"
  source "$LIB_DIR/utils.sh"
  source "$LIB_DIR/installer.sh"
  source "$LIB_DIR/registry.sh"
}

install_commands() {
  print_header
  print_status "Installing qwen-tools commands... ${DIM}($MODE mode)${NC}"
  echo

  ensure_global_commands_dir

  while IFS='|' read -r command_name template_file; do
    local template_path
    template_path=$(get_template_path "$template_file")
    install_command "$template_path" "$command_name"
  done < <(get_commands)

  echo
  print_success "Command installation complete!"
  echo
  print_status "Available commands:"
  while IFS='|' read -r command_name template_file; do
    local template_path
    template_path=$(get_template_path "$template_file")
    if [[ -f "$template_path" ]]; then
      local description=$(grep -m1 '^description\s*:\s*' "$template_path" | sed -E 's/.*:\s*"(.*)"/\1/' | sed -E "s/.*:\s*'(.*)'/\1/")
      echo -e "  ${BOLD}/${command_name}${NC} - ${DIM}${description}${NC}"
    fi
  done < <(get_commands)
  echo
  print_status "The primary command for managing the qwen-tools project is ${BOLD}/add${NC}"
}

uninstall_commands() {
  print_header
  print_status "Uninstalling qwen-tools commands... ${DIM}($MODE mode)${NC}"
  echo

  while IFS='|' read -r command_name _; do
    uninstall_command "$command_name"
  done < <(get_commands)

  if [[ -d "$GLOBAL_COMMANDS_DIR" ]] && [[ -z "$(ls -A "$GLOBAL_COMMANDS_DIR")" ]]; then
    rmdir "$GLOBAL_COMMANDS_DIR"
    print_info "Removed empty global commands directory"
  fi

  echo
  print_success "Command removal complete!"
}

main() {
  parse_args "$@"
  detect_mode

  if [[ "$MODE" == "remote" ]]; then
    fetch_remote_files
  else
    setup_local_mode
  fi

  source_libs

  case "${CMD_ARGS:-help}" in
    "install")
        install_commands
        ;;
    "uninstall")
        uninstall_commands
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: ${CMD_ARGS:-}${NC}"
        echo
        show_help
        exit 1
        ;;
  esac
}

main "$@"
