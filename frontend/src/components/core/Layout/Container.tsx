import React from 'react';
import { Box } from '@mui/material';
import { designTokens } from '../../../theme/designTokens';

export interface ContainerProps {
  children: React.ReactNode;
  maxWidth?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | false;
  padding?: 'none' | 'small' | 'medium' | 'large';
  centered?: boolean;
  className?: string;
}

export const Container: React.FC<ContainerProps> = ({
  children,
  maxWidth = 'lg',
  padding = 'medium',
  centered = true,
  className,
}) => {
  const getMaxWidth = () => {
    if (maxWidth === false) return 'none';
    const breakpoints = {
      xs: designTokens.breakpoints.xs,
      sm: designTokens.breakpoints.sm,
      md: designTokens.breakpoints.md,
      lg: designTokens.breakpoints.lg,
      xl: designTokens.breakpoints.xl,
    };
    return breakpoints[maxWidth] || breakpoints.lg;
  };

  const getPadding = () => {
    switch (padding) {
      case 'none': return designTokens.spacing[0];
      case 'small': return designTokens.spacing[4];
      case 'large': return designTokens.spacing[8];
      default: return designTokens.spacing[6];
    }
  };

  return (
    <Box
      className={className}
      sx={{
        maxWidth: getMaxWidth(),
        width: '100%',
        margin: centered ? '0 auto' : '0',
        padding: `0 ${getPadding()}`,
        
        // Responsive padding
        '@media (max-width: 768px)': {
          padding: `0 ${designTokens.spacing[4]}`,
        },
        
        '@media (max-width: 480px)': {
          padding: `0 ${designTokens.spacing[3]}`,
        },
      }}
    >
      {children}
    </Box>
  );
};