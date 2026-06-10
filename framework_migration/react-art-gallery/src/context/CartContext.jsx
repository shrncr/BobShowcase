import { createContext, useState, useEffect, useCallback } from 'react';
import { useCookies } from 'react-cookie';

const COOKIE_NAME = 'art_gallery_cart';
const COOKIE_OPTIONS = {
  path: '/',
  maxAge: 30 * 24 * 60 * 60, // 30 days
  sameSite: 'lax',
  secure: import.meta.env.PROD
};

export const CartContext = createContext(null);

export const CartProvider = ({ children }) => {
  const [cookies, setCookie, removeCookie] = useCookies([COOKIE_NAME]);
  const [cartItems, setCartItems] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  // Initialize from cookies
  useEffect(() => {
    try {
      const savedCart = cookies[COOKIE_NAME];
      if (savedCart && Array.isArray(savedCart)) {
        setCartItems(savedCart);
      }
    } catch (error) {
      console.error('Error loading cart from cookies:', error);
      setCartItems([]);
    } finally {
      setIsLoading(false);
    }
  }, []); // Only run once on mount

  // Sync to cookies
  useEffect(() => {
    if (!isLoading) {
      try {
        setCookie(COOKIE_NAME, cartItems, COOKIE_OPTIONS);
      } catch (error) {
        console.error('Error saving cart to cookies:', error);
      }
    }
  }, [cartItems, isLoading, setCookie]);

  // Add to cart
  const addToCart = useCallback((painting, options = {}) => {
    const cartItem = {
      id: `${Date.now()}_${Math.random()}`, // Unique ID
      paintingId: painting.paintingId,
      painting: {
        paintingId: painting.paintingId,
        title: painting.title,
        imageFileName: painting.imageFileName,
        firstName: painting.firstName,
        lastName: painting.lastName,
        msrp: painting.msrp
      },
      quantity: options.quantity || 1,
      frame: options.frame || 'None',
      glass: options.glass || 'None',
      matt: options.matt || 'None',
      price: painting.msrp,
      addedAt: new Date().toISOString()
    };

    setCartItems(prev => [...prev, cartItem]);
    return cartItem;
  }, []);

  // Remove from cart
  const removeFromCart = useCallback((cartItemId) => {
    setCartItems(prev => prev.filter(item => item.id !== cartItemId));
  }, []);

  // Update cart item
  const updateCartItem = useCallback((cartItemId, updates) => {
    setCartItems(prev => prev.map(item =>
      item.id === cartItemId ? { ...item, ...updates } : item
    ));
  }, []);

  // Update quantity
  const updateQuantity = useCallback((cartItemId, quantity) => {
    if (quantity < 1) return;
    setCartItems(prev => prev.map(item =>
      item.id === cartItemId ? { ...item, quantity: parseInt(quantity) } : item
    ));
  }, []);

  // Clear cart
  const clearCart = useCallback(() => {
    setCartItems([]);
    removeCookie(COOKIE_NAME);
  }, [removeCookie]);

  // Get cart total
  const getCartTotal = useCallback(() => {
    return cartItems.reduce((total, item) => 
      total + (item.price * item.quantity), 0
    );
  }, [cartItems]);

  // Get cart count
  const cartCount = cartItems.length;

  // Get total items (including quantities)
  const getTotalItems = useCallback(() => {
    return cartItems.reduce((total, item) => total + item.quantity, 0);
  }, [cartItems]);

  const value = {
    cartItems,
    addToCart,
    removeFromCart,
    updateCartItem,
    updateQuantity,
    clearCart,
    getCartTotal,
    cartCount,
    getTotalItems,
    isLoading
  };

  return (
    <CartContext.Provider value={value}>
      {children}
    </CartContext.Provider>
  );
};

export default CartProvider;

// Made with Bob
