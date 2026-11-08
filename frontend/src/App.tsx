// frontend/src/App.tsx
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Provider } from 'react-redux';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { store } from './store';
import { theme } from './theme';

// Pages & Components
import Dashboard from './pages/Dashboard';
import LicensesPage from './pages/LicensesPage';
import RegisterPage from './pages/RegisterPage';
import LoginForm from './components/LoginForm';
import DashboardLayout from './components/layout/DashboardLayout';
import VerifyPage from './components/auth/VerifyPage';
import AcceptInvitePage from './pages/AcceptInvitePage'; // Import the new page

// Protected Route Component
const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const token = localStorage.getItem('token');
  return token ? <>{children}</> : <Navigate to="/login" replace />;
};

// Public Route Component
const PublicRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const token = localStorage.getItem('token');
  return !token ? <>{children}</> : <Navigate to="/dashboard" replace />;
};

// Login Page Wrapper
const LoginPage: React.FC = () => {
  return (
    <div style={{ 
      minHeight: '100vh', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center',
      backgroundColor: '#f5f5f5'
    }}>
      <LoginForm />
    </div>
  );
};

const App: React.FC = () => {
  return (
    <Provider store={store}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Router>
          <Routes>
            {/* Public Routes */}
            <Route path="/login" element={
              <PublicRoute>
                <LoginPage />
              </PublicRoute>
            } />
            
            <Route path="/register" element={
              <PublicRoute>
                <RegisterPage />
              </PublicRoute>
            } />
            
            <Route path="/verify" element={
              <PublicRoute>
                <VerifyPage />
              </PublicRoute>
            } />

            <Route path="/accept-invite" element={
              <PublicRoute>
                <AcceptInvitePage />
              </PublicRoute>
            } />

            {/* Protected Routes */}
            <Route path="/" element={
              <ProtectedRoute>
                <DashboardLayout />
              </ProtectedRoute>
            }>
              <Route index element={<Navigate to="/dashboard" replace />} />
              <Route path="dashboard" element={<Dashboard />} />
              <Route path="licenses" element={<LicensesPage />} />
            </Route>

            {/* Redirects */}
            <Route path="/dashboard" element={<Navigate to="/" replace />} />
            <Route path="/licenses" element={<Navigate to="/licenses" replace />} />
            
            {/* Catch-all Redirect */}
            <Route path="*" element={<Navigate to="/register" replace />} />
          </Routes>
        </Router>
      </ThemeProvider>
    </Provider>
  );
};

export default App;