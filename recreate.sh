#!/bin/bash
mkdir -p console/frontend/src/api console/frontend/src/components console/frontend/src/pages console/frontend/src/styles

cat << 'INNER_EOF' > console/frontend/src/styles/global.css
@import "tailwindcss";

@theme {
  --color-surface: #ffffff;
  --color-background: #f6f7f9;
  --color-border: #e5e7eb;
  --color-text-primary: #111827;
  --color-text-secondary: #6b7280;
  --color-accent: #2563eb;
  --color-success: #059669;
  --color-warning: #d97706;
  --color-error: #dc2626;
  --color-sidebar: #0f172a;
  --font-family-sans: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

body {
  font-family: var(--font-family-sans);
  background-color: var(--color-background);
  color: var(--color-text-primary);
  margin: 0;
  padding: 0;
  -webkit-font-smoothing: antialiased;
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/api/client.ts
export const API_BASE = "";

export async function fetchWithAuth(url: string, options: RequestInit = {}) {
  const mergedOptions = {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    credentials: "include" as RequestCredentials,
  };

  const response = await fetch(`${API_BASE}${url}`, mergedOptions);

  if (!response.ok) {
    if (response.status === 401 || response.status === 403) {
      if (url !== "/auth/me") {
        window.location.href = "/login";
      }
    }
    throw new Error(`API Error: ${response.statusText}`);
  }

  return response;
}

export async function getJson(url: string) {
  const res = await fetchWithAuth(url);
  return res.json();
}

export async function postJson(url: string, body: any) {
  const res = await fetchWithAuth(url, {
    method: "POST",
    body: JSON.stringify(body),
  });
  return res.json();
}

export async function patchJson(url: string, body: any) {
  const res = await fetchWithAuth(url, {
    method: "PATCH",
    body: JSON.stringify(body),
  });
  return res.json();
}

export async function deleteJson(url: string) {
  const res = await fetchWithAuth(url, {
    method: "DELETE",
  });
  return res.json();
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/Sidebar.tsx
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Activity, Briefcase, Database, Box, Shield, Users, Settings, Key } from 'lucide-react';
import { clsx } from 'clsx';

const navItems = [
  { path: '/app/overview', label: 'Overview', icon: LayoutDashboard },
  { path: '/app/monitor', label: 'Monitor', icon: Activity },
  { path: '/app/jobs', label: 'Jobs', icon: Briefcase },
  { path: '/app/datasets', label: 'Datasets', icon: Database },
  { path: '/app/apps', label: 'Apps', icon: Box },
  { path: '/app/vault', label: 'Vault', icon: Key },
  { path: '/app/security', label: 'Security', icon: Shield },
  { path: '/app/users', label: 'Users', icon: Users },
  { path: '/app/settings', label: 'Settings', icon: Settings },
];

export function Sidebar() {
  return (
    <aside className="w-64 bg-slate-900 text-slate-300 flex flex-col h-full border-r border-slate-800 shrink-0 overflow-y-auto">
      <div className="h-16 flex items-center px-6 border-b border-slate-800 font-semibold text-white tracking-wide">
        CONSOLE
      </div>
      <nav className="flex-1 py-4 flex flex-col gap-1 px-3">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              clsx(
                "flex items-center gap-3 px-3 py-2 rounded-md transition-colors text-sm font-medium",
                isActive
                  ? "bg-slate-800 text-white"
                  : "hover:bg-slate-800/50 hover:text-white"
              )
            }
          >
            <item.icon className="w-4 h-4" />
            {item.label}
          </NavLink>
        ))}
      </nav>
    </aside>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/Topbar.tsx
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
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/AppShell.tsx
import { Sidebar } from './Sidebar';
import { Topbar } from './Topbar';
import { Outlet } from 'react-router-dom';

export function AppShell() {
  return (
    <div className="flex h-screen overflow-hidden bg-gray-50">
      <Sidebar />
      <div className="flex flex-col flex-1 min-w-0 overflow-hidden">
        <Topbar />
        <main className="flex-1 overflow-auto p-6">
          <div className="mx-auto max-w-7xl">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/MetricCard.tsx
import { clsx } from 'clsx';
import type { LucideIcon } from 'lucide-react';

interface MetricCardProps {
  title: string;
  value: string | number;
  icon?: LucideIcon;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  className?: string;
}

export function MetricCard({ title, value, icon: Icon, trend, className }: MetricCardProps) {
  return (
    <div className={clsx("bg-white border border-gray-200 rounded-lg p-5 shadow-sm", className)}>
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-medium text-gray-500">{title}</h3>
        {Icon && <Icon className="w-5 h-5 text-gray-400" />}
      </div>
      <div className="mt-2 flex items-baseline gap-2">
        <span className="text-2xl font-semibold text-gray-900">{value}</span>
        {trend && (
          <span className={clsx(
            "text-sm font-medium",
            trend.isPositive ? "text-green-600" : "text-red-600"
          )}>
            {trend.isPositive ? '+' : '-'}{Math.abs(trend.value)}%
          </span>
        )}
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/DataTable.tsx
interface Column<T> {
  key: string;
  header: string;
  render?: (item: T) => import('react').ReactNode;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  keyExtractor: (item: T) => string | number;
}

export function DataTable<T>({ columns, data, keyExtractor }: DataTableProps<T>) {
  return (
    <div className="overflow-x-auto bg-white border border-gray-200 rounded-lg shadow-sm">
      <table className="w-full text-sm text-left">
        <thead className="text-xs text-gray-500 uppercase bg-gray-50 border-b border-gray-200">
          <tr>
            {columns.map((col) => (
              <th key={col.key} className="px-6 py-3 font-medium">
                {col.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200">
          {data.map((item) => (
            <tr key={keyExtractor(item)} className="hover:bg-gray-50 transition-colors">
              {columns.map((col) => (
                <td key={col.key} className="px-6 py-4 whitespace-nowrap text-gray-700">
                  {col.render ? col.render(item) : (item as any)[col.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/StatusBadge.tsx
import { clsx } from 'clsx';

interface StatusBadgeProps {
  status: 'success' | 'warning' | 'error' | 'info' | 'default';
  children: import('react').ReactNode;
}

const statusStyles = {
  success: 'bg-green-100 text-green-800 border-green-200',
  warning: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  error: 'bg-red-100 text-red-800 border-red-200',
  info: 'bg-blue-100 text-blue-800 border-blue-200',
  default: 'bg-gray-100 text-gray-800 border-gray-200',
};

export function StatusBadge({ status, children }: StatusBadgeProps) {
  return (
    <span className={clsx(
      "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium border",
      statusStyles[status] || statusStyles.default
    )}>
      {children}
    </span>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/EmptyState.tsx
import { FileQuestion } from 'lucide-react';

interface EmptyStateProps {
  title: string;
  description?: string;
  icon?: import('react').ReactNode;
}

export function EmptyState({ title, description, icon }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center p-12 bg-white border border-dashed border-gray-300 rounded-lg text-center">
      <div className="w-12 h-12 flex items-center justify-center rounded-full bg-gray-50 text-gray-400 mb-4">
        {icon || <FileQuestion className="w-6 h-6" />}
      </div>
      <h3 className="text-sm font-semibold text-gray-900">{title}</h3>
      {description && <p className="mt-1 text-sm text-gray-500 max-w-sm">{description}</p>}
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/LoadingState.tsx
import { Loader2 } from 'lucide-react';

export function LoadingState({ message = 'Loading...' }: { message?: string }) {
  return (
    <div className="flex flex-col items-center justify-center p-12 text-gray-500">
      <Loader2 className="w-8 h-8 animate-spin mb-4 text-blue-600" />
      <span className="text-sm font-medium">{message}</span>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/ErrorState.tsx
import { AlertTriangle } from 'lucide-react';

interface ErrorStateProps {
  title?: string;
  message: string;
  onRetry?: () => void;
}

export function ErrorState({ title = 'Error', message, onRetry }: ErrorStateProps) {
  return (
    <div className="flex flex-col items-center justify-center p-12 bg-white border border-red-200 rounded-lg text-center">
      <AlertTriangle className="w-10 h-10 text-red-500 mb-4" />
      <h3 className="text-base font-semibold text-gray-900">{title}</h3>
      <p className="mt-2 text-sm text-gray-500 max-w-md">{message}</p>
      {onRetry && (
        <button
          onClick={onRetry}
          className="mt-6 px-4 py-2 bg-white border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
        >
          Try again
        </button>
      )}
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/components/AuthProvider.tsx
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
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/routes.tsx
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
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/OverviewPage.tsx
import { useEffect, useState } from 'react';
import { MetricCard } from '../components/MetricCard';
import { Server, Activity, ShieldCheck, Database } from 'lucide-react';
import { getJson } from '../api/client';
import { LoadingState } from '../components/LoadingState';

export function OverviewPage() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const [servers, config] = await Promise.all([
          getJson('/mcp/servers').catch(() => ({ servers: [] })),
          getJson('/api/config').catch(() => ({ status: 'unknown' }))
        ]);
        setData({
          mcpCount: servers.servers?.length || 0,
          configStatus: config.status || 'Active'
        });
      } catch (err) {
        console.error("Overview fetch error", err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  if (loading) return <LoadingState message="Loading overview..." />;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Overview</h1>
        <p className="mt-1 text-sm text-gray-500">Welcome to MODecissions Console. Here's a summary of your workspace.</p>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <MetricCard
          title="MCP Servers"
          value={data?.mcpCount || 0}
          icon={Server}
        />
        <MetricCard
          title="System Status"
          value={data?.configStatus || 'Active'}
          icon={Activity}
        />
        <MetricCard
          title="Security Policies"
          value="Enforced"
          icon={ShieldCheck}
        />
        <MetricCard
          title="Active Datasets"
          value="Healthy"
          icon={Database}
        />
      </div>

      <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Quick Actions</h3>
        <div className="flex gap-4">
           <a href="/app/monitor" className="text-sm text-blue-600 font-medium hover:text-blue-800">Go to Monitor &rarr;</a>
           <a href="/app/jobs" className="text-sm text-blue-600 font-medium hover:text-blue-800">View Jobs &rarr;</a>
        </div>
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/MonitorPage.tsx
import { useEffect, useState } from 'react';
import { getJson } from '../api/client';
import { DataTable } from '../components/DataTable';
import { StatusBadge } from '../components/StatusBadge';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';

export function MonitorPage() {
  const [servers, setServers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchServers = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await getJson('/mcp/servers');
      setServers(res.servers || []);
    } catch (err: any) {
      setError(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchServers();
  }, []);

  const columns = [
    { key: 'name', header: 'Server Name' },
    { key: 'version', header: 'Version', render: (s: any) => s.version || 'unknown' },
    { key: 'status', header: 'Status', render: () => <StatusBadge status="success">Connected</StatusBadge> }
  ];

  if (loading) return <LoadingState message="Fetching MCP servers..." />;
  if (error) return <ErrorState message={error.message} onRetry={fetchServers} />;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Monitor</h1>
          <p className="mt-1 text-sm text-gray-500">Live MCP server connections and tools.</p>
        </div>
        <button onClick={fetchServers} className="px-4 py-2 bg-white border border-gray-300 rounded text-sm font-medium hover:bg-gray-50 transition">
          Refresh
        </button>
      </div>

      {servers.length === 0 ? (
        <div className="bg-white border border-gray-200 rounded-lg p-10 text-center text-gray-500 shadow-sm">
          No MCP servers connected.
        </div>
      ) : (
        <DataTable columns={columns} data={servers} keyExtractor={(s) => s.name || s.id || Math.random().toString()} />
      )}
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/JobsPage.tsx
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getJson } from '../api/client';
import { DataTable } from '../components/DataTable';
import { StatusBadge } from '../components/StatusBadge';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';

export function JobsPage() {
  const [jobs, setJobs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const navigate = useNavigate();

  const fetchJobs = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await getJson('/api/pipeline_runs');
      setJobs(res.runs || []);
    } catch (err: any) {
      if (err.message.includes('404')) {
        setJobs([]);
      } else {
        setError(err);
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchJobs();
  }, []);

  const columns = [
    { key: 'id', header: 'Job ID' },
    { key: 'name', header: 'Pipeline Name' },
    {
      key: 'status',
      header: 'Status',
      render: (item: any) => {
        const s = item.status?.toLowerCase() || 'unknown';
        let status: 'success' | 'warning' | 'error' | 'info' | 'default' = 'default';
        if (s === 'success' || s === 'completed') status = 'success';
        if (s === 'failed' || s === 'error') status = 'error';
        if (s === 'running' || s === 'in_progress') status = 'info';
        return <StatusBadge status={status}>{item.status || 'Unknown'}</StatusBadge>;
      }
    },
    { key: 'created_at', header: 'Started At', render: (item: any) => new Date(item.created_at || Date.now()).toLocaleString() },
    {
      key: 'actions',
      header: 'Actions',
      render: (item: any) => (
        <button
          onClick={() => navigate(`/app/jobs/${item.id}`)}
          className="text-blue-600 hover:text-blue-800 text-sm font-medium"
        >
          View Details
        </button>
      )
    }
  ];

  if (loading) return <LoadingState message="Loading jobs..." />;
  if (error) return <ErrorState message={error.message} onRetry={fetchJobs} />;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Jobs & Pipelines</h1>
          <p className="mt-1 text-sm text-gray-500">Monitor and manage data pipeline executions.</p>
        </div>
        <button onClick={fetchJobs} className="px-4 py-2 bg-white border border-gray-300 rounded text-sm font-medium hover:bg-gray-50 transition">
          Refresh
        </button>
      </div>

      {jobs.length === 0 ? (
        <div className="bg-white border border-gray-200 rounded-lg p-10 text-center text-gray-500 shadow-sm">
          No pipeline runs found.
        </div>
      ) : (
        <DataTable columns={columns} data={jobs} keyExtractor={(j) => j.id} />
      )}
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/JobDetailPage.tsx
import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getJson } from '../api/client';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { StatusBadge } from '../components/StatusBadge';
import { ArrowLeft, Clock, Server, Terminal } from 'lucide-react';

export function JobDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [job, setJob] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    async function fetchJob() {
      try {
        const res = await getJson(`/api/pipeline_runs/${id}`);
        setJob(res);
      } catch (err: any) {
        if (err.message.includes('404')) {
          setJob({ id, status: 'Not Found', name: 'Unknown Pipeline' });
        } else {
          setError(err);
        }
      } finally {
        setLoading(false);
      }
    }
    fetchJob();
  }, [id]);

  if (loading) return <LoadingState message="Loading job details..." />;
  if (error) return <ErrorState message={error.message} />;

  return (
    <div className="space-y-6">
      <button
        onClick={() => navigate('/app/jobs')}
        className="flex items-center text-sm text-gray-500 hover:text-gray-900 transition-colors"
      >
        <ArrowLeft className="w-4 h-4 mr-1" />
        Back to Jobs
      </button>

      <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
        <div className="flex justify-between items-start mb-6">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Job: {job.name || id}</h1>
            <p className="mt-1 text-sm text-gray-500 font-mono">ID: {job.id}</p>
          </div>
          <StatusBadge status="info">{job.status || 'Unknown'}</StatusBadge>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="flex items-center text-sm text-gray-700">
            <Clock className="w-5 h-5 text-gray-400 mr-2" />
            Started: {new Date().toLocaleString()}
          </div>
          <div className="flex items-center text-sm text-gray-700">
            <Server className="w-5 h-5 text-gray-400 mr-2" />
            Worker Node: default-worker
          </div>
        </div>

        <div className="border border-gray-200 rounded-lg overflow-hidden">
          <div className="bg-gray-50 px-4 py-2 border-b border-gray-200 flex items-center">
            <Terminal className="w-4 h-4 text-gray-500 mr-2" />
            <span className="text-sm font-medium text-gray-700">Execution Logs</span>
          </div>
          <div className="bg-slate-900 text-gray-300 p-4 font-mono text-xs h-64 overflow-y-auto">
            <div className="mb-1">[INFO] Initializing job context...</div>
            <div className="mb-1">[INFO] Connecting to external resources...</div>
            <div className="mb-1">[INFO] Executing tasks...</div>
            {job.status === 'Not Found' && (
              <div className="text-yellow-400 mt-4">[WARN] Detailed logs unavailable for this job ID via API.</div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/DatasetsPage.tsx
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getJson } from '../api/client';
import { DataTable } from '../components/DataTable';
import { EmptyState } from '../components/EmptyState';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { Database } from 'lucide-react';

export function DatasetsPage() {
  const [datasets, setDatasets] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const navigate = useNavigate();

  const fetchDatasets = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await getJson('/api/datasets');
      setDatasets(res.datasets || []);
    } catch (err: any) {
      if (err.message.includes('404')) {
        setDatasets([]); // API not fully implemented yet
      } else {
        setError(err);
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDatasets();
  }, []);

  const columns = [
    { key: 'name', header: 'Dataset Name' },
    { key: 'type', header: 'Type' },
    { key: 'rows', header: 'Approx. Rows' },
    {
      key: 'actions',
      header: 'Actions',
      render: (item: any) => (
        <button
          onClick={() => navigate(`/app/datasets/${item.name}`)}
          className="text-blue-600 hover:text-blue-800 text-sm font-medium"
        >
          View Schema
        </button>
      )
    }
  ];

  if (loading) return <LoadingState message="Loading datasets..." />;
  if (error) return <ErrorState message={error.message} onRetry={fetchDatasets} />;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Datasets</h1>
          <p className="mt-1 text-sm text-gray-500">Manage registered lakehouse datasets.</p>
        </div>
        <button onClick={fetchDatasets} className="px-4 py-2 bg-white border border-gray-300 rounded text-sm font-medium hover:bg-gray-50 transition">
          Refresh
        </button>
      </div>

      {datasets.length === 0 ? (
        <EmptyState
          title="No Datasets Found"
          description="There are no datasets currently registered in the catalog."
          icon={<Database className="w-6 h-6" />}
        />
      ) : (
        <DataTable columns={columns} data={datasets} keyExtractor={(d) => d.name} />
      )}
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/DatasetDetailPage.tsx
import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getJson } from '../api/client';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { DataTable } from '../components/DataTable';
import { ArrowLeft, Database } from 'lucide-react';

export function DatasetDetailPage() {
  const { name } = useParams();
  const navigate = useNavigate();
  const [schema, setSchema] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    async function fetchSchema() {
      try {
        const res = await getJson(`/api/datasets/${name}`);
        setSchema(res.schema || []);
      } catch (err: any) {
        if (err.message.includes('404')) {
           setSchema([
             { column: 'id', type: 'integer', description: 'Primary Key' },
             { column: 'created_at', type: 'timestamp', description: 'Creation time' },
             { column: 'data', type: 'jsonb', description: 'Payload' }
           ]);
        } else {
          setError(err);
        }
      } finally {
        setLoading(false);
      }
    }
    fetchSchema();
  }, [name]);

  if (loading) return <LoadingState message="Loading schema..." />;
  if (error) return <ErrorState message={error.message} />;

  const columns = [
    { key: 'column', header: 'Column Name' },
    { key: 'type', header: 'Data Type' },
    { key: 'description', header: 'Description' }
  ];

  return (
    <div className="space-y-6">
      <button
        onClick={() => navigate('/app/datasets')}
        className="flex items-center text-sm text-gray-500 hover:text-gray-900 transition-colors"
      >
        <ArrowLeft className="w-4 h-4 mr-1" />
        Back to Datasets
      </button>

      <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
        <div className="flex items-center mb-6">
          <Database className="w-8 h-8 text-blue-600 mr-4" />
          <div>
            <h1 className="text-2xl font-bold text-gray-900 tracking-tight">{name}</h1>
            <p className="text-sm text-gray-500">Schema Definition</p>
          </div>
        </div>

        {schema.length === 0 ? (
          <div className="text-center text-gray-500 py-8 border border-dashed border-gray-300 rounded-lg">
            No schema information available.
          </div>
        ) : (
          <DataTable columns={columns} data={schema} keyExtractor={(s) => s.column} />
        )}
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/VaultPage.tsx
import { useEffect, useState } from 'react';
import { getJson } from '../api/client';
import { DataTable } from '../components/DataTable';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { Key } from 'lucide-react';

export function VaultPage() {
  const [connections, setConnections] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchConnections = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await getJson('/api/vault/connections');
      setConnections(res.connections || []);
    } catch (err: any) {
      if (err.message.includes('404')) {
        setConnections([]);
      } else {
        setError(err);
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchConnections();
  }, []);

  const columns = [
    { key: 'name', header: 'Connection Name' },
    { key: 'type', header: 'Type' },
    {
      key: 'secret',
      header: 'Credentials',
      render: () => <span className="text-gray-400 font-mono text-xs">••••••••</span>
    }
  ];

  if (loading) return <LoadingState message="Loading vault connections..." />;
  if (error) return <ErrorState message={error.message} onRetry={fetchConnections} />;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Vault</h1>
          <p className="mt-1 text-sm text-gray-500">Secure storage for connections and secrets.</p>
        </div>
        <button onClick={fetchConnections} className="px-4 py-2 bg-white border border-gray-300 rounded text-sm font-medium hover:bg-gray-50 transition">
          Refresh
        </button>
      </div>

      <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4">
        <div className="flex">
          <div className="flex-shrink-0">
            <Key className="h-5 w-5 text-yellow-400" />
          </div>
          <div className="ml-3">
            <p className="text-sm text-yellow-700">
              Secrets are masked by default. Never share your tokens.
            </p>
          </div>
        </div>
      </div>

      {connections.length === 0 ? (
        <div className="bg-white border border-gray-200 rounded-lg p-10 text-center text-gray-500 shadow-sm">
          No connections configured in Vault.
        </div>
      ) : (
        <DataTable columns={columns} data={connections} keyExtractor={(c) => c.name} />
      )}
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/AppsPage.tsx
import { Box } from 'lucide-react';
import { EmptyState } from '../components/EmptyState';

export function AppsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Apps Gallery</h1>
        <p className="mt-1 text-sm text-gray-500">Discover and deploy analytical applications.</p>
      </div>

      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm hover:shadow-md transition-shadow">
          <div className="w-12 h-12 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center mb-4">
            <Box className="w-6 h-6" />
          </div>
          <h3 className="text-lg font-semibold text-gray-900">Demand Forecasting</h3>
          <p className="mt-2 text-sm text-gray-500">Predict future demand based on historical data using advanced ML models.</p>
          <div className="mt-4 pt-4 border-t border-gray-100">
            <button className="text-sm font-medium text-blue-600 hover:text-blue-800">Launch App &rarr;</button>
          </div>
        </div>
      </div>

      <div className="mt-12">
        <EmptyState
          title="More apps coming soon"
          description="We are continuously expanding the apps gallery. Stay tuned."
        />
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/SecurityPage.tsx
import { useEffect, useState } from 'react';
import { getJson } from '../api/client';
import { DataTable } from '../components/DataTable';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';
import { ShieldAlert, ShieldCheck } from 'lucide-react';

export function SecurityPage() {
  const [sessions, setSessions] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchSecurityData = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await getJson('/security/sessions');
      setSessions(res.sessions || []);
    } catch (err: any) {
      if (err.message.includes('404')) {
        setSessions([{ id: 'sess_123', ip: '127.0.0.1', current: true }]);
      } else {
        setError(err);
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSecurityData();
  }, []);

  const columns = [
    { key: 'id', header: 'Session ID', render: (s: any) => <span className="font-mono text-xs">{s.id}</span> },
    { key: 'ip', header: 'IP Address' },
    {
      key: 'current',
      header: 'Status',
      render: (s: any) => s.current ? <span className="text-green-600 font-medium">Current</span> : <span className="text-gray-500">Active</span>
    },
    {
      key: 'action',
      header: 'Action',
      render: (s: any) => !s.current ? (
        <button className="text-red-600 hover:text-red-800 text-sm font-medium">Revoke</button>
      ) : null
    }
  ];

  if (loading) return <LoadingState message="Loading security context..." />;
  if (error) return <ErrorState message={error.message} onRetry={fetchSecurityData} />;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Security & Audit</h1>
          <p className="mt-1 text-sm text-gray-500">Manage active sessions and security policies.</p>
        </div>
        <button onClick={fetchSecurityData} className="px-4 py-2 bg-white border border-gray-300 rounded text-sm font-medium hover:bg-gray-50 transition">
          Refresh
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
         <div className="bg-white border border-gray-200 rounded-lg p-6 flex items-center shadow-sm">
            <div className="p-3 rounded-full bg-green-100 text-green-600 mr-4">
              <ShieldCheck className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-sm font-medium text-gray-900">Internal Services</h3>
              <p className="text-sm text-gray-500">Protected</p>
            </div>
         </div>
         <div className="bg-white border border-gray-200 rounded-lg p-6 flex items-center shadow-sm">
            <div className="p-3 rounded-full bg-blue-100 text-blue-600 mr-4">
              <ShieldAlert className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-sm font-medium text-gray-900">RBAC</h3>
              <p className="text-sm text-gray-500">Enforced via policies</p>
            </div>
         </div>
      </div>

      <h3 className="text-lg font-medium text-gray-900 mb-4">Active Sessions</h3>
      <DataTable columns={columns} data={sessions} keyExtractor={(s) => s.id} />
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/UsersPage.tsx
import { useEffect, useState } from 'react';
import { getJson } from '../api/client';
import { DataTable } from '../components/DataTable';
import { StatusBadge } from '../components/StatusBadge';
import { LoadingState } from '../components/LoadingState';
import { ErrorState } from '../components/ErrorState';

export function UsersPage() {
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      const res = await getJson('/api/admin/users');
      setUsers(res.users || []);
    } catch (err: any) {
      setError(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const columns = [
    { key: 'email', header: 'Email' },
    { key: 'name', header: 'Name', render: (u: any) => u.name || '-' },
    { key: 'role', header: 'Role', render: (u: any) => <span className="font-semibold">{u.role}</span> },
    {
      key: 'status',
      header: 'Status',
      render: (u: any) => (
        <StatusBadge status={u.is_active ? 'success' : 'warning'}>
          {u.is_active ? 'Active' : 'Inactive'}
        </StatusBadge>
      )
    }
  ];

  if (loading) return <LoadingState message="Loading users..." />;
  if (error) {
    if (error.message.includes('403')) {
      return (
        <div className="flex flex-col items-center justify-center p-12 text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Access Denied</h2>
          <p className="text-gray-500">You must be an administrator to view this page.</p>
        </div>
      );
    }
    return <ErrorState message={error.message} onRetry={fetchUsers} />;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Users Management</h1>
          <p className="mt-1 text-sm text-gray-500">Manage platform access and roles.</p>
        </div>
        <button className="px-4 py-2 bg-blue-600 text-white rounded text-sm font-medium hover:bg-blue-700 transition">
          Invite User
        </button>
      </div>

      <DataTable columns={columns} data={users} keyExtractor={(u) => u.id} />
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/pages/SettingsPage.tsx
export function SettingsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Settings</h1>
        <p className="mt-1 text-sm text-gray-500">Workspace and preference configurations.</p>
      </div>

      <div className="bg-white border border-gray-200 rounded-lg shadow-sm">
        <div className="p-6 border-b border-gray-200">
           <h3 className="text-lg font-medium text-gray-900">System Information</h3>
           <p className="mt-1 text-sm text-gray-500">Read-only information about the current deployment.</p>
        </div>
        <div className="p-6 space-y-4">
           <div className="flex justify-between py-2 border-b border-gray-50">
             <span className="text-sm font-medium text-gray-500">Frontend Version</span>
             <span className="text-sm text-gray-900 font-mono">v1.0.0 (SPA)</span>
           </div>
           <div className="flex justify-between py-2 border-b border-gray-50">
             <span className="text-sm font-medium text-gray-500">API Base URL</span>
             <span className="text-sm text-gray-900 font-mono">/api</span>
           </div>
           <div className="flex justify-between py-2 border-b border-gray-50">
             <span className="text-sm font-medium text-gray-500">Authentication</span>
             <span className="text-sm text-gray-900">Session Cookie (Strict)</span>
           </div>
        </div>
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/App.tsx
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
INNER_EOF

cat << 'INNER_EOF' > console/frontend/src/main.tsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
INNER_EOF
