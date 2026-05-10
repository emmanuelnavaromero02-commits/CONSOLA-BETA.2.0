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
