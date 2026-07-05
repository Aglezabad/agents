# Test Input: UNCLEBOB — Clean Code Violations

Analyze the following Java class for clean code issues:

```java
public class UserMgr {
    private String dbUrl = "jdbc:mysql://localhost:3306/mydb";
    private String dbUser = "admin";
    private String dbPass = "admin123";
    
    public void doEverything(int a, String b, boolean c, double d, List<String> e) {
        // Validate
        if (a <= 0) {
            throw new IllegalArgumentException("bad a");
        }
        if (b == null || b.isEmpty()) {
            throw new IllegalArgumentException("bad b");
        }
        if (e == null) {
            throw new IllegalArgumentException("bad e");
        }
        
        // Connect to DB
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            
            // Do stuff
            String sql = "SELECT * FROM users WHERE id = ? AND active = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, a);
            ps.setBoolean(2, c);
            ResultSet rs = ps.executeQuery();
            
            // Process results
            List<Map<String, Object>> results = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("name", rs.getString("name"));
                row.put("email", rs.getString("email"));
                row.put("salary", rs.getDouble("salary"));
                row.put("created", rs.getTimestamp("created"));
                results.add(row);
            }
            
            // Send email
            for (Map<String, Object> r : results) {
                String email = (String) r.get("email");
                String name = (String) r.get("name");
                sendEmail(email, "Hello " + name);
            }
            
            // Calculate bonus
            double bonus = 0;
            for (Map<String, Object> r : results) {
                double salary = (Double) r.get("salary");
                if (salary > 50000) {
                    bonus += salary * d;
                }
            }
            
            // Log
            System.out.println("Processed " + results.size() + " users, total bonus: " + bonus);
            
            // Update DB
            String updateSql = "UPDATE users SET last_processed = NOW() WHERE id = ?";
            PreparedStatement updatePs = conn.prepareStatement(updateSql);
            updatePs.setInt(1, a);
            updatePs.executeUpdate();
            
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }
    
    private void sendEmail(String to, String body) {
        // ... email sending logic ...
    }
    
    public void x(String y, String z) {
        if (y.equals(z)) {
            System.out.println("same");
        } else {
            System.out.println("different");
        }
    }
}
```

Issues intentionally present:
- God class / long method (`doEverything` does validation, DB access, email, calculation, logging, updates)
- Poor naming (`UserMgr`, `doEverything`, `a`, `b`, `c`, `d`, `e`, `x`, `y`, `z`)
- Feature envy / primitive obsession (using Map instead of User object)
- Hardcoded credentials
- No separation of concerns
- Silent failure (`ex.printStackTrace()`)
- Magic values and mixed abstraction levels
