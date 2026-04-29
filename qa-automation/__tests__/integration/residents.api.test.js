const request = require('supertest');
const express = require('express');

// Mock dependencies before requiring app
jest.mock('../../../backend/src/middleware/auth.middleware', () => ({
  authenticate: (req, res, next) => {
    req.user = { id: 'mock-user-id' };
    next();
  }
}));

jest.mock('../../../backend/src/services/resident.service');
const residentService = require('../../../backend/src/services/resident.service');

// Require app after mocks are set up
const app = require('../../../backend/src/app');

describe('Residents API Integration Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /api/residents', () => {
    it('should return 200 and residents list on success', async () => {
      const mockData = [{ id: 1, nama_lengkap: 'Budi' }];
      residentService.getResidentsByFamily.mockResolvedValue(mockData);

      const response = await request(app)
        .get('/api/residents')
        .query({ family_id: '1' });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockData);
    });

    it('should return 400 when family_id is missing', async () => {
      const error = new Error('Family ID diperlukan');
      residentService.getResidentsByFamily.mockRejectedValue(error);

      const response = await request(app).get('/api/residents');

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Family ID diperlukan');
    });
  });

  describe('POST /api/residents', () => {
    it('should return 201 and created resident on success', async () => {
      const newResident = { family_id: '1', nik: '1234567890', nama_lengkap: 'Budi' };
      const mockResult = { id: 1, ...newResident };
      residentService.addResident.mockResolvedValue(mockResult);

      const response = await request(app)
        .post('/api/residents')
        .send(newResident);

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockResult);
    });

    it('should return 400 when NIK is already registered', async () => {
      const error = new Error('NIK sudah terdaftar');
      residentService.addResident.mockRejectedValue(error);

      const response = await request(app)
        .post('/api/residents')
        .send({ family_id: '1', nik: '1234567890' });

      expect(response.status).toBe(400);
      expect(response.body.message).toBe('NIK sudah terdaftar');
    });
  });

  describe('PATCH /api/residents/:id', () => {
    it('should return 200 and updated resident on success', async () => {
      const mockResult = { id: 1, nama_lengkap: 'Budi Edit' };
      residentService.updateResident.mockResolvedValue(mockResult);

      const response = await request(app)
        .patch('/api/residents/1')
        .send({ nama_lengkap: 'Budi Edit' });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockResult);
    });

    it('should return 404 when resident not found', async () => {
      const error = new Error('Anggota keluarga tidak ditemukan');
      residentService.updateResident.mockRejectedValue(error);

      const response = await request(app)
        .patch('/api/residents/99')
        .send({ nama_lengkap: 'Budi Edit' });

      expect(response.status).toBe(404);
      expect(response.body.message).toBe('Anggota keluarga tidak ditemukan');
    });
  });

  describe('DELETE /api/residents/:id', () => {
    it('should return 200 and delete resident on success', async () => {
      const mockResult = { id: 1, nama_lengkap: 'Budi' };
      residentService.deleteResident.mockResolvedValue(mockResult);

      const response = await request(app).delete('/api/residents/1');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockResult);
    });

    it('should return 404 when resident not found', async () => {
      const error = new Error('Anggota keluarga tidak ditemukan');
      residentService.deleteResident.mockRejectedValue(error);

      const response = await request(app).delete('/api/residents/99');

      expect(response.status).toBe(404);
      expect(response.body.message).toBe('Anggota keluarga tidak ditemukan');
    });
  });
});
