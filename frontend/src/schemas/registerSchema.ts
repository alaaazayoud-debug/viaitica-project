import * as yup from 'yup';

export const registerSchema = yup.object().shape({
  customer_type: yup.string().required(),

  // Conditional validation for company name
  company_name: yup.string().when('customer_type', {
    is: 'company',
    then: (schema) => schema.required('Company name is required'),
    otherwise: (schema) => schema.notRequired()
  }),

  // Conditional validation for first/last name (required for individual)
  first_name: yup.string().when('customer_type', {
    is: 'individual',
    then: (schema) => schema.required('First name is required').min(2, 'First name must be at least 2 characters'),
    otherwise: (schema) => schema.notRequired()
  }),

  last_name: yup.string().when('customer_type', {
    is: 'individual',
    then: (schema) => schema.required('Last name is required').min(2, 'Last name must be at least 2 characters'),
    otherwise: (schema) => schema.notRequired()
  }),

  customer_phone: yup
    .string()
    .matches(/^[+]?[(]?[0-9]{1,4}[)]?[-\s.]?[(]?[0-9]{1,4}[)]?[-\s.]?[0-9]{1,9}$/, 'Please enter a valid phone number')
    .required('Phone number is required'),

  mgrFirst: yup
    .string()
    .min(2, 'First name must be at least 2 characters')
    .required('Administrator first name is required'),

  mgrLast: yup
    .string()
    .min(2, 'Last name must be at least 2 characters')
    .required('Administrator last name is required'),

  mgrEmail: yup
    .string()
    .email('Please enter a valid email address')
    .required('Administrator email is required'),

  mgrPhone: yup
    .string()
    .matches(/^[+]?[(]?[0-9]{1,4}[)]?[-\s.]?[(]?[0-9]{1,4}[)]?[-\s.]?[0-9]{1,9}$/, 'Please enter a valid phone number')
    .required('Administrator phone number is required'),

  password: yup
    .string()
    .min(8, 'Password must be at least 8 characters')
    .matches(/[a-z]/, 'Password must contain at least one lowercase letter')
    .matches(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .matches(/[0-9]/, 'Password must contain at least one number')
    .required('Password is required'),

  mgrPasswordConfirm: yup
    .string()
    .oneOf([yup.ref('password')], 'Passwords must match')
    .required('Please confirm your password'),

  // Customer Address
  cust_street: yup
    .string()
    .min(3, 'Street name must be at least 3 characters')
    .required('Street name is required'),

  cust_building: yup
    .string()
    .required('Building number is required'),

  cust_post: yup
    .string()
    .required('Postal code is required'),

  cust_city: yup
    .string()
    .min(2, 'City name must be at least 2 characters')
    .required('City is required'),

  cust_state: yup
    .string()
    .min(2, 'State/Province must be at least 2 characters')
    .notRequired(),

  cust_country: yup
    .string()
    .min(2, 'Country name must be at least 2 characters')
    .required('Country is required'),

  // Manager Address
  mgr_street: yup
    .string()
    .min(3, 'Street name must be at least 3 characters')
    .required('Street name is required'),

  mgr_building: yup
    .string()
    .required('Building number is required'),

  mgr_post: yup
    .string()
    .required('Postal code is required'),

  mgr_city: yup
    .string()
    .min(2, 'City name must be at least 2 characters')
    .required('City is required'),

  mgr_state: yup
    .string()
    .min(2, 'State/Province must be at least 2 characters')
    .notRequired(),

  mgr_country: yup
    .string()
    .min(2, 'Country name must be at least 2 characters')
    .required('Country is required'),
});