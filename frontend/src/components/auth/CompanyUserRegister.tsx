import React, { useState } from 'react';
import {
  Box,
  TextField,
  Button,
  Alert,
  Typography,
  InputAdornment,
  IconButton,
  CircularProgress,
  Link
} from '@mui/material';
import { Visibility, VisibilityOff, Group, Business } from '@mui/icons-material';
import { register } from '../../services/auth';
import { useDispatch } from 'react-redux';
import { loginUser } from '../../store/slices/authSlice';

const CompanyUserRegister: React.FC = () => {
  const [formData, setFormData] = useState({
    invitation_code: '',
    first_name: '',
    last_name: '',
    email: '',
    password: '',
    phone: ''
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
      // استخدام register مباشرة من services/auth
      const response = await register({
        ...formData,
        customer_type: 'individual',
        role: 'user',
      });

      const { token, user } = response.data;

      setSuccess('Account created successfully! Welcome to the company. Redirecting...');
      
      // استخدام Redux للتعامل مع المصادقة
      dispatch(loginUser.fulfilled({ token, user }, '', { email: formData.email, password: formData.password }));
      
      // التوجيه للوحة التحكم بعد ثانيتين
      setTimeout(() => {
        window.location.href = '/dashboard';
      }, 2000);

    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to create account. Check invitation code.');
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
        Join Existing Company
      </Typography>

      <TextField
        fullWidth
        label="Invitation Code"
        name="invitation_code"
        value={formData.invitation_code}
        onChange={handleChange}
        margin="normal"
        required
        placeholder="Get this from your company admin"
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <Group color="action" />
            </InputAdornment>
          ),
        }}
      />

      <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
        Ask your company administrator for the invitation code to join.
      </Typography>

      <Typography variant="h6" gutterBottom color="primary" sx={{ mt: 3 }}>
        Personal Information
      </Typography>

      <Box sx={{ display: 'flex', gap: 2 }}>
        <TextField
          fullWidth
          label="First Name"
          name="first_name"
          value={formData.first_name}
          onChange={handleChange}
          margin="normal"
          required
        />
        <TextField
          fullWidth
          label="Last Name"
          name="last_name"
          value={formData.last_name}
          onChange={handleChange}
          margin="normal"
          required
        />
      </Box>

      <TextField
        fullWidth
        label="Email Address"
        name="email"
        type="email"
        value={formData.email}
        onChange={handleChange}
        margin="normal"
        required
        placeholder="your@email.com"
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
        label="Phone Number (Optional)"
        name="phone"
        type="tel"
        value={formData.phone}
        onChange={handleChange}
        margin="normal"
        placeholder="+1234567890"
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
          'Join Company'
        )}
      </Button>

      <Typography variant="body2" color="text.secondary" align="center">
        Want to create a new company instead?{' '}
        <Link 
          component="button" 
          type="button"
          onClick={() => window.location.href = '/register?tab=0'}
          sx={{ fontWeight: 600 }}
        >
          Create New Company
        </Link>
      </Typography>
    </Box>
  );
};

export default CompanyUserRegister;