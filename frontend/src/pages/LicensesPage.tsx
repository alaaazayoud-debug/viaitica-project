// frontend/src/pages/LicensesPage.tsx
import React, { useState, useEffect } from 'react';
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Button,
  Box,
  Typography,
  CircularProgress,
  Alert,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  MenuItem,
  Stack
} from '@mui/material';
import { licenseService, License } from '../services/licenseService';

import { useSelector } from 'react-redux';
import { RootState } from '../store';

const LicensesPage: React.FC = () => {
  const { user } = useSelector((state: RootState) => state.auth);
  const [licenses, setLicenses] = useState<License[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  // Purchase Dialog State
  const [openPurchase, setOpenPurchase] = useState(false);
  const [purchaseLoading, setPurchaseLoading] = useState(false);
  const [purchaseData, setPurchaseData] = useState({
    planType: 'yearly' as 'yearly' | '3years' | 'floating',
    seats: 1,
    phoneNumber: ''
  });

  useEffect(() => {
    fetchLicenses();
  }, []);

  const fetchLicenses = async () => {
    try {
      setLoading(true);
      setError('');
      const licensesData = await licenseService.getAllLicenses();
      setLicenses(licensesData);
    } catch (err) {
      setError('Failed to load licenses');
      console.error('Error fetching licenses:', err);
    } finally {
      setLoading(false);
    }
  };

  const handlePurchase = async () => {
    try {
      setPurchaseLoading(true);
      setError('');

      await licenseService.purchaseLicense({
        planType: purchaseData.planType,
        seats: Number(purchaseData.seats),
        phoneNumber: purchaseData.phoneNumber
      });

      setOpenPurchase(false);
      fetchLicenses(); // Refresh list
      // Reset form
      setPurchaseData({ planType: 'yearly', seats: 1, phoneNumber: '' });
      
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to purchase license');
    } finally {
      setPurchaseLoading(false);
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="200px">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" fontWeight="bold" sx={{ color: '#1a237e' }}>
          License Management
        </Typography>
        {['admin', 'owner', 'super_admin'].includes(user?.role || '') && (
          <Button 
            variant="contained" 
            onClick={() => setOpenPurchase(true)}
            sx={{ 
              borderRadius: 2,
              textTransform: 'none',
              boxShadow: '0 4px 12px rgba(0,0,0,0.1)'
            }}
          >
            Purchase New License
          </Button>
        )}
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>License Key</TableCell>
              <TableCell>Type</TableCell>
              <TableCell>Seats</TableCell>
              <TableCell>Issue Date</TableCell>
              <TableCell>Expiration</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {licenses.map((license) => (
              <TableRow key={license.id}>
                <TableCell sx={{ fontFamily: 'monospace' }}>{license.key}</TableCell>
                <TableCell>{license.type}</TableCell>
                <TableCell>{license.seatNumber}</TableCell>
                <TableCell>{new Date(license.issueDate).toLocaleDateString()}</TableCell>
                <TableCell>{new Date(license.expiryDate).toLocaleDateString()}</TableCell>
                <TableCell>
                  <Box
                    component="span"
                    sx={{
                      px: 1,
                      py: 0.5,
                      borderRadius: 1,
                      bgcolor: license.isActive ? 'success.light' : 'error.light',
                      color: license.isActive ? 'success.dark' : 'error.dark',
                      fontSize: '0.875rem'
                    }}
                  >
                    {license.isActive ? 'Active' : 'Inactive'}
                  </Box>
                </TableCell>
              </TableRow>
            ))}
            {licenses.length === 0 && (
              <TableRow>
                <TableCell colSpan={6} align="center">
                  No licenses found. Purchase one to get started!
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Purchase Dialog */}
      <Dialog open={openPurchase} onClose={() => setOpenPurchase(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Purchase License</DialogTitle>
        <DialogContent>
          <Box sx={{ mt: 2 }}>
            <Stack spacing={2}>
              <Box>
                <TextField
                  select
                  fullWidth
                  label="Plan Type"
                  value={purchaseData.planType}
                  onChange={(e) => setPurchaseData({ ...purchaseData, planType: e.target.value as any })}
                >
                  <MenuItem value="yearly">Yearly License</MenuItem>
                  <MenuItem value="3years">3 Years License</MenuItem>
                  <MenuItem value="floating">Floating License</MenuItem>
                </TextField>
              </Box>
              <Box>
                <TextField
                  fullWidth
                  type="number"
                  label="Number of Seats"
                  value={purchaseData.seats}
                  onChange={(e) => setPurchaseData({ ...purchaseData, seats: Number(e.target.value) })}
                  inputProps={{ min: 1 }}
                />
              </Box>
              <Box>
                <TextField
                  fullWidth
                  label="Phone Number (Payment Verification)"
                  placeholder="Enter 0966262458 for test"
                  value={purchaseData.phoneNumber}
                  onChange={(e) => setPurchaseData({ ...purchaseData, phoneNumber: e.target.value })}
                  helperText="For testing, use: 0966262458"
                />
              </Box>
            </Stack>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenPurchase(false)}>Cancel</Button>
          <Button 
            onClick={handlePurchase} 
            variant="contained" 
            disabled={purchaseLoading || !purchaseData.phoneNumber}
          >
            {purchaseLoading ? 'Processing...' : 'Purchase'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default LicensesPage;