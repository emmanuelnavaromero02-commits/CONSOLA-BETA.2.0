import { RouterProvider, createBrowserRouter } from 'react-router-dom';
import { AuthProvider } from './components/AuthProvider';
import { routes } from './routes';
import './styles/global.css';

const router = createBrowserRouter(routes, {
  basename: '/app'
});

function App() {
  return (
    <AuthProvider>
      <RouterProvider router={router} />
    </AuthProvider>
  );
}

export default App;
