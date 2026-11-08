// frontend/src/services/auth.ts
import api from './api';
import { User } from '../types';

export const login = async (credentials: { email: string; password: string }) => {
  const response = await api.post<{ token: string; user: User }>('/auth/login', credentials);
  
  // 🔧 حفظ التوكن في localStorage بعد login ناجح
  if (response.data.token) {
    localStorage.setItem('token', response.data.token);
    localStorage.setItem('user', JSON.stringify(response.data.user));
  }
  
  return response;
};

export const register = async (userData: any) => {
  const response = await api.post<{ token: string; user: User }>('/auth/register', userData);
  
  // 🔧 حفظ التوكن في localStorage بعد register ناجح
  if (response.data.token) {
    localStorage.setItem('token', response.data.token);
    localStorage.setItem('user', JSON.stringify(response.data.user));
  }
  
  return response;
};

export const getCurrentUser = () =>
  api.get<User>('/auth/me');

export const logoutUser = () => {
  // 🔧 إزالة التوكن من localStorage عند logout
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  return api.post('/auth/logout');
};