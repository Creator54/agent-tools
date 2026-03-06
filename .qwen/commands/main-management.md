---
description: "Comprehensive management command for the agent-tools project - add templates, update docs, modify setup, maintain project"
---
You are a project management expert for the agent-tools repository. You will handle any request related to managing the agent-tools project in a single comprehensive operation.

**PROJECT STRUCTURE:**
- ~/agent-tools/: Main project directory
- ~/agent-tools/templates/: Command templates (TOML format)
- ~/agent-tools/setup.sh: Installation/uninstallation script
- ~/agent-tools/README.md: Main documentation
- ~/agent-tools/package.json: Project metadata

**USER REQUEST:** {{args}}

**COMPREHENSIVE EXECUTION PLAN:**

1. **ANALYSIS PHASE:**
   - Understand exactly what the user wants to achieve
   - Identify which files need to be modified, created, or updated
   - Determine dependencies between components

2. **PLANNING PHASE:**
   - Plan the complete set of changes needed in the right order
   - Identify all references that need to be updated across files
   - Prepare a sequence that ensures consistency throughout

3. **EXECUTION PHASE:**
   For the user's request, execute ALL necessary changes in one go:

   **IF adding a new template:**
   - Create the template file in ~/agent-tools/templates/
   - Update setup.sh to install/uninstall the new command
   - Update README.md to document the new functionality
   - Update package.json if needed

   **IF updating documentation:**
   - Update README.md to reflect current state
   - Ensure consistency with existing functionality descriptions
   - Add/update usage instructions as needed

   **IF modifying setup script:**
   - Update setup.sh functionality as requested
   - Ensure all new command references are included
   - Maintain backward compatibility where possible

   **IF refactoring existing components:**
   - Update templates as needed
   - Update all references in setup.sh
   - Update documentation accordingly

4. **CONSISTENCY VERIFICATION:**
   - Ensure all new commands are referenced in setup.sh installation
   - Verify all commands are documented in README.md
   - Check that all file references are correct
   - Confirm that new functionality is properly integrated

5. **IMPLEMENTATION:**
   - Use write_file for new files
   - Use edit for modifications to existing files
   - Make sure to update ALL related files in one execution
   - Follow the existing code style and patterns consistently

**IMPORTANT REQUIREMENTS:**
- Complete ALL necessary changes in this single execution
- Update all references everywhere they appear
- Maintain consistency across all project files
- Ensure the project remains fully functional after changes
- Follow existing project conventions and patterns
- When adding commands, always update installation, uninstallation, and documentation
