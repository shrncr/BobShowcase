import { createContext, useState, useEffect, useCallback } from 'react';
import { useCookies } from 'react-cookie';

const COOKIE_NAME = 'art_gallery_favorites';
const COOKIE_OPTIONS = {
  path: '/',
  maxAge: 365 * 24 * 60 * 60, // 1 year
  sameSite: 'lax',
  secure: import.meta.env.PROD
};

export const FavoritesContext = createContext(null);

export const FavoritesProvider = ({ children }) => {
  const [cookies, setCookie, removeCookie] = useCookies([COOKIE_NAME]);
  const [favorites, setFavorites] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  // Initialize from cookies on mount
  useEffect(() => {
    try {
      const savedFavorites = cookies[COOKIE_NAME];
      if (savedFavorites && Array.isArray(savedFavorites)) {
        setFavorites(savedFavorites);
      }
    } catch (error) {
      console.error('Error loading favorites from cookies:', error);
      setFavorites([]);
    } finally {
      setIsLoading(false);
    }
  }, []); // Only run once on mount

  // Sync to cookies whenever favorites change
  useEffect(() => {
    if (!isLoading) {
      try {
        setCookie(COOKIE_NAME, favorites, COOKIE_OPTIONS);
      } catch (error) {
        console.error('Error saving favorites to cookies:', error);
      }
    }
  }, [favorites, isLoading, setCookie]);

  // Add to favorites
  const addFavorite = useCallback((paintingId) => {
    setFavorites(prev => {
      if (prev.includes(paintingId)) {
        return prev; // Already exists
      }
      return [...prev, paintingId];
    });
  }, []);

  // Remove from favorites
  const removeFavorite = useCallback((paintingId) => {
    setFavorites(prev => prev.filter(id => id !== paintingId));
  }, []);

  // Toggle favorite
  const toggleFavorite = useCallback((paintingId) => {
    setFavorites(prev => {
      if (prev.includes(paintingId)) {
        return prev.filter(id => id !== paintingId);
      }
      return [...prev, paintingId];
    });
  }, []);

  // Clear all favorites
  const clearFavorites = useCallback(() => {
    setFavorites([]);
    removeCookie(COOKIE_NAME);
  }, [removeCookie]);

  // Check if painting is favorited
  const isFavorite = useCallback((paintingId) => {
    return favorites.includes(paintingId);
  }, [favorites]);

  // Get favorites count
  const favoritesCount = favorites.length;

  const value = {
    favorites,
    addFavorite,
    removeFavorite,
    toggleFavorite,
    clearFavorites,
    isFavorite,
    favoritesCount,
    isLoading
  };

  return (
    <FavoritesContext.Provider value={value}>
      {children}
    </FavoritesContext.Provider>
  );
};

export default FavoritesProvider;

// Made with Bob
