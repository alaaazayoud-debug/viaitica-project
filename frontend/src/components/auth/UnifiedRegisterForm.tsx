// frontend/src/components/auth/UnifiedRegisterForm.tsx
import React, { useState, useRef } from 'react';
import {
  Box,
  TextField,
  Button,
  Alert,
  Typography,
  InputAdornment,
  IconButton,
  CircularProgress,
  FormControlLabel,
  Radio,
  RadioGroup,
  FormLabel,
  Divider,
  Card,
  CardContent,
  Grid,
  Collapse
} from '@mui/material';
import {
  Visibility,
  VisibilityOff,
  Business,
  Person,
  LocationOn,
  Email,
  Phone,
  Security,
  CheckCircle
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import api from '../../services/api';
import PasswordStrength from '../common/PasswordStrength';
import { registerSchema } from '../../schemas/registerSchema';

interface FieldErrors {
  [key: string]: string;
}

const UnifiedRegisterForm: React.FC = () => {
  const [formData, setFormData] = useState({
    customer_type: 'individual',
    company_name: '',
    first_name: '',
    last_name: '',
    customer_phone: '',
    cust_street: '',
    cust_building: '',
    cust_post: '',
    cust_city: '',
    cust_state: '',
    cust_country: '',
    mgrFirst: '',
    mgrLast: '',
    mgrEmail: '',
    password: '',
    mgrPasswordConfirm: '',
    mgrPhone: '',
    mgr_street: '',
    mgr_building: '',
    mgr_post: '',
    mgr_city: '',
    mgr_state: '',
    mgr_country: ''
  });

  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({});
  const [touchedFields, setTouchedFields] = useState<Set<string>>(new Set());
  const formRef = useRef<HTMLFormElement>(null);
  const navigate = useNavigate();

  const isCompany = formData.customer_type === 'company';

  // Validate single field
  const validateField = async (fieldName: string, value: any) => {
    try {
      await registerSchema.validateAt(fieldName, { ...formData, [fieldName]: value });
      setFieldErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[fieldName];
        return newErrors;
      });
      return true;
    } catch (err: any) {
      if (err.message) setFieldErrors(prev => ({ ...prev, [fieldName]: err.message }));
      return false;
    }
  };

  const handleBlur = (fieldName: string) => {
    setTouchedFields(prev => new Set(prev).add(fieldName));
    validateField(fieldName, formData[fieldName as keyof typeof formData]);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
    if (touchedFields.has(name)) validateField(name, value);
  };
const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    try {
      // Validate using yup schema
      await registerSchema.validate(formData, { abortEarly: false });

      // 🔥 البيانات المصححة
      const registrationData = {
        email: formData.mgrEmail,
        password: formData.password,
        phone: formData.mgrPhone,
        customer_type: formData.customer_type,
        company_name: formData.customer_type === 'company' ? formData.company_name : undefined,
        first_name: formData.mgrFirst,
        last_name: formData.mgrLast,
        role: 'admin'
      };

      // Call API
      await api.post('/auth/register', registrationData);
      
      setSuccess('Registration successful! Please check your email for verification code.');
      
      setTimeout(() => {
  navigate(`/verify?email=${encodeURIComponent(formData.mgrEmail)}&password=${encodeURIComponent(formData.password)}`);
}, 2000);
    } catch (err: any) {
      // 🔥 أضف معالجة الأخطاء
      if (err.inner) {
        const errors: FieldErrors = {};
        err.inner.forEach((e: any) => {
          errors[e.path] = e.message;
        });
        setFieldErrors(errors);
        setTouchedFields(new Set(Object.keys(formData)));
        setError('Please fix the errors in the form.');
      } 
      else if (err.response?.data?.message) {
        setError(err.response.data.message);
      } 
      else {
        setError('Registration failed. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const getFieldError = (fieldName: string) =>
    touchedFields.has(fieldName) && fieldErrors[fieldName]
      ? fieldErrors[fieldName]
      : undefined;

  return (
    <Box component="form" ref={formRef} onSubmit={handleSubmit} sx={{ mt: 2 }}>
      <Collapse in={!!error}>
        <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }} onClose={() => setError('')}>
          {error}
        </Alert>
      </Collapse>

      <Collapse in={!!success}>
        <Alert severity="success" sx={{ mb: 3, borderRadius: 2 }} icon={<CheckCircle />}>
          {success}
        </Alert>
      </Collapse>

      {/* Customer Type Selection */}
      <Card sx={{ mb: 4, border: '1px solid', borderColor: 'divider', borderRadius: 3 }}>
        <CardContent sx={{ p: 4 }}>
          <FormLabel sx={{ fontSize: '1.1rem', fontWeight: 600, color: 'text.primary', mb: 3, display: 'block' }}>
            <Business sx={{ mr: 1, verticalAlign: 'middle' }} />
            Account Type
          </FormLabel>
          <RadioGroup
            name="customer_type"
            value={formData.customer_type}
            onChange={handleChange}
            row
            sx={{ gap: 4, mt: 2 }}
          >
            <FormControlLabel
              value="individual"
              control={<Radio color="primary" />}
              label={
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Person color="primary" />
                  <Box>
                    <Typography variant="subtitle1" fontWeight={600}>Individual</Typography>
                    <Typography variant="body2" color="text.secondary">Personal license for individual use</Typography>
                  </Box>
                </Box>
              }
              sx={{
                flex: 1,
                border: formData.customer_type === 'individual' ? '2px solid' : '1px solid',
                borderColor: formData.customer_type === 'individual' ? 'primary.main' : 'divider',
                borderRadius: 2, p: 2, m: 0,
                transition: 'all 0.2s ease-in-out',
                '&:hover': { borderColor: 'primary.main', boxShadow: 1 }
              }}
            />
            <FormControlLabel
              value="company"
              control={<Radio color="primary" />}
              label={
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Business color="primary" />
                  <Box>
                    <Typography variant="subtitle1" fontWeight={600}>Company</Typography>
                    <Typography variant="body2" color="text.secondary">Business license with team management</Typography>
                  </Box>
                </Box>
              }
              sx={{
                flex: 1,
                border: formData.customer_type === 'company' ? '2px solid' : '1px solid',
                borderColor: formData.customer_type === 'company' ? 'primary.main' : 'divider',
                borderRadius: 2, p: 2, m: 0,
                transition: 'all 0.2s ease-in-out',
                '&:hover': { borderColor: 'primary.main', boxShadow: 1 }
              }}
            />
          </RadioGroup>
        </CardContent>
      </Card>

      {/* Customer Details */}
      <Card sx={{ mb: 4, border: '1px solid', borderColor: 'divider', borderRadius: 3 }}>
        <CardContent sx={{ p: 4 }}>
          <Typography variant="h6" sx={{ mb: 3, color: 'text.primary', display: 'flex', alignItems: 'center', gap: 1 }}>
            <Business color="primary" />
            {isCompany ? 'Company' : 'Customer'} Information
          </Typography>

          <Grid container spacing={3}>
            {!isCompany && (
              <>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField
                    fullWidth
                    label="First Name"
                    name="first_name"
                    value={formData.first_name}
                    onChange={handleChange}
                    onBlur={() => handleBlur('first_name')}
                    error={!!getFieldError('first_name')}
                    helperText={getFieldError('first_name')}
                    required={!isCompany}
                    variant="outlined"
                    disabled={loading}
                  />
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <TextField
                    fullWidth
                    label="Last Name"
                    name="last_name"
                    value={formData.last_name}
                    onChange={handleChange}
                    onBlur={() => handleBlur('last_name')}
                    error={!!getFieldError('last_name')}
                    helperText={getFieldError('last_name')}
                    required={!isCompany}
                    variant="outlined"
                    disabled={loading}
                  />
                </Grid>
              </>
            )}
            {isCompany && (
              <Grid size={{ xs: 12 }}>
                <TextField
                  fullWidth
                  label="Company Name"
                  name="company_name"
                  value={formData.company_name}
                  onChange={handleChange}
                  onBlur={() => handleBlur('company_name')}
                  error={!!getFieldError('company_name')}
                  helperText={getFieldError('company_name')}
                  required={isCompany}
                  variant="outlined"
                  disabled={loading}
                />
              </Grid>
            )}
            <Grid size={{ xs: 12 }}>
              <TextField
                fullWidth
                label="Phone Number"
                name="customer_phone"
                value={formData.customer_phone}
                onChange={handleChange}
                onBlur={() => handleBlur('customer_phone')}
                error={!!getFieldError('customer_phone')}
                helperText={getFieldError('customer_phone') || 'Format: +49 151 2345678'}
                required
                placeholder="+49 151 2345678"
                variant="outlined"
                disabled={loading}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Phone color="action" />
                    </InputAdornment>
                  ),
                }}
              />
            </Grid>
          </Grid>

          <Divider sx={{ my: 4 }} />
          <Typography variant="h6" sx={{ mb: 3, color: 'text.primary', display: 'flex', alignItems: 'center', gap: 1 }}>
            <LocationOn color="primary" /> Customer Address
          </Typography>
          <Grid container spacing={2}>
            <Grid size={{ xs: 12, sm: 8 }}>
              <TextField
                fullWidth
                label="Street Name"
                name="cust_street"
                value={formData.cust_street}
                onChange={handleChange}
                onBlur={() => handleBlur('cust_street')}
                error={!!getFieldError('cust_street')}
                helperText={getFieldError('cust_street')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 4 }}>
              <TextField
                fullWidth
                label="Building No."
                name="cust_building"
                value={formData.cust_building}
                onChange={handleChange}
                onBlur={() => handleBlur('cust_building')}
                error={!!getFieldError('cust_building')}
                helperText={getFieldError('cust_building')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 3 }}>
              <TextField
                fullWidth
                label="Postal Code"
                name="cust_post"
                value={formData.cust_post}
                onChange={handleChange}
                onBlur={() => handleBlur('cust_post')}
                error={!!getFieldError('cust_post')}
                helperText={getFieldError('cust_post')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 5 }}>
              <TextField
                fullWidth
                label="City"
                name="cust_city"
                value={formData.cust_city}
                onChange={handleChange}
                onBlur={() => handleBlur('cust_city')}
                error={!!getFieldError('cust_city')}
                helperText={getFieldError('cust_city')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 4 }}>
              <TextField
                fullWidth
                label="State/Province"
                name="cust_state"
                value={formData.cust_state}
                onChange={handleChange}
                onBlur={() => handleBlur('cust_state')}
                error={!!getFieldError('cust_state')}
                helperText={getFieldError('cust_state')}
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12 }}>
              <TextField
                fullWidth
                label="Country"
                name="cust_country"
                value={formData.cust_country}
                onChange={handleChange}
                onBlur={() => handleBlur('cust_country')}
                error={!!getFieldError('cust_country')}
                helperText={getFieldError('cust_country')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Administrator Account */}
      <Card sx={{ mb: 4, border: '1px solid', borderColor: 'divider', borderRadius: 3, bgcolor: 'grey.50' }}>
        <CardContent sx={{ p: 4 }}>
          <Typography variant="h6" sx={{ mb: 2, color: 'text.primary', display: 'flex', alignItems: 'center', gap: 1 }}>
            <Security color="secondary" /> Administrator Account
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 4 }}>
            This account will manage licenses and team access for your organization.
          </Typography>
          <Grid container spacing={3}>
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                fullWidth
                label="First Name"
                name="mgrFirst"
                value={formData.mgrFirst}
                onChange={handleChange}
                onBlur={() => handleBlur('mgrFirst')}
                error={!!getFieldError('mgrFirst')}
                helperText={getFieldError('mgrFirst')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                fullWidth
                label="Last Name"
                name="mgrLast"
                value={formData.mgrLast}
                onChange={handleChange}
                onBlur={() => handleBlur('mgrLast')}
                error={!!getFieldError('mgrLast')}
                helperText={getFieldError('mgrLast')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                fullWidth
                label="Email Address"
                name="mgrEmail"
                type="email"
                value={formData.mgrEmail}
                onChange={handleChange}
                onBlur={() => handleBlur('mgrEmail')}
                error={!!getFieldError('mgrEmail')}
                helperText={getFieldError('mgrEmail')}
                required
                placeholder="name@company.com"
                variant="outlined"
                disabled={loading}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Email color="action" />
                    </InputAdornment>
                  ),
                }}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                fullWidth
                label="Phone Number"
                name="mgrPhone"
                type="tel"
                value={formData.mgrPhone}
                onChange={handleChange}
                onBlur={() => handleBlur('mgrPhone')}
                error={!!getFieldError('mgrPhone')}
                helperText={getFieldError('mgrPhone')}
                required
                placeholder="+49 151 2345678"
                variant="outlined"
                disabled={loading}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Phone color="action" />
                    </InputAdornment>
                  ),
                }}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                fullWidth
                label="Password"
                name="password"
                type={showPassword ? 'text' : 'password'}
                value={formData.password}
                onChange={handleChange}
                onBlur={() => handleBlur('password')}
                error={!!getFieldError('password')}
                helperText={getFieldError('password')}
                required
                placeholder="Minimum 8 characters"
                variant="outlined"
                disabled={loading}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Security color="action" />
                    </InputAdornment>
                  ),
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton onClick={() => setShowPassword(!showPassword)} edge="end" disabled={loading}>
                        {showPassword ? <VisibilityOff /> : <Visibility />}
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
              />
              <PasswordStrength password={formData.password} />
            </Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <TextField
                fullWidth
                label="Confirm Password"
                name="mgrPasswordConfirm"
                type={showConfirmPassword ? 'text' : 'password'}
                value={formData.mgrPasswordConfirm}
                onChange={handleChange}
                onBlur={() => handleBlur('mgrPasswordConfirm')}
                error={!!getFieldError('mgrPasswordConfirm')}
                helperText={getFieldError('mgrPasswordConfirm')}
                required
                placeholder="Re-enter your password"
                variant="outlined"
                disabled={loading}
                InputProps={{
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton onClick={() => setShowConfirmPassword(!showConfirmPassword)} edge="end" disabled={loading}>
                        {showConfirmPassword ? <VisibilityOff /> : <Visibility />}
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
              />
            </Grid>
          </Grid>

          <Divider sx={{ my: 4 }} />

          <Typography variant="h6" sx={{ mb: 3, color: 'text.primary', display: 'flex', alignItems: 'center', gap: 1 }}>
            <LocationOn color="secondary" />
            Administrator Address
          </Typography>
          
          <Grid container spacing={2}>
            <Grid size={{ xs: 12, sm: 8 }}>
              <TextField
                fullWidth
                label="Street Name"
                name="mgr_street"
                value={formData.mgr_street}
                onChange={handleChange}
                onBlur={() => handleBlur('mgr_street')}
                error={!!getFieldError('mgr_street')}
                helperText={getFieldError('mgr_street')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 4 }}>
              <TextField
                fullWidth
                label="Building No."
                name="mgr_building"
                value={formData.mgr_building}
                onChange={handleChange}
                onBlur={() => handleBlur('mgr_building')}
                error={!!getFieldError('mgr_building')}
                helperText={getFieldError('mgr_building')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 3 }}>
              <TextField
                fullWidth
                label="Postal Code"
                name="mgr_post"
                value={formData.mgr_post}
                onChange={handleChange}
                onBlur={() => handleBlur('mgr_post')}
                error={!!getFieldError('mgr_post')}
                helperText={getFieldError('mgr_post')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 5 }}>
              <TextField
                fullWidth
                label="City"
                name="mgr_city"
                value={formData.mgr_city}
                onChange={handleChange}
                onBlur={() => handleBlur('mgr_city')}
                error={!!getFieldError('mgr_city')}
                helperText={getFieldError('mgr_city')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 4 }}>
              <TextField
                fullWidth
                label="State/Province"
                name="mgr_state"
                value={formData.mgr_state}
                onChange={handleChange}
                onBlur={() => handleBlur('mgr_state')}
                error={!!getFieldError('mgr_state')}
                helperText={getFieldError('mgr_state')}
                variant="outlined"
                disabled={loading}
              />
            </Grid>
            <Grid size={{ xs: 12 }}>
              <TextField
                fullWidth
                label="Country"
                name="mgr_country"
                value={formData.mgr_country}
                onChange={handleChange}
                onBlur={() => handleBlur('mgr_country')}
                error={!!getFieldError('mgr_country')}
                helperText={getFieldError('mgr_country')}
                required
                variant="outlined"
                disabled={loading}
              />
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Button
        type="submit"
        fullWidth
        variant="contained"
        size="large"
        disabled={loading}
        sx={{
          py: 2,
          fontSize: '1.1rem',
          fontWeight: 600,
          borderRadius: 2,
          bgcolor: 'primary.main',
          '&:hover': {
            bgcolor: 'primary.dark',
            transform: 'translateY(-2px)',
            boxShadow: 6,
          },
          '&:active': {
            transform: 'translateY(0)',
          },
          transition: 'all 0.2s ease-in-out',
          boxShadow: 2,
        }}
      >
        {loading ? <CircularProgress size={24} color="inherit" /> : 'Create Account & Continue'}
      </Button>
    </Box>
  );
};

export default UnifiedRegisterForm;
