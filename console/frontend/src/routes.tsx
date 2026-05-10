import { Navigate } from 'react-router-dom';
import type { RouteObject } from 'react-router-dom';
import { AppShell } from './components/AppShell';
import { useAuth } from './components/AuthProvider';

import { OverviewPage } from './pages/OverviewPage';
import { MonitorPage } from './pages/MonitorPage';
import { JobsPage } from './pages/JobsPage';
import { JobDetailPage } from './pages/JobDetailPage';
import { DatasetsPage } from './pages/DatasetsPage';
import { DatasetDetailPage } from './pages/DatasetDetailPage';
import { AppsPage } from './pages/AppsPage';
import { VaultPage } from './pages/VaultPage';
import { SecurityPage } from './pages/SecurityPage';
import { UsersPage } from './pages/UsersPage';
import { SettingsPage } from './pages/SettingsPage';

function ProtectedRoute({ children }: { children: import('react').ReactNode }) {
  const { user, isLoading } = useAuth();

  if (isLoading) return null;

  if (!user) {
    window.location.href = '/login';
    return null;
  }

  return <>{children}</>;
}

export const routes: RouteObject[] = [
  {
    path: '/',
    element: (
      <ProtectedRoute>
        <AppShell />
      </ProtectedRoute>
    ),
    children: [
      { index: true, element: <Navigate to="/app/overview" replace /> },
      { path: 'overview', element: <OverviewPage /> },
      { path: 'monitor', element: <MonitorPage /> },
      { path: 'jobs', element: <JobsPage /> },
      { path: 'jobs/:id', element: <JobDetailPage /> },
      { path: 'datasets', element: <DatasetsPage /> },
      { path: 'datasets/:name', element: <DatasetDetailPage /> },
      { path: 'apps', element: <AppsPage /> },
      { path: 'vault', element: <VaultPage /> },
      { path: 'security', element: <SecurityPage /> },
      { path: 'users', element: <UsersPage /> },
      { path: 'settings', element: <SettingsPage /> },
      { path: '*', element: <Navigate to="/app/overview" replace /> }
    ],
  },
];
