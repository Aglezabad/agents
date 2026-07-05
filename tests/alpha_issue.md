# Test Input: ALPHA — Bug Report

**Title:** User login fails with 500 error when email contains unicode characters

**Body:**
Hi team,

Our users are reporting that they cannot log in when their email contains unicode characters like `ñ` or `é`. The server returns a 500 Internal Server Error instead of a proper validation message.

Steps to reproduce:
1. Go to /login
2. Enter email `test@tëst.com`
3. Enter any password
4. Click "Login"
5. Observe 500 error

Expected: Either successful login or a clear validation error.
Actual: 500 Internal Server Error with no helpful message.

Environment: Production v2.3.1
Browser: Chrome 126

This is affecting ~12 users according to our error tracker.
