# agent-tools

A collection of self-managing utilities and templates to enhance the functionality of Agent CLIs and other LLM interfaces.

## Usage

**Quick Setup (Remote):**
```bash
curl -fsSL https://raw.githubusercontent.com/Creator54/agent-tools/main/setup.sh | bash -s -- --all install
```

**Local Repository:**
```bash
bash setup.sh install                   # Global commands only (default)
bash setup.sh install --project-commands  # Include project-specific commands
bash setup.sh uninstall                 # Uninstall from Qwen
```

**Supported AI Agents:**

| Flag | Agent | Config Path |
|------|-------|-------------|
| `--qwen` (default) | Qwen Code | `~/.qwen/commands` |
| `--claude` | Claude Code | `~/.claude/commands` |
| `--gemini` | Gemini Code | `~/.gemini/commands` |
| `--opencode` | OpenCode | `~/.config/opencode/commands` |
| `--aider` | Aider | `~/.aider/commands` |
| `--all` | All above | — |

## Available Commands

**Global Commands** (installed by default):

| Command | Description |
|---|---|
| `/create-command-local` | Create project-specific commands. |
| `/create-command-global`| Create global commands for all projects. |

**Project Commands** (`--project-commands`):

| Command | Description |
|---|---|
| `/add` | Add new functionality to agent-tools. |
| `/main-management` | Full project management. |
| `/add-template` | Add a new template. |
| `/update-readme` | Update documentation. |
| `/update-setup` | Modify setup script. |
| `/manage-project` | Project consistency checking. |

## Creating Custom Commands

`agent-tools` custom commands are written in Markdown and stored in the `templates/` directory.

### Basic Structure

```markdown
---
description: "A short description shown in /help"
---
Process user input: {{args}}

Results from shell command: !{ls -la}
File content injection: @{path/to/file.txt}
```

### Self-Management

This project is fully self-managing. If you want to add a new command, simply use `/add` from within this project. The system will automatically:
1. Create the template in `templates/`
2. Register the command in `commands.json`
3. Update `setup.sh` to install it
4. Rebuild the README if needed

## License

This project is licensed under the [MIT License](LICENSE).