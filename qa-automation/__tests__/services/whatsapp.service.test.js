const whatsappService = require('../../../backend/src/services/whatsapp.service');

describe('WhatsApp Service', () => {
  let consoleLogSpy, consoleWarnSpy, consoleErrorSpy;

  beforeEach(() => {
    consoleLogSpy = jest.spyOn(console, 'log').mockImplementation(() => {});
    consoleWarnSpy = jest.spyOn(console, 'warn').mockImplementation(() => {});
    consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('sendMessage', () => {
    it('should return false if target is missing', async () => {
      const result = await whatsappService.sendMessage(null, 'Hello');
      expect(result).toBe(false);
      expect(consoleWarnSpy).toHaveBeenCalledWith('[WA-SERVICE] Skip sending: No target number');
    });

    it('should simulate sending message and return true', async () => {
      const result = await whatsappService.sendMessage('08123', 'Hello');
      expect(consoleLogSpy).toHaveBeenCalledWith('[WA-SERVICE] SENDING TO: 08123');
      expect(consoleLogSpy).toHaveBeenCalledWith(expect.stringContaining('Hello'));
      expect(result).toBe(true);
    });
  });

  describe('sendDueReminder', () => {
    it('should format message and call sendMessage', async () => {
      const spy = jest.spyOn(whatsappService, 'sendMessage').mockResolvedValue(true);
      
      const data = {
        nama: 'Budi',
        jenis: 'Keamanan',
        nominal: 50000,
        bulan: 'Januari',
        tahun: 2024
      };
      
      const result = await whatsappService.sendDueReminder('08123', data);
      
      expect(spy).toHaveBeenCalled();
      const messageArg = spy.mock.calls[0][1];
      expect(messageArg).toContain('Budi');
      expect(messageArg).toContain('Keamanan');
      expect(messageArg).toContain('Januari 2024');
      expect(messageArg).toContain('50.000');
      expect(result).toBe(true);
    });
  });
});
