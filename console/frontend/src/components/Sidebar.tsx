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
