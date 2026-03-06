#!/usr/bin/env bash

set -e

REPO_BASE="${AGENT_TOOLS_REPO:-https://raw.githubusercontent.com/Creator54/agent-tools/main}"
MODE="auto"
TARGETS=()
CMD_ARGS=""

# Functions print_status and print_error are provided by lib/utils.sh.
# Since fetch_remote_files runs before utils.sh is available in remote mode,
# we use standard echo statements there.

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "${1:-}" in
      --local) MODE="local" ;;
      --remote) MODE="remote" ;;
      --qwen|--claude|--gemini|--opencode|--aider)
        TARGETS+=("${1#--}")
        ;;
      --all)
        TARGETS+=("qwen" "claude" "gemini" "opencode" "aider")
        ;;
      --project-commands) INSTALL_PROJECT_COMMANDS="true" ;;
      --uninstall-project-commands) UNINSTALL_PROJECT_COMMANDS="true" ;;
      -h|--help) CMD_ARGS="$1"; shift; break ;;
      install|uninstall)
        if [[ -z "$CMD_ARGS" ]]; then
          CMD_ARGS="$1"
        fi
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    TARGETS=("qwen")
  fi
  export TARGETS
  CMD_ARGS="$CMD_ARGS $@"
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
  echo "▶ Fetching agent-tools from $REPO_BASE..."

  local FILES=(
    "lib/config.sh"
    "lib/utils.sh"
    "lib/installer.sh"
    "lib/registry.sh"
    "commands.json.global"
    "commands.json.project"
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
  COMMANDS_REGISTRY="$TEMP_DIR/commands.json.project"
  COMMANDS_REGISTRY_GLOBAL="$TEMP_DIR/commands.json.global"
}

setup_local_mode() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  LIB_DIR="$SCRIPT_DIR/lib"
  PROJECT_ROOT="$SCRIPT_DIR"
  TEMPLATES_DIR="$SCRIPT_DIR/templates"
  COMMANDS_REGISTRY="$SCRIPT_DIR/commands.json.project"
  COMMANDS_REGISTRY_GLOBAL="$SCRIPT_DIR/commands.json.global"
}

source_libs() {
  source "$LIB_DIR/config.sh"
  source "$LIB_DIR/utils.sh"
  source "$LIB_DIR/installer.sh"
  source "$LIB_DIR/registry.sh"
}

install_commands() {
  print_header
  print_status "Installing agent-tools commands... ${DIM}($MODE mode)${NC}"
  echo

  for target in "${TARGETS[@]}"; do
    set_target_paths "$target"
    ensure_global_commands_dir
    print_status "Target: $target (${GLOBAL_COMMANDS_DIR})"

    # Always install global commands first
    while IFS='|' read -r command_name template_file; do
      local template_path
      template_path=$(get_template_path "$template_file")
      install_command "$template_path" "$command_name"
    done < <(get_commands "$COMMANDS_REGISTRY_GLOBAL")

    # Install project-specific commands if requested
    if [[ "$INSTALL_PROJECT_COMMANDS" == "true" ]]; then
      # In local mode, copy from .qwen/commands/ directory
      if [[ "$MODE" == "local" && -d "$PROJECT_ROOT/.qwen/commands" ]]; then
        for cmd_file in "$PROJECT_ROOT/.qwen/commands"/*.md; do
          if [[ -f "$cmd_file" ]]; then
            cp "$cmd_file" "$GLOBAL_COMMANDS_DIR/"
            cmd_name=$(basename "$cmd_file" .md)
            print_success "Installed /${cmd_name} (project command)"
          fi
        done
      else
        # Remote mode: install from templates
        while IFS='|' read -r command_name template_file; do
          local template_path
          template_path=$(get_template_path "$template_file")
          install_command "$template_path" "$command_name"
        done < <(get_commands "$COMMANDS_REGISTRY")
      fi
    fi
  done

  echo
  print_success "Command installation complete!"
  echo
  print_status "Available commands:"

  # List global commands
  while IFS='|' read -r command_name template_file; do
    local template_path
    template_path=$(get_template_path "$template_file")
    if [[ -f "$template_path" ]]; then
      local description=$(grep -m1 '^description\s*:\s*' "$template_path" | sed -E 's/.*:\s*"(.*)"/\1/' | sed -E "s/.*:\s*'(.*)'/\1/")
      echo -e "  ${BOLD}/${command_name}${NC} - ${DIM}${description}${NC}"
    fi
  done < <(get_commands "$COMMANDS_REGISTRY_GLOBAL")

  # List project-specific commands if installed
  if [[ "$INSTALL_PROJECT_COMMANDS" == "true" ]]; then
    if [[ "$MODE" == "local" && -d "$PROJECT_ROOT/.qwen/commands" ]]; then
      for cmd_file in "$PROJECT_ROOT/.qwen/commands"/*.md; do
        if [[ -f "$cmd_file" ]]; then
          cmd_name=$(basename "$cmd_file" .md)
          echo -e "  ${BOLD}/${cmd_name}${NC} - ${DIM}Project management command${NC}"
        fi
      done
    else
      while IFS='|' read -r command_name template_file; do
        local template_path
        template_path=$(get_template_path "$template_file")
        if [[ -f "$template_path" ]]; then
          local description=$(grep -m1 '^description\s*:\s*' "$template_path" | sed -E 's/.*:\s*"(.*)"/\1/' | sed -E "s/.*:\s*'(.*)'/\1/")
          echo -e "  ${BOLD}/${command_name}${NC} - ${DIM}${description}${NC}"
        fi
      done < <(get_commands "$COMMANDS_REGISTRY")
    fi
  fi

  echo
  if [[ "$INSTALL_PROJECT_COMMANDS" != "true" ]]; then
    print_status "Note: Project-specific commands (e.g., /manage-project, /add) are not installed."
    print_status "Run with --project-commands to install all commands."
  fi
}

uninstall_commands() {
  print_header
  print_status "Uninstalling agent-tools commands... ${DIM}($MODE mode)${NC}"
  echo

  for target in "${TARGETS[@]}"; do
    set_target_paths "$target"
    print_status "Uninstalling target: $target (${GLOBAL_COMMANDS_DIR})"

    # Always uninstall global commands
    while IFS='|' read -r command_name _; do
      uninstall_command "$command_name"
    done < <(get_commands "$COMMANDS_REGISTRY_GLOBAL")

    # Uninstall project-specific commands if requested
    if [[ "$UNINSTALL_PROJECT_COMMANDS" == "true" ]]; then
      while IFS='|' read -r command_name _; do
        uninstall_command "$command_name"
      done < <(get_commands "$COMMANDS_REGISTRY")
    fi

    if [[ -d "$GLOBAL_COMMANDS_DIR" ]] && [[ -z "$(ls -A "$GLOBAL_COMMANDS_DIR")" ]]; then
      rmdir "$GLOBAL_COMMANDS_DIR" 2>/dev/null || true
      print_info "Removed empty global commands directory for $target"
    fi
  done

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

  # Trim leading/trailing whitespace from CMD_ARGS
  CMD_ARGS="${CMD_ARGS#"${CMD_ARGS%%[![:space:]]*}"}"
  CMD_ARGS="${CMD_ARGS%"${CMD_ARGS##*[![:space:]]}"}"

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
