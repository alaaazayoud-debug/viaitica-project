// src/components/AppRouter.tsx
import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import LoginForm from './LoginForm';
import Dashboard from '../pages/Dashboard';
import LicensesPage from '../pages/LicensesPage';
import RegisterPage from '../pages/RegisterPage';

interface AppRouterProps {
  isAuthenticated: boolean;
}

const AppRouter: React.FC<AppRouterProps> = ({ isAuthenticated }) => {
  return (
    <Routes>
      <Route 
        path="/login" 
        element={!isAuthenticated ? <LoginForm /> : <Navigate to="/dashboard" replace />} 
      />
      <Route 
        path="/register" 
        element={!isAuthenticated ? <RegisterPage /> : <Navigate to="/dashboard" replace />} 
      />
      <Route 
        path="/dashboard" 
        element={isAuthenticated ? <Dashboard /> : <Navigate to="/login" replace />} 
      />
      <Route 
        path="/licenses" 
        element={isAuthenticated ? <LicensesPage /> : <Navigate to="/login" replace />} 
      />
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
};

export default AppRouter;