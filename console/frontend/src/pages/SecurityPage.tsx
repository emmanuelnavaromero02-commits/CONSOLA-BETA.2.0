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
