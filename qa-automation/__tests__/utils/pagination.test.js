const { getPagination, getPaginationMeta } = require('../../../backend/src/utils/pagination');

describe('Pagination Utility', () => {
  describe('getPagination', () => {
    it('should return default pagination when no parameters are provided', () => {
      const result = getPagination();

      expect(result).toEqual({
        page: 1,
        limit: 10,
        offset: 0
      });
    });

    it('should compute correct offset and values for given page and limit numbers', () => {
      const result = getPagination(3, 20);

      expect(result).toEqual({
        page: 3,
        limit: 20,
        offset: 40
      });
    });

    it('should correctly parse numeric strings for page and limit', () => {
      const result = getPagination('2', '15');

      expect(result).toEqual({
        page: 2,
        limit: 15,
        offset: 15
      });
    });

    it('should fallback to defaults when invalid non-numeric inputs are provided', () => {
      const result = getPagination('invalid_page', 'invalid_limit');

      expect(result).toEqual({
        page: 1,
        limit: 10,
        offset: 0
      });
    });

    it('should calculate offset as 0 for first page', () => {
      const result = getPagination(1, 25);

      expect(result).toEqual({
        page: 1,
        limit: 25,
        offset: 0
      });
    });
  });

  describe('getPaginationMeta', () => {
    it('should compute metadata correctly on the first page with next pages available', () => {
      const count = 25;
      const meta = getPaginationMeta(count, 1, 10);

      expect(meta).toEqual({
        total_items: 25,
        total_pages: 3,
        current_page: 1,
        per_page: 10,
        has_next: true,
        has_prev: false
      });
    });

    it('should compute metadata correctly on a middle page with both prev and next', () => {
      const count = 50;
      const meta = getPaginationMeta(count, 2, 10);

      expect(meta).toEqual({
        total_items: 50,
        total_pages: 5,
        current_page: 2,
        per_page: 10,
        has_next: true,
        has_prev: true
      });
    });

    it('should compute metadata correctly on the last page without next page', () => {
      const count = 30;
      const meta = getPaginationMeta(count, 3, 10);

      expect(meta).toEqual({
        total_items: 30,
        total_pages: 3,
        current_page: 3,
        per_page: 10,
        has_next: false,
        has_prev: true
      });
    });

    it('should handle count 0 (empty items) correctly', () => {
      const count = 0;
      const meta = getPaginationMeta(count, 1, 10);

      expect(meta).toEqual({
        total_items: 0,
        total_pages: 0,
        current_page: 1,
        per_page: 10,
        has_next: false,
        has_prev: false
      });
    });

    it('should parse string parameters for page and limit in metadata', () => {
      const count = 100;
      const meta = getPaginationMeta(count, '4', '20');

      expect(meta).toEqual({
        total_items: 100,
        total_pages: 5,
        current_page: 4,
        per_page: 20,
        has_next: true,
        has_prev: true
      });
    });

    it('should fallback to default page and limit when invalid non-numeric inputs are passed', () => {
      const count = 15;
      const meta = getPaginationMeta(count, 'abc', 'xyz');

      expect(meta).toEqual({
        total_items: 15,
        total_pages: 2,
        current_page: 1,
        per_page: 10,
        has_next: true,
        has_prev: false
      });
    });
  });
});
