import { RouterProvider } from 'react-router-dom';
import { CookiesProvider } from 'react-cookie';
import { FavoritesProvider } from './context/FavoritesContext';
import { CartProvider } from './context/CartContext';
import { router } from './routes';
import 'semantic-ui-css/semantic.min.css';
import './App.css';

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

export default App;

// Made with Bob
