import React from 'react';
import { TextField, Box, Typography } from '@mui/material';
import { designTokens } from '../../../theme/designTokens';

export interface InputFieldProps {
  label?: string;
  placeholder?: string;
  value: string;
  onChange: (value: string) => void;
  type?: 'text' | 'email' | 'password' | 'number';
  error?: string;
  helperText?: string;
  required?: boolean;
  disabled?: boolean;
  startIcon?: React.ReactNode;
  endIcon?: React.ReactNode;
  size?: 'small' | 'medium';
  fullWidth?: boolean;
}

export const InputField: React.FC<InputFieldProps> = ({
  label,
  placeholder,
  value,
  onChange,
  type = 'text',
  error,
  helperText,
  required = false,
  disabled = false,
  startIcon,
  endIcon,
  size = 'medium',
  fullWidth = true,
}) => {
  return (
    <Box sx={{ width: fullWidth ? '100%' : 'auto' }}>
      {label && (
        <Typography 
          variant="subtitle2" 
          sx={{ 
            mb: 1, 
            color: error ? designTokens.colors.error.main : designTokens.colors.text.primary,
            fontWeight: designTokens.typography.fontWeight.medium,
          }}
        >
          {label}
          {required && (
            <span style={{ color: designTokens.colors.error.main, marginLeft: 4 }}>*</span>
          )}
        </Typography>
      )}
      
      <TextField
        type={type}
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        error={!!error}
        helperText={error || helperText}
        required={required}
        disabled={disabled}
        fullWidth={fullWidth}
        size={size}
        InputProps={{
          startAdornment: startIcon,
          endAdornment: endIcon,
          sx: {
            borderRadius: designTokens.borderRadius.lg,
            fontSize: designTokens.typography.fontSize[size === 'small' ? 'sm' : 'base'],
            
            '& .MuiOutlinedInput-notchedOutline': {
              borderColor: designTokens.colors.gray[300],
            },
            
            '&:hover .MuiOutlinedInput-notchedOutline': {
              borderColor: designTokens.colors.primary[300],
            },
            
            '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
              borderColor: designTokens.colors.primary[500],
              borderWidth: '2px',
            },
            
            '&.Mui-error .MuiOutlinedInput-notchedOutline': {
              borderColor: designTokens.colors.error.main,
            },
          },
        }}
        FormHelperTextProps={{
          sx: {
            marginLeft: 0,
            marginTop: 1,
            fontSize: designTokens.typography.fontSize.xs,
          },
        }}
      />
    </Box>
  );
};