// frontend/src/services/inviteService.ts
import api from './api';

export interface Invitation {
    id: number;
    email: string;
    status: 'PENDING' | 'ACCEPTED' | 'EXPIRED';
    createdAt: string;
}

export const inviteService = {
    sendInvite: async (email: string) => {
        const response = await api.post('/invitations', { email });
        return response.data;
    },

    getPendingInvites: async (): Promise<Invitation[]> => {
        const response = await api.get('/invitations');
        return response.data.invitations;
    }
};
