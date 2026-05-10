import { Box } from 'lucide-react';
import { EmptyState } from '../components/EmptyState';

export function AppsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Apps Gallery</h1>
        <p className="mt-1 text-sm text-gray-500">Discover and deploy analytical applications.</p>
      </div>

      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm hover:shadow-md transition-shadow">
          <div className="w-12 h-12 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center mb-4">
            <Box className="w-6 h-6" />
          </div>
          <h3 className="text-lg font-semibold text-gray-900">Demand Forecasting</h3>
          <p className="mt-2 text-sm text-gray-500">Predict future demand based on historical data using advanced ML models.</p>
          <div className="mt-4 pt-4 border-t border-gray-100">
            <button className="text-sm font-medium text-blue-600 hover:text-blue-800">Launch App &rarr;</button>
          </div>
        </div>
      </div>

      <div className="mt-12">
        <EmptyState
          title="More apps coming soon"
          description="We are continuously expanding the apps gallery. Stay tuned."
        />
      </div>
    </div>
  );
}
