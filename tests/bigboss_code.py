# Test Input: BIGBOSS — SOLID Violations

Analyze the following Python class:

```python
class EmployeeManager:
    def __init__(self, db_connection):
        self.db = db_connection

    def add_employee(self, name, email, salary):
        cursor = self.db.cursor()
        cursor.execute("INSERT INTO employees (name, email, salary) VALUES (?, ?, ?)", (name, email, salary))
        self.db.commit()
        self.send_welcome_email(email, name)
        return cursor.lastrowid

    def calculate_payroll(self, employee_ids):
        results = []
        for eid in employee_ids:
            cursor = self.db.cursor()
            cursor.execute("SELECT salary FROM employees WHERE id = ?", (eid,))
            row = cursor.fetchone()
            tax = row[0] * 0.25
            bonus = row[0] * 0.10 if row[0] > 50000 else 0
            results.append({"id": eid, "net": row[0] - tax + bonus})
        return results

    def generate_report(self, filename):
        cursor = self.db.cursor()
        cursor.execute("SELECT * FROM employees")
        rows = cursor.fetchall()
        with open(filename, "w") as f:
            f.write("Name,Email,Salary\n")
            for row in rows:
                f.write(f"{row[0]},{row[1]},{row[2]}\n")

    def send_welcome_email(self, email, name):
        import smtplib
        server = smtplib.SMTP("smtp.example.com")
        server.sendmail("hr@example.com", [email], f"Welcome {name}!")
        server.quit()

    def export_to_xml(self, filename):
        cursor = self.db.cursor()
        cursor.execute("SELECT * FROM employees")
        rows = cursor.fetchall()
        with open(filename, "w") as f:
            f.write("<employees>\n")
            for row in rows:
                f.write(f"  <employee name='{row[0]}' email='{row[1]}' salary='{row[2]}' />\n")
            f.write("</employees>\n")
```
