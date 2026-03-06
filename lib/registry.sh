#!/usr/bin/env bash

# Registry module for agent-tools
# Contains functions related to command registry management

# Function to get command list from registry
get_commands() {
    local registry_file="${1:-$COMMANDS_REGISTRY}"
    
    if command -v jq >/dev/null 2>&1; then
        # Use jq if available for proper JSON parsing
        jq -r '.commands[] | "\(.name)|\(.template)"' "$registry_file" 2>/dev/null || {
            echo "Error: Cannot parse commands registry"
            exit 1
        }
    else
        # Fallback to sed/awk if jq is not available (less robust but more portable)
        grep -o '"name": "[^"]*", "template": "[^"]*"' "$registry_file" | \
        sed -E 's/.*"name": "([^"]+)", "template": "([^"]+)".*/\1|\2/' || {
            echo "Error: Cannot parse commands registry"
            exit 1
        }
    fi
}

# Function to get full template path
get_template_path() {
    local template_name="$1"
    echo "$TEMPLATES_DIR/$template_name"
}

# Function to add a new command to the registry
add_command_to_registry() {
    local command_name="$1"
    local template_file="$2"
    local description="$3"
    
    if [[ -f "$COMMANDS_REGISTRY" ]]; then
        # Check if command already exists
        if jq -e ".commands[] | select(.name == \"$command_name\")" "$COMMANDS_REGISTRY" >/dev/null 2>&1; then
            print_warning "Command $command_name already exists in registry"
            return 1
        fi
        
        # Add the new command to the registry using a temporary approach
        # Since jq in-place editing can be tricky, we'll use a more portable approach
        local temp_registry=$(mktemp)
        local current_commands=$(jq -c ".commands" "$COMMANDS_REGISTRY")
        local new_command=$(jq -n --arg name "$command_name" --arg template "$template_file" --arg desc "$description" \
            '{name: $name, template: $template, description: $desc}')
        
        local updated_commands=$(echo "$current_commands" | jq ". += [$new_command]")
        jq --argjson new_commands "$updated_commands" '.commands = $new_commands' "$COMMANDS_REGISTRY" > "$temp_registry" && mv "$temp_registry" "$COMMANDS_REGISTRY"
        
        if [[ $? -eq 0 ]]; then
            print_success "Added command $command_name to registry"
            return 0
        else
            print_error "Failed to add command $command_name to registry"
            return 1
        fi
    else
        print_error "Commands registry file not found: $COMMANDS_REGISTRY"
        return 1
    fi
}

# Function to remove a command from the registry
remove_command_from_registry() {
    local command_name="$1"
    
    if [[ -f "$COMMANDS_REGISTRY" ]]; then
        # Check if command exists
        if jq -e ".commands[] | select(.name == \"$command_name\")" "$COMMANDS_REGISTRY" >/dev/null 2>&1; then
            local temp_registry=$(mktemp)
            # Remove the command from the array
            jq --arg name "$command_name" 'del(.commands[] | select(.name == $name))' "$COMMANDS_REGISTRY" > "$temp_registry" && mv "$temp_registry" "$COMMANDS_REGISTRY"
            
            if [[ $? -eq 0 ]]; then
                print_success "Removed command $command_name from registry"
                return 0
            else
                print_error "Failed to remove command $command_name from registry"
                return 1
            fi
        else
            print_warning "Command $command_name not found in registry"
            return 1
        fi
    else
        print_error "Commands registry file not found: $COMMANDS_REGISTRY"
        return 1
    fi
}