import React from 'react';
import { Paper, Box } from '@mui/material';
import { designTokens } from '../../../theme/designTokens';

export interface CardProps {
  children: React.ReactNode;
  elevation?: number;
  padding?: 'none' | 'small' | 'medium' | 'large';
  hoverEffect?: boolean;
  className?: string;
}

export const Card: React.FC<CardProps> = ({
  children,
  elevation = 1,
  padding = 'medium',
  hoverEffect = true,
  className,
}) => {
  const getPadding = () => {
    switch (padding) {
      case 'none': return designTokens.spacing[0];
      case 'small': return designTokens.spacing[3];
      case 'large': return designTokens.spacing[6];
      default: return designTokens.spacing[4];
    }
  };

  return (
    <Paper
      elevation={elevation}
      className={className}
      sx={{
        borderRadius: designTokens.borderRadius.xl,
        border: `1px solid ${designTokens.colors.gray[200]}`,
        overflow: 'hidden',
        transition: hoverEffect ? 'all 0.3s ease-in-out' : 'none',
        
        ...(hoverEffect && {
          '&:hover': {
            transform: 'translateY(-2px)',
            boxShadow: designTokens.shadows.lg,
            borderColor: designTokens.colors.primary[200],
          },
        }),
      }}
    >
      <Box sx={{ padding: getPadding() }}>
        {children}
      </Box>
    </Paper>
  );
};