// src/pages/RegisterPage.tsx
import React from 'react';
import {
  Container,
  Paper,
  Box,
  Typography,
  useTheme,
  useMediaQuery
} from '@mui/material';
import UnifiedRegisterForm from '../components/auth/UnifiedRegisterForm';

const RegisterPage: React.FC = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  return (
    <Container 
      component="main" 
      maxWidth="md" 
      sx={{ 
        mt: 4,
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }}
    >
      <Paper 
        elevation={8} 
        sx={{ 
          p: 4, 
          width: '100%',
          background: 'linear-gradient(135deg, #f8fafc 0%, #ffffff 100%)',
          border: '1px solid #e2e8f0'
        }}
      >
        {/* Header with Logo Placeholder */}
        <Box textAlign="center" sx={{ mb: 3 }}>
          <Typography 
            variant="h4" 
            component="h1" 
            gutterBottom 
            sx={{ 
              fontWeight: 700,
              color: theme.palette.primary.main,
              fontSize: isMobile ? '1.8rem' : '2.2rem'
            }}
          >
            PowerFlow Studio
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Create your account to get started
          </Typography>
        </Box>

        <UnifiedRegisterForm />

        <Typography 
          variant="body2" 
          color="text.secondary" 
          align="center" 
          sx={{ mt: 3 }}
        >
          Already have an account?{' '}
          <Typography 
            component="span" 
            color="primary" 
            sx={{ 
              fontWeight: 600, 
              cursor: 'pointer',
              '&:hover': { textDecoration: 'underline' }
            }}
            onClick={() => window.location.href = '/login'}
          >
            Sign in
          </Typography>
        </Typography>
      </Paper>
    </Container>
  );
};

export default RegisterPage;