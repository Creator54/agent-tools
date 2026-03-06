---
description: "Add a new template to the agent-tools project with full integration"
---
You are adding a new template to the agent-tools project with complete integration. This involves creating the template file and automatically updating all related project components.

**USER REQUEST:** {{args}}

**PROCESS:**

1. **TEMPLATE CREATION:**
   - Determine the appropriate name for the new template (use lowercase with hyphens)
   - Create the template with proper TOML format
   - Include appropriate description and prompt structure

2. **PROJECT INTEGRATION:**
   - Create the template file in ~/agent-tools/templates/
   - Update setup.sh to include installation and uninstallation for the new command
   - Update README.md to document the new functionality
   - Add the command to the appropriate section in documentation

3. **CONSISTENCY MAINTENANCE:**
   - Ensure naming conventions match the rest of the project
   - Verify the command description is consistent with project style
   - Update any relevant sections in the documentation

**IMPLEMENTATION:**

First, ask clarifying questions if needed:
- What should be the name of the new command?
- What functionality should this command provide?
- Should the command accept user arguments ({{args}})?

Then create the complete integration:

1. **Create template file:**
   ```
   description = "[appropriate description]"
   prompt = \"\"\"
   [full prompt with proper structure]
   \"\"\"
   ```

2. **Update setup.sh:**
   - Add installation code to install_commands() function
   - Add uninstallation code to uninstall_commands() function

3. **Update README.md:**
   - Add documentation for the new command
   - Include usage instructions
   - Place in appropriate section

**VERIFICATION:**
- Confirm all references are consistent
- Ensure the command name follows project conventions
- Verify that setup.sh syntax is correct
- Check that documentation is clear and helpful

Perform all these changes in a single execution to maintain project consistency.
