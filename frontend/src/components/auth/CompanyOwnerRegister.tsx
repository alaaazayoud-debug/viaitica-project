// CompanyOwnerRegister.tsx - التصحيح النهائي
import React, { useState } from 'react';
import {
  Box,
  TextField,
  Button,
  Alert,
  Typography,
  InputAdornment,
  IconButton,
  CircularProgress
} from '@mui/material';
import { Visibility, VisibilityOff, Business } from '@mui/icons-material';
import { register } from '../../services/auth';
import { useDispatch } from 'react-redux';
import { loginUser } from '../../store/slices/authSlice';

const CompanyOwnerRegister: React.FC = () => {
  const [formData, setFormData] = useState({
    company_name: '',
    first_name: '',
    last_name: '',
    email: '',
    password: '',
    phone: '',
    address: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const dispatch = useDispatch();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      // 🔧 التصحيح: استخدام البيانات الصحيحة التي يتوقعها الـ Backend
      const response = await register({
        first_name: formData.company_name, // اسم الشركة كـ first_name
        last_name: formData.company_name,  // استخدام اسم الشركة كـ last_name أيضاً
        email: formData.email,
        password: formData.password,
        phone: formData.phone,
        address: formData.address,
        customer_type: 'company',
        role: 'owner'
      });

      const { token, user } = response.data;

      setSuccess('Company account created successfully! Redirecting to dashboard...');
      
      dispatch(loginUser.fulfilled({ token, user }, '', { email: formData.email, password: formData.password }));
      
      setTimeout(() => {
        window.location.href = '/dashboard';
      }, 2000);

    } catch (err: any) {
      console.error('Registration error details:', err.response?.data);
      setError(err.response?.data?.message || 'Failed to create account');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  return (
    <Box component="form" onSubmit={handleSubmit} sx={{ mt: 2 }}>
      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}
      
      {success && (
        <Alert severity="success" sx={{ mb: 2 }}>
          {success}
        </Alert>
      )}

      <Typography variant="h6" gutterBottom color="primary">
        <Business sx={{ mr: 1, verticalAlign: 'bottom' }} />
        Company Information
      </Typography>

      <TextField
        fullWidth
        label="Company Name"
        name="company_name"
        value={formData.company_name}
        onChange={handleChange}
        margin="normal"
        required
        placeholder="Enter your company name"
      />

      <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
        Company name will be used as your display name in the system
      </Typography>

      <Typography variant="h6" gutterBottom color="primary" sx={{ mt: 3 }}>
        Account Information
      </Typography>

      <TextField
        fullWidth
        label="Email Address"
        name="email"
        type="email"
        value={formData.email}
        onChange={handleChange}
        margin="normal"
        required
        placeholder="your@company.com"
      />

      <TextField
        fullWidth
        label="Password"
        name="password"
        type={showPassword ? 'text' : 'password'}
        value={formData.password}
        onChange={handleChange}
        margin="normal"
        required
        placeholder="At least 8 characters"
        InputProps={{
          endAdornment: (
            <InputAdornment position="end">
              <IconButton
                onClick={() => setShowPassword(!showPassword)}
                edge="end"
              >
                {showPassword ? <VisibilityOff /> : <Visibility />}
              </IconButton>
            </InputAdornment>
          ),
        }}
      />

      <TextField
        fullWidth
        label="Phone Number"
        name="phone"
        type="tel"
        value={formData.phone}
        onChange={handleChange}
        margin="normal"
        placeholder="+1234567890"
      />

      <TextField
        fullWidth
        label="Address"
        name="address"
        multiline
        rows={3}
        value={formData.address}
        onChange={handleChange}
        margin="normal"
        placeholder="Company address"
      />

      <Button
        type="submit"
        fullWidth
        variant="contained"
        size="large"
        disabled={loading}
        sx={{
          mt: 3,
          mb: 2,
          py: 1.5,
          fontSize: '1.1rem',
          fontWeight: 600
        }}
      >
        {loading ? (
          <CircularProgress size={24} />
        ) : (
          'Create Company Account'
        )}
      </Button>
    </Box>
  );
};

export default CompanyOwnerRegister;