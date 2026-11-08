import React from 'react';
import { Button as MuiButton, CircularProgress } from '@mui/material';
import { designTokens } from '../../../theme/designTokens';

export interface ButtonProps {
  variant?: 'contained' | 'outlined' | 'text';
  size?: 'small' | 'medium' | 'large';
  color?: 'primary' | 'secondary' | 'success' | 'error' | 'warning';
  loading?: boolean;
  disabled?: boolean;
  startIcon?: React.ReactNode;
  endIcon?: React.ReactNode;
  fullWidth?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
  type?: 'button' | 'submit' | 'reset';
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'contained',
  size = 'medium',
  color = 'primary',
  loading = false,
  disabled = false,
  startIcon,
  endIcon,
  fullWidth = false,
  onClick,
  children,
  type = 'button',
}) => {
  const getSizeStyles = () => {
    switch (size) {
      case 'small':
        return {
          padding: `${designTokens.spacing[1.5]} ${designTokens.spacing[3]}`,
          fontSize: designTokens.typography.fontSize.xs,
          minHeight: '32px',
        };
      case 'large':
        return {
          padding: `${designTokens.spacing[3]} ${designTokens.spacing[6]}`,
          fontSize: designTokens.typography.fontSize.base,
          minHeight: '48px',
        };
      default:
        return {
          padding: `${designTokens.spacing[2]} ${designTokens.spacing[4]}`,
          fontSize: designTokens.typography.fontSize.sm,
          minHeight: '40px',
        };
    }
  };

  return (
    <MuiButton
      variant={variant}
      color={color}
      disabled={disabled || loading}
      startIcon={!loading ? startIcon : undefined}
      endIcon={!loading ? endIcon : undefined}
      fullWidth={fullWidth}
      onClick={onClick}
      type={type}
      sx={{
        borderRadius: designTokens.borderRadius.lg,
        fontWeight: designTokens.typography.fontWeight.semibold,
        textTransform: 'none',
        letterSpacing: '0.025em',
        transition: 'all 0.2s ease-in-out',
        boxShadow: variant === 'contained' ? designTokens.shadows.base : 'none',
        position: 'relative',
        
        '&:hover': {
          transform: 'translateY(-1px)',
          boxShadow: variant === 'contained' ? designTokens.shadows.lg : 'none',
        },
        
        '&:active': {
          transform: 'translateY(0)',
        },
        
        ...getSizeStyles(),
        
        ...(variant === 'outlined' && {
          borderWidth: '2px',
          '&:hover': {
            borderWidth: '2px',
          },
        }),
      }}
    >
      {loading && (
        <CircularProgress 
          size={20} 
          sx={{ 
            position: 'absolute',
            color: 'inherit'
          }} 
        />
      )}
      
      <span style={{ opacity: loading ? 0 : 1 }}>
        {children}
      </span>
    </MuiButton>
  );
};