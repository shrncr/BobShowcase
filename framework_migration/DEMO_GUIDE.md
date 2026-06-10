# IBM Bob Demo Guide: PHP to React Migration Showcase

**Version 1.0**  
**Target Audience:** Technical Sellers  
**Duration:** 15-20 minutes  
**Difficulty:** Intermediate

---

## Overview

This demo showcases IBM Bob's powerful AI-assisted development capabilities by demonstrating a complete PHP-to-React migration with bug fixes. You'll show how Bob can plan, execute, and test a full application migration while fixing broken functionality.

---

## Prerequisites

Before starting the demo, ensure you have:

- ✅ **PHP installed** (version 7.4 or higher)
  - Check with: `php --version`
  - Download from: https://www.php.net/downloads
- ✅ **Node.js installed** (version 18 or higher)
- ✅ **VS Code with IBM Bob extension**
- ✅ **This codebase cloned locally**

---

## Demo Script

### Part 1: Highlight Bob's Custom Rules (2 minutes)

**What to Say:**  
*"Before we start, let me show you one of Bob's most powerful features - custom rules that guide code generation."*

**Actions:**

1. **Open the `.bob/rules.md` file** in VS Code
2. **Scroll through the file** to show its comprehensive nature (3,810 lines!)
3. **Highlight key sections:**
   - Point to the Table of Contents (lines 21-100)
   - Show the 8 categories of React best practices:
     - ✨ **Eliminating Waterfalls** (CRITICAL)
     - 📦 **Bundle Size Optimization** (CRITICAL)
     - 🖥️ **Server-Side Performance** (HIGH)
     - 🌐 **Client-Side Data Fetching** (MEDIUM-HIGH)
     - 🔄 **Re-render Optimization** (MEDIUM)
     - 🎨 **Rendering Performance** (MEDIUM)
     - ⚡ **JavaScript Performance** (LOW-MEDIUM)
     - 🚀 **Advanced Patterns** (LOW)

**Key Talking Points:**
- *"This rules file contains 40+ React best practices from Vercel Engineering"*
- *"Bob will automatically follow these rules when generating React code"*
- *"This ensures enterprise-grade, production-ready code every time"*
- *"You can customize these rules for your organization's standards"*

---

### Part 2: Run the Broken PHP Application (3 minutes)

**What to Say:**  
*"Let's start with the original PHP application and identify the problems we need to solve."*

**Actions:**

1. **Start the PHP server:**
   ```bash
   php -S localhost:8000
   ```
   
   *Or ask Bob to do it:*
   - Open Bob chat
   - Type: `Start the PHP development server on port 8000`
   - Bob will execute: `php -S localhost:8000`

2. **Open the application in browser:**
   - Navigate to: `http://localhost:8000/browse-paintings.php`

3. **Click through the application and demonstrate the bugs:**

   **Bug #1: Add to Cart Doesn't Work**
   - Click the orange "Add to Cart" button on any painting
   - **Show:** The button links to `cart.php?id=XXX` but the file doesn't exist
   - **Result:** 404 error or broken functionality
   
   **Bug #2: Favorites Feature Doesn't Work**
   - Click the heart icon on any painting
   - **Show:** The button has an empty `href=""` attribute
   - **Result:** Page just refreshes, nothing happens
   
   **Bug #3: No Cart Persistence**
   - **Show:** There's no shopping cart display or persistence mechanism
   - **Result:** Users can't see what they've added

**Key Talking Points:**
- *"This is a typical legacy PHP application with broken features"*
- *"The cart functionality was never implemented"*
- *"The favorites feature has no backend logic"*
- *"Let's see how Bob can help us migrate AND fix these issues"*

---

### Part 3: Switch to Plan Mode & Create Migration Strategy (4 minutes)

**What to Say:**  
*"Now let's use Bob's Plan mode to create a comprehensive migration strategy. Bob can break down complex tasks into actionable steps."*

**Actions:**

1. **Switch Bob to Plan Mode:**
   - Click the mode selector in Bob's interface
   - Select "📝 Plan" mode

2. **Use the Advanced Prompt Feature:**
   - Click the "Advanced Prompt" button (or press the keyboard shortcut)
   - This allows for more detailed, structured prompts

3. **Enter this prompt:**
   ```
   I need a comprehensive plan to migrate this PHP art gallery application to React.js 
   and fix the broken functionality. Specifically:
   
   1. Migrate from PHP to React.js with modern best practices
   2. Fix the non-functional "Add to Cart" feature
   3. Fix the non-functional "Favorites" feature
   4. Implement proper state management for cart and favorites
   5. Ensure data persistence using localStorage
   6. Maintain the existing UI/UX design
   
   Please create a detailed migration plan with:
   - Architecture decisions
   - Component structure
   - State management approach
   - Step-by-step implementation phases
   - Testing strategy
   ```

4. **Watch Bob work:**
   - Bob will analyze the PHP codebase
   - Bob will read multiple files to understand the structure
   - Bob will create a comprehensive plan document

**Expected Output:**
- Bob will create files like:
  - `MIGRATION_STRATEGY.md` - Overall approach
  - `IMPLEMENTATION_PLAN.md` - Step-by-step tasks
  - `ARCHITECTURE_DIAGRAM.md` - Component hierarchy
  - Detailed breakdown of each phase

**Key Talking Points:**
- *"Notice how Bob analyzes the existing codebase first"*
- *"Bob creates multiple planning documents for different audiences"*
- *"The plan follows the React best practices from our rules file"*
- *"Bob breaks down the complex migration into manageable phases"*

---

### Part 4: Switch to Code Mode & Execute Migration (8 minutes)

**What to Say:**  
*"Now comes the magic - let's have Bob execute the entire migration plan. This is where Bob really shines."*

**Actions:**

1. **Switch Bob to Code Mode:**
   - Click the mode selector
   - Select "💻 Code" mode

2. **Give Bob the execution command:**
   ```
   Execute the migration plan we just created. Migrate the PHP application to React.js 
   and implement the cart and favorites functionality as specified in the plan.
   
   Follow the implementation plan step by step and ensure all features work correctly.
   ```

3. **Watch Bob work (this may take 5-10 minutes):**
   
   Bob will systematically:
   - ✅ Create the React project structure
   - ✅ Set up routing with React Router
   - ✅ Create reusable components (Header, Footer, Layout)
   - ✅ Build the paintings data structure
   - ✅ Implement custom hooks for state management:
     - `useFavorites.js` - Favorites with localStorage
     - `useCart.js` - Shopping cart with localStorage
   - ✅ Create page components:
     - `BrowsePaintings.jsx` - Main gallery view
     - `PaintingDetail.jsx` - Individual painting view
     - `Favorites.jsx` - Favorites collection
   - ✅ Implement filter functionality
   - ✅ Add cart and favorites UI components
   - ✅ Style with Semantic UI (matching original design)

**Key Talking Points During Execution:**
- *"Bob is following the plan we created earlier"*
- *"Notice how Bob creates files one at a time, waiting for confirmation"*
- *"Bob is applying the React best practices from our rules file"*
- *"The code includes proper error handling and edge cases"*
- *"Bob is implementing localStorage for data persistence"*

**What to Highlight in the Generated Code:**

Show these key files:

**`src/hooks/useFavorites.js`:**
```javascript
// Bob implemented proper state management with localStorage
const [favorites, setFavorites] = useState(() => {
  const saved = localStorage.getItem('artGalleryFavorites');
  return saved ? JSON.parse(saved) : [];
});
```

**`src/hooks/useCart.js`:**
```javascript
// Bob created a complete cart system with quantity management
const addToCart = (painting) => {
  setCart(prevCart => {
    const existingItem = prevCart.find(item => item.id === painting.PaintingID);
    // ... proper cart logic
  });
};
```

**`src/components/favorites/FavoriteButton.jsx`:**
```javascript
// Bob fixed the broken favorites feature
const handleToggle = () => {
  if (isFavorite) {
    removeFromFavorites(paintingId);
  } else {
    addToFavorites(paintingId);
  }
};
```

---

### Part 5: Test the React Application (Optional - 3 minutes)

**What to Say:**  
*"Let's verify that everything works. We can even have Bob test it for us using Advanced mode with browser tools."*

**Actions:**

1. **Switch Bob to Advanced Mode:**
   - Click the mode selector
   - Select "🛠️ Advanced" mode
   - (This mode has access to browser automation tools)

2. **Ask Bob to test:**
   ```
   Test the React application in the browser. Verify that:
   1. The application runs without errors
   2. The "Add to Cart" functionality works
   3. The "Favorites" functionality works
   4. Data persists after page refresh
   ```

3. **Or manually test:**
   - Open a new terminal
   - Navigate to `react-art-gallery/`
   - Run: `npm install` (if not already done)
   - Run: `npm run dev`
   - Open: `http://localhost:5173`

4. **Demonstrate the fixed functionality:**

   **✅ Working Add to Cart:**
   - Click "Add to Cart" on any painting
   - Show the cart counter increase in the header
   - Show the cart box with items
   - Demonstrate quantity adjustment
   - Show cart total calculation

   **✅ Working Favorites:**
   - Click the heart icon on paintings
   - Show the heart fill with color
   - Navigate to the Favorites page
   - Show all favorited paintings
   - Demonstrate removing favorites

   **✅ Data Persistence:**
   - Add items to cart and favorites
   - Refresh the page
   - Show that cart and favorites are preserved
   - Open browser DevTools → Application → Local Storage
   - Show the stored data

---

## Key Demo Takeaways

### What You've Demonstrated:

1. **🎯 Custom Rules & Standards**
   - Bob follows enterprise-grade React best practices
   - Rules are customizable for any organization
   - Ensures consistent, high-quality code

2. **📋 Intelligent Planning**
   - Bob analyzes existing codebases
   - Creates comprehensive migration strategies
   - Breaks down complex tasks into phases

3. **💻 Autonomous Execution**
   - Bob implements entire features end-to-end
   - Follows plans systematically
   - Handles edge cases and error scenarios

4. **🔧 Bug Fixing**
   - Bob identified and fixed broken functionality
   - Implemented missing features (cart, favorites)
   - Added data persistence

5. **🚀 Modern Best Practices**
   - React hooks for state management
   - Component composition
   - localStorage for persistence
   - Responsive design maintained

---

## Talking Points for Sales Conversations

### Value Propositions:

**For Development Teams:**
- *"Reduce migration time from weeks to hours"*
- *"Ensure code quality with built-in best practices"*
- *"Free developers to focus on business logic, not boilerplate"*

**For Technical Leaders:**
- *"Standardize code quality across teams"*
- *"Accelerate modernization initiatives"*
- *"Reduce technical debt with automated refactoring"*

**For Business Stakeholders:**
- *"Faster time to market for new features"*
- *"Lower development costs"*
- *"Reduced risk in technology migrations"*

### Common Objections & Responses:

**"Can it handle our complex codebase?"**
- *"Bob analyzed a multi-file PHP application and created a complete React migration"*
- *"The rules system scales to any complexity level"*

**"Will it follow our coding standards?"**
- *"The `.bob/rules.md` file is fully customizable"*
- *"You can encode your organization's standards"*

**"What about testing?"**
- *"Bob can generate tests and even run browser automation"*
- *"Advanced mode includes testing capabilities"*

---

## Advanced Demo Variations

### For Different Audiences:

**Frontend Developers:**
- Focus on the React best practices in `.bob/rules.md`
- Show component composition and hooks implementation
- Demonstrate state management patterns

**Backend Developers:**
- Emphasize the PHP analysis capabilities
- Show how Bob understands existing logic
- Highlight the data structure migration

**DevOps/Platform Engineers:**
- Show the project structure and build setup
- Demonstrate the development workflow
- Highlight the testing and deployment readiness

**Architects:**
- Focus on the planning phase
- Show the architecture decisions
- Demonstrate the migration strategy

---

## Troubleshooting

### If PHP Server Won't Start:
```bash
# Check if port 8000 is in use
netstat -ano | findstr :8000

# Use a different port
php -S localhost:8080
```

### If React App Won't Start:
```bash
# Clear node_modules and reinstall
cd react-art-gallery
rm -rf node_modules package-lock.json
npm install
npm run dev
```

### If Bob Seems Stuck:
- Check the terminal output for errors
- Ensure all prerequisites are installed
- Try breaking the task into smaller steps
- Use the "Stop" button and restart with a clearer prompt

---

## Follow-Up Resources

After the demo, provide:

1. **This Demo Guide** - For them to practice
2. **The `.bob/rules.md` file** - As an example of custom rules
3. **The completed React application** - As a reference
4. **Bob documentation links** - For deeper learning

---

## Demo Checklist

Before presenting:
- [ ] PHP installed and working
- [ ] Node.js installed
- [ ] VS Code with Bob extension ready
- [ ] Codebase cloned and accessible
- [ ] Browser ready for testing
- [ ] This guide printed or on second screen

During demo:
- [ ] Show `.bob/rules.md` file
- [ ] Run PHP app and demonstrate bugs
- [ ] Switch to Plan mode
- [ ] Use advanced prompt feature
- [ ] Switch to Code mode
- [ ] Let Bob execute migration
- [ ] Test the React application
- [ ] Show working cart and favorites

After demo:
- [ ] Answer questions
- [ ] Provide follow-up materials
- [ ] Schedule next steps

---

## Success Metrics

A successful demo should result in:
- ✅ Audience understands Bob's planning capabilities
- ✅ Audience sees Bob execute complex migrations
- ✅ Audience recognizes the value of custom rules
- ✅ Audience can envision Bob in their workflow
- ✅ Next steps scheduled (POC, trial, etc.)

---

**Questions?** Contact your IBM Bob team for support.

**Ready to try it yourself?** Start with Part 1 and follow the script!