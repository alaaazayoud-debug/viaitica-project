// frontend/src/pages/TeamPage.tsx
import React, { useEffect, useState } from 'react';
import {
  Box,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Chip,
  Stack,
  Alert
} from '@mui/material';
import { Add as AddIcon, Mail as MailIcon } from '@mui/icons-material';
import { useSelector } from 'react-redux';
import { RootState } from '../store';
import api from '../services/api';
import { inviteService, Invitation } from '../services/inviteService';

interface User {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  role: string;
  isActive: boolean;
  isVerified: boolean;
}

const TeamPage: React.FC = () => {
  const { user } = useSelector((state: RootState) => state.auth);
  const [users, setUsers] = useState<User[]>([]);
  const [invitations, setInvitations] = useState<Invitation[]>([]);
  const [openInvite, setOpenInvite] = useState(false);
  const [inviteEmail, setInviteEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const fetchData = async () => {
    try {
      // Fetch Users
      const usersRes = await api.get('/users'); // Assuming we have this route exposed
      setUsers(usersRes.data.users);

      // Fetch Pending Invites
      const invites = await inviteService.getPendingInvites();
      setInvitations(invites);
    } catch (err) {
      console.error('Failed to fetch team data', err);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleInvite = async () => {
    setLoading(true);
    setError('');
    setSuccess('');
    try {
      await inviteService.sendInvite(inviteEmail);
      setSuccess(`Invitation sent to ${inviteEmail}`);
      setInviteEmail('');
      setOpenInvite(false);
      fetchData(); // Refresh list
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to send invite');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box>
      <Stack direction="row" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight="bold">
          Team Members
        </Typography>
        {['admin', 'owner', 'super_admin'].includes(user?.role || '') && (
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            onClick={() => setOpenInvite(true)}
          >
            Invite Member
          </Button>
        )}
      </Stack>

      {success && <Alert severity="success" sx={{ mb: 2 }}>{success}</Alert>}
      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      <TableContainer component={Paper} sx={{ mb: 4 }}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Email</TableCell>
              <TableCell>Role</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {users.map((user) => (
              <TableRow key={user.id}>
                <TableCell>{user.firstName} {user.lastName}</TableCell>
                <TableCell>{user.email}</TableCell>
                <TableCell>
                  <Chip label={user.role} size="small" color={user.role === 'ADMIN' ? 'primary' : 'default'} />
                </TableCell>
                <TableCell>
                  <Chip 
                    label={user.isActive ? 'Active' : 'Inactive'} 
                    color={user.isActive ? 'success' : 'error'} 
                    size="small" 
                  />
                </TableCell>
              </TableRow>
            ))}
            {users.length === 0 && (
                <TableRow>
                    <TableCell colSpan={4} align="center">No team members found.</TableCell>
                </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {invitations.length > 0 && (
        <>
          <Typography variant="h6" gutterBottom>
            Pending Invitations
          </Typography>
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Email</TableCell>
                  <TableCell>Sent At</TableCell>
                  <TableCell>Status</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {invitations.map((invite) => (
                  <TableRow key={invite.id}>
                    <TableCell>{invite.email}</TableCell>
                    <TableCell>{new Date(invite.createdAt).toLocaleDateString()}</TableCell>
                    <TableCell>
                      <Chip label="Pending" color="warning" size="small" icon={<MailIcon />} />
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </>
      )}

      {/* Invite Modal */}
      <Dialog open={openInvite} onClose={() => setOpenInvite(false)}>
        <DialogTitle>Invite New Member</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Enter the email address of the person you want to invite to your team.
          </Typography>
          <TextField
            autoFocus
            margin="dense"
            label="Email Address"
            type="email"
            fullWidth
            variant="outlined"
            value={inviteEmail}
            onChange={(e) => setInviteEmail(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenInvite(false)}>Cancel</Button>
          <Button onClick={handleInvite} variant="contained" disabled={loading}>
            {loading ? 'Sending...' : 'Send Invite'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default TeamPage;
