// frontend/src/types/index.ts
export interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  role: 'admin' | 'user' | 'owner' | 'super_admin';
  company_id?: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Company {
  id: number;
  name: string;
  contact_email: string;
  phone_number?: string;
  address?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface License {
  id: number;
  license_key: string;
  customer_name: string;
  customer_email: string;
  expiration_date: string;
  is_active: boolean;
  created_by: number;
  created_at: string;
  updated_at: string;
}

// 🔧 إضافة نوع جديد للبيانات المرسلة إلى Backend
export interface CreateLicenseRequest {
  customer_id: number;
  license_type: 'floating' | 'yearly' | '3years';
  seat_count: number;
  duration_years?: number;
  username?: string;
  pc_uuid?: string;
}