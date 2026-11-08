import { GlobalStyles as MuiGlobalStyles } from '@mui/material';
import { designTokens } from './designTokens';

export const GlobalStyles = () => (
  <MuiGlobalStyles
    styles={{
      '*': {
        boxSizing: 'border-box',
        margin: 0,
        padding: 0,
      },
      
      'html, body': {
        height: '100%',
        width: '100%',
        fontFamily: designTokens.typography.fontFamily.primary,
        fontSize: designTokens.typography.fontSize.base,
        lineHeight: designTokens.typography.lineHeight.normal,
        color: designTokens.colors.text.primary,
        backgroundColor: designTokens.colors.background.default,
        WebkitFontSmoothing: 'antialiased',
        MozOsxFontSmoothing: 'grayscale',
      },
      
      '#root': {
        height: '100%',
        width: '100%',
      },
      
      // Scrollbar Styling
      '::-webkit-scrollbar': {
        width: '8px',
      },
      '::-webkit-scrollbar-track': {
        background: designTokens.colors.gray[100],
        borderRadius: designTokens.borderRadius.full,
      },
      '::-webkit-scrollbar-thumb': {
        background: designTokens.colors.gray[300],
        borderRadius: designTokens.borderRadius.full,
        '&:hover': {
          background: designTokens.colors.gray[400],
        },
      },
      
      // Selection Styling
      '::selection': {
        backgroundColor: designTokens.colors.primary[100],
        color: designTokens.colors.primary[700],
      },
      
      // Focus Styles for Accessibility
      '*:focus-visible': {
        outline: `2px solid ${designTokens.colors.primary[500]}`,
        outlineOffset: '2px',
        borderRadius: designTokens.borderRadius.sm,
      },
      
      // Typography Enhancements
      'h1, h2, h3, h4, h5, h6': {
        fontWeight: designTokens.typography.fontWeight.semibold,
        lineHeight: designTokens.typography.lineHeight.tight,
        marginBottom: designTokens.spacing[2],
      },
      
      'p': {
        marginBottom: designTokens.spacing[3],
        lineHeight: designTokens.typography.lineHeight.relaxed,
      },
      
      // Link Styles
      'a': {
        color: designTokens.colors.primary[600],
        textDecoration: 'none',
        transition: 'color 0.2s ease-in-out',
        '&:hover': {
          color: designTokens.colors.primary[700],
          textDecoration: 'underline',
        },
      },
      
      // Button Base Styles
      'button': {
        cursor: 'pointer',
        fontFamily: 'inherit',
        transition: 'all 0.2s ease-in-out',
      },
      
      // Input Enhancements
      'input, textarea, select': {
        fontFamily: 'inherit',
        fontSize: 'inherit',
        '&:focus': {
          outline: 'none',
        },
      },
      
      // Image Optimization
      'img': {
        maxWidth: '100%',
        height: 'auto',
        display: 'block',
      },
      
      // Utility Classes for Quick Styling
      '.text-gradient': {
        background: `linear-gradient(135deg, ${designTokens.colors.primary[500]} 0%, ${designTokens.colors.secondary[500]} 100%)`,
        WebkitBackgroundClip: 'text',
        WebkitTextFillColor: 'transparent',
        backgroundClip: 'text',
      },
      
      '.glass-effect': {
        background: 'rgba(255, 255, 255, 0.25)',
        backdropFilter: 'blur(10px)',
        border: '1px solid rgba(255, 255, 255, 0.18)',
      },
      
      '.shadow-soft': {
        boxShadow: `0 4px 20px 0 rgba(0, 0, 0, 0.05)`,
      },
    }}
  />
);