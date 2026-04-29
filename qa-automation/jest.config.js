module.exports = {
  testEnvironment: 'node',
  clearMocks: true,
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageProvider: 'v8',
  rootDir: '..',
  testMatch: ['<rootDir>/qa-automation/__tests__/**/*.test.js'],
  collectCoverageFrom: [
    '<rootDir>/backend/src/**/*.js'
  ],
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/config/',
    '/utils/',
    '/__tests__/'
  ],
  moduleDirectories: [
    'node_modules',
    '<rootDir>/backend/node_modules'
  ],
  setupFilesAfterEnv: ['<rootDir>/qa-automation/jest.setup.js']
};
