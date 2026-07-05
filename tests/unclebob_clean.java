# Clean Test Input: UNCLEBOB — Clean Java Code

Analyze the following Java class. It is intentionally clean and well-designed:

```java
import java.sql.*;
import java.util.*;
import java.util.logging.Logger;

public class UserService {
    private static final Logger logger = Logger.getLogger(UserService.class.getName());
    private static final double BONUS_ELIGIBILITY_THRESHOLD = 50000.0;
    private static final double BONUS_RATE = 0.10;

    private final DataSource dataSource;
    private final EmailService emailService;

    public UserService(DataSource dataSource, EmailService emailService) {
        this.dataSource = dataSource;
        this.emailService = emailService;
    }

    public void onboardUser(String name, String email, double salary) {
        validateInput(name, email);
        User user = new User(name, email, salary);
        saveUser(user);
        emailService.sendWelcomeEmail(email, name);
        logger.info("Onboarded user: " + user.getId());
    }

    public List<User> findActiveUsers() {
        String sql = "SELECT id, name, email, salary, created_at FROM users WHERE active = true";
        List<User> users = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            logger.severe("Database error: " + e.getMessage());
            throw new UserRepositoryException("Failed to fetch active users", e);
        }
        return users;
    }

    public double calculateTotalBonus(List<User> users) {
        return users.stream()
            .filter(u -> u.getSalary() > BONUS_ELIGIBILITY_THRESHOLD)
            .mapToDouble(u -> u.getSalary() * BONUS_RATE)
            .sum();
    }

    private void validateInput(String name, String email) {
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Name must not be empty");
        }
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email address");
        }
    }

    private void saveUser(User user) {
        String sql = "INSERT INTO users (name, email, salary) VALUES (?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setDouble(3, user.getSalary());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    user.setId(keys.getInt(1));
                }
            }
        } catch (SQLException e) {
            logger.severe("Database error: " + e.getMessage());
            throw new UserRepositoryException("Failed to save user", e);
        }
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User(
            rs.getString("name"),
            rs.getString("email"),
            rs.getDouble("salary")
        );
        user.setId(rs.getInt("id"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }
}

class User {
    private int id;
    private final String name;
    private final String email;
    private final double salary;
    private Timestamp createdAt;

    public User(String name, String email, double salary) {
        this.name = name;
        this.email = email;
        this.salary = salary;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public double getSalary() { return salary; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}

class UserRepositoryException extends RuntimeException {
    public UserRepositoryException(String message, Throwable cause) {
        super(message, cause);
    }
}

interface EmailService {
    void sendWelcomeEmail(String email, String name);
}
```

Clean code characteristics:
- Small, focused methods (single responsibility)
- Clear, descriptive naming
- Proper use of try-with-resources
- Dependency injection via constructor
- Typed domain object instead of Map
- Named constants instead of magic numbers
- Proper exception handling (no silent swallowing)
- Stream API for collection operations
