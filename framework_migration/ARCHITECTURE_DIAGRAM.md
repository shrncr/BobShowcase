# Architecture Diagrams
## Visual Reference for React Migration

---

## System Architecture Overview

```mermaid
graph TB
    subgraph "User Interface Layer"
        UI[React Components]
        Router[React Router]
    end
    
    subgraph "State Management Layer"
        Context[Context Providers]
        Hooks[Custom Hooks]
        Cookies[react-cookies]
    end
    
    subgraph "Data Layer"
        Service[Data Services]
        Data[Paintings Data]
    end
    
    UI --> Router
    UI --> Hooks
    Hooks --> Context
    Context --> Cookies
    UI --> Service
    Service --> Data
    
    style UI fill:#61dafb
    style Context fill:#764abc
    style Cookies fill:#f39c12
    style Service fill:#27ae60
```

---

## Component Hierarchy

```mermaid
graph TD
    App[App.jsx]
    App --> Providers[Context Providers]
    App --> RouterConfig[Router Configuration]
    
    Providers --> FavProv[FavoritesProvider]
    Providers --> CartProv[CartProvider]
    
    RouterConfig --> Layout[Layout Component]
    
    Layout --> Header[Header]
    Layout --> Main[Main Content - Outlet]
    Layout --> Footer[Footer]
    
    Header --> Nav[Navigation]
    Header --> FavCounter[Favorites Counter]
    Header --> CartCounter[Cart Counter]
    
    Main --> Browse[Browse Paintings Page]
    Main --> Detail[Painting Detail Page]
    Main --> Favorites[Favorites Page]
    Main --> CartPage[Cart Page]
    
    Browse --> Filters[Filter Panel]
    Browse --> Grid[Painting Grid]
    Grid --> Card[Painting Card]
    Card --> FavBtn1[Favorite Button]
    
    Detail --> Image[Painting Image]
    Detail --> Info[Painting Info]
    Detail --> Tabs[Info Tabs]
    Detail --> CartBox[Cart Box]
    CartBox --> Options[Product Options]
    CartBox --> AddCart[Add to Cart Button]
    CartBox --> FavBtn2[Favorite Button]
    
    Favorites --> FavList[Favorites List]
    FavList --> FavItem[Favorite Item]
    
    CartPage --> CartList[Cart List]
    CartList --> CartItem[Cart Item]
    
    style App fill:#61dafb
    style Providers fill:#764abc
    style Header fill:#3498db
    style Main fill:#2ecc71
```

---

## Data Flow: Favorites System

```mermaid
sequenceDiagram
    participant User
    participant FavButton as Favorite Button
    participant Hook as useFavorites Hook
    participant Context as FavoritesContext
    participant Cookie as react-cookie
    participant Storage as Browser Cookies
    
    User->>FavButton: Click favorite button
    FavButton->>Hook: toggleFavorite(paintingId)
    Hook->>Context: Update favorites state
    Context->>Context: setFavorites([...prev, id])
    Context->>Cookie: setCookie('favorites', data)
    Cookie->>Storage: Store in browser
    Storage-->>Cookie: Confirm storage
    Cookie-->>Context: Storage successful
    Context-->>Hook: State updated
    Hook-->>FavButton: Re-render with new state
    FavButton-->>User: UI updates (heart fills)
    
    Note over Context,Storage: Automatic sync via useEffect
```

---

## Data Flow: Cart System

```mermaid
sequenceDiagram
    participant User
    participant CartBox
    participant Hook as useCart Hook
    participant Context as CartContext
    participant Cookie as react-cookie
    participant Storage as Browser Cookies
    
    User->>CartBox: Configure options
    User->>CartBox: Click "Add to Cart"
    CartBox->>Hook: addToCart(painting, options)
    Hook->>Context: Create cart item
    Context->>Context: Generate unique ID
    Context->>Context: Add to cartItems array
    Context->>Cookie: setCookie('cart', cartItems)
    Cookie->>Storage: Persist to browser
    Storage-->>Cookie: Confirm
    Cookie-->>Context: Success
    Context-->>Hook: State updated
    Hook-->>CartBox: Show success message
    CartBox-->>User: Display confirmation
    
    Note over User,Storage: Cart persists for 30 days
```

---

## State Initialization Flow

```mermaid
flowchart TD
    Start([App Starts]) --> Mount[Providers Mount]
    Mount --> CheckCookie{Cookies Exist?}
    
    CheckCookie -->|Yes| ReadCookie[Read Cookie Data]
    CheckCookie -->|No| EmptyState[Initialize Empty State]
    
    ReadCookie --> Validate{Valid Data?}
    Validate -->|Yes| LoadState[Load State from Cookie]
    Validate -->|No| EmptyState
    
    LoadState --> SetState[Set Initial State]
    EmptyState --> SetState
    
    SetState --> RenderApp[Render Application]
    RenderApp --> UserInteraction[User Interacts]
    
    UserInteraction --> StateChange[State Changes]
    StateChange --> SyncCookie[Sync to Cookie]
    SyncCookie --> UserInteraction
    
    style Start fill:#2ecc71
    style CheckCookie fill:#f39c12
    style Validate fill:#f39c12
    style RenderApp fill:#61dafb
```

---

## Error Handling Flow

```mermaid
flowchart TD
    Action[User Action] --> Try{Try Operation}
    
    Try -->|Success| Update[Update State]
    Try -->|Cookie Error| CookieErr[Cookie Error Handler]
    Try -->|Validation Error| ValidErr[Validation Error Handler]
    Try -->|Network Error| NetErr[Network Error Handler]
    
    CookieErr --> Fallback{Fallback Available?}
    Fallback -->|Yes| LocalStorage[Use localStorage]
    Fallback -->|No| Notify[Notify User]
    
    LocalStorage --> Update
    
    ValidErr --> Sanitize[Sanitize Data]
    Sanitize --> Retry{Retry?}
    Retry -->|Yes| Try
    Retry -->|No| Notify
    
    NetErr --> RetryNet{Retry Network?}
    RetryNet -->|Yes| Try
    RetryNet -->|No| Notify
    
    Update --> Success[Show Success]
    Notify --> UserFeedback[Display Error Message]
    
    Success --> End([Complete])
    UserFeedback --> End
    
    style Action fill:#3498db
    style Update fill:#2ecc71
    style Notify fill:#e74c3c
    style Success fill:#2ecc71
```

---

## Cookie Storage Strategy

```mermaid
graph LR
    subgraph "Primary Storage"
        Cookies[Browser Cookies]
    end
    
    subgraph "Fallback Storage"
        LocalStorage[localStorage]
        SessionStorage[sessionStorage]
    end
    
    subgraph "Data Types"
        Favorites[Favorites Array]
        Cart[Cart Items Array]
    end
    
    Favorites --> Cookies
    Cart --> Cookies
    
    Cookies -.->|If Disabled| LocalStorage
    LocalStorage -.->|If Unavailable| SessionStorage
    
    Cookies -->|Max Age: 365 days| FavExpiry[Favorites Expiry]
    Cookies -->|Max Age: 30 days| CartExpiry[Cart Expiry]
    
    style Cookies fill:#f39c12
    style LocalStorage fill:#95a5a6
    style SessionStorage fill:#95a5a6
    style Favorites fill:#e74c3c
    style Cart fill:#3498db
```

---

## Component Communication Patterns

```mermaid
graph TB
    subgraph "Global State"
        FavContext[FavoritesContext]
        CartContext[CartContext]
    end
    
    subgraph "Pages"
        Browse[Browse Page]
        Detail[Detail Page]
        FavPage[Favorites Page]
        CartPage[Cart Page]
    end
    
    subgraph "Shared Components"
        FavBtn[Favorite Button]
        CartBtn[Add to Cart Button]
        FavCounter[Favorites Counter]
        CartCounter[Cart Counter]
    end
    
    FavContext -.->|Provides State| Browse
    FavContext -.->|Provides State| Detail
    FavContext -.->|Provides State| FavPage
    FavContext -.->|Provides State| FavBtn
    FavContext -.->|Provides State| FavCounter
    
    CartContext -.->|Provides State| Detail
    CartContext -.->|Provides State| CartPage
    CartContext -.->|Provides State| CartBtn
    CartContext -.->|Provides State| CartCounter
    
    Browse --> FavBtn
    Detail --> FavBtn
    Detail --> CartBtn
    
    style FavContext fill:#764abc
    style CartContext fill:#764abc
    style FavBtn fill:#e74c3c
    style CartBtn fill:#3498db
```

---

## Migration Phases Timeline

```mermaid
gantt
    title PHP to React Migration Timeline
    dateFormat  YYYY-MM-DD
    section Phase 1-3
    Assessment & Analysis           :a1, 2024-01-01, 3d
    React Setup                     :a2, after a1, 2d
    API Layer Design                :a3, after a2, 3d
    
    section Phase 4-6
    Component Architecture          :b1, after a3, 3d
    State Management Setup          :b2, after b1, 4d
    Browse Page Migration           :b3, after b2, 5d
    
    section Phase 7-9
    Detail Page Migration           :c1, after b3, 4d
    Favorites Implementation        :c2, after c1, 4d
    Cart Implementation             :c3, after c2, 5d
    
    section Phase 10-12
    UI/UX Enhancement               :d1, after c3, 4d
    Testing & QA                    :d2, after d1, 7d
    Documentation & Deployment      :d3, after d2, 3d
```

---

## Testing Strategy Pyramid

```mermaid
graph TB
    subgraph "Testing Pyramid"
        E2E[E2E Tests<br/>Cypress<br/>10%]
        Integration[Integration Tests<br/>React Testing Library<br/>30%]
        Unit[Unit Tests<br/>Jest + RTL<br/>60%]
    end
    
    E2E --> Integration
    Integration --> Unit
    
    subgraph "Test Coverage"
        Hooks[Custom Hooks]
        Components[Components]
        Context[Context Providers]
        Utils[Utilities]
        Flows[User Flows]
    end
    
    Unit -.-> Hooks
    Unit -.-> Utils
    Integration -.-> Components
    Integration -.-> Context
    E2E -.-> Flows
    
    style E2E fill:#e74c3c
    style Integration fill:#f39c12
    style Unit fill:#2ecc71
```

---

## Deployment Architecture

```mermaid
graph LR
    subgraph "Development"
        Dev[Local Dev Server<br/>Vite]
    end
    
    subgraph "Build Process"
        Build[npm run build]
        Optimize[Code Splitting<br/>Minification<br/>Tree Shaking]
    end
    
    subgraph "Production"
        CDN[CDN<br/>Static Assets]
        Server[Web Server<br/>SPA Routing]
    end
    
    subgraph "Monitoring"
        Analytics[Analytics]
        Errors[Error Tracking]
        Performance[Performance Monitoring]
    end
    
    Dev --> Build
    Build --> Optimize
    Optimize --> CDN
    Optimize --> Server
    
    Server --> Analytics
    Server --> Errors
    Server --> Performance
    
    style Dev fill:#61dafb
    style Build fill:#f39c12
    style Server fill:#2ecc71
    style Monitoring fill:#3498db
```

---

## Security Considerations

```mermaid
graph TD
    subgraph "Security Layers"
        Input[User Input]
        Validation[Input Validation]
        Sanitization[Data Sanitization]
        Storage[Secure Storage]
    end
    
    Input --> Validation
    Validation --> Sanitization
    Sanitization --> Storage
    
    subgraph "Cookie Security"
        SameSite[SameSite: Lax]
        Secure[Secure: true in prod]
        MaxAge[MaxAge: Limited]
    end
    
    Storage --> SameSite
    Storage --> Secure
    Storage --> MaxAge
    
    subgraph "Best Practices"
        HTTPS[HTTPS Only]
        CSP[Content Security Policy]
        XSS[XSS Protection]
    end
    
    SameSite --> HTTPS
    Secure --> HTTPS
    HTTPS --> CSP
    CSP --> XSS
    
    style Input fill:#3498db
    style Validation fill:#f39c12
    style Storage fill:#2ecc71
    style HTTPS fill:#e74c3c
```

---

## Performance Optimization Strategy

```mermaid
graph TB
    subgraph "Code Optimization"
        Split[Code Splitting]
        Lazy[Lazy Loading]
        Memo[React.memo]
    end
    
    subgraph "Asset Optimization"
        Images[Image Optimization<br/>WebP, Lazy Load]
        Fonts[Font Optimization<br/>Subset, Preload]
        CSS[CSS Optimization<br/>Critical CSS]
    end
    
    subgraph "Runtime Optimization"
        Virtual[Virtual Scrolling]
        Debounce[Debouncing]
        Cache[Caching Strategy]
    end
    
    subgraph "Metrics"
        FCP[First Contentful Paint<br/>< 1.5s]
        TTI[Time to Interactive<br/>< 3s]
        LCP[Largest Contentful Paint<br/>< 2.5s]
    end
    
    Split --> FCP
    Lazy --> TTI
    Images --> LCP
    Virtual --> TTI
    Cache --> FCP
    
    style Split fill:#61dafb
    style Images fill:#2ecc71
    style Virtual fill:#f39c12
    style FCP fill:#e74c3c
```

---

## Summary

These diagrams provide visual representations of:

1. **System Architecture** - Overall structure and layers
2. **Component Hierarchy** - How components are organized
3. **Data Flow** - How data moves through the application
4. **State Management** - Context and cookie integration
5. **Error Handling** - Graceful degradation strategies
6. **Testing Strategy** - Comprehensive test coverage
7. **Deployment** - Production architecture
8. **Security** - Protection mechanisms
9. **Performance** - Optimization strategies

Use these diagrams as reference during development and for team communication.