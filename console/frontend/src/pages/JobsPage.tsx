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
