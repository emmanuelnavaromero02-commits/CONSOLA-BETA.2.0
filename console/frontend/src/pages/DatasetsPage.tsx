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
