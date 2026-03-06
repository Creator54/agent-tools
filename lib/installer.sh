#!/usr/bin/env bash

# Installer module for qwen-tools
# Contains functions related to command installation and management

# Function to install a single command with validation
install_command() {
    local template_path="$1"
    local command_name="$2"
    
    if validate_template_file "$template_path"; then
        cp "$template_path" "$GLOBAL_COMMANDS_DIR/${command_name}.md"
        print_success "Installed /${command_name}"
    else
        print_error "Validation failed for /${command_name}"
    fi
}

# Function to uninstall a single command
uninstall_command() {
    local command_name="$1"
    
    # Clean up both markdown and legacy TOML configurations
    if [[ -f "$GLOBAL_COMMANDS_DIR/${command_name}.md" || -f "$GLOBAL_COMMANDS_DIR/${command_name}.toml" ]]; then
        rm -f "$GLOBAL_COMMANDS_DIR/${command_name}.md" "$GLOBAL_COMMANDS_DIR/${command_name}.toml"
        print_success "Uninstalled /${command_name}"
    else
        print_info "Not found: /${command_name}"
    fi
}

# Function to validate template file before installation
validate_template_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        print_error "Template file does not exist: $file"
        return 1
    fi

    # Check if it's a valid Markdown format with YAML frontmatter
    # We expect `---` block containing `description:`
    if ! grep -q "^---" "$file" || ! grep -q "^description:" "$file"; then
        print_error "Template file is not in valid Markdown format: $file"
        return 1
    fi

    return 0
}