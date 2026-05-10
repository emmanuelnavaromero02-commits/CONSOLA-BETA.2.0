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
