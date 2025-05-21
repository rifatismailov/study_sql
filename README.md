## 🧾 SQL Шпаргалка з поясненнями

Цей файл містить пояснення до прикладів SQL-запитів, які охоплюють:
- SELECT
- JOIN (INNER, LEFT, RIGHT)
- GROUP BY + HAVING
- Підзапити (в т.ч. з MAX, AVG)
- EXISTS, CASE
- Агрегати, фільтрація, сортування
- Підзапити
- Аналітичні функції (MySQL 8+)

🔁 Можна продовжити з UNION, CTE (WITH), індексацією, NULL-логікою — тільки скажи!


---

### 🔹 SELECT + WHERE

```sql
SELECT first_name, last_name, salary
FROM employees
WHERE salary > 12000;
```

✅ Пояснення: Виводить усіх працівників, у яких зарплата більше 12000.

---

### 🔹 INNER JOIN + фільтр

```sql
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.department_id = 90;
```

✅ Пояснення: Показує всіх працівників, які працюють у відділі з id = 90.

---

### 🔹 RIGHT JOIN + COUNT + GROUP BY

```sql
SELECT d.department_name, COUNT(*) AS count
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id;
```

✅ Пояснення: Показує, скільки працівників у кожному відділі, включаючи ті відділи, де нікого немає (через RIGHT JOIN).

---

### 🔹 JOIN + AVG

```sql
SELECT j.job_title, AVG(e.salary) AS salary
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
GROUP BY j.job_title;
```

✅ Пояснення: Виводить середню зарплату по кожній посаді (job title).

---

### 🔹 Фільтрація по даті

```sql
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date < '2000-01-01';
```

✅ Пояснення: Показує працівників, яких найняли до 2000 року.

```sql
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date >= '2000-01-01';
```

✅ Пояснення: Показує тих, кого найняли після або рівно 1 січня 2000 року.

---

### 🔹 NULL перевірка

```sql
SELECT first_name, last_name
FROM employees
WHERE manager_id IS NULL;
```

✅ Пояснення: Показує працівників без менеджера (тобто керівників).

---

### 🔹 MAX + підзапит

```sql
SELECT MAX(salary) AS max_salary
FROM employees;
```

✅ Пояснення: Максимальна зарплата в компанії.

```sql
SELECT first_name, last_name, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);
```

✅ Пояснення: Показує, хто отримує максимальну зарплату.

---

### 🔹 JOIN через країни

```sql
SELECT c.country_name, COUNT(d.department_id) AS dep_count
FROM departments d
JOIN locations l ON d.location_id = l.location_id
JOIN countries c ON l.country_id = c.country_id
GROUP BY c.country_name;
```

✅ Пояснення: Показує кількість відділів у кожній країні.

---

### 🔹 Місто + кількість працівників

```sql
SELECT l.city, COUNT(e.employee_id) AS employee
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
GROUP BY l.city;
```

✅ Пояснення: Кількість працівників у кожному місті.

---

### 🔹 CASE + AVG зарплати

```sql
SELECT AVG(salary),
       CASE
           WHEN salary < 5000 THEN 'Low'
           WHEN salary BETWEEN 5000 AND 10000 THEN 'Medium'
           ELSE 'High'
       END AS salary_level
FROM employees
GROUP BY CASE
           WHEN salary < 5000 THEN 'Low'
           WHEN salary BETWEEN 5000 AND 10000 THEN 'Medium'
           ELSE 'High'
         END;
```

✅ Пояснення: Показує середню зарплату по рівнях (low, medium, high).

---

### 🔹 MAX salary per department

```sql
SELECT department_id, MAX(salary) AS max_salary
FROM employees
GROUP BY department_id;
```

✅ Пояснення: Найвища зарплата в кожному відділі.

```sql
SELECT department_id, max_salary
FROM (
    SELECT department_id, MAX(salary) AS max_salary
    FROM employees
    GROUP BY department_id
    HAVING MAX(salary) > 10000
) AS max
WHERE department_id > 40;
```

✅ Пояснення: Ті відділи, де макс. зарплата більше 10000, і їх id > 40.

---

### 🔹 COUNT + CASE + HAVING

```sql
SELECT department_id,
       CASE
           WHEN salary <= 5000 THEN 'low'
           WHEN salary <= 10000 THEN 'mid'
           ELSE 'high'
       END AS salary_level,
       COUNT(*) AS employee_count
FROM employees
GROUP BY department_id,
         CASE
           WHEN salary <= 5000 THEN 'low'
           WHEN salary <= 10000 THEN 'mid'
           ELSE 'high'
         END
HAVING COUNT(*) > 2;
```

✅ Пояснення: Показує, скільки працівників кожного рівня зарплати у відділі, якщо їх більше 2.

---

### 🔹 JOIN + CASE + HAVING (назва відділу)

```sql
SELECT d.department_name,
       CASE
           WHEN e.salary <= 5000 THEN 'low'
           WHEN e.salary <= 10000 THEN 'mid'
           ELSE 'high'
       END AS salary_level,
       COUNT(*) AS employee_count
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name,
         CASE
           WHEN e.salary <= 5000 THEN 'low'
           WHEN e.salary <= 10000 THEN 'mid'
           ELSE 'high'
         END
HAVING COUNT(*) > 2;
```

✅ Пояснення: Як вище, але з назвами відділів.

---

### 🔹 Підзапит з MAX у відділі

```sql
SELECT first_name, last_name, salary, department_id
FROM employees e
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department_id = e.department_id
);
```

✅ Пояснення: Показує працівників, які мають найвищу зарплату у своєму відділі.

---

### 🔹 EXISTS — лише ті, в кого дійсний відділ

```sql
SELECT first_name, last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM departments d
    WHERE d.department_id = e.department_id
);
```

✅ Пояснення: Показує працівників, у яких є відповідний запис у таблиці `departments`.

---

### 🔹 Всі працівники + LEFT JOIN відділів

```sql
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
```

✅ Пояснення: Виводить всіх працівників, навіть якщо у них немає відділу (NULL department\_name).

---

## 🔍 Додаткові категорії:

### 🔸 Агрегатні функції:

* `COUNT(*)`: підрахунок рядків
* `AVG(salary)`: середнє значення
* `SUM(salary)`: сума
* `MIN(salary)`, `MAX(salary)`: мінімум і максимум

### 🔸 Фільтрація:

* `WHERE`: до агрегатів та групування
* `HAVING`: після `GROUP BY`, для фільтрації груп

### 🔸 Сортування:

```sql
ORDER BY salary DESC;
```

* сортує по спадній

```sql
ORDER BY department_name ASC, salary DESC;
```

* спочатку по відділу, потім по зарплаті

### 🔸 Підзапити:

```sql
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

* знайти всіх, хто заробляє більше за середнє

### 🔸 Аналітичні функції (у MySQL 8+):

```sql
SELECT first_name, salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rank
FROM employees;
```

✅ Пояснення: Нумерує працівників по зарплаті в межах відділу

```sql
SELECT department_id, salary,
       AVG(salary) OVER (PARTITION BY department_id) AS avg_dep_salary
FROM employees;
```

✅ Пояснення: Додає колонку з середньою зарплатою у відділі (без `GROUP BY`)

---

🔁 Можна продовжити з UNION, CTE (WITH), індексацією, NULL-логікою — тільки скажи!
