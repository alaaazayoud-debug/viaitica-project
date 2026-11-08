// في src/theme.ts
import { createTheme } from '@mui/material/styles';

export const theme = createTheme({
  direction: 'rtl',
  palette: {
    primary: {
      main: '#2563eb', // الأزرق الأساسي من هوية PowerFlow
      light: '#3b82f6',
      dark: '#1d4ed8',
    },
    secondary: {
      main: '#64748b', // الرمادي الاحترافي
      light: '#94a3b8',
      dark: '#475569',
    },
    background: {
      default: '#f8fafc', // خلفية فاتحة وأنيقة
      paper: '#ffffff',
    },
  },
  typography: {
    fontFamily: '"Inter", "Tajawal", sans-serif',
    h4: {
      fontWeight: 700,
      color: '#1e293b',
    },
  },
  shape: {
    borderRadius: 12, // زوايا أكثر نعومة
  },
});