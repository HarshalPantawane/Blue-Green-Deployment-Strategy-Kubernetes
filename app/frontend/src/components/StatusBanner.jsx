import React from 'react';

const StatusBanner = ({ systemInfo }) => {
  return (
    <div className="status-banner glass">
      <div className="status-dot"></div>
      <div>
        <span style={{ fontSize: '0.8rem', color: 'var(--text-light)', display: 'block' }}>Connected to API</span>
        <strong>Version: {systemInfo?.version?.toUpperCase() || 'UNKNOWN'}</strong>
      </div>
    </div>
  );
};

export default StatusBanner;
