#!/usr/bin/env bash

# Installer module for qwen-tools
# Contains functions related to command installation and management

# Function to install a single command with validation
install_command() {
    local template_path="$1"
    local command_name="$2"
    
    if validate_template_file "$template_path"; then
        cp "$template_path" "$GLOBAL_COMMANDS_DIR/${command_name}.toml"
        print_success "Installed /${command_name}"
    else
        print_error "Validation failed for /${command_name}"
    fi
}

# Function to uninstall a single command
uninstall_command() {
    local command_name="$1"
    
    if [[ -f "$GLOBAL_COMMANDS_DIR/${command_name}.toml" ]]; then
        rm "$GLOBAL_COMMANDS_DIR/${command_name}.toml"
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

    # Check if it's a valid TOML format (basic validation)
    if ! grep -q '^description\s*=' "$file" || ! grep -q '^prompt\s*=' "$file"; then
        print_error "Template file is not in valid format: $file"
        return 1
    fi

    return 0
}