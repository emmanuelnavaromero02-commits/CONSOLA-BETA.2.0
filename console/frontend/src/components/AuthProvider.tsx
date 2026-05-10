import { createContext, useContext, useEffect, useState } from 'react';
import { getJson } from '../api/client';
import { LoadingState } from './LoadingState';
import { ErrorState } from './ErrorState';

interface User {
  id: string | number;
  email: string;
  name?: string;
  roles?: string[];
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  error: Error | null;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  isLoading: true,
  error: null,
});

export function AuthProvider({ children }: { children: import('react').ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let mounted = true;

    async function loadUser() {
      try {
        const userData = await getJson('/auth/me');
        if (mounted) {
          setUser(userData);
          setIsLoading(false);
        }
      } catch (err: any) {
        if (mounted) {
          setError(err);
          setIsLoading(false);
          // Redirect to login if unauthorized
          if (err.message.includes('401') || err.message.includes('403')) {
            window.location.href = '/login';
          }
        }
      }
    }

    loadUser();

    return () => {
      mounted = false;
    };
  }, []);

  if (isLoading) {
    return (
      <div className="h-screen w-screen flex items-center justify-center bg-gray-50">
        <LoadingState message="Authenticating..." />
      </div>
    );
  }

  if (error && (!error.message.includes('401') && !error.message.includes('403'))) {
    return (
      <div className="h-screen w-screen flex items-center justify-center bg-gray-50 p-6">
         <ErrorState
           title="Authentication Error"
           message={error.message}
           onRetry={() => window.location.reload()}
         />
      </div>
    );
  }

  return (
    <AuthContext.Provider value={{ user, isLoading, error }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
