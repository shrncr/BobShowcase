import { createBrowserRouter } from 'react-router-dom';
import Layout from './components/common/Layout';
import BrowsePaintings from './pages/BrowsePaintings';
import PaintingDetail from './pages/PaintingDetail';
import Favorites from './pages/Favorites';
import Cart from './pages/Cart';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        index: true,
        element: <BrowsePaintings />
      },
      {
        path: 'paintings',
        element: <BrowsePaintings />
      },
      {
        path: 'paintings/:id',
        element: <PaintingDetail />
      },
      {
        path: 'favorites',
        element: <Favorites />
      },
      {
        path: 'cart',
        element: <Cart />
      }
    ]
  }
]);

export default router;

// Made with Bob
