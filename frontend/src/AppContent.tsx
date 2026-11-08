// src/AppContent.tsx
import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { RootState, AppDispatch } from './store';
import AppRouter from './components/AppRouter';
import LoadingSpinner from './components/common/LoadingSpinner';
import { getCurrentUser } from './services/auth';
import { loginUser } from './store/slices/authSlice';

const AppContent: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { isAuthenticated } = useSelector((state: RootState) => state.auth);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);

  useEffect(() => {
    const checkAuthStatus = async () => {
      const token = localStorage.getItem('token');
      
      if (!token) {
        setIsCheckingAuth(false);
        return;
      }

      try {
        // Verify token with backend
        const response = await getCurrentUser();
        const user = response.data;
        
        // Update Redux state with user data
        dispatch(loginUser.fulfilled({ token, user }, '', { email: user.email, password: '' }));
      } catch (error) {
        // Token is invalid, clear it
        localStorage.removeItem('token');
        console.log('Invalid token, user logged out');
      } finally {
        setIsCheckingAuth(false);
      }
    };

    checkAuthStatus();
  }, [dispatch]);

  if (isCheckingAuth) {
    return <LoadingSpinner />;
  }

  return <AppRouter isAuthenticated={isAuthenticated} />;
};

export default AppContent;