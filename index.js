global.__basename = __dirname;
global.is_reading = new Array();
require('coffee-script');
process.env.TZ = 'PRC';
module.exports = require('./server');
