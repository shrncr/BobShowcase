# Quick Start Guide
## React Migration - Developer Reference

---

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ and npm 9+
- Git
- Code editor (VS Code recommended)
- Basic React knowledge

### Initial Setup

```bash
# Create React project with Vite
npm create vite@latest react-art-gallery -- --template react

# Navigate to project
cd react-art-gallery

# Install dependencies
npm install

# Install additional packages
npm install react-router-dom react-cookie semantic-ui-react semantic-ui-css

# Install dev dependencies
npm install --save-dev @testing-library/react @testing-library/jest-dom @testing-library/user-event vitest
```

### Project Structure Setup

```bash
# Create directory structure
mkdir -p src/{components/{common,paintings,favorites,cart,filters},context,hooks,pages,services,data,utils,styles}

# Create subdirectories
mkdir -p src/components/common
mkdir -p src/components/paintings
mkdir -p src/components/favorites
mkdir -p src/components/cart
mkdir -p src/components/filters
```

---

## 📁 File Organization

```
src/
├── components/
│   ├── common/          # Shared components (Header, Footer, etc.)
│   ├── paintings/       # Painting-related components
│   ├── favorites/       # Favorites feature components
│   ├── cart/           # Cart feature components
│   └── filters/        # Filter components
├── context/            # Context providers
├── hooks/              # Custom hooks
├── pages/              # Page components
├── services/           # API/data services
├── data/               # Static data
├── utils/              # Utility functions
└── styles/             # Global styles
```

---

## 🔑 Key Implementation Patterns

### 1. Context Provider Pattern

```javascript
// Always wrap your app with providers
import { CookiesProvider } from 'react-cookie';
import { FavoritesProvider } from './context/FavoritesContext';
import { CartProvider } from './context/CartContext';

function App() {
  return (
    <CookiesProvider>
      <FavoritesProvider>
        <CartProvider>
          <RouterProvider router={router} />
        </CartProvider>
      </FavoritesProvider>
    </CookiesProvider>
  );
}
```

### 2. Custom Hook Usage

```javascript
// In any component
import { useFavorites } from '../hooks/useFavorites';
import { useCart } from '../hooks/useCart';

function MyComponent() {
  const { favorites, addFavorite, isFavorite } = useFavorites();
  const { cartItems, addToCart } = useCart();
  
  // Use the hooks...
}
```

### 3. Cookie Configuration

```javascript
// Standard cookie options
const COOKIE_OPTIONS = {
  path: '/',
  maxAge: 30 * 24 * 60 * 60, // 30 days
  sameSite: 'lax',
  secure: process.env.NODE_ENV === 'production'
};
```

---

## 🎯 Common Tasks

### Adding a New Page

1. Create page component in `src/pages/`
2. Add route in `src/routes.jsx`
3. Add navigation link in Header component

```javascript
// src/pages/NewPage.jsx
import { Container, Header } from 'semantic-ui-react';

const NewPage = () => {
  return (
    <Container>
      <Header as="h1">New Page</Header>
      {/* Content */}
    </Container>
  );
};

export default NewPage;

// src/routes.jsx
import NewPage from './pages/NewPage';

{
  path: 'new-page',
  element: <NewPage />
}
```

### Creating a New Component

```javascript
// src/components/common/MyComponent.jsx
import { Button } from 'semantic-ui-react';

const MyComponent = ({ title, onClick }) => {
  return (
    <Button onClick={onClick}>
      {title}
    </Button>
  );
};

export default MyComponent;
```

### Adding State to Context

```javascript
// 1. Add to context provider
const [newState, setNewState] = useState(initialValue);

// 2. Add to context value
const value = {
  // ... existing values
  newState,
  setNewState
};

// 3. Use in components via hook
const { newState, setNewState } = useYourContext();
```

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm test -- --coverage

# Run specific test file
npm test -- MyComponent.test.jsx
```

### Writing a Component Test

```javascript
import { render, screen, fireEvent } from '@testing-library/react';
import MyComponent from './MyComponent';

describe('MyComponent', () => {
  test('renders correctly', () => {
    render(<MyComponent title="Test" />);
    expect(screen.getByText('Test')).toBeInTheDocument();
  });

  test('handles click', () => {
    const handleClick = jest.fn();
    render(<MyComponent title="Test" onClick={handleClick} />);
    
    fireEvent.click(screen.getByText('Test'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

---

## 🐛 Debugging

### Common Issues and Solutions

#### Issue: "Cannot read property of undefined"
**Solution:** Check if data is loaded before rendering
```javascript
if (!data) return <LoadingSpinner />;
return <Component data={data} />;
```

#### Issue: "Hook called outside of component"
**Solution:** Ensure hooks are called at top level of component
```javascript
// ❌ Wrong
function MyComponent() {
  if (condition) {
    const data = useMyHook(); // Don't do this
  }
}

// ✅ Correct
function MyComponent() {
  const data = useMyHook(); // Always at top level
  if (condition) {
    // Use data here
  }
}
```

#### Issue: "Cookie not persisting"
**Solution:** Check cookie options and browser settings
```javascript
// Ensure correct options
setCookie('name', value, {
  path: '/',
  maxAge: 30 * 24 * 60 * 60,
  sameSite: 'lax'
});
```

#### Issue: "State not updating"
**Solution:** Use functional updates for state based on previous state
```javascript
// ❌ Wrong
setItems(items.push(newItem));

// ✅ Correct
setItems(prev => [...prev, newItem]);
```

---

## 🎨 Styling Guidelines

### Using Semantic UI

```javascript
import { Button, Icon, Container, Grid } from 'semantic-ui-react';

// Basic usage
<Button primary>Click Me</Button>

// With icon
<Button icon labelPosition='left'>
  <Icon name='heart' />
  Favorite
</Button>

// Grid layout
<Grid>
  <Grid.Column width={4}>Sidebar</Grid.Column>
  <Grid.Column width={12}>Main Content</Grid.Column>
</Grid>
```

### Custom Styles

```css
/* src/styles/custom.css */
.my-component {
  padding: 1em;
  border-radius: 4px;
}

/* Use CSS modules for scoped styles */
/* MyComponent.module.css */
.container {
  max-width: 1200px;
  margin: 0 auto;
}
```

---

## 📊 Performance Tips

### 1. Memoization

```javascript
import { memo, useMemo, useCallback } from 'react';

// Memoize expensive components
const ExpensiveComponent = memo(({ data }) => {
  return <div>{/* Render data */}</div>;
});

// Memoize expensive calculations
const sortedData = useMemo(() => {
  return data.sort((a, b) => a.price - b.price);
}, [data]);

// Memoize callbacks
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);
```

### 2. Code Splitting

```javascript
import { lazy, Suspense } from 'react';

// Lazy load components
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <HeavyComponent />
    </Suspense>
  );
}
```

### 3. Image Optimization

```javascript
// Use lazy loading
<img 
  src={imageSrc} 
  alt={alt}
  loading="lazy"
/>

// Use responsive images
<img
  srcSet={`
    ${smallImage} 300w,
    ${mediumImage} 768w,
    ${largeImage} 1200w
  `}
  sizes="(max-width: 768px) 100vw, 50vw"
  src={mediumImage}
  alt={alt}
/>
```

---

## 🔐 Security Checklist

- [ ] Use HTTPS in production
- [ ] Set secure cookie options in production
- [ ] Validate all user inputs
- [ ] Sanitize data before storage
- [ ] Implement Content Security Policy
- [ ] Keep dependencies updated
- [ ] Use environment variables for sensitive data
- [ ] Implement proper error boundaries

---

## 📝 Code Review Checklist

### Before Submitting PR

- [ ] All tests pass
- [ ] No console errors or warnings
- [ ] Code follows project style guide
- [ ] Components are properly documented
- [ ] No hardcoded values (use constants)
- [ ] Accessibility attributes added (aria-labels, etc.)
- [ ] Mobile responsive
- [ ] Browser tested (Chrome, Firefox, Safari)
- [ ] Performance checked (no unnecessary re-renders)
- [ ] Error handling implemented

---

## 🚢 Deployment

### Build for Production

```bash
# Create production build
npm run build

# Preview production build locally
npm run preview

# Check build size
npm run build -- --report
```

### Environment Variables

```bash
# .env.development
VITE_API_URL=http://localhost:3000
VITE_ENV=development

# .env.production
VITE_API_URL=https://api.production.com
VITE_ENV=production
```

### Deployment Checklist

- [ ] Environment variables configured
- [ ] Build completes without errors
- [ ] All routes work correctly
- [ ] Cookies persist correctly
- [ ] Images load properly
- [ ] Analytics configured
- [ ] Error tracking setup
- [ ] Performance monitoring active

---

## 📚 Useful Commands

```bash
# Development
npm run dev              # Start dev server
npm run build           # Build for production
npm run preview         # Preview production build

# Testing
npm test                # Run tests
npm test -- --watch     # Watch mode
npm test -- --coverage  # With coverage

# Linting
npm run lint            # Check for issues
npm run lint -- --fix   # Auto-fix issues

# Dependencies
npm install <package>   # Add dependency
npm update              # Update dependencies
npm audit               # Check for vulnerabilities
npm audit fix           # Fix vulnerabilities
```

---

## 🆘 Getting Help

### Resources

- **React Docs**: https://react.dev
- **React Router**: https://reactrouter.com
- **Semantic UI React**: https://react.semantic-ui.com
- **react-cookie**: https://www.npmjs.com/package/react-cookie
- **Testing Library**: https://testing-library.com/react

### Team Communication

- Check `MIGRATION_STRATEGY.md` for overall plan
- Check `IMPLEMENTATION_PLAN.md` for detailed specs
- Check `ARCHITECTURE_DIAGRAM.md` for visual references
- Ask questions in team chat
- Create issues for bugs or feature requests

---

## 🎓 Learning Path

### For New Team Members

1. **Week 1**: Setup environment, understand project structure
2. **Week 2**: Learn Context API and custom hooks
3. **Week 3**: Implement small features, write tests
4. **Week 4**: Take on larger features independently

### Recommended Learning

1. React Hooks (useState, useEffect, useContext, useCallback, useMemo)
2. React Router v6
3. Context API for state management
4. Testing with React Testing Library
5. Semantic UI React components

---

## ✅ Daily Workflow

1. **Start of Day**
   - Pull latest changes: `git pull origin main`
   - Install any new dependencies: `npm install`
   - Start dev server: `npm run dev`

2. **During Development**
   - Create feature branch: `git checkout -b feature/my-feature`
   - Make small, focused commits
   - Write tests alongside code
   - Run tests frequently: `npm test`

3. **End of Day**
   - Run full test suite: `npm test`
   - Check for linting issues: `npm run lint`
   - Commit and push changes
   - Create PR if feature is complete

---

## 🎯 Success Metrics

Track these metrics to ensure quality:

- **Test Coverage**: > 80%
- **Build Time**: < 30 seconds
- **Bundle Size**: < 500KB (gzipped)
- **Lighthouse Score**: > 90
- **Zero Console Errors**: In production build

---

## 💡 Pro Tips

1. **Use React DevTools** - Essential for debugging
2. **Enable Strict Mode** - Catches potential issues early
3. **Keep Components Small** - Easier to test and maintain
4. **Write Tests First** - TDD approach when possible
5. **Use TypeScript** - Consider for better type safety
6. **Document Complex Logic** - Future you will thank you
7. **Review Your Own PRs** - Catch issues before others do
8. **Ask for Help Early** - Don't struggle alone

---

## 🔄 Version Control

### Branch Naming

- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `test/` - Adding tests
- `docs/` - Documentation updates

### Commit Messages

```
feat: Add favorites functionality
fix: Resolve cookie persistence issue
refactor: Simplify cart context logic
test: Add tests for FavoriteButton
docs: Update README with setup instructions
```

---

**Happy Coding! 🎉**

For questions or issues, refer to the main documentation or reach out to the team.