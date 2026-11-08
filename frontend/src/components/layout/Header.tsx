// frontend/src/components/layout/Header.tsx
import React from 'react';
import { 
  AppBar, 
  Toolbar, 
  Box, 
  Button, 
  Typography,
  Avatar
} from '@mui/material';
import { useDispatch, useSelector } from 'react-redux';
import { RootState, AppDispatch } from '../../store';
import { logout } from '../../store/slices/authSlice';

const Header: React.FC = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { user } = useSelector((state: RootState) => state.auth);

  const handleLogout = () => {
    dispatch(logout());
    window.location.href = '/login';
  };

  return (
    <AppBar 
      position="fixed"
      elevation={2}
      sx={{ 
        width: '100%',
        zIndex: 1300,
        backgroundColor: '#ffffff',
        color: '#333333',
        borderBottom: '1px solid #e0e0e0',
        boxShadow: '0 2px 10px rgba(0,0,0,0.1)'
      }}
    >
      <Toolbar sx={{ minHeight: '64px', justifyContent: 'space-between' }}>
        <Typography 
          variant="h6" 
          component="div" 
          sx={{ 
            fontWeight: 700,
            fontSize: '1.5rem',
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent'
          }}
        >
          PowerFlow Portal
        </Typography>
        
        {user ? (
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Avatar 
                sx={{ 
                  width: 36, 
                  height: 36, 
                  bgcolor: 'primary.main',
                  fontSize: '0.9rem'
                }}
              >
                {user.first_name?.[0]}{user.last_name?.[0]}
              </Avatar>
              <Box>
                <Typography variant="subtitle2" sx={{ fontWeight: 600, lineHeight: 1.2 }}>
                  {user.first_name} {user.last_name}
                </Typography>
                <Typography variant="caption" sx={{ color: 'text.secondary', lineHeight: 1 }}>
                  {user.role === 'admin' ? 'Administrator' : 'User'}
                </Typography>
              </Box>
            </Box>
            <Button 
              variant="outlined" 
              color="primary"
              onClick={handleLogout}
              sx={{ 
                borderWidth: 2,
                fontWeight: 600,
                textTransform: 'none',
                borderRadius: 2,
                px: 2,
                '&:hover': { 
                  borderWidth: 2,
                  backgroundColor: 'primary.light',
                  color: 'white'
                }
              }}
            >
              Sign Out
            </Button>
          </Box>
        ) : (
          <Button 
            variant="contained" 
            color="primary"
            onClick={() => window.location.href = '/login'}
            sx={{ fontWeight: 600 }}
          >
            Sign In
          </Button>
        )}
      </Toolbar>
    </AppBar>
  );
};

export default Header;