// frontend/src/components/layout/DashboardLayout.tsx
import React from 'react';
import { Outlet } from 'react-router-dom';
import { Box } from '@mui/material';
import Header from './Header';
import Sidebar from './Sidebar';

const DashboardLayout: React.FC = () => {
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <Header />
      <Box sx={{ display: 'flex', flex: 1, pt: '64px' }}>
        <Sidebar />
        <Box 
          component="main" 
          sx={{ 
            flexGrow: 1,
            p: 0,
            ml: '240px',
            width: 'calc(100% - 240px)',
            minHeight: 'calc(100vh - 64px)',
            backgroundColor: '#f8fafc'
          }}
        >
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
};

export default DashboardLayout;