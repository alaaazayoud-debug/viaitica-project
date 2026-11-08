// frontend/src/types/redux.ts
export interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  role: 'admin' | 'user' | 'owner' | 'super_admin';
  company_id?: number;
}

export interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}

export interface License {
  id: number;
  license_id?: number; // إضافة للحقل المستخدم
  license_key?: string; // موجود أصلاً
  license_hash?: string; // إضافة جديد
  customer_name: string;
  customer_email: string;
  expiration_date: string;
  is_active: boolean;
  seat_number?: number; // إضافة جديد
  license_type?: string; // إضافة جديد
  is_free?: boolean; // إضافة جديد
}

export interface LicenseState {
  licenses: License[];
  isLoading: boolean;
  error: string | null;
}