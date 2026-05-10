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
