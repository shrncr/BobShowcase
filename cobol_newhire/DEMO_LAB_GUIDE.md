# Bob AI Demo Lab Guide: COBOL Development Workflow with Trello Integration

## Overview
This lab guide demonstrates how Bob AI can streamline COBOL development workflows by integrating with Trello for task management, performing code modifications, conducting code reviews, and creating pull requests - all through natural language interactions.

## Prerequisites
- Bob IDE installed and configured
- Git repository cloned (cobol-banking-masterclass)
- Trello account with API access
- GitHub account with repository access
- GnuCOBOL compiler installed

---

## Part 0: Initialize Bob for the Project

### Demo Script

**Say to Bob:**
```
/init
```

**What Bob Does:**
1. Analyzes the entire codebase structure
2. Identifies build commands, test commands, and project conventions
3. Creates AGENTS.md files with project-specific guidance
4. Discovers non-obvious patterns and requirements (e.g., COBOL column rules, compilation flags)

**Expected Output:**
```
Created AGENTS.md files with project guidance:
- Build commands (make all, cobc flags)
- COBOL-specific rules (fixed format, column requirements)
- File dependencies (copybooks, data files)
- Critical patterns (COMP-3 for money, ISAM file handling)
```

**Key Talking Points:**
- Bob learns the project structure automatically
- Discovers build requirements without manual documentation
- Identifies language-specific constraints (COBOL fixed format)
- Creates reusable knowledge for future sessions

---

## Part 1: Setting Up Trello MCP Server

### Step 1: Configure Trello API Credentials

1. **Get Trello API Credentials:**
   - Go to https://trello.com/power-ups/admin
   - Generate your API Key
   - Generate a Token with read/write permissions

2. **Configure Bob's MCP Settings:**
   - Open Bob IDE
   - Navigate to `.bob/mcp.json` in your workspace
   - Add your Trello credentials:

```json
{
  "mcpServers": {
    "trello": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-trello"
      ],
      "env": {
        "TRELLO_API_KEY": "your-api-key-here",
        "TRELLO_API_TOKEN": "your-token-here"
      }
    }
  }
}
```

3. **Restart Bob IDE** to load the MCP server configuration

Note; Ensure that you have created a trello board with categories for "to-do" tasks and "completed" tasks. Add a task "Add account age to the RPTGEN report" to your to-do list and assign it to yourself.

---

## Part 2: Understanding the Codebase (Optional Demo)

### Demo Script - Code Explanation Feature

**Before starting the task, demonstrate Bob's code understanding:**

1. **Open** `src/INTCALC.cbl` in the editor
2. **Highlight** a function (e.g., the interest calculation logic around line 400)
3. **Right-click** on the highlighted code
4. **Hover over** "Bob" in the context menu
5. **Click** "Explain"

**What Bob Does:**
1. Analyzes the selected code in context
2. Explains the business logic and COBOL patterns
3. Describes how it fits into the larger system
4. Identifies key COBOL constructs (COMP-3, FUNCTION INTEGER-OF-DATE, etc.)

**Expected Output:**
```
This code calculates interest using the day count convention method:

1. Converts dates to Julian day numbers using INTEGER-OF-DATE
2. Calculates actual days between dates
3. Applies the appropriate day count convention (ACT/360, ACT/365, 30/360)
4. Computes interest using packed decimal (COMP-3) for precision

Key COBOL patterns:
- COMP-3 ensures exact decimal arithmetic for financial calculations
- INTEGER-OF-DATE converts YYYYMMDD to Julian day numbers
- Day count conventions affect interest calculation accuracy
```

**Key Talking Points:**
- Bob understands legacy code without prior training
- Explains business logic, not just syntax
- Identifies domain-specific patterns (financial calculations)
- Helps new developers understand unfamiliar codebases

---

## Part 3: Discovering Tasks from Trello

### Demo Script

**Say to Bob:**
```
"What tasks are assigned to me in Trello?"
```

**What Bob Does:**
1. Connects to Trello via MCP
2. Searches for your assigned tasks across all boards
3. Lists tasks with details (board name, task name, URL, status)

**Expected Output:**
```
You have 1 task assigned to you in Trello:

Board: ATM_System
Task: Add account age to the RPTGEN report
- URL: https://trello.com/c/MdWAYZci
- Status: Open (no due date set)
```

**Key Talking Points:**
- Bob automatically discovers tasks without manual navigation
- Works across multiple Trello boards
- Provides direct links for easy reference

---

## Part 4: Building the Project (Baseline)

### Demo Script

**Before making changes, compile and run the existing code:**

**Say to Bob:**
```
"Run the makefile to compile all programs"
```

**What Bob Does:**
1. Executes `make all` in the cobol-banking-masterclass directory
2. Compiles all COBOL programs with proper flags
3. Shows compilation output

**Expected Output:**
```
Compiling COBOL programs...
✓ ACCTMSTR compiled successfully
✓ TXNPROC compiled successfully
✓ INTCALC compiled successfully
✓ RPTGEN compiled successfully
✓ AUDITLOG compiled successfully
All programs compiled successfully
```

**Then run the report generator:**

**Say to Bob:**
```
"Run RPTGEN to generate the current report"
```

**What Bob Does:**
1. Changes to bin/ directory (required for data file access)
2. Executes ./RPTGEN
3. Generates FINREPORT.RPT

**Show the current report:**
- Open `bin/FINREPORT.RPT`
- Point out that there is **NO AGE column** yet
- This establishes the baseline before Bob's changes

**Key Talking Points:**
- Bob understands COBOL build requirements (flags, copybooks)
- Knows programs must run from bin/ directory (data file dependency)
- This baseline proves Bob actually added the feature (not pre-existing)

---

## Part 5: Implementing the Feature

### Demo Script

**Say to Bob:**
```
"Help me complete this task. Age should appear as another column in the FINREPORT.RPT file"
```

**What Bob Does:**
1. **Analyzes the codebase** - Reads RPTGEN.cbl and related files
2. **Plans the implementation** - Identifies what needs to change:
   - Report header layout
   - Detail line structure
   - Age calculation logic
   - Working storage fields
3. **Makes surgical edits** - Uses `apply_diff` for precise changes
4. **Validates changes** - Ensures COBOL syntax and column rules are followed

**Key Files Modified:**
- `src/RPTGEN.cbl` - Added age calculation and display

**Key Talking Points:**
- Bob understands COBOL-specific requirements (fixed format, column rules)
- Makes minimal, targeted changes rather than rewriting entire files
- Follows COBOL best practices (COMP-3 for calculations, proper data types)
- Uses COBOL intrinsic functions (INTEGER-OF-DATE) for date arithmetic

---

## Part 6: Verifying the Changes

### Demo Script

**After Bob makes the code changes, recompile and run:**

**Say to Bob:**
```
"Recompile RPTGEN and run it again"
```

**What Bob Does:**
1. Compiles the modified RPTGEN.cbl
2. Runs the updated program
3. Generates new FINREPORT.RPT

**Show the updated report:**
- Open `bin/FINREPORT.RPT`
- **Point out the new AGE column** between OPENED and LAST TXN
- Show actual age values (11 years, 6 years, 7 years, 16 years)

**Key Talking Points:**
- Bob's changes work immediately without debugging
- Age column is properly formatted and positioned
- Calculations are accurate (using COBOL date functions)
- Report layout maintains proper alignment

---

## Part 7: Updating Task Status in Trello

### Demo Script

**Say to Bob:**
```
"Mark my task as complete and move it to completed in Trello"
```

**What Bob Does:**
1. Fetches board structure to find the "Done" list
2. Moves the card from "To Do" to "Done"
3. Confirms the update

**Expected Output:**
```
Task completed successfully!

Changes Made:
- Added AGE column to FINREPORT.RPT showing account age in years
- Modified RPTGEN.cbl to include age calculation using COBOL date functions

Trello Card Updated:
Moved "Add account age to the RPTGEN report" from To Do → Done
```

**Key Talking Points:**
- Seamless integration between development and project management
- Automatic status updates without context switching
- Maintains traceability between code changes and tasks

---

## Part 8: Code Review

### Demo Script

**Say to Bob:**
```
"/review"
```

**What Bob Does:**
1. **Analyzes changes** - Examines modified files
2. **Searches for impacts** - Finds related code and dependencies
3. **Identifies issues** - Checks for:
   - Bugs and edge cases
   - Security vulnerabilities
   - Performance concerns
   - Style and maintainability
4. **Creates findings** - Submits issues to Bob Findings panel

**Expected Findings:**
- Low severity: Age calculation uses 365 days (doesn't account for leap years)
- Medium severity: Potential overflow in Julian date fields (PIC 9(7))

**Key Talking Points:**
- Bob performs comprehensive code analysis
- Identifies issues that might be missed in manual review
- Provides specific suggestions for fixes
- Categorizes findings by severity and type
- Findings appear in dedicated panel for easy tracking

---

## Part 9: Creating a Pull Request

### Demo Script

**Say to Bob:**
```
"/create-pr"
```

**What Bob Does:**
1. **Prompts for base branch** - Asks which branch to target
2. **Creates feature branch** - `feature/add-account-age-column`
3. **Commits changes** - With descriptive commit message
4. **Pushes to remote** - Uploads branch to GitHub
5. **Generates PR description** - Creates comprehensive description
6. **Creates pull request** - Opens PR on GitHub

**Expected Output:**
```
Pull request successfully created!

https://github.com/shrncr/cobol-banking-masterclass/pull/1

The PR includes:
- Account age column added to FINREPORT
- Age calculation using COBOL INTEGER-OF-DATE function
- All changes committed to feature/add-account-age-column branch
- Ready for review and merge
```

**Key Talking Points:**
- Bob handles entire Git workflow automatically
- Generates professional PR descriptions
- Follows Git best practices (feature branches, descriptive commits)
- Creates clickable PR link for immediate access

---

## Part 10: Advanced Features to Highlight

### 1. Natural Language Understanding
**Example:**
```
"The age column should show years, not days"
```
Bob understands intent and makes appropriate changes.

### 2. Context Awareness
Bob remembers:
- Previous conversations
- File modifications
- Task requirements
- Project structure

### 3. Multi-Tool Orchestration
Bob seamlessly combines:
- File operations (read, write, edit)
- Git operations (branch, commit, push)
- MCP integrations (Trello, GitHub)
- Code analysis tools

### 4. COBOL Expertise
Bob knows:
- Fixed format column rules (Area A vs Area B)
- Data types (COMP-3 for money, PIC 9 for numbers)
- Intrinsic functions (INTEGER-OF-DATE, CURRENT-DATE)
- Best practices (packed decimal for financial calculations)

---

## Demo Flow Summary

```
0. /init
   ↓
1. [Optional] Highlight code in INTCALC.cbl → Right-click → Bob → Explain
   ↓
2. "Run the makefile to compile all programs"
   ↓
3. "Run RPTGEN to generate the current report" (show NO age column)
   ↓
4. "What tasks are assigned to me in Trello?"
   ↓
5. "Help me complete this task. Age should appear as another column..."
   ↓
6. "Recompile RPTGEN and run it again" (show NEW age column)
   ↓
7. "Mark my task as complete and move it to completed in Trello"
   ↓
8. /review
   ↓
9. /create-pr
```

**Total Time:** ~10-15 minutes (with baseline demonstration)
**Lines of Code Changed:** 25 insertions, 2 deletions
**Manual Steps Eliminated:** 20+

---

## Key Value Propositions

### For Developers
- **Faster Development:** Natural language replaces manual coding
- **Fewer Errors:** AI understands COBOL syntax and best practices
- **Better Code Quality:** Automatic code review catches issues early
- **Reduced Context Switching:** All tools in one interface

### For Teams
- **Improved Collaboration:** Automatic task tracking and updates
- **Better Visibility:** PR descriptions and code reviews are comprehensive
- **Consistent Quality:** AI enforces coding standards
- **Knowledge Preservation:** AI learns from codebase patterns

### For Organizations
- **Faster Time to Market:** Accelerated development cycles
- **Lower Training Costs:** AI guides developers through unfamiliar code
- **Reduced Technical Debt:** Proactive issue identification
- **Mainframe Modernization:** Makes COBOL development accessible

---

## Troubleshooting

### Trello Connection Issues
- Verify API key and token are correct
- Check token permissions (read/write required)
- Restart Bob IDE after configuration changes

### Git/GitHub Issues
- Ensure Git is configured with user name and email
- Verify GitHub authentication (SSH keys or personal access token)
- Check repository permissions

### COBOL Compilation Issues
- Ensure GnuCOBOL is installed
- Verify copybooks directory is accessible
- Check file paths are relative to workspace

---

## Additional Demo Scenarios

### Scenario 1: Bug Fix
```
"There's a bug in the interest calculation. It's using 360 days instead of 365."
```

### Scenario 2: Feature Enhancement
```
"Add a new column showing the last transaction amount in the report"
```

### Scenario 3: Code Explanation
```
"Explain how the control break logic works in RPTGEN.cbl"
```

### Scenario 4: Refactoring
```
"Extract the date formatting logic into a separate paragraph"
```

---

## Conclusion

This demo showcases how Bob AI transforms COBOL development by:
1. **Integrating** with existing tools (Trello, GitHub)
2. **Understanding** legacy code and business logic
3. **Automating** repetitive tasks and workflows
4. **Improving** code quality through AI-powered reviews
5. **Accelerating** development cycles with natural language programming

The result is a modern development experience for mainframe applications, making COBOL development accessible to new developers while empowering experienced developers to work more efficiently.

---

## Alternative Demo Approach: Using Conversation History

### Pre-Recording the Demo

If you want to avoid live execution during customer presentations, you can use Bob's conversation history feature:

**Setup (Do Once):**
1. Run through the entire demo flow once in Bob IDE
2. Complete all steps from `/init` through `/create-pr`
3. Bob automatically saves the entire conversation history

**During Customer Demo:**
1. Open Bob IDE and navigate to the conversation history
2. Click on the saved demo conversation
3. Walk through the conversation step-by-step, showing:
   - Your original prompts/commands
   - Bob's responses and actions
   - Code changes made
   - Files created/modified
   - Review findings
   - Pull request creation

**Benefits of This Approach:**
- **No live execution risk** - Everything is pre-recorded and verified
- **Faster presentation** - No waiting for compilation or API calls
- **Consistent results** - Same output every time
- **Easy navigation** - Jump to specific parts of the workflow
- **Pause and explain** - Take time to discuss each step without time pressure
- **Backup plan** - If live demo fails, switch to conversation history

**Best Practice:**
- Run the live demo at least once before customer meetings
- Keep the conversation history as a backup
- Use live demo for technical audiences who want to see real-time execution
- Use conversation history for executive audiences focused on outcomes

**Accessing Conversation History:**
1. Click the conversation history icon in Bob IDE (top right)
2. Select the demo conversation from the list
3. All messages, code changes, and tool outputs are preserved
4. You can even continue the conversation from any point

This approach gives you the flexibility to deliver either a live, interactive demo or a polished, pre-recorded walkthrough depending on your audience and circumstances.

---

## Next Steps

After the demo, discuss:
- Integration with customer's existing tools (Jira, Azure DevOps, etc.)
- Custom mode creation for specific workflows
- Training on customer's codebase
- Pilot program scope and success metrics