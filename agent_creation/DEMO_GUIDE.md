# 🎯 Bob + WXO Agent Builder Demo Guide for Technical Sellers

## Overview
This repository demonstrates Bob's ability to build production-ready watsonx Orchestrate agents through an intelligent, interview-based workflow. The demo showcases a complete Talent Acquisition screening agent built for Brightwell Health.

---

## 🎬 Demo Flow (15-20 minutes)

### Part 1: Show the Custom Mode (2 minutes)
**What to highlight:**
- Open `.bob/custom_modes.yaml` and show the `domain-agent-builder` mode
- **Key point:** This is a specialized Bob mode that knows how to build WXO agents end-to-end
- **What it does:**
  - Conducts structured interviews to gather requirements
  - Designs agent architecture based on proven patterns
  - Generates all files (tools, configs, data, scripts)
  - Deploys agents to watsonx Orchestrate
  - Tests and validates the deployment

**Demo script:**
> "Bob has a custom mode specifically for building watsonx Orchestrate agents. This mode contains all the expertise needed to go from a business idea to a deployed, working agent. It follows IBM's best practices and uses proven templates."

---

### Part 2: Show the Orchestrate MCP Server (2 minutes)
**What to highlight:**
- Open `.bob/mcp.json` and show the `wxo-docs` server configuration
- **Key point:** Bob can search the entire WXO ADK documentation in real-time
- **What it enables:**
  - Bob searches docs while building agents
  - Always uses current best practices
  - Finds code examples and API references on-demand

**Demo script:**
> "Bob is connected to the watsonx Orchestrate documentation through an MCP server. This means Bob can search the entire ADK documentation in real-time while building your agent. It's like having an expert who always has the latest docs open."

---

### Part 3: Show the Discovery Call Transcript (3 minutes)
**What to highlight:**
- Open `ta_discovery_call_transcript.md`
- **Key point:** This is a real discovery call transcript from a Brightwell Health TA use case
- **Options for sellers:**
  1. **Use as-is:** Demo with the Brightwell Health example
  2. **Replace it:** Drop in your own customer's discovery call transcript
  3. **Delete it:** Let Bob conduct a live interview with you playing the customer

**Demo script:**
> "This transcript captures a real discovery call about a Talent Acquisition screening use case. You have three options:
> 1. Use this example to show a complete healthcare TA agent
> 2. Replace it with your own customer's transcript before the demo
> 3. Delete it and let Bob interview you live during the demo - you play the customer role"

---

### Part 4: Environment Setup (2 minutes)
**What to show:**
- Open `.bob/.env` (or create it if it doesn't exist)
- **Required credentials:**
  ```bash
  WO_API_KEY=your_wxo_api_key_here
  WO_INSTANCE=https://api.us-south.watson-orchestrate.cloud.ibm.com/instances/your-instance-id
  ```

**Demo script:**
> "Before Bob can deploy agents to your watsonx Orchestrate instance, we need two things in the .env file: your API key and your instance URL. Bob will ask for these during deployment and use them to authenticate."

**When to set this up:**
- **Before the demo:** If you're deploying to your own WXO instance
- **During the demo:** If you want to show the deployment process live
- **After the demo:** If you're just showing the code generation without deployment

---

### Part 5: The Main Demo - Building the Agent (8-10 minutes)

#### Option A: Using the Transcript (Faster)
**Prompt to use:**
```
I want to build a watsonx Orchestrate agent based on the discovery call transcript in ta_discovery_call_transcript.md. Please review the transcript and build the complete agent.
```

**What Bob will do:**
1. Read and analyze the transcript
2. Extract requirements (domain, entities, capabilities)
3. Design the agent architecture
4. Generate all files (tools, configs, data, scripts)
5. Deploy to WXO (if credentials are set)
6. Test the agent
7. Generate business use case documentation

**Timeline:** ~5-7 minutes for Bob to complete

#### Option B: Live Interview (More Interactive)
**Prompt to use:**
```
I want to build a watsonx Orchestrate agent. Please interview me to gather requirements.
```

**What Bob will do:**
1. Ask structured questions about:
   - Domain/industry
   - Entity types and tiers
   - Required capabilities
   - Data sources
   - Communication types
2. Design based on your answers
3. Generate and deploy the agent

**Timeline:** ~8-10 minutes depending on interview depth

---

### Part 6: Show the Generated Agent (3-5 minutes)

**What to highlight:**

1. **Project Structure:**
   ```
   brightwell-ta-agent/
   ├── agent_config.yaml          # Agent configuration
   ├── tools/                     # Python tools with embedded data
   │   ├── requisition_tools.py
   │   ├── candidate_tools.py
   │   └── screening_tools.py
   ├── data/                      # CSV files for knowledge base
   ├── knowledge_bases/           # Vector search configuration
   └── scripts/                   # Deployment automation
   ```

2. **Key Files to Open:**
   - `agent_config.yaml` - Show the agent instructions and tool configuration
   - `tools/screening_tools.py` - Show the embedded data and screening logic
   - `BUSINESS_USE_CASE.md` - Show the sample queries and use case

3. **Test in WXO:**
   - Open watsonx Orchestrate
   - Find the deployed agent
   - Try sample queries from `BUSINESS_USE_CASE.md`:
     - "Get candidate CAND-001"
     - "Show me all candidates for REQ-2026-001"
     - "Screen candidate CAND-001 against requisition REQ-2026-001"

---

## 🎯 Key Demo Talking Points

### 1. Speed to Value
> "Bob went from a discovery call transcript to a fully deployed, working agent in under 10 minutes. Traditionally, this would take days or weeks of development."

### 2. Best Practices Built-In
> "Bob follows IBM's watsonx Orchestrate best practices automatically - proper tool isolation, embedded data patterns, correct CLI commands, and proven agent architectures."

### 3. Domain Agnostic
> "While we showed a healthcare TA example, Bob can build agents for any domain - retail, finance, manufacturing, education, etc. The same workflow adapts to any industry."

### 4. Production Ready
> "This isn't a prototype. The generated agent includes proper error handling, deployment scripts, documentation, and is ready for production use."

### 5. Customizable
> "Everything Bob generates is editable. You can customize the tools, add more capabilities, integrate with external APIs, or modify the agent instructions."

---

## 📋 Pre-Demo Checklist

- [ ] Clone this repository
- [ ] Install Bob (if not already installed)
- [ ] Set up `.bob/.env` with WXO credentials (if deploying)
- [ ] Review `ta_discovery_call_transcript.md` (or replace with your own)
- [ ] Test your WXO instance is accessible
- [ ] Have watsonx Orchestrate UI open in a browser tab
- [ ] Prepare to show both Bob's code generation AND the live agent

---

## 🎤 Sample Demo Script

**Opening (1 min):**
> "Today I'm going to show you how Bob can build production-ready watsonx Orchestrate agents in minutes. We'll start with a discovery call transcript and end with a fully deployed, working agent."

**Custom Mode (1 min):**
> "Bob has a specialized mode for building WXO agents. This mode contains all the expertise needed - it knows the ADK, best practices, deployment patterns, and can even search the documentation in real-time through this MCP server."

**The Build (5-7 min):**
> "Let me show you Bob in action. I'm going to give Bob this discovery call transcript from a Talent Acquisition use case. Watch as Bob analyzes the requirements, designs the architecture, and generates all the code."

[Run the prompt, narrate what Bob is doing]

**The Result (3 min):**
> "In just a few minutes, Bob has created a complete agent with tools, data, knowledge base, and deployment scripts. Let me show you the generated code... and now let's test it in watsonx Orchestrate."

[Show the agent working in WXO]

**Closing (1 min):**
> "What you just saw - from transcript to deployed agent - would typically take days or weeks. Bob did it in minutes, following all best practices, and the result is production-ready."

---

## 🔧 Troubleshooting

### If tools return empty output:
- Check that tools return `Dict[str, Any]` not `List` or `Optional`
- Verify embedded data is present in tool files
- Re-import tools: `uvx --from ibm-watsonx-orchestrate orchestrate tools import -k python -f tools/file.py`

### If deployment fails:
- Verify `.bob/.env` has correct `WO_API_KEY` and `WO_INSTANCE`
- Check that environment is activated before deployment
- Ensure instance URL includes `/instances/your-instance-id`

### If agent doesn't appear in WXO:
- Wait 30-60 seconds for deployment to propagate
- Refresh the WXO UI
- Check deployment logs for errors

---

## 📞 Questions to Anticipate

**Q: Can Bob build agents for other domains?**
A: Yes! Bob can build agents for any domain - healthcare, retail, finance, manufacturing, etc. The workflow is domain-agnostic.

**Q: How does Bob know WXO best practices?**
A: Bob's custom mode includes all WXO best practices, and Bob can search the ADK documentation in real-time through the MCP server.

**Q: Can we customize the generated agent?**
A: Absolutely. Everything Bob generates is editable code. You can modify tools, add capabilities, change instructions, or integrate with external systems.

**Q: Is this production-ready?**
A: Yes. Bob generates production-ready code with proper error handling, deployment automation, and documentation.

**Q: How long does it take to build an agent?**
A: With a transcript: 5-7 minutes. With a live interview: 8-10 minutes. Manual development: days to weeks.

---

## 🎁 Demo Variations

### Quick Demo (10 min):
- Use the transcript
- Show code generation only
- Skip deployment
- Show sample queries in documentation

### Full Demo (20 min):
- Use the transcript
- Show complete deployment
- Test live in WXO
- Show customization options

### Interactive Demo (25 min):
- Delete the transcript
- Let Bob interview you live
- Deploy and test
- Show how to modify the agent

---

## 📚 Additional Resources

- **WXO ADK Documentation:** https://developer.watson-orchestrate.ibm.com/
- **Bob Documentation:** [Link to Bob docs]
- **Sample Agents:** Check `.bob/portfolio-advisor-agent/` for the reference template
- **Custom Modes Guide:** `.bob/rules-domain-agent-builder/` contains all the rules Bob follows

---

## ✅ Success Metrics

After the demo, the customer should understand:
- ✅ Bob can build WXO agents in minutes, not days
- ✅ The agents follow IBM best practices automatically
- ✅ The workflow works for any domain or industry
- ✅ The output is production-ready, not a prototype
- ✅ Everything is customizable and extensible

---

**Questions?** Contact your IBM watsonx Orchestrate team or check the ADK documentation.