60, // 1 year
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production'
    }
  },
  cart: {
    name: 'art_gallery_cart',
    options: {
      path: '/',
      maxAge: 30 * 24 * 60 * 60, // 30 days
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production'
    }
  }
};

// Cookie size limits and handling
export const COOKIE_SIZE_LIMIT = 4000; // bytes (conservative limit)

export const checkCookieSize = (data) => {
  const size = new Blob([JSON.stringify(data)]).size;
  return size < COOKIE_SIZE_LIMIT;
};

export const compressCookieData = (data) => {
  // Implement compression if needed
  // For now, just return minimal data
  return data;
};
```

### Cookie Service Utility

```javascript
// src/services/cookieService.js
import Cookies from 'js-cookie';
import { COOKIE_CONFIG } from '../config/cookieConfig';

export const cookieService = {
  // Get cookie
  get: (cookieName) => {
    try {
      const value = Cookies.get(cookieName);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error(`Error reading cookie ${cookieName}:`, error);
      return null;
    }
  },

  // Set cookie
  set: (cookieName, value, options = {}) => {
    try {
      const stringValue = JSON.stringify(value);
      Cookies.set(cookieName, stringValue, options);
      return true;
    } catch (error) {
      console.error(`Error setting cookie ${cookieName}:`, error);
      return false;
    }
  },

  // Remove cookie
  remove: (cookieName) => {
    try {
      Cookies.remove(cookieName);
      return true;
    } catch (error) {
      console.error(`Error removing cookie ${cookieName}:`, error);
      return false;
    }
  },

  // Check if cookie exists
  exists: (cookieName) => {
    return Cookies.get(cookieName) !== undefined;
  },

  // Get all cookies
  getAll: () => {
    return Cookies.get();
  }
};
```

### Cookie Storage Fallback Strategy

```javascript
// src/utils/storageManager.js

const STORAGE_TYPE = {
  COOKIE: 'cookie',
  LOCAL_STORAGE: 'localStorage',
  SESSION_STORAGE: 'sessionStorage'
};

class StorageManager {
  constructor() {
    this.preferredStorage = this.detectBestStorage();
  }

  detectBestStorage() {
    // Check if cookies are enabled
    if (this.areCookiesEnabled()) {
      return STORAGE_TYPE.COOKIE;
    }
    
    // Fallback to localStorage
    if (this.isLocalStorageAvailable()) {
      return STORAGE_TYPE.LOCAL_STORAGE;
    }
    
    // Last resort: sessionStorage
    if (this.isSessionStorageAvailable()) {
      return STORAGE_TYPE.SESSION_STORAGE;
    }
    
    console.warn('No storage mechanism available');
    return null;
  }

  areCookiesEnabled() {
    try {
      document.cookie = 'test=1';
      const enabled = document.cookie.indexOf('test=') !== -1;
      document.cookie = 'test=1; expires=Thu, 01-Jan-1970 00:00:01 GMT';
      return enabled;
    } catch (e) {
      return false;
    }
  }

  isLocalStorageAvailable() {
    try {
      const test = '__storage_test__';
      localStorage.setItem(test, test);
      localStorage.removeItem(test);
      return true;
    } catch (e) {
      return false;
    }
  }

  isSessionStorageAvailable() {
    try {
      const test = '__storage_test__';
      sessionStorage.setItem(test, test);
      sessionStorage.removeItem(test);
      return true;
    } catch (e) {
      return false;
    }
  }

  setItem(key, value) {
    const stringValue = JSON.stringify(value);
    
    switch (this.preferredStorage) {
      case STORAGE_TYPE.COOKIE:
        return cookieService.set(key, value);
      case STORAGE_TYPE.LOCAL_STORAGE:
        localStorage.setItem(key, stringValue);
        return true;
      case STORAGE_TYPE.SESSION_STORAGE:
        sessionStorage.setItem(key, stringValue);
        return true;
      default:
        return false;
    }
  }

  getItem(key) {
    try {
      switch (this.preferredStorage) {
        case STORAGE_TYPE.COOKIE:
          return cookieService.get(key);
        case STORAGE_TYPE.LOCAL_STORAGE:
          return JSON.parse(localStorage.getItem(key));
        case STORAGE_TYPE.SESSION_STORAGE:
          return JSON.parse(sessionStorage.getItem(key));
        default:
          return null;
      }
    } catch (e) {
      console.error('Error getting item:', e);
      return null;
    }
  }

  removeItem(key) {
    switch (this.preferredStorage) {
      case STORAGE_TYPE.COOKIE:
        return cookieService.remove(key);
      case STORAGE_TYPE.LOCAL_STORAGE:
        localStorage.removeItem(key);
        return true;
      case STORAGE_TYPE.SESSION_STORAGE:
        sessionStorage.removeItem(key);
        return true;
      default:
        return false;
    }
  }
}

export const storageManager = new StorageManager();
```

---

## Component Structure

### Component Hierarchy Diagram

```
App
├── Providers
│   ├── CookiesProvider (react-cookie)
│   ├── FavoritesProvider
│   └── CartProvider
├── Router
│   └── Layout
│       ├── Header
│       │   ├── Navigation
│       │   ├── AccountMenu
│       │   ├── FavoritesCounter
│       │   └── CartCounter
│       ├── Main (Outlet)
│       │   ├── BrowsePaintings
│       │   │   ├── FilterPanel
│       │   │   └── PaintingGrid
│       │   │       └── PaintingCard
│       │   │           └── FavoriteButton
│       │   ├── PaintingDetail
│       │   │   ├── PaintingImage
│       │   │   ├── PaintingInfo
│       │   │   ├── PaintingTabs
│       │   │   └── CartBox
│       │   │       ├── ProductOptions
│       │   │       ├── AddToCartButton
│       │   │       └── FavoriteButton
│       │   ├── Favorites
│       │   │   └── FavoritesList
│       │   │       └── FavoriteItem
│       │   └── Cart
│       │       └── CartList
│       │           └── CartItem
│       └── Footer
```

### Shared Components

```javascript
// src/components/common/LoadingSpinner.jsx
import { Loader, Segment } from 'semantic-ui-react';

const LoadingSpinner = ({ message = 'Loading...' }) => (
  <Segment basic textAlign="center" style={{ minHeight: '400px' }}>
    <Loader active inline="centered">{message}</Loader>
  </Segment>
);

export default LoadingSpinner;
```

```javascript
// src/components/common/ErrorMessage.jsx
import { Message } from 'semantic-ui-react';

const ErrorMessage = ({ title = 'Error', message, onRetry }) => (
  <Message negative>
    <Message.Header>{title}</Message.Header>
    <p>{message}</p>
    {onRetry && (
      <Button onClick={onRetry}>Try Again</Button>
    )}
  </Message>
);

export default ErrorMessage;
```

```javascript
// src/components/common/EmptyState.jsx
import { Segment, Header, Icon, Button } from 'semantic-ui-react';
import { Link } from 'react-router-dom';

const EmptyState = ({ 
  icon = 'inbox', 
  title, 
  message, 
  actionText, 
  actionLink 
}) => (
  <Segment basic textAlign="center" style={{ padding: '4em 0' }}>
    <Icon name={icon} size="huge" color="grey" />
    <Header as="h2">{title}</Header>
    <p>{message}</p>
    {actionText && actionLink && (
      <Button as={Link} to={actionLink} primary>
        {actionText}
      </Button>
    )}
  </Segment>
);

export default EmptyState;
```

---

## Data Flow Architecture

### Data Flow Diagram

```
User Action → Component → Hook → Context → Cookie Storage
                ↓           ↓       ↓           ↓
            UI Update ← State ← Provider ← Persistence
```

### Detailed Flow Examples

**Adding to Favorites:**
```
1. User clicks FavoriteButton
2. FavoriteButton calls toggleFavorite(paintingId)
3. useFavorites hook forwards to FavoritesContext
4. FavoritesContext updates state
5. useEffect detects state change
6. State synced to cookies via react-cookie
7. Component re-renders with new state
8. UI updates (heart icon fills, counter increments)
```

**Adding to Cart:**
```
1. User configures options in CartBox
2. User clicks "Add to Cart"
3. CartBox calls addToCart(painting, options)
4. useCart hook forwards to CartContext
5. CartContext creates cart item with unique ID
6. State updated with new item
7. useEffect syncs to cookies
8. Success message shown
9. Cart counter updates in header
```

**Loading Persisted Data:**
```
1. App initializes
2. Providers mount
3. useEffect reads cookies
4. Cookies parsed and validated
5. State initialized with cookie data
6. Components render with persisted data
7. User sees their saved favorites/cart
```

---

## Error Handling

### Error Types and Handling Strategies

#### 1. Cookie Storage Errors

```javascript
// src/utils/errorHandling.js

export class CookieError extends Error {
  constructor(message, originalError) {
    super(message);
    this.name = 'CookieError';
    this.originalError = originalError;
  }
}

export const handleCookieError = (error, fallbackAction) => {
  console.error('Cookie operation failed:', error);
  
  // Try fallback storage
  if (fallbackAction) {
    try {
      fallbackAction();
    } catch (fallbackError) {
      console.error('Fallback storage also failed:', fallbackError);
    }
  }
  
  // Notify user if critical
  if (error.critical) {
    alert('Unable to save your data. Please check your browser settings.');
  }
};
```

#### 2. Data Validation Errors

```javascript
// src/utils/validation.js

export const validateFavorites = (favorites) => {
  if (!Array.isArray(favorites)) {
    throw new Error('Favorites must be an array');
  }
  
  return favorites.filter(id => 
    typeof id === 'number' && id > 0
  );
};

export const validateCartItem = (item) => {
  const required = ['id', 'paintingId', 'painting', 'quantity', 'price'];
  
  for (const field of required) {
    if (!(field in item)) {
      throw new Error(`Cart item missing required field: ${field}`);
    }
  }
  
  if (item.quantity < 1 || item.quantity > 10) {
    throw new Error('Invalid quantity');
  }
  
  return true;
};
```

#### 3. Network/Service Errors

```javascript
// src/services/paintingsService.js

export const paintingsService = {
  getAllPaintings: async () => {
    try {
      // Simulate API call
      const paintings = await import('../data/paintings');
      return paintings.default;
    } catch (error) {
      console.error('Failed to load paintings:', error);
      throw new Error('Unable to load paintings. Please try again later.');
    }
  },

  getPaintingById: async (id) => {
    try {
      const paintings = await paintingsService.getAllPaintings();
      const painting = paintings.find(p => p.paintingId === parseInt(id));
      
      if (!painting) {
        throw new Error('Painting not found');
      }
      
      return painting;
    } catch (error) {
      console.error(`Failed to load painting ${id}:`, error);
      throw error;
    }
  }
};
```

#### 4. Error Boundaries

```javascript
// src/components/common/ErrorBoundary.jsx
import React from 'react';
import { Message, Button, Container } from 'semantic-ui-react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  handleReset = () => {
    this.setState({ hasError: false, error: null });
    window.location.reload();
  };

  render() {
    if (this.state.hasError) {
      return (
        <Container style={{ marginTop: '2em' }}>
          <Message negative>
            <Message.Header>Something went wrong</Message.Header>
            <p>We're sorry, but something unexpected happened.</p>
            <Button onClick={this.handleReset}>Reload Page</Button>
          </Message>
        </Container>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
```

---

## User Experience Considerations

### 1. Loading States

```javascript
// Skeleton loading for painting cards
const PaintingCardSkeleton = () => (
  <Item>
    <Placeholder>
      <Placeholder.Image square />
    </Placeholder>
    <Item.Content>
      <Placeholder>
        <Placeholder.Header>
          <Placeholder.Line length="medium" />
        </Placeholder.Header>
        <Placeholder.Paragraph>
          <Placeholder.Line length="short" />
        </Placeholder.Paragraph>
      </Placeholder>
    </Item.Content>
  </Item>
);
```

### 2. Success Feedback

```javascript
// Toast notifications for user actions
import { toast } from 'react-toastify';

const showSuccessToast = (message) => {
  toast.success(message, {
    position: 'bottom-right',
    autoClose: 3000,
    hideProgressBar: false,
    closeOnClick: true,
    pauseOnHover: true
  });
};

// Usage
addToCart(painting, options);
showSuccessToast('Added to cart!');
```

### 3. Animations

```css
/* src/styles/animations.css */

@keyframes heartBeat {
  0%, 100% { transform: scale(1); }
  25% { transform: scale(1.3); }
  50% { transform: scale(1.1); }
}

.favorite-animate {
  animation: heartBeat 0.3s ease-in-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.cart-item-enter {
  animation: slideIn 0.3s ease-out;
}

/* Smooth transitions */
.transition-all {
  transition: all 0.3s ease;
}
```

### 4. Accessibility

```javascript
// Accessible button with proper ARIA labels
<Button
  icon
  color={favorite ? 'red' : undefined}
  onClick={handleFavoriteClick}
  aria-label={favorite ? 'Remove from favorites' : 'Add to favorites'}
  aria-pressed={favorite}
>
  <Icon name="heart" aria-hidden="true" />
</Button>

// Screen reader announcements
const announceToScreenReader = (message) => {
  const announcement = document.createElement('div');
  announcement.setAttribute('role', 'status');
  announcement.setAttribute('aria-live', 'polite');
  announcement.className = 'sr-only';
  announcement.textContent = message;
  document.body.appendChild(announcement);
  setTimeout(() => document.body.removeChild(announcement), 1000);
};
```

### 5. Mobile Optimization

```css
/* Mobile-first responsive design */
@media (max-width: 768px) {
  .cart-table {
    font-size: 0.9em;
  }
  
  .cart-table img {
    width: 60px !important;
    height: 60px !important;
  }
  
  .product-options {
    flex-direction: column;
  }
  
  .product-options .field {
    width: 100% !important;
    margin-bottom: 1em;
  }
}
```

### 6. Performance Optimization

```javascript
// Memoize expensive components
const PaintingCard = React.memo(({ painting }) => {
  // Component implementation
}, (prevProps, nextProps) => {
  return prevProps.painting.paintingId === nextProps.painting.paintingId;
});

// Lazy load images
const LazyImage = ({ src, alt, ...props }) => {
  return (
    <img
      src={src}
      alt={alt}
      loading="lazy"
      {...props}
    />
  );
};

// Debounce search/filter inputs
import { debounce } from 'lodash';

const debouncedSearch = debounce((searchTerm) => {
  performSearch(searchTerm);
}, 300);
```

---

## Testing Strategy

### 1. Unit Tests

```javascript
// __tests__/hooks/useFavorites.test.js
import { renderHook, act } from '@testing-library/react-hooks';
import { FavoritesProvider } from '../../context/FavoritesContext';
import { useFavorites } from '../../hooks/useFavorites';

describe('useFavorites', () => {
  const wrapper = ({ children }) => (
    <FavoritesProvider>{children}</FavoritesProvider>
  );

  test('should add favorite', () => {
    const { result } = renderHook(() => useFavorites(), { wrapper });

    act(() => {
      result.current.addFavorite(441);
    });

    expect(result.current.favorites).toContain(441);
    expect(result.current.favoritesCount).toBe(1);
  });

  test('should remove favorite', () => {
    const { result } = renderHook(() => useFavorites(), { wrapper });

    act(() => {
      result.current.addFavorite(441);
      result.current.removeFavorite(441);
    });

    expect(result.current.favorites).not.toContain(441);
    expect(result.current.favoritesCount).toBe(0);
  });

  test('should toggle favorite', () => {
    const { result } = renderHook(() => useFavorites(), { wrapper });

    act(() => {
      result.current.toggleFavorite(441);
    });
    expect(result.current.isFavorite(441)).toBe(true);

    act(() => {
      result.current.toggleFavorite(441);
    });
    expect(result.current.isFavorite(441)).toBe(false);
  });
});
```

### 2. Component Tests

```javascript
// __tests__/components/FavoriteButton.test.jsx
import { render, screen, fireEvent } from '@testing-library/react';
import { FavoritesProvider } from '../../context/FavoritesContext';
import FavoriteButton from '../../components/favorites/FavoriteButton';

describe('FavoriteButton', () => {
  const renderWithProvider = (component) => {
    return render(
      <FavoritesProvider>
        {component}
      </FavoritesProvider>
    );
  };

  test('renders correctly', () => {
    renderWithProvider(<FavoriteButton paintingId={441} />);
    const button = screen.getByRole('button');
    expect(button).toBeInTheDocument();
  });

  test('adds to favorites on click', () => {
    renderWithProvider(<FavoriteButton paintingId={441} labeled />);
    
    const button = screen.getByText(/Add to Favorites/i);
    fireEvent.click(button);
    
    expect(screen.getByText(/Remove from Favorites/i)).toBeInTheDocument();
  });

  test('shows correct icon state', () => {
    renderWithProvider(<FavoriteButton paintingId={441} />);
    
    const button = screen.getByRole('button');
    fireEvent.click(button);
    
    expect(button).toHaveClass('red');
  });
});
```

### 3. Integration Tests

```javascript
// __tests__/integration/cart-workflow.test.jsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { CartProvider } from '../../context/CartContext';
import CartBox from '../../components/cart/CartBox';
import Cart from '../../pages/Cart';

const mockPainting = {
  paintingId: 441,
  title: 'Test Painting',
  msrp: 2000,
  imageFileName: '114020',
  firstName: 'Test',
  lastName: 'Artist'
};

describe('Cart Workflow', () => {
  test('complete add to cart flow', async () => {
    const { rerender } = render(
      <BrowserRouter>
        <CartProvider>
          <CartBox painting={mockPainting} />
        </CartProvider>
      </BrowserRouter>
    );

    // Select options
    const quantityInput = screen.getByLabelText(/quantity/i);
    fireEvent.change(quantityInput, { target: { value: '2' } });

    // Add to cart
    const addButton = screen.getByText(/Add to Cart/i);
    fireEvent.click(addButton);

    // Verify success message
    await waitFor(() => {
      expect(screen.getByText(/Added to Cart/i)).toBeInTheDocument();
    });

    // Navigate to cart page
    rerender(
      <BrowserRouter>
        <CartProvider>
          <Cart />
        </CartProvider>
      </BrowserRouter>
    );

    // Verify item in cart
    expect(screen.getByText('Test Painting')).toBeInTheDocument();
    expect(screen.getByDisplayValue('2')).toBeInTheDocument();
  });
});
```

### 4. E2E Tests (Cypress)

```javascript
// cypress/e2e/favorites-and-cart.cy.js
describe('Favorites and Cart E2E', () => {
  beforeEach(() => {
    cy.visit('/paintings');
    cy.clearCookies();
  });

  it('should add painting to favorites and persist', () => {
    // Add to favorites
    cy.get('[data-testid="painting-card"]').first().within(() => {
      cy.get('[aria-label="Add to favorites"]').click();
    });

    // Verify counter updated
    cy.get('[data-testid="favorites-counter"]').should('contain', '1');

    // Reload page
    cy.reload();

    // Verify persistence
    cy.get('[data-testid="favorites-counter"]').should('contain', '1');

    // Navigate to favorites page
    cy.contains('Favorites').click();
    cy.url().should('include', '/favorites');
    cy.get('table tbody tr').should('have.length', 1);
  });

  it('should add painting to cart with options', () => {
    // Navigate to painting detail
    cy.get('[data-testid="painting-card"]').first().click();

    // Configure options
    cy.get('select[name="frame"]').select('Wood');
    cy.get('select[name="glass"]').select('UV Protection');
    cy.get('input[type="number"]').clear().type('3');

    // Add to cart
    cy.contains('Add to Cart').click();

    // Verify success
    cy.contains('Added to Cart').should('be.visible');

    // Navigate to cart
    cy.contains('Cart').click();

    // Verify item details
    cy.get('table tbody tr').should('have.length', 1);
    cy.contains('Wood').should('be.visible');
    cy.contains('UV Protection').should('be.visible');
    cy.get('input[type="number"]').should('have.value', '3');
  });

  it('should persist cart across sessions', () => {
    // Add item to cart
    cy.get('[data-testid="painting-card"]').first().within(() => {
      cy.get('[aria-label="Add to cart"]').click();
    });

    // Verify cart counter
    cy.get('[data-testid="cart-counter"]').should('contain', '1');

    // Simulate closing and reopening browser
    cy.clearLocalStorage(); // Clear localStorage but keep cookies
    cy.reload();

    // Verify cart persisted
    cy.get('[data-testid="cart-counter"]').should('contain', '1');
  });
});
```

### 5. Performance Tests

```javascript
// __tests__/performance/rendering.test.jsx
import { render } from '@testing-library/react';
import { performance } from 'perf_hooks';
import PaintingGrid from '../../components/paintings/PaintingGrid';

describe('Performance Tests', () => {
  test('renders large list efficiently', () => {
    const largePaintingList = Array.from({ length: 100 }, (_, i) => ({
      paintingId: i,
      title: `Painting ${i}`,
      // ... other fields
    }));

    const startTime = performance.now();
    render(<PaintingGrid paintings={largePaintingList} />);
    const endTime = performance.now();

    const renderTime = endTime - startTime;
    expect(renderTime).toBeLessThan(1000); // Should render in less than 1 second
  });
});
```

---

## Summary

This implementation plan provides:

1. **Complete code examples** for favorites and cart systems
2. **react-cookies integration** with fallback strategies
3. **Detailed component structure** with reusable patterns
4. **Comprehensive error handling** for robustness
5. **UX best practices** for smooth user experience
6. **Testing strategy** covering all levels

### Key Takeaways

- **State Management**: Context API + react-cookies for persistence
- **Error Handling**: Graceful degradation with fallbacks
- **User Experience**: Loading states, animations, accessibility
- **Testing**: Comprehensive coverage from unit to E2E
- **Performance**: Optimized rendering and lazy loading
- **Maintainability**: Clean architecture, reusable components

### Next Steps

1. Review and approve this implementation plan
2. Set up React project with dependencies
3. Implement Context providers first
4. Build components incrementally
5. Add tests alongside features
6. Iterate based on user feedback

**Ready to start building! 🚀**