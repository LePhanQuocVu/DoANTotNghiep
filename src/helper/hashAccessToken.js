var bcrypt = require('bcryptjs');
async function hashToken(token) {
  const saltRounds = 10;
  return await bcrypt.hash(token, saltRounds);
};

module.exports = { hashToken };
