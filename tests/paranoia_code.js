# Test Input: PARANOIA — Security Vulnerabilities

Analyze the following Node.js/Express code for security flaws:

```javascript
const express = require('express');
const mysql = require('mysql');
const app = express();

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password123',
  database: 'app_db'
});

app.use(express.json());

app.post('/login', (req, res) => {
  const { username, password } = req.body;
  const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
  connection.query(query, (err, results) => {
    if (results.length > 0) {
      res.json({ token: results[0].id + '_secret' });
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  });
});

app.get('/user/:id', (req, res) => {
  const query = `SELECT * FROM users WHERE id = ${req.params.id}`;
  connection.query(query, (err, results) => {
    if (err) throw err;
    res.json(results[0]);
  });
});

app.get('/search', (req, res) => {
  res.send(`<h1>Search results for: ${req.query.q}</h1>`);
});

app.listen(3000, () => console.log('Server running on port 3000'));
```

Issues intentionally present:
- SQL Injection in `/login` and `/user/:id`
- Hardcoded database credentials
- Weak token generation (predictable, no JWT)
- XSS vulnerability in `/search`
- No input validation or sanitization
- No rate limiting
- No HTTPS enforcement
- Error details exposed to client (`throw err`)
