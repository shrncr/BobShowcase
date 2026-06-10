# 🚀 Personal Use Guide: Build Your Own WXO Demo Agents

## For Technical Sellers Who Want to Create Custom Demos

This guide is for **you** - the technical seller who wants to build your own watsonx Orchestrate agents for customer demos. You don't need to be a developer. Bob will do the heavy lifting.

---

## 🎯 Why Build Your Own Agents?

### Instead of using generic demos, you can:
- ✅ **Match your customer's industry** - Build a retail agent for retail customers, healthcare for healthcare, etc.
- ✅ **Use their terminology** - Speak their language with domain-specific entities and workflows
- ✅ **Address their pain points** - Focus on capabilities that solve their actual problems
- ✅ **Stand out from competitors** - Show up with a working demo tailored to their business
- ✅ **Build your demo library** - Create reusable agents for different industries and use cases

---

## 🏃 Quick Start (30 Minutes to Your First Agent)

### Step 1: Set Up Your Environment (5 minutes)

1. **Get your WXO credentials:**
   - Log into your watsonx Orchestrate instance
   - Get your API key from Settings
   - Copy your instance URL (looks like: `https://api.us-south.watson-orchestrate.cloud.ibm.com/instances/your-instance-id`)

2. **Create `.bob/.env` file:**
   ```bash
   WO_API_KEY=your_api_key_here
   WO_INSTANCE=https://api.us-south.watson-orchestrate.cloud.ibm.com/instances/your-instance-id
   ```

3. **You're ready!** Bob will use these credentials to deploy agents to your instance.

---

### Step 2: Choose Your Approach (Pick One)

#### 🎤 **Option A: Use a Discovery Call Transcript** (Fastest - 10 minutes)
**Best for:** When you have notes from a customer call or want to recreate a specific use case

**How to do it:**
1. Take notes from your customer discovery call (or use the example `ta_discovery_call_transcript.md`)
2. Create a markdown file with the key points:
   - What domain/industry?
   - What entities do they manage? (customers, patients, orders, etc.)
   - What are their pain points?
   - What capabilities do they need?
3. Prompt Bob:
   ```
   Build a watsonx Orchestrate agent based on the discovery call in [filename].md
   ```

**Example domains you can build:**
- Retail: Customer loyalty and personalized marketing
- Healthcare: Patient engagement and appointment management
- Finance: Client portfolio management and advisory
- Manufacturing: Supplier relationship management
- Education: Student progress tracking and engagement
- Hospitality: Guest services and loyalty programs
- Real Estate: Property matching and client management
- Insurance: Policy management and claims processing

---

#### 💬 **Option B: Let Bob Interview You** (Interactive - 15 minutes)
**Best for:** When you want to explore ideas or don't have detailed notes

**How to do it:**
1. Think about your customer's domain and pain points
2. Prompt Bob:
   ```
   I want to build a watsonx Orchestrate agent for [industry/domain]. Please interview me to gather requirements.
   ```
3. Answer Bob's questions about:
   - Domain and industry
   - Entity types (customers, products, orders, etc.)
   - Tier/segment structure (Basic/Premium/VIP, etc.)
   - Required capabilities
   - Communication types needed

**Bob will ask smart questions like:**
- "What do you call the main entities in your domain?"
- "Do you have tiers or segments for these entities?"
- "What are the 3-5 main capabilities this agent should have?"
- "What types of communications should the agent generate?"

---

#### 🎨 **Option C: Describe Your Vision** (Flexible - 12 minutes)
**Best for:** When you have a clear idea but no formal documentation

**How to do it:**
Just tell Bob what you want in natural language:

```
I want to build a retail customer service agent that can:
- Look up customer profiles and purchase history
- Check loyalty tier status (Basic, Silver, Gold, Platinum)
- Generate personalized product recommendations
- Create promotional emails based on customer preferences
- Calculate loyalty points and rewards

The agent should work with customer data including purchase history, 
preferences, and loyalty status. It should be able to answer questions 
like "Show me Gold tier customers" or "Generate a promotion for customer C001".
```

Bob will extract the requirements and build the agent.

---

### Step 3: Let Bob Build (5-7 minutes)

**What Bob will do automatically:**
1. ✅ Analyze your requirements
2. ✅ Design the agent architecture
3. ✅ Generate Python tools with embedded sample data
4. ✅ Create agent configuration (YAML)
5. ✅ Set up knowledge base for RAG
6. ✅ Generate deployment scripts
7. ✅ Deploy to your WXO instance
8. ✅ Test the agent
9. ✅ Create documentation with sample queries

**You just watch and wait.** Bob handles everything.

---

### Step 4: Test Your Agent (5 minutes)

1. **Open watsonx Orchestrate** in your browser
2. **Find your agent** in the agent list
3. **Try the sample queries** from the generated `BUSINESS_USE_CASE.md` file

**Example queries to try:**
- "Get [entity] [ID]" (e.g., "Get customer C001")
- "Show me all [tier] [entities]" (e.g., "Show me all Premium customers")
- "Calculate [entity] metrics"
- "Generate a [communication type] for [entity ID]"

---

### Step 5: Customize (Optional - 10+ minutes)

**Want to make it more realistic?**

1. **Replace sample data:**
   - Edit `data/entities.csv` with realistic data
   - Use your customer's actual entity names and tiers
   - Add more records (10-20 is good for demos)

2. **Add more capabilities:**
   - Tell Bob: "Add a tool that can [new capability]"
   - Bob will generate the new tool and update the agent

3. **Customize communications:**
   - Edit `tools/communication_tools.py`
   - Modify HTML templates to match your customer's branding
   - Add new message types

4. **Re-deploy:**
   ```bash
   cd [agent-name]-agent
   ./scripts/deploy_all.sh
   ```

---

## 📚 Building Your Demo Library

### Create Agents for Different Industries

**Retail:**
```
Build a retail customer engagement agent that manages customer profiles, 
loyalty tiers (Basic/Silver/Gold/Platinum), purchase history, and generates 
personalized product recommendations and promotional emails.
```

**Healthcare:**
```
Build a patient engagement agent for a healthcare provider that manages 
patient profiles, appointment scheduling, prescription refills, and sends 
appointment reminders and health education messages.
```

**Finance:**
```
Build a financial advisory agent that manages client portfolios, investment 
accounts, risk profiles (Conservative/Moderate/Aggressive), and generates 
personalized investment recommendations and market updates.
```

**Manufacturing:**
```
Build a supplier relationship management agent that tracks supplier 
performance, manages purchase orders, monitors quality metrics, and 
generates performance reports and contract renewal reminders.
```

**Education:**
```
Build a student success agent that tracks student progress, course 
enrollments, GPA, and generates personalized learning recommendations, 
assignment reminders, and progress reports.
```

---

## 🎯 Tips for Great Demo Agents

### 1. **Use Realistic Entity Names**
- ❌ "Entity001", "Entity002"
- ✅ "Jennifer Martinez", "Acme Corporation", "Order #12345"

### 2. **Create Diverse Tiers**
- Include entities across all tiers (not just premium)
- Show different statuses (active, inactive, pending)
- Demonstrate tier-specific benefits

### 3. **Make Data Relevant**
- Use industry-appropriate metrics
- Include realistic dates and values
- Add domain-specific fields

### 4. **Test Multiple Scenarios**
- Entity lookup by ID
- Filtering by tier/status
- Metrics and analytics
- Communication generation
- Open-ended questions (RAG)

### 5. **Prepare Your Story**
- Know why each capability matters
- Connect features to business value
- Have 2-3 "wow" queries ready

---

## 🔧 Common Customizations

### Change Entity Names
**Prompt:** "Rename 'customers' to 'members' throughout the agent"

### Add a New Tier
**Prompt:** "Add a 'Diamond' tier above Platinum with exclusive benefits"

### Add Integration
**Prompt:** "Add a tool that calls the Salesforce API to get customer data"

### Change Communication Style
**Prompt:** "Make the email templates more formal and professional"

### Add More Sample Data
**Prompt:** "Generate 15 more realistic customer records with diverse data"

---

## 📋 Pre-Demo Checklist

Before showing your custom agent to a customer:

- [ ] Test all sample queries work correctly
- [ ] Verify entity names match customer's terminology
- [ ] Check that tiers/segments align with their business model
- [ ] Ensure communications use appropriate tone
- [ ] Have 3-5 "wow" queries prepared
- [ ] Know the business value of each capability
- [ ] Test on mobile if customer uses mobile devices
- [ ] Have backup queries ready if something fails

---

## 🎤 Demo Script Template

**Opening:**
> "I built this agent specifically for [customer's industry]. It understands your [entities], your [tier structure], and can help with [key pain points]."

**Show Capabilities:**
> "Let me show you what it can do. First, let's look up [entity]..."
> [Run query]
> "Now let's see all your [tier] [entities]..."
> [Run query]
> "And here's where it gets interesting - it can generate personalized [communications]..."
> [Run query]

**Connect to Value:**
> "This means your team can [business benefit] without [current pain point]. Instead of [manual process], the agent handles it automatically."

**Close:**
> "This agent is already deployed and working. We can customize it further for your specific needs, add integrations with your systems, and have it production-ready in weeks, not months."

---

## 💡 Ideas for Different Customer Types

### **Enterprise Customers:**
- Build agents with complex tier structures (5-6 tiers)
- Include compliance and audit capabilities
- Show integration with enterprise systems
- Demonstrate scalability with large datasets

### **Mid-Market Customers:**
- Focus on quick wins and immediate value
- Show how it replaces manual processes
- Emphasize ease of deployment
- Demonstrate ROI with specific metrics

### **Industry-Specific Customers:**
- Use their exact terminology and workflows
- Include industry-specific regulations
- Show domain expertise through agent instructions
- Reference industry benchmarks and standards

---

## 🚀 Advanced: Multi-Agent Demos

**Want to show multiple agents working together?**

Build 2-3 related agents:
1. **Customer Service Agent** - Handles inquiries and support
2. **Sales Agent** - Manages leads and opportunities
3. **Operations Agent** - Tracks orders and fulfillment

**Prompt for each:**
```
Build a [type] agent that works with [entities] and can [capabilities]. 
This agent will work alongside [other agents] in a multi-agent system.
```

---

## 📞 Getting Help

### If something doesn't work:
1. Check `.bob/.env` has correct credentials
2. Verify your WXO instance is accessible
3. Try re-deploying: `cd [agent-name]-agent && ./scripts/deploy_all.sh`
4. Check `TROUBLESHOOTING.md` in the agent directory

### If you want to modify something:
Just tell Bob what you want changed:
- "Add a new capability for [feature]"
- "Change the tier names to [new names]"
- "Make the communications more [style]"
- "Add 10 more sample [entities]"

---

## 🎁 Bonus: Reusable Patterns

### Save Your Best Agents
Keep a library of agents you've built:
```
my-demo-agents/
├── retail-customer-service/
├── healthcare-patient-engagement/
├── finance-portfolio-advisor/
├── manufacturing-supplier-mgmt/
└── education-student-success/
```

### Clone and Customize
When you need a similar agent:
1. Copy an existing agent directory
2. Tell Bob: "Customize this agent for [new customer/use case]"
3. Bob will adapt it while keeping the proven structure

### Share with Your Team
- Commit agents to a shared repository
- Document what works well for each industry
- Build a playbook of successful demos

---

## ✅ Success Checklist

You're ready to demo when:
- ✅ Agent deploys successfully to your WXO instance
- ✅ All sample queries return correct results
- ✅ Entity names match customer's terminology
- ✅ Tiers/segments align with their business model
- ✅ Communications use appropriate tone and style
- ✅ You can explain the business value of each capability
- ✅ You have 3-5 "wow" queries prepared
- ✅ You've tested the agent end-to-end

---

## 🎯 Remember

**You don't need to be a developer.** Bob handles all the technical details:
- ✅ Python code generation
- ✅ WXO best practices
- ✅ Deployment automation
- ✅ Error handling
- ✅ Documentation

**You just need to:**
- 🎯 Understand your customer's needs
- 🎯 Describe what you want
- 🎯 Test the agent
- 🎯 Tell a compelling story

**Bob does the rest.**

---

## 🚀 Ready to Build?

**Start with this prompt:**
```
I want to build a watsonx Orchestrate agent for [your customer's industry]. 
Please interview me to gather requirements.
```

**Or use a transcript:**
```
Build a watsonx Orchestrate agent based on the discovery call in [filename].md
```

**Or describe your vision:**
```
I want to build a [domain] agent that can [capabilities]. 
It should work with [entities] and help with [pain points].
```

**Then sit back and watch Bob build your custom demo agent in minutes.**

---

**Questions?** Just ask Bob. Bob can help you refine requirements, add features, fix issues, or explain how anything works.

**Happy building! 🎉**