const dashboardService = require('../services/dashboard.service');
const financeRepository = require('../repositories/finance.repository');
const { successResponse, errorResponse } = require('../utils/response');
const Tesseract = require('tesseract.js');

const dashboardController = {
  async getStats(req, res, next) {
    try {
      const stats = await dashboardService.getStats(req.user);
      return successResponse(res, 'Dashboard statistics fetched', stats);
    } catch (error) {
      next(error);
    }
  },

  async getFinanceSummary(req, res, next) {
    try {
      const user = req.user;
      let data = {};
      if (user.role === 'RW') {
        data = await financeRepository.getFinanceSummaryForRW(user.rw_id);
      } else if (user.role === 'RT') {
        data = await financeRepository.getFinanceSummaryForRT(user.rt_id);
      } else if (user.role === 'WARGA') {
        data = await financeRepository.getFinanceSummaryForWarga(user.id);
      }
      return successResponse(res, 'Finance summary', data);
    } catch (error) {
      next(error);
    }
  },

  async scanReceipt(req, res, next) {
    try {
      if (!req.file) {
        return res.status(400).json({ success: false, message: 'No image uploaded' });
      }
      
      const { data: { text } } = await Tesseract.recognize(req.file.buffer, 'ind', {
        logger: m => console.log(m)
      });
      
      const matches = text.match(/\b\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?\b|\b\d{4,}\b/g);
      let guessedAmount = 0;
      if (matches) {
        const amounts = matches.map(m => parseInt(m.replace(/[.,]/g, ''))).filter(a => !isNaN(a));
        if (amounts.length > 0) {
          guessedAmount = Math.max(...amounts);
        }
      }

      return successResponse(res, 'Receipt scanned successfully', {
        amount: guessedAmount,
        rawText: text
      });
    } catch (error) {
      console.error('OCR Error:', error);
      return res.status(500).json({ success: false, message: 'Failed to process image' });
    }
  },
};

module.exports = dashboardController;
