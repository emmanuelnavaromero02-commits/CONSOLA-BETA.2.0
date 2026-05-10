import { useEffect, useState } from 'react';
import { MetricCard } from '../components/MetricCard';
import { Server, Activity, ShieldCheck, Database } from 'lucide-react';
import { getJson } from '../api/client';
import { LoadingState } from '../components/LoadingState';

export function OverviewPage() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const [servers, config] = await Promise.all([
          getJson('/mcp/servers').catch(() => ({ servers: [] })),
          getJson('/api/config').catch(() => ({ status: 'unknown' }))
        ]);
        setData({
          mcpCount: servers.servers?.length || 0,
          configStatus: config.status || 'Active'
        });
      } catch (err) {
        console.error("Overview fetch error", err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, []);

  if (loading) return <LoadingState message="Loading overview..." />;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Overview</h1>
        <p className="mt-1 text-sm text-gray-500">Welcome to MODecissions Console. Here's a summary of your workspace.</p>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <MetricCard
          title="MCP Servers"
          value={data?.mcpCount || 0}
          icon={Server}
        />
        <MetricCard
          title="System Status"
          value={data?.configStatus || 'Active'}
          icon={Activity}
        />
        <MetricCard
          title="Security Policies"
          value="Enforced"
          icon={ShieldCheck}
        />
        <MetricCard
          title="Active Datasets"
          value="Healthy"
          icon={Database}
        />
      </div>

      <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Quick Actions</h3>
        <div className="flex gap-4">
           <a href="/app/monitor" className="text-sm text-blue-600 font-medium hover:text-blue-800">Go to Monitor &rarr;</a>
           <a href="/app/jobs" className="text-sm text-blue-600 font-medium hover:text-blue-800">View Jobs &rarr;</a>
        </div>
      </div>
    </div>
  );
}
