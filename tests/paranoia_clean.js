# Clean Test Input: PARANOIA — Secure Code Snippet

Analyze the following Node.js/Express code. It is intentionally secure:

```javascript
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('./db-pool'); // pre-configured connection pool

const app = express();

app.use(helmet());
app.use(express.json({ limit: '10kb' }));

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts, please try again later'
});

app.post('/login',
  loginLimiter,
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }).trim()
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;
    const query = 'SELECT id, password_hash FROM users WHERE email = ?';
    const [rows] = await pool.execute(query, [email]);

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const match = await bcrypt.compare(password, rows[0].password_hash);
    if (!match) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { sub: rows[0].id, iat: Date.now() },
      process.env.JWT_SECRET,
      { expiresIn: '1h', algorithm: 'HS256' }
    );

    return res.json({ token });
  }
);

app.get('/users/:id',
  async (req, res) => {
    const query = 'SELECT id, name, email FROM users WHERE id = ?';
    const [rows] = await pool.execute(query, [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    return res.json(rows[0]);
  }
);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal Server Error' });
});

module.exports = app;
```

Security measures present:
- Helmet for security headers
- Rate limiting on login
- Input validation and sanitization (express-validator)
- Parameterized queries (prepared statements)
- Bcrypt for password hashing
- JWT with secret from environment variable, expiration, and strong algorithm
- No hardcoded secrets
- Generic error messages to client
- HTTPS enforced at load balancer level (production deployment)
