// frontend/src/components/LoginForm.tsx
import React, { useState } from 'react';
import { Box, Alert, Typography, Link } from '@mui/material';
import { useDispatch } from 'react-redux';
import { useNavigate } from 'react-router-dom';
import { loginUser } from '../store/slices/authSlice';
import { Button, InputField, Text, Card, Container } from './core';
import { AppDispatch } from '../store';

const LoginForm: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const dispatch = useDispatch<AppDispatch>();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const result = await dispatch(loginUser({ email, password })).unwrap();
      console.log('Login successful, redirecting...', result);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err.payload || 'Invalid email or password');
    } finally {
      setLoading(false);
    }
  };

  const handleRegisterRedirect = () => {
    navigate('/register');
  };

  return (
    <Container maxWidth="sm" centered>
      <Box sx={{ mt: 8 }}>
        <Card padding="large" hoverEffect={false}>
          <Text variant="h3" align="center" color="primary" gutterBottom>
            Sign In
          </Text>
          
          <Text variant="body2" align="center" color="textSecondary" gutterBottom>
            Enter your credentials to access your account
          </Text>

          {error && (
            <Alert severity="error" sx={{ mb: 3 }}>
              {error}
            </Alert>
          )}

          <Box component="form" onSubmit={handleSubmit} sx={{ mt: 3 }}>
            <Box sx={{ mb: 3 }}>
              <InputField
                label="Email Address"
                type="email"
                value={email}
                onChange={setEmail}
                placeholder="your@email.com"
                required
                fullWidth
              />
            </Box>

            <Box sx={{ mb: 4 }}>
              <InputField
                label="Password"
                type="password"
                value={password}
                onChange={setPassword}
                placeholder="Enter your password"
                required
                fullWidth
              />
            </Box>

            {/* 🔧 إصلاح الزر - إزالة sx وإضافة margin باستخدام Box */}
            <Box sx={{ mb: 2 }}>
              <Button
                type="submit"
                variant="contained"
                size="large"
                disabled={loading}
                fullWidth
              >
                {loading ? 'Signing In...' : 'Sign In'}
              </Button>
            </Box>

            <Box sx={{ textAlign: 'center' }}>
              <Typography variant="body2" color="textSecondary">
                Don't have an account?{' '}
                <Link 
                  component="button" 
                  type="button"
                  onClick={handleRegisterRedirect}
                  sx={{ 
                    fontWeight: 600, 
                    textDecoration: 'none',
                    '&:hover': { textDecoration: 'underline' }
                  }}
                >
                  Sign up here
                </Link>
              </Typography>
            </Box>
          </Box>
        </Card>
      </Box>
    </Container>
  );
};

export default LoginForm;