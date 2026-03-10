const getPagination = (page = 1, limit = 10) => {
  const pageNum = parseInt(page) || 1;
  const limitNum = parseInt(limit) || 10;
  const offset = (pageNum - 1) * limitNum;

  return {
    limit: limitNum,
    offset,
    page: pageNum,
  };
};

const getPaginationMeta = (count, page = 1, limit = 10) => {
  const pageNum = parseInt(page) || 1;
  const limitNum = parseInt(limit) || 10;
  const totalPages = Math.ceil(count / limitNum);

  return {
    total_items: count,
    total_pages: totalPages,
    current_page: pageNum,
    per_page: limitNum,
    has_next: pageNum < totalPages,
    has_prev: pageNum > 1,
  };
};

module.exports = {
  getPagination,
  getPaginationMeta,
};

