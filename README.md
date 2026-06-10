# Bob Showcase Demos

This repository contains the code used in Bob AI Assistant showcase demonstrations. Each folder represents a different demo showcasing Bob's capabilities across various development scenarios.

## 📂 Repository Structure

This repository has **two branches**:

### 🌱 `startingcodebases` Branch
Contains the **initial state** of each codebase **before** Bob worked on them. Use this branch to recreate the demos yourself.

### ✨ `finalproducts` Branch
Contains the **final state** of each codebase **after** Bob completed the demos. Use this branch to see what Bob created.

---

## 🎯 Demo Projects

### 1. **agent_creation** - IBM watsonx Orchestrate Agent Builder
**Demo Focus:** Creating AI agents with IBM watsonx Orchestrate

This demo showcases Bob's ability to:
- Build enterprise AI agents from scratch
- Configure agent tools, knowledge bases, and workflows
- Deploy agents to IBM watsonx Orchestrate
- Follow complex deployment procedures and CLI commands

**Technologies:** Python, IBM watsonx Orchestrate, YAML configuration

---

### 2. **cobol_newhire** - COBOL Banking System Onboarding
**Demo Focus:** Modernizing and understanding legacy COBOL systems

This demo showcases Bob's ability to:
- Understand and explain legacy COBOL code
- Document complex banking system logic
- Help new developers onboard to mainframe systems
- Generate reports and analysis of COBOL programs

**Technologies:** COBOL, Mainframe Banking Systems

---

### 3. **framework_migration** - PHP to React Migration
**Demo Focus:** Migrating a legacy PHP application to modern React

This demo showcases Bob's ability to:
- Analyze existing PHP codebases
- Plan and execute framework migrations
- Convert server-side rendering to client-side React
- Modernize UI/UX with contemporary patterns

**Technologies:** PHP, React, JavaScript, Vite

---

## 🚀 How to Recreate the Demos

To experience Bob's capabilities yourself:

1. **Fork and clone this repository:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/BobShowcase.git
   cd BobShowcase
   ```

2. **Switch to the `startingcodebases` branch:**
   ```bash
   git checkout startingcodebases
   ```

3. **Open the specific demo folder in Bob IDE:**
   - Open **only the folder** for the demo you want to try (e.g., `agent_creation`, `cobol_newhire`, or `framework_migration`)
   - Each folder contains a `.bob` directory with:
     - Custom rules and instructions
     - Specialized modes for that demo
     - Context-specific configurations

4. **Start working with Bob:**
   - Bob will automatically load the demo-specific rules and modes
   - Follow the demo scenario or create your own tasks
   - Watch Bob work its magic!

---

## 👀 How to View Final Results

To see what Bob created:

1. **Fork and clone this repository:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/BobShowcase.git
   cd BobShowcase
   ```

2. **Switch to the `finalproducts` branch:**
   ```bash
   git checkout finalproducts
   ```

3. **Explore the completed code:**
   - Browse through each demo folder
   - Review Bob's implementations
   - Study the patterns and approaches used

---

## 📋 Prerequisites

Depending on which demo you want to run:

### For `agent_creation`:
- Python 
- IBM watsonx Orchestrate account
- API credentials (see `.bob/.env.example`)

### For `cobol_newhire`:
- GnuCOBOL compiler (optional, for running code)
- Understanding of mainframe concepts (helpful but not required)

### For `framework_migration`:
- Node.js 18+
- npm or yarn
- PHP to run original application
- Basic understanding of React

---

## 🔒 Security Note

This repository includes a comprehensive `.gitignore` file that protects:
- Environment variables and API keys
- Credentials and secrets
- Build artifacts and dependencies
- IDE and system files

**Never commit sensitive information like API keys or credentials to version control.**

---

## 📖 Learning Resources

Each demo folder may contain additional documentation:
- `README.md` - Project-specific instructions
- `TROUBLESHOOTING.md` - Common issues and solutions
- `.bob/rules.md` - Bob's custom rules for that demo
- `.bob/custom_modes.yaml` - Specialized Bob modes

---

## 🤝 Contributing

This repository is primarily for demonstration purposes. However, if you find issues or have suggestions:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

See individual project folders for specific licensing information.

---

## 🎓 About Bob

Bob is an AI-powered development assistant that helps developers:
- Write and refactor code
- Understand complex codebases
- Migrate between frameworks
- Deploy applications
- And much more!

Visit [Bob's website](https://bob.build) to learn more.

---

**Happy Coding with Bob! 🤖✨**