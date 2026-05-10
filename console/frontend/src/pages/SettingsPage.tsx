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
