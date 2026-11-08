import React, { useState } from 'react';
import { TextField, Button, Box, Alert, Typography } from '@mui/material';
import { register } from '../services/auth';
import { useDispatch } from 'react-redux';
import { loginUser } from '../store/slices/authSlice';

const RegisterForm: React.FC = () => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    first_name: '',
    last_name: '',
    customer_id: 1
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const dispatch = useDispatch();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      // استخدام register مباشرة من services/auth
      const response = await register({
        ...formData,
        customer_type: 'individual',
        role: 'user'
      });

      const { user, token } = response.data;
      
      // استخدام Redux للتعامل مع المصادقة
      dispatch(loginUser.fulfilled({ token, user }, '', { email: formData.email, password: formData.password }));
      
      setSuccess('تم إنشاء الحساب بنجاح!');
      setError('');
    } catch (err) {
      setError('فشل في إنشاء الحساب. قد يكون البريد مستخدماً مسبقاً');
      setSuccess('');
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  return (
    <Box component="form" onSubmit={handleSubmit} sx={{ maxWidth: 400, mx: 'auto', mt: 4 }}>
      <Typography variant="h5" gutterBottom>إنشاء حساب جديد</Typography>
      
      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }}>{success}</Alert>}

      <TextField
        fullWidth
        label="الاسم الأول"
        name="first_name"
        value={formData.first_name}
        onChange={handleChange}
        margin="normal"
        required
      />

      <TextField
        fullWidth
        label="الاسم الأخير"
        name="last_name"
        value={formData.last_name}
        onChange={handleChange}
        margin="normal"
        required
      />

      <TextField
        fullWidth
        label="البريد الإلكتروني"
        name="email"
        type="email"
        value={formData.email}
        onChange={handleChange}
        margin="normal"
        required
      />

      <TextField
        fullWidth
        label="كلمة المرور"
        name="password"
        type="password"
        value={formData.password}
        onChange={handleChange}
        margin="normal"
        required
      />

      <Button type="submit" variant="contained" fullWidth sx={{ mt: 3 }}>
        إنشاء حساب
      </Button>
    </Box>
  );
};

export default RegisterForm;