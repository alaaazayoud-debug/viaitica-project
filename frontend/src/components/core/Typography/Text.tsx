import React from 'react';
import { Typography as MuiTypography } from '@mui/material';
import { designTokens } from '../../../theme/designTokens';

export interface TextProps {
  variant?: 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6' | 'body1' | 'body2' | 'caption';
  color?: 'primary' | 'secondary' | 'success' | 'error' | 'warning' | 'inherit' | 'textPrimary' | 'textSecondary';
  align?: 'left' | 'center' | 'right' | 'justify';
  fontWeight?: 'light' | 'normal' | 'medium' | 'semibold' | 'bold';
  children: React.ReactNode;
  className?: string;
  gutterBottom?: boolean;
  noWrap?: boolean;
}

export const Text: React.FC<TextProps> = ({
  variant = 'body1',
  color = 'textPrimary',
  align = 'left',
  fontWeight = 'normal',
  children,
  className,
  gutterBottom = false,
  noWrap = false,
}) => {
  const getColor = () => {
    if (color === 'inherit') return 'inherit';
    
    // Handle semantic colors
    if (color === 'success') return designTokens.colors.success.main;
    if (color === 'error') return designTokens.colors.error.main;
    if (color === 'warning') return designTokens.colors.warning.main;
    
    // Handle text colors
    if (color === 'textPrimary') return designTokens.colors.text.primary;
    if (color === 'textSecondary') return designTokens.colors.text.secondary;
    
    // Handle primary/secondary colors (use 500 as main)
    if (color === 'primary') return designTokens.colors.primary[500];
    if (color === 'secondary') return designTokens.colors.secondary[500];
    
    return designTokens.colors.text.primary;
  };

  return (
    <MuiTypography
      variant={variant}
      align={align}
      className={className}
      gutterBottom={gutterBottom}
      noWrap={noWrap}
      sx={{
        color: getColor(),
        fontWeight: designTokens.typography.fontWeight[fontWeight],
        
        ...(variant.startsWith('h') && {
          lineHeight: designTokens.typography.lineHeight.tight,
        }),
        
        ...(variant === 'caption' && {
          color: designTokens.colors.text.secondary,
        }),
      }}
    >
      {children}
    </MuiTypography>
  );
};