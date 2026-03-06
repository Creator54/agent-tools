# Qwen Enhancement Tools

A self-manageable collection of tools to enhance the functionality of Qwen Code CLI and other LLM interfaces.

## Overview

This project provides utilities and commands that enhance the Qwen experience by adding useful functionality that streamlines common tasks. The project is designed to be completely self-manageable - you can add new commands, update documentation, and modify functionality while working within this repository.

## Self-Management Features

The qwen-tools project includes commands that allow you to manage the project itself:

### Primary Management Command

- `/add` - Main command to add any functionality to the project (recommended as primary entry point)

### Core Management Commands

- `/main-management` - Comprehensive project management for adding templates, updating docs, modifying setup, maintaining the project
- `/add-template` - Add new templates to the project with automatic integration
- `/update-readme` - Update project documentation with new features or changes  
- `/update-setup` - Modify the setup script with new functionality
- `/manage-project` - High-level project management tasks

### Command Creation Tools

- `/create-command:local` - Interactive tool to create project-specific commands
- `/create-command:global` - Interactive tool to create global commands for all projects

## Installation

To install the tools, run:

```bash
bash setup.sh install
```

## Usage

After installation, you can use the following management commands:

### Primary Command
```
/add <query>
```
This is the main command for managing the qwen-tools project itself. Use this to add new functionality, update documentation, or modify project behavior. This is the recommended primary entry point.

### Creating New Commands
```
/create-command:local
```
This helps you create commands that are specific to your current project.

```
/create-command:global
```
This helps you create commands that are available across all projects.

### Other Management Commands
```
/main-management
```
Comprehensive project management command (equivalent to /add but more explicit).

```
/add-template
```
Add new templates to the project with automatic integration into the setup process.

```
/update-readme`
```
Update the project documentation when adding new features.

```
/update-setup
```
Modify the installation script when adding new functionality.

## How It Works

### Template Structure

All commands are defined as template files organized in the `templates/` directory with subdirectories:

- `templates/management/` - Core project management commands
- `templates/creation/` - Command creation tools
- `templates/utility/` - Utility and documentation commands

Each template follows the format:

```toml
description = "A short description shown in /help"
prompt = """
Your multi-line prompt template with {{args}} for arguments.
{{args}} will be replaced with the user's input.
"""
```

### Automatic Integration

When you add a new template:
1. The template file is created in `~/qwen-tools/templates/`
2. The `setup.sh` script is automatically updated with installation/uninstallation code
3. The `README.md` documentation is updated to include the new command
4. The command becomes immediately available after installation

### Self-Management Process

The project is designed to be managed from within itself:
1. Use `/add` for comprehensive changes (recommended)
2. The system handles all necessary file updates automatically
3. All references are updated consistently across the project
4. Verification ensures the project remains functional

## Custom Commands

`qwen-tools` custom commands are written in Markdown and stored in the `templates/` directory.

### Basic Structure
```markdown
---
description: "A short description shown in /help"
---
Your multi-line prompt template.
```

### Using Arguments
```markdown
---
description: "Command that accepts user input"
---
Process user input: {{args}}

Additional processing here...
```

### Shell Commands (Qwen Code only)
```markdown
---
description: "Command that executes shell commands"
---
Results from shell command:
!{ls -la}
```

### File Content Injection (Qwen Code only)
```markdown
---
description: "Command that injects file content"
---
File content:
@{path/to/file.txt}
```

## Security Notice

Be cautious when creating commands that execute shell commands or access sensitive files. The interactive command creation tools will prompt for confirmation before creating commands that might have security implications.

## Extending the Project

The project is designed to be easily extensible:
- Add new templates to the `templates/` directory
- Use the management commands to integrate them properly
- Update documentation automatically
- Maintain consistency across all project files