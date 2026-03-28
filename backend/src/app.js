const express = require('express');
const cors = require('cors');

// Routes
const authRoutes = require('./routes/auth.routes');
const usersRoutes = require('./routes/users.routes');
const invitationsRoutes = require('./routes/invitations.routes');
const familiesRoutes = require('./routes/families.routes');
const residentsRoutes = require('./routes/residents.routes');
const announcementsRoutes = require('./routes/announcements.routes');
const facilitiesRoutes = require('./routes/facilities.routes');
const duesRoutes = require('./routes/dues.routes');
const lettersRoutes = require('./routes/letters.routes');
const rwRoutes = require('./routes/rw.routes');
const dashboardRoutes = require('./routes/dashboard.routes');
const notificationRoutes = require('./routes/notification.routes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/invitations', invitationsRoutes);
app.use('/api/families', familiesRoutes);
app.use('/api/residents', residentsRoutes);
app.use('/api/announcements', announcementsRoutes);
app.use('/api/facilities', facilitiesRoutes);
app.use('/api/dues', duesRoutes);
app.use('/api/letters', lettersRoutes);
app.use('/api/rw', rwRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/notifications', notificationRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'RT/RW API is running' });
});

module.exports = app;

