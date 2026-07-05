# Clean Test Input: BIGBOSS — SOLID-Compliant Code

Analyze the following Python code. It is intentionally designed to follow SOLID principles:

```python
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import List, Protocol


@dataclass
class Employee:
    id: int
    name: str
    email: str
    salary: float


class EmployeeRepository(ABC):
    @abstractmethod
    def save(self, employee: Employee) -> int:
        pass

    @abstractmethod
    def find_by_id(self, employee_id: int) -> Employee | None:
        pass

    @abstractmethod
    def find_all(self) -> List[Employee]:
        pass


class SqlEmployeeRepository(EmployeeRepository):
    def __init__(self, db_connection):
        self.db = db_connection

    def save(self, employee: Employee) -> int:
        cursor = self.db.cursor()
        cursor.execute(
            "INSERT INTO employees (name, email, salary) VALUES (?, ?, ?)",
            (employee.name, employee.email, employee.salary)
        )
        self.db.commit()
        return cursor.lastrowid

    def find_by_id(self, employee_id: int) -> Employee | None:
        cursor = self.db.cursor()
        cursor.execute("SELECT id, name, email, salary FROM employees WHERE id = ?", (employee_id,))
        row = cursor.fetchone()
        if row:
            return Employee(*row)
        return None

    def find_all(self) -> List[Employee]:
        cursor = self.db.cursor()
        cursor.execute("SELECT id, name, email, salary FROM employees")
        return [Employee(*row) for row in cursor.fetchall()]


class NotificationService(Protocol):
    def send(self, recipient: str, message: str) -> None:
        ...


class EmailNotificationService:
    def __init__(self, smtp_host: str):
        self.smtp_host = smtp_host

    def send(self, recipient: str, message: str) -> None:
        import smtplib
        server = smtplib.SMTP(self.smtp_host)
        server.sendmail("hr@example.com", [recipient], message)
        server.quit()


class PayrollCalculator:
    TAX_RATE = 0.25
    BONUS_THRESHOLD = 50000.0
    BONUS_RATE = 0.10

    def calculate_net(self, gross_salary: float) -> float:
        tax = gross_salary * self.TAX_RATE
        bonus = gross_salary * self.BONUS_RATE if gross_salary > self.BONUS_THRESHOLD else 0.0
        return gross_salary - tax + bonus


class ReportGenerator(ABC):
    @abstractmethod
    def generate(self, employees: List[Employee], filename: str) -> None:
        pass


class CsvReportGenerator(ReportGenerator):
    def generate(self, employees: List[Employee], filename: str) -> None:
        with open(filename, "w") as f:
            f.write("Name,Email,Salary\n")
            for emp in employees:
                f.write(f"{emp.name},{emp.email},{emp.salary}\n")


class EmployeeService:
    def __init__(
        self,
        repository: EmployeeRepository,
        payroll: PayrollCalculator,
        notifier: NotificationService,
        report_generator: ReportGenerator
    ):
        self.repository = repository
        self.payroll = payroll
        self.notifier = notifier
        self.report_generator = report_generator

    def onboard(self, employee: Employee) -> int:
        employee_id = self.repository.save(employee)
        self.notifier.send(employee.email, f"Welcome {employee.name}!")
        return employee_id

    def process_payroll(self, employee_ids: List[int]) -> List[dict]:
        results = []
        for eid in employee_ids:
            emp = self.repository.find_by_id(eid)
            if emp:
                net = self.payroll.calculate_net(emp.salary)
                results.append({"id": eid, "net": net})
        return results

    def generate_report(self, filename: str) -> None:
        employees = self.repository.find_all()
        self.report_generator.generate(employees, filename)
```
