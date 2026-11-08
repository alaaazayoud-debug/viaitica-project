// frontend/src/components/common/PasswordStrength.tsx
import React from 'react';
import { Box, Typography, LinearProgress, Stack } from '@mui/material';
import { Check, Close } from '@mui/icons-material';

interface PasswordStrengthProps {
  password: string;
}

interface PasswordRequirement {
  label: string;
  test: (password: string) => boolean;
}

const requirements: PasswordRequirement[] = [
  { label: 'At least 8 characters', test: (pwd) => pwd.length >= 8 },
  { label: 'One uppercase letter', test: (pwd) => /[A-Z]/.test(pwd) },
  { label: 'One lowercase letter', test: (pwd) => /[a-z]/.test(pwd) },
  { label: 'One number', test: (pwd) => /[0-9]/.test(pwd) },
  { label: 'One special character', test: (pwd) => /[^A-Za-z0-9]/.test(pwd) },
];

const calculateStrength = (password: string): number => {
  if (!password) return 0;
  const metRequirements = requirements.filter(req => req.test(password)).length;
  return (metRequirements / requirements.length) * 100;
};

const getStrengthColor = (strength: number): string => {
  if (strength < 40) return '#ef4444'; // Red
  if (strength < 70) return '#f59e0b'; // Orange
  return '#10b981'; // Green
};

const getStrengthLabel = (strength: number): string => {
  if (strength === 0) return '';
  if (strength < 40) return 'Weak';
  if (strength < 70) return 'Medium';
  return 'Strong';
};

const PasswordStrength: React.FC<PasswordStrengthProps> = ({ password }) => {
  const strength = calculateStrength(password);
  const strengthColor = getStrengthColor(strength);
  const strengthLabel = getStrengthLabel(strength);

  if (!password) return null;

  return (
    <Box sx={{ mt: 2 }}>
      {/* Strength Bar */}
      <Box sx={{ mb: 2 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
          <Typography variant="caption" color="text.secondary">
            Password Strength
          </Typography>
          <Typography 
            variant="caption" 
            sx={{ 
              fontWeight: 600,
              color: strengthColor
            }}
          >
            {strengthLabel}
          </Typography>
        </Box>
        <LinearProgress 
          variant="determinate" 
          value={strength} 
          sx={{
            height: 6,
            borderRadius: 3,
            backgroundColor: 'rgba(0,0,0,0.1)',
            '& .MuiLinearProgress-bar': {
              backgroundColor: strengthColor,
              borderRadius: 3,
              transition: 'all 0.3s ease-in-out',
            }
          }}
        />
      </Box>

      {/* Requirements Checklist */}
      <Stack spacing={0.5}>
        {requirements.map((req, index) => {
          const isMet = req.test(password);
          return (
            <Box 
              key={index}
              sx={{ 
                display: 'flex', 
                alignItems: 'center',
                gap: 1,
                transition: 'all 0.2s ease-in-out',
              }}
            >
              {isMet ? (
                <Check sx={{ fontSize: 16, color: '#10b981' }} />
              ) : (
                <Close sx={{ fontSize: 16, color: '#ef4444' }} />
              )}
              <Typography 
                variant="caption" 
                sx={{ 
                  color: isMet ? '#10b981' : 'text.secondary',
                  fontWeight: isMet ? 500 : 400,
                  transition: 'all 0.2s ease-in-out',
                }}
              >
                {req.label}
              </Typography>
            </Box>
          );
        })}
      </Stack>
    </Box>
  );
};

export default PasswordStrength;
