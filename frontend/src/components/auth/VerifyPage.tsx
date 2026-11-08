// src/components/auth/VerifyPage.tsx
import React, { useState, useRef, useEffect } from 'react';
import {
  Box,
  TextField,
  Button,
  Alert,
  Typography,
  CircularProgress,
  Card,
  CardContent,
  Container
} from '@mui/material';
import { Security, Email, ArrowBack } from '@mui/icons-material';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { loginUser } from '../../store/slices/authSlice';
import api from '../../services/api';


const VerifyPage: React.FC = () => {
  const [code, setCode] = useState(['', '', '', '']);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState(''); // تخزين كلمة المرور
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const [searchParams] = useSearchParams();

  useEffect(() => {
    const userEmail = searchParams.get('email');
    const userPassword = searchParams.get('password'); // الحصول على كلمة المرور
    if (userEmail) {
      setEmail(userEmail);
    }
    if (userPassword) {
      setPassword(userPassword);
    }
  }, [searchParams]);

  const handleChange = (index: number, value: string) => {
    if (value.length <= 1 && /^\d*$/.test(value)) {
      const newCode = [...code];
      newCode[index] = value;
      setCode(newCode);

      if (value && index < 3) {
        inputRefs.current[index + 1]?.focus();
      }
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !code[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
  };

  const handlePaste = (e: React.ClipboardEvent) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData('text');
    const numbers = pastedData.replace(/\D/g, '').slice(0, 4).split('');
    
    if (numbers.length === 4) {
      const newCode = [...code];
      numbers.forEach((num, index) => {
        newCode[index] = num;
      });
      setCode(newCode);
      inputRefs.current[3]?.focus();
    }
  };

  const handleVerify = async () => {
    const verificationCode = code.join('');
    
    if (verificationCode.length !== 4) {
      setError('Please enter the complete 4-digit code');
      return;
    }

    setLoading(true);
    setError('');

    try {
      // 1. التحقق من الكود
      await api.post('/auth/verify', {
        email: email,
        code: verificationCode
      });

      setSuccess('Account verified successfully! Logging you in...');

      // 2. محاولة تسجيل الدخول تلقائياً
      try {
        const loginResponse = await api.post('/auth/login', {
          email: email,
          password: password
        });

        const { token, user } = loginResponse.data;
        
        // حفظ التوكن في localStorage
        localStorage.setItem('token', token);
        localStorage.setItem('user', JSON.stringify(user));
        
        // تحديث الـ state في Redux
        dispatch(loginUser.fulfilled({ token, user }, '', { email, password }));
        
        // الانتقال للـ dashboard
        setTimeout(() => {
          navigate('/dashboard');
        }, 1000);

      } catch (loginError: any) {
        // إذا فشل Login، انتقل لصفحة Login مع رسالة
        setTimeout(() => {
          navigate('/login', { 
            state: { 
              message: 'Account verified! Please login with your password.',
              email: email
            }
          });
        }, 1000);
      }

    } catch (err: any) {
      if (err.response?.data?.message) {
        setError(err.response.data.message);
      } else {
        setError('Verification failed. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleResendCode = async () => {
    setLoading(true);
    setError('');

    try {
      await api.post('/auth/resend', { email: email });
      setSuccess('Verification code sent successfully!');
    } catch (err: any) {
      if (err.response?.data?.message) {
        setError(err.response.data.message);
      } else {
        setError('Failed to resend code. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const isCodeComplete = code.every(digit => digit !== '');

  return (
    <Container component="main" maxWidth="sm">
      <Box sx={{ mt: 8, mb: 4 }}>
        <Button
          startIcon={<ArrowBack />}
          onClick={() => navigate('/register')}
          sx={{ mb: 3 }}
          disabled={loading}
        >
          Back to Registration
        </Button>

        <Card sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 3 }}>
          <CardContent sx={{ p: 4, textAlign: 'center' }}>
            <Box sx={{ display: 'flex', justifyContent: 'center', mb: 3 }}>
              <Security sx={{ fontSize: 60, color: 'primary.main' }} />
            </Box>

            <Typography variant="h4" fontWeight="bold" gutterBottom>
              Verify Your Email
            </Typography>

            <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
              We sent a 4-digit verification code to
            </Typography>

            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', mb: 4 }}>
              <Email sx={{ mr: 1, color: 'primary.main' }} />
              <Typography variant="h6" fontWeight="600">
                {email}
              </Typography>
            </Box>

            {error && (
              <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>
                {error}
              </Alert>
            )}

            {success && (
              <Alert severity="success" sx={{ mb: 3, borderRadius: 2 }}>
                {success}
              </Alert>
            )}

            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', mb: 4 }}>
              {code.map((digit, index) => (
                <TextField
                  key={index}
                  inputRef={el => inputRefs.current[index] = el}
                  value={digit}
                  onChange={(e) => handleChange(index, e.target.value)}
                  onKeyDown={(e) => handleKeyDown(index, e)}
                  onPaste={handlePaste}
                  inputProps={{
                    maxLength: 1,
                    style: { 
                      textAlign: 'center',
                      fontSize: '1.5rem',
                      fontWeight: 'bold'
                    }
                  }}
                  sx={{
                    width: 60,
                    '& .MuiOutlinedInput-root': {
                      '& fieldset': {
                        borderColor: digit ? 'primary.main' : 'grey.400',
                        borderWidth: digit ? 2 : 1
                      },
                      '&:hover fieldset': {
                        borderColor: 'primary.main',
                      },
                    }
                  }}
                  disabled={loading}
                />
              ))}
            </Box>

            <Button
              fullWidth
              variant="contained"
              size="large"
              onClick={handleVerify}
              disabled={!isCodeComplete || loading}
              sx={{
                py: 2,
                fontSize: '1.1rem',
                fontWeight: 600,
                borderRadius: 2,
                bgcolor: 'primary.main',
                '&:hover': {
                  bgcolor: 'primary.dark',
                  transform: 'translateY(-1px)',
                  boxShadow: 4,
                },
                transition: 'all 0.2s ease-in-out',
                boxShadow: 2,
              }}
            >
              {loading ? <CircularProgress size={24} color="inherit" /> : 'Verify & Continue'}
            </Button>

            <Typography variant="body2" color="text.secondary" sx={{ mt: 3 }}>
              Didn't receive the code? 
              <Button 
                color="primary" 
                sx={{ ml: 1, fontWeight: 600 }}
                onClick={handleResendCode}
                disabled={loading}
              >
                Resend Code
              </Button>
            </Typography>
          </CardContent>
        </Card>
      </Box>
    </Container>
  );
};

export default VerifyPage;