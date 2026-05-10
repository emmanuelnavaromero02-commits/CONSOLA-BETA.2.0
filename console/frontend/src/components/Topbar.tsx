import { useAuth } from './AuthProvider';
import { LogOut, User } from 'lucide-react';

export function Topbar() {
  const { user } = useAuth();

  const handleLogout = async () => {
    window.location.href = '/login';
  };

  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6 shrink-0 z-10 shadow-sm">
      <div className="flex items-center gap-4 text-sm font-medium text-gray-700">
        <span className="text-gray-400">Environment:</span>
        <span className="px-2 py-1 bg-blue-50 text-blue-700 rounded text-xs font-semibold uppercase tracking-wider">Production</span>
      </div>
      <div className="flex items-center gap-4">
        {user && (
          <div className="flex items-center gap-2 text-sm text-gray-600">
            <User className="w-4 h-4" />
            <span>{user.email || user.name || 'User'}</span>
          </div>
        )}
        <button
          onClick={handleLogout}
          className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-md transition-colors"
          title="Logout"
        >
          <LogOut className="w-4 h-4" />
        </button>
      </div>
    </header>
  );
}
