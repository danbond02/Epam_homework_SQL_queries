#1

SELECT roles.role, COUNT(employee_project.employee_id) AS number_of_employees 		
FROM employee_project RIGHT JOIN roles ON employee_project.role_id = roles.id
GROUP BY role
ORDER BY number_of_employees DESC;

#2

SELECT roles.role, COUNT(employee_project.employee_id) AS number_of_employees		
FROM employee_project RIGHT JOIN roles ON employee_project.role_id = roles.id
GROUP BY role
HAVING COUNT(employee_project.employee_id) = 0
ORDER BY number_of_employees DESC;

#3

SELECT nt.name, nt.role, COUNT(ep.employee_id) AS number_of_employees   
FROM employee_project AS ep
RIGHT JOIN (
	SELECT p.name, r.role, r.id, p.id AS p_id, p.state
	FROM projects AS p, roles AS r
) AS nt
ON ep.role_id = nt.id AND ep.project_id = nt.p_id
WHERE nt.state = 'open'
GROUP BY nt.name, nt.role
ORDER BY nt.name, nt.role;

#4

SELECT new_table.project_id, new_table.employee_id, COUNT(*) as average_number_of_tasks      
FROM (SELECT project_id, employee_id 
	  FROM tasks 
      INNER JOIN task_employee ON task_employee.task_id = tasks.id
      WHERE state = 'done') new_table
GROUP BY new_table.project_id, new_table.employee_id
ORDER BY new_table.project_id, new_table.employee_id;

#5

SELECT name, DATEDIFF(current_date(), creation_date) AS duration_in_days, state		
FROM projects 
WHERE state = 'open'
UNION ALL
SELECT projects.name, DATEDIFF(closed_projects.close_date, projects.creation_date), state
FROM projects INNER JOIN closed_projects ON projects.id = closed_projects.project_id;

#6

WITH NonClosedTasks AS (										
SELECT te.employee_id, COUNT(te.task_id) AS non_closed_tasks	#find all non closed tasks	
FROM task_employee AS te									 
WHERE change_date = (					#if status at the time of the last change is 'need work' then task is non closed
	SELECT MAX(change_date) 
	FROM task_employee
    WHERE task_employee.task_id= te.task_id
	GROUP BY task_id
)
AND state = 'need work'
GROUP BY te.employee_id
),
ALLEmployees AS(					#make join with 'employees' table to get employees with 0 non closed tasks if such exist
SELECT e.name, 					#also if the employee has not yet taken any tasks, then the number of non closed tasks is also 0 
CASE
	WHEN nct.non_closed_tasks IS NULL THEN 0
    ELSE nct.non_closed_tasks
END AS non_closed_tasks
FROM employees AS e
LEFT JOIN NonClosedTasks AS nct ON e.id =nct.employee_id
)
SELECT * 						#choose a person with a minimum number of non closed tasks
FROM ALLEmployees				
WHERE non_closed_tasks = (
	SELECT MIN(non_closed_tasks)
    FROM ALLEmployees
);

#7

WITH NonCLosedTasks AS(											
SELECT te.employee_id, COUNT(te.task_id) AS non_closed_tasks	#find all non closed tasks with failed deadlines
FROM task_employee AS te
INNER JOIN tasks ON tasks.id = te.task_id									 
WHERE change_date = (					#if status at the time of the last change is 'need work' then task is non closed
	SELECT MAX(change_date) 
	FROM task_employee
    WHERE task_employee.task_id= te.task_id
	GROUP BY task_id
)
AND state = 'need work'
AND DATEDIFF(current_date(), tasks.deadline) > 0
GROUP BY te.employee_id
)
SELECT e.name, nct.non_closed_tasks 
FROM NonClosedTasks AS nct
RIGHT JOIN employees AS e
ON e.id = nct.employee_id
WHERE nct.non_closed_tasks = (
		SELECT MAX(non_closed_tasks)
		FROM NonClosedTasks
);

#8

WITH NonCLosedTasks AS (											
SELECT te.task_id						#find all non closed tasks
FROM task_employee AS te								 
WHERE change_date = (					#if status at the time of the last change is 'need work' then task is non closed
	SELECT MAX(change_date) 
	FROM task_employee
    WHERE task_employee.task_id= te.task_id
	GROUP BY task_id
)
AND state = 'need work'
)
UPDATE tasks SET deadline= deadline + 5
WHERE id IN ( SELECT * FROM NonClosedTasks);

#9

WITH task9 AS (										
SELECT tasks.project_id , te.task_id, te.state
FROM tasks INNER JOIN task_employee AS te
ON tasks.id = te.task_id
WHERE  (											#if there is only 1 entry with such task_id in the table, it means that it was opened but not started
	SELECT COUNT(te.state)	
    FROM task_employee
    WHERE task_employee.task_id = te.task_id
    GROUP BY task_employee.task_id
) = 1)
SELECT p.name, COUNT(task9.task_id) AS not_started_tasks
FROM projects AS p 
LEFT JOIN task9 ON p.id = task9.project_id
GROUP BY p.name;

#10

CREATE VIEW tasks_state AS
	SELECT tasks.id, tasks.project_id, 			#Creating a VIEW for Task 10 with information about accepted or not accepted tasks 
	CASE
		WHEN accepted_tasks.state = 'closed' THEN 'closed'
		ELSE 'open'
	END AS state
	FROM tasks LEFT JOIN (
		SELECT te_1.task_id, 'closed' as state
		FROM task_employee AS te_1, task_employee AS te_2
		WHERE te_1.state = 'open' AND te_2.state = 'accepted' AND te_1.task_id = te_2.task_id
	) AS accepted_tasks 
	ON tasks.id = accepted_tasks.task_id;
    
CREATE VIEW projects_to_close AS
SELECT t.project_id
	FROM tasks AS t										#Creating a VIEW for Task 10 with id of projects to close
	INNER JOIN tasks_state AS ts
	ON t.id = ts.id
	GROUP BY t.project_id
	HAVING MAX(CASE ts.state WHEN 'open' THEN 1 ELSE 0 END) = 0;
    
DELIMITER $$
CREATE PROCEDURE close_projects()
BEGIN
	DECLARE a BIGINT DEFAULT 0;
    DECLARE var DATE;
    DECLARE len BIGINT;
    DECLARE id_ BIGINT;
    
    SELECT COUNT(*) INTO len FROM projects_to_close;
    
    new_loop: LOOP
		IF a = len THEN
			LEAVE new_loop;
		END IF;
        
		SELECT * INTO id_ FROM projects_to_close LIMIT 1 OFFSET a;
        SET a = a + 1;
        
		UPDATE projects SET state = 'closed' WHERE id = id_;		#Creating the procedure for task 10 for closing projects
		
		SELECT MAX(te.change_date) INTO var 
		FROM task_employee AS te 
		INNER JOIN tasks ON tasks.id = te.task_id 
		WHERE tasks.project_id = id_;
		
		INSERT INTO closed_projects VALUE (id_, var);
        
	END LOOP new_loop;
END $$
DELIMITER $$

CALL close_projects();

#11

WITH NonClosedTasks AS (										
SELECT te.employee_id, COUNT(te.task_id) AS non_closed_tasks	#The main logic has been taken from the task 6
FROM task_employee AS te									 
WHERE change_date = (								#Firstly we get all non closed tasks
	SELECT MAX(change_date) 
	FROM task_employee
    WHERE task_employee.task_id= te.task_id
	GROUP BY task_id
)
AND state = 'need work'
GROUP BY te.employee_id
)					
SELECT e.name
FROM employees AS e
LEFT JOIN NonClosedTasks AS nct ON e.id =nct.employee_id	#Here we make join with 'emloyees' to get NULL values for employees who have all tasks closed
WHERE non_closed_tasks is NULL

#12

CREATE VIEW NonClosedTasks AS									
SELECT te.employee_id, COUNT(te.task_id) AS non_closed_tasks	#using task 6 script again
FROM task_employee AS te									 
WHERE change_date = (					
	SELECT MAX(change_date) 
	FROM task_employee
    WHERE task_employee.task_id= te.task_id
	GROUP BY task_id
)
AND state = 'need work'
GROUP BY te.employee_id;

CREATE VIEW ALLEmployees AS					
SELECT e.name, 					
CASE
	WHEN nct.non_closed_tasks IS NULL THEN 0
    ELSE nct.non_closed_tasks
END AS non_closed_tasks
FROM employees AS e
LEFT JOIN NonClosedTasks AS nct ON e.id =nct.employee_id;


DELIMITER $$
CREATE PROCEDURE assign_task(IN description_ VARCHAR(255))
BEGIN
	DECLARE var VARCHAR(255);
    DECLARE name_ VARCHAR(255);
    DECLARE id_  BIGINT;
    DECLARE task_id_ BIGINT;
    
    SELECT name INTO name_ FROM allemployees
    WHERE non_closed_tasks = (
		SELECT MIN(non_closed_tasks)
        FROM allemployees
    ) LIMIT 1;
    
    SELECT id INTO id_ FROM employees WHERE name = name_;
    SELECT id INTO task_id_ FROM tasks WHERE description = description_;
    
    INSERT INTO task_employee VALUE(task_id_ ,id_, 'need work', current_date());
END $$
DELIMITER $$

CALL assign_task('Add donations');





