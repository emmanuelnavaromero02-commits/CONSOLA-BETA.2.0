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
