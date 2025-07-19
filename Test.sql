#1
SELECT first_name, last_name
FROM employees;

#2 Знайди всіх працівників з зарплатою понад 10000.
SELECT *
FROM employees
WHERE salary > 10000;

#3 Покажи імена та дати найму працівників, що були найняті до 2005 року.
SELECT *
FROM employees
WHERE hire_date < '2000.01.01';

#4 Виведи імена та ID працівників, у яких менеджер не призначений.
SELECT first_name, last_name, manager_id
FROM employees
where manager_id is null;

#5 Знайди максимальну зарплату серед усіх працівників.
SELECT MAX(salary)
FROM employees;

#6 Знайди імена та назви відділів працівників, які працюють у відділі з ID = 50.
SELECT e.last_name, d.department_name
FROM employees e
         join departments d on d.department_id = e.department_id
where d.department_id = 50;

#7 Виведи кількість працівників у кожному відділі.
SELECT d.department_name, COUNT(*) as Count_
FROM employees e
         right join departments d on d.department_id = e.department_id
GROUP BY d.department_id;

SELECT d.department_name, e.last_name
FROM employees e
         right join departments d on d.department_id = e.department_id;

#8 Покажи середню зарплату по кожній посаді (job_title).
SELECT job_title, AVG(e.salary) as SALARY
FROM employees e
         JOIN jobs j ON e.job_id = j.job_id
GROUP BY j.job_id;

#9 Знайди працівників, які працюють в одній країні, але в різних містах.

SELECT c.country_id
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
         JOIN locations l ON d.location_id = l.location_id
         JOIN countries c ON l.country_id = c.country_id
GROUP BY c.country_id;
;

SELECT l.city
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
         JOIN locations l ON d.location_id = l.location_id
GROUP BY l.city;
;

SELECT c.country_id, l.city, e.last_name, e.first_name
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
         JOIN locations l ON d.location_id = l.location_id
         JOIN countries c ON l.country_id = c.country_id
;

SELECT c.country_id
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
         JOIN locations l ON d.location_id = l.location_id
         JOIN countries c ON l.country_id = c.country_id
GROUP BY c.country_id
HAVING COUNT(DISTINCT l.city) > 1;


SELECT e.first_name, e.last_name, c.country_id, l.city
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
         JOIN locations l ON d.location_id = l.location_id
         JOIN countries c ON l.country_id = c.country_id
WHERE c.country_id IN (SELECT c.country_id
                       FROM employees e
                                JOIN departments d ON e.department_id = d.department_id
                                JOIN locations l ON d.location_id = l.location_id
                                JOIN countries c ON l.country_id = c.country_id
                       GROUP BY c.country_id
                       HAVING COUNT(DISTINCT l.city) > 1);

#10 Виведи список країн, де немає жодного відділу.
SELECT c.country_id, c.country_name
FROM countries c
         LEFT JOIN locations l ON c.country_id = l.country_id
         LEFT JOIN departments d ON l.location_id = d.location_id
         LEFT JOIN employees e on d.department_id = e.department_id
WHERE d.department_id IS NULL;

SELECT c.country_id
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
         JOIN locations l ON d.location_id = l.location_id
         JOIN countries c ON l.country_id = c.country_id
WHERE d.department_id IS NULL;
# Важкий рівень (5 задач)
#11 Знайди всіх працівників, чия зарплата вища за середню зарплату у їхньому відділі.


SELECT first_name, last_name, salary, department_id
FROM employees e
WHERE salary > (SELECT AVG(salary)
                FROM employees
                WHERE department_id = e.department_id);

SELECT first_name, last_name, salary, department_id
FROM (SELECT first_name,
             last_name,
             salary,
             department_id,
             AVG(salary) OVER (PARTITION BY department_id) AS avg_salary
      FROM employees) as sub
WHERE salary > avg_salary;

#12 Покажи найнятого останнім працівника в кожному відділі.


SELECT first_name, last_name, hire_date, department_id
FROM employees e
WHERE hire_date = (SELECT MAX(hire_date)
                   FROM employees
                   WHERE department_id = e.department_id);

SELECT first_name, last_name, hire_date, department_id
FROM (SELECT first_name,
             last_name,
             hire_date,
             department_id,
             MAX(hire_date) OVER (PARTITION BY department_id) AS hire_date_
      FROM employees) as sub
WHERE hire_date = hire_date_;

#13 Виведи імена працівників, які мають ту ж посаду, що й працівник з ID = 104.
SELECT first_name,
       last_name,
       job_id
FROM employees
WHERE job_id = (SELECT job_id FROM employees WHERE employee_id = 104);

# Альтернатива з JOIN (не обов'язкова, просто як варіант)
SELECT e.first_name, e.last_name, e.job_id
FROM employees e
         JOIN employees ref ON ref.employee_id = 104
WHERE e.job_id = ref.job_id;

#14 Знайди назви відділів, де працює більше працівників, ніж у середньому по всіх відділах.

SELECT d.department_name, COUNT(e.employee_id) AS emp_count
FROM departments d
         LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) > (SELECT AVG(emp_count)
                               FROM (SELECT COUNT(e.employee_id) AS emp_count
                                     FROM departments d
                                              LEFT JOIN employees e ON d.department_id = e.department_id
                                     GROUP BY d.department_id) AS sub);

#15 Зроби запит, який виведе ієрархію працівник-менеджер (self join).
