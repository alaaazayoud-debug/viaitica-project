import { createTheme } from '@mui/material/styles';
import { designTokens } from './designTokens';

export const professionalTheme = createTheme({
  palette: {
    primary: {
      light: designTokens.colors.primary[300],
      main: designTokens.colors.primary[500],
      dark: designTokens.colors.primary[700],
      contrastText: designTokens.colors.text.inverse,
    },
    secondary: {
      light: designTokens.colors.secondary[300],
      main: designTokens.colors.secondary[500],
      dark: designTokens.colors.secondary[700],
      contrastText: designTokens.colors.text.inverse,
    },
    success: {
      light: designTokens.colors.success.light,
      main: designTokens.colors.success.main,
      dark: designTokens.colors.success.dark,
      contrastText: designTokens.colors.text.inverse,
    },
    error: {
      light: designTokens.colors.error.light,
      main: designTokens.colors.error.main,
      dark: designTokens.colors.error.dark,
      contrastText: designTokens.colors.text.inverse,
    },
    warning: {
      light: designTokens.colors.warning.light,
      main: designTokens.colors.warning.main,
      dark: designTokens.colors.warning.dark,
      contrastText: designTokens.colors.text.primary,
    },
    info: {
      light: designTokens.colors.info.light,
      main: designTokens.colors.info.main,
      dark: designTokens.colors.info.dark,
      contrastText: designTokens.colors.text.inverse,
    },
    background: {
      default: designTokens.colors.background.default,
      paper: designTokens.colors.background.paper,
    },
    text: {
      primary: designTokens.colors.text.primary,
      secondary: designTokens.colors.text.secondary,
      disabled: designTokens.colors.text.disabled,
    },
    grey: {
      50: designTokens.colors.gray[50],
      100: designTokens.colors.gray[100],
      200: designTokens.colors.gray[200],
      300: designTokens.colors.gray[300],
      400: designTokens.colors.gray[400],
      500: designTokens.colors.gray[500],
      600: designTokens.colors.gray[600],
      700: designTokens.colors.gray[700],
      800: designTokens.colors.gray[800],
      900: designTokens.colors.gray[900],
    },
  },
  
  typography: {
    fontFamily: designTokens.typography.fontFamily.primary,
    
    h1: {
      fontSize: designTokens.typography.fontSize['4xl'],
      fontWeight: designTokens.typography.fontWeight.bold,
      lineHeight: designTokens.typography.lineHeight.tight,
      color: designTokens.colors.text.primary,
    },
    h2: {
      fontSize: designTokens.typography.fontSize['3xl'],
      fontWeight: designTokens.typography.fontWeight.bold,
      lineHeight: designTokens.typography.lineHeight.tight,
      color: designTokens.colors.text.primary,
    },
    h3: {
      fontSize: designTokens.typography.fontSize['2xl'],
      fontWeight: designTokens.typography.fontWeight.semibold,
      lineHeight: designTokens.typography.lineHeight.tight,
      color: designTokens.colors.text.primary,
    },
    h4: {
      fontSize: designTokens.typography.fontSize.xl,
      fontWeight: designTokens.typography.fontWeight.semibold,
      lineHeight: designTokens.typography.lineHeight.normal,
      color: designTokens.colors.text.primary,
    },
    h5: {
      fontSize: designTokens.typography.fontSize.lg,
      fontWeight: designTokens.typography.fontWeight.semibold,
      lineHeight: designTokens.typography.lineHeight.normal,
      color: designTokens.colors.text.primary,
    },
    h6: {
      fontSize: designTokens.typography.fontSize.base,
      fontWeight: designTokens.typography.fontWeight.semibold,
      lineHeight: designTokens.typography.lineHeight.normal,
      color: designTokens.colors.text.primary,
    },
    
    body1: {
      fontSize: designTokens.typography.fontSize.base,
      fontWeight: designTokens.typography.fontWeight.normal,
      lineHeight: designTokens.typography.lineHeight.normal,
      color: designTokens.colors.text.primary,
    },
    body2: {
      fontSize: designTokens.typography.fontSize.sm,
      fontWeight: designTokens.typography.fontWeight.normal,
      lineHeight: designTokens.typography.lineHeight.normal,
      color: designTokens.colors.text.secondary,
    },
    
    subtitle1: {
      fontSize: designTokens.typography.fontSize.base,
      fontWeight: designTokens.typography.fontWeight.medium,
      lineHeight: designTokens.typography.lineHeight.normal,
      color: designTokens.colors.text.primary,
    },
    subtitle2: {
      fontSize: designTokens.typography.fontSize.sm,
      fontWeight: designTokens.typography.fontWeight.medium,
      lineHeight: designTokens.typography.lineHeight.normal,
      color: designTokens.colors.text.secondary,
    },
    
    button: {
      fontSize: designTokens.typography.fontSize.sm,
      fontWeight: designTokens.typography.fontWeight.semibold,
      textTransform: 'none' as const,
      letterSpacing: '0.025em',
    },
    
    caption: {
      fontSize: designTokens.typography.fontSize.xs,
      fontWeight: designTokens.typography.fontWeight.normal,
      lineHeight: designTokens.typography.lineHeight.normal,
      color: designTokens.colors.text.secondary,
    },
    
    overline: {
      fontSize: designTokens.typography.fontSize.xs,
      fontWeight: designTokens.typography.fontWeight.medium,
      lineHeight: designTokens.typography.lineHeight.normal,
      color: designTokens.colors.text.secondary,
      textTransform: 'uppercase' as const,
      letterSpacing: '0.05em',
    },
  },
  
  spacing: (factor: number) => designTokens.spacing[factor as keyof typeof designTokens.spacing] || `${factor * 8}px`,
  
  shape: {
    borderRadius: Number(designTokens.borderRadius.md.replace('rem', '')) * 16,
  },
  
  shadows: [
    'none',
    designTokens.shadows.sm,
    designTokens.shadows.base,
    designTokens.shadows.md,
    designTokens.shadows.lg,
    designTokens.shadows.xl,
    designTokens.shadows['2xl'],
    ...Array(18).fill(designTokens.shadows['2xl']),
  ] as any,
  
  breakpoints: {
    values: {
      xs: designTokens.breakpoints.xs,
      sm: designTokens.breakpoints.sm,
      md: designTokens.breakpoints.md,
      lg: designTokens.breakpoints.lg,
      xl: designTokens.breakpoints.xl,
    },
  },
  
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: designTokens.borderRadius.lg,
          padding: `${designTokens.spacing[2]} ${designTokens.spacing[4]}`,
          fontSize: designTokens.typography.fontSize.sm,
          fontWeight: designTokens.typography.fontWeight.semibold,
          boxShadow: 'none',
          '&:hover': {
            boxShadow: designTokens.shadows.md,
            transform: 'translateY(-1px)',
            transition: 'all 0.2s ease-in-out',
          },
          '&:active': {
            transform: 'translateY(0)',
          },
        },
        contained: {
          '&:hover': {
            boxShadow: designTokens.shadows.lg,
          },
        },
        outlined: {
          borderWidth: '2px',
          '&:hover': {
            borderWidth: '2px',
          },
        },
        sizeSmall: {
          padding: `${designTokens.spacing[1.5]} ${designTokens.spacing[3]}`,
          fontSize: designTokens.typography.fontSize.xs,
        },
        sizeLarge: {
          padding: `${designTokens.spacing[3]} ${designTokens.spacing[6]}`,
          fontSize: designTokens.typography.fontSize.base,
        },
      },
    },
    
    MuiTextField: {
      styleOverrides: {
        root: {
          '& .MuiOutlinedInput-root': {
            borderRadius: designTokens.borderRadius.lg,
            '&:hover .MuiOutlinedInput-notchedOutline': {
              borderColor: designTokens.colors.primary[300],
            },
            '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
              borderColor: designTokens.colors.primary[500],
              borderWidth: '2px',
            },
          },
        },
      },
    },
    
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: designTokens.borderRadius.xl,
          boxShadow: designTokens.shadows.base,
          border: `1px solid ${designTokens.colors.gray[200]}`,
          '&:hover': {
            boxShadow: designTokens.shadows.lg,
            transform: 'translateY(-2px)',
            transition: 'all 0.3s ease-in-out',
          },
        },
      },
    },
    
    MuiAppBar: {
      styleOverrides: {
        root: {
          backgroundColor: designTokens.colors.background.default,
          boxShadow: designTokens.shadows.sm,
          borderBottom: `1px solid ${designTokens.colors.gray[200]}`,
        },
      },
    },
  },
});

export type ProfessionalTheme = typeof professionalTheme;