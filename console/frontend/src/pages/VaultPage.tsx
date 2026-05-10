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
