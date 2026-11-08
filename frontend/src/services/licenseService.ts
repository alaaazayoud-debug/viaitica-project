// frontend/src/services/licenseService.ts
import api from './api';

export interface License {
  id: number;
  key: string;
  type: string;
  seatNumber: number;
  expiryDate: string;
  issueDate: string;
  isFree: boolean;
  isActive: boolean;
  customerId: number;
}

export const licenseService = {
  getAllLicenses: async (): Promise<License[]> => {
    const response = await api.get('/admin/licenses');
    return response.data.licenses;
  },

  purchaseLicense: async (data: {
    planType: 'yearly' | '3years' | 'floating';
    seats: number;
    phoneNumber: string;
  }): Promise<any> => {
    const response = await api.post('/admin/licenses/purchase', data);
    return response.data;
  }
};
