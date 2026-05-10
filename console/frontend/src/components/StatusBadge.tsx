import { clsx } from 'clsx';

interface StatusBadgeProps {
  status: 'success' | 'warning' | 'error' | 'info' | 'default';
  children: import('react').ReactNode;
}

const statusStyles = {
  success: 'bg-green-100 text-green-800 border-green-200',
  warning: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  error: 'bg-red-100 text-red-800 border-red-200',
  info: 'bg-blue-100 text-blue-800 border-blue-200',
  default: 'bg-gray-100 text-gray-800 border-gray-200',
};

export function StatusBadge({ status, children }: StatusBadgeProps) {
  return (
    <span className={clsx(
      "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium border",
      statusStyles[status] || statusStyles.default
    )}>
      {children}
    </span>
  );
}
