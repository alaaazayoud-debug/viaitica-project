// frontend/src/hooks/useAuth.ts
import { useSelector, useDispatch } from 'react-redux';
import { useEffect } from 'react';
import { RootState, AppDispatch } from '../store';
import { loginSuccess, loginUser, logout } from '../store/slices/authSlice';
import api from '../services/api';

export const useAuth = () => {
  const dispatch = useDispatch<AppDispatch>();
  const auth = useSelector((state: RootState) => state.auth);

  useEffect(() => {
    const validateToken = async () => {
      const token = localStorage.getItem('token');
      
      if (token && !auth.user) {
        try {
          // جلب بيانات المستخدم باستخدام التوكن
          const response = await api.get('/auth/me');
          dispatch(loginSuccess(response.data.user));
        } catch (error) {
          // إذا فشل التحقق، نظف التوكن
          console.log('Token validation failed, logging out...');
          localStorage.removeItem('token');
          dispatch(logout());
        }
      }
    };

    validateToken();
  }, [dispatch, auth.user]);

  return {
    user: auth.user,
    isAuthenticated: auth.isAuthenticated,
    isLoading: auth.isLoading,
    error: auth.error,
    login: (credentials: { email: string; password: string }) => dispatch(loginUser(credentials)),
    logout: () => dispatch(logout())
  };
};