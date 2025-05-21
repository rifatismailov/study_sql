
-- 🧾 SQL Шпаргалка з поясненнями

-- 🔹 SELECT + WHERE
-- ✅ Виводить усіх працівників, у яких зарплата більше 12000.
SELECT first_name, last_name, salary
FROM employees
WHERE salary > 12000;

-- 🔹 INNER JOIN + фільтр
-- ✅ Показує всіх працівників, які працюють у відділі з id = 90.
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
WHERE d.department_id = 90;

-- 🔹 RIGHT JOIN + COUNT + GROUP BY
-- ✅ Показує, скільки працівників у кожному відділі, включаючи ті, де нікого немає.
SELECT d.department_name, COUNT(*) AS count
FROM employees e
         RIGHT JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id;

-- 🔹 JOIN + AVG
-- ✅ Виводить середню зарплату по кожній посаді.
SELECT j.job_title, AVG(e.salary) AS salary
FROM employees e
         JOIN jobs j ON e.job_id = j.job_id
GROUP BY j.job_title;

-- 🔹 Фільтрація по даті
-- ✅ Показує працівників, яких найняли до 2000 року.
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date < '2000-01-01';

-- ✅ Показує тих, кого найняли після або рівно 1 січня 2000 року.
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date >= '2000-01-01';

-- 🔹 NULL перевірка
-- ✅ Показує працівників без менеджера.
SELECT first_name, last_name
FROM employees
WHERE manager_id IS NULL;

-- 🔹 MAX + підзапит
-- ✅ Максимальна зарплата в компанії.
SELECT MAX(salary) AS max_salary
FROM employees;

-- ✅ Показує, хто отримує максимальну зарплату.
SELECT first_name, last_name, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);

-- 🔹 JOIN через країни
-- ✅ Показує кількість відділів у кожній країні.
SELECT c.country_name, COUNT(d.department_id) AS dep_count
FROM departments d
         JOIN locations l ON d.location_id = l.location_id
         JOIN countries c ON l.country_id = c.country_id
GROUP BY c.country_name;

-- 🔹 Місто + кількість працівників
-- ✅ Кількість працівників у кожному місті.
SELECT l.city, COUNT(e.employee_id) AS employee
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
         JOIN locations l ON d.location_id = l.location_id
GROUP BY l.city;

-- 🔹 CASE + AVG зарплати
-- ✅ Показує середню зарплату по рівнях (low, medium, high).
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

-- 🔹 MAX salary per department
-- ✅ Найвища зарплата в кожному відділі.
SELECT department_id, MAX(salary) AS max_salary
FROM employees
GROUP BY department_id;

-- ✅ Ті відділи, де макс. зарплата більше 10000 і id > 40.
SELECT department_id, max_salary
FROM (
         SELECT department_id, MAX(salary) AS max_salary
         FROM employees
         GROUP BY department_id
         HAVING MAX(salary) > 10000
     ) AS max
WHERE department_id > 40;

-- 🔹 COUNT + CASE + HAVING
-- ✅ Показує скільки працівників кожного рівня зарплати, якщо їх більше 2.
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

-- 🔹 JOIN + CASE + HAVING (назва відділу)
-- ✅ Як вище, але з назвами відділів.
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

-- 🔹 Підзапит з MAX у відділі
-- ✅ Показує працівників з найвищою зарплатою у своєму відділі.
SELECT first_name, last_name, salary, department_id
FROM employees e
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department_id = e.department_id
);

-- 🔹 EXISTS — лише ті, в кого дійсний відділ
-- ✅ Показує працівників, у яких є відповідний запис у таблиці departments.
SELECT first_name, last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM departments d
    WHERE d.department_id = e.department_id
);

-- 🔹 LEFT JOIN
-- ✅ Виводить всіх працівників, навіть якщо у них немає відділу.
SELECT e.first_name, d.department_name
FROM employees e
         LEFT JOIN departments d ON e.department_id = d.department_id;


-- 🔹 Аналітичні функції (MySQL 8+)
-- ✅ Нумерує працівників по зарплаті в межах відділу.
SELECT first_name, salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rank_
FROM employees;

-- ✅ Додає колонку з середньою зарплатою у відділі.
SELECT department_id, salary,
       AVG(salary) OVER (PARTITION BY department_id) AS avg_dep_salary
FROM employees;
