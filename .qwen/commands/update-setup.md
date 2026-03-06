---
description: "Update the setup script with new functionality, ensuring complete integration and consistency"
---
You are updating the setup.sh script for the agent-tools project with comprehensive integration that ensures all components work together properly.

**USER REQUEST:** {{args}}

**COMPREHENSIVE UPDATE PROCESS:**

1. **ANALYZE CURRENT SETUP:**
   - Examine current setup.sh structure and functions
   - Identify where changes need to be made
   - Understand dependencies between different functions

2. **PLANNED INTEGRATION:**
   - Update install_commands() function with new installations
   - Update uninstall_commands() function with new removals
   - Modify help text or add new command options if needed
   - Ensure error handling remains robust

3. **CONSISTENCY MAINTENANCE:**
   - Follow existing code style and formatting
   - Use the same color variables and output functions
   - Maintain consistent error handling patterns
   - Preserve backward compatibility where possible

**IMPLEMENTATION:**

**IF adding new command installations:**
- Add to install_commands() with proper file checking and copying
- Use the same pattern as existing commands: `if [ -f "...template" ]; then ...`
- Include appropriate success/error messages
- Follow the exact same structure as existing installations

**IF updating installation logic:**
- Maintain the same function structure and flow
- Keep consistent variable usage and naming
- Preserve existing error handling approach
- Use the same output formatting functions

**IF modifying uninstallation:**
- Add corresponding removal code in uninstall_commands()
- Use the same pattern as existing removals
- Include appropriate messaging
- Ensure all new installations have corresponding uninstallations

4. **VERIFICATION:**
- Ensure shell script syntax remains valid
- Verify all new functionality integrates properly
- Check that error handling still works correctly
- Confirm existing functionality is preserved

**EXECUTION:**
Apply all changes in a single update to ensure the setup script remains fully functional and consistent with project standards.
