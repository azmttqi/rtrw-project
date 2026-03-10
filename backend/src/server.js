require('dotenv').config();
const app = require('./app');
const { errorHandler, notFoundHandler } = require('./middleware/error.middleware');

const PORT = process.env.PORT || 3000;

app.use(notFoundHandler);
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

