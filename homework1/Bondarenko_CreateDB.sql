CREATE TABLE `employees`(
	id BIGINT AUTO_INCREMENT NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    birth_date DATE NOT NULL,
    hire_date DATE NOT NULL,
    months_of_work_experience BIGINT NOT NULL,
    salary FLOAT NOT NULL,
    CONSTRAINT em_pk PRIMARY KEY (id)
);

CREATE TABLE `projects`(
	id BIGINT AUTO_INCREMENT NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL UNIQUE,
    creation_date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
    state ENUM ('open', 'closed') NOT NULL,
    CONSTRAINT pr_pk PRIMARY KEY (id)
);

CREATE TABLE `employee_project`(
	employee_id BIGINT NOT NULL,
    project_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    CONSTRAINT ep_pk PRIMARY KEY (employee_id, project_id), 
    CONSTRAINT ep_fk_1 FOREIGN KEY (employee_id) REFERENCES `employees`(id),
    CONSTRAINT ep_fk_2 FOREIGN KEY (project_id) REFERENCES `projects`(id),
    CONSTRAINT ep_fk_3 FOREIGN KEY (role_id) REFERENCES `roles`(id)
);
CREATE TABLE `tasks`(
	id BIGINT AUTO_INCREMENT NOT NULL UNIQUE,
    project_id BIGINT NOT NULL,
    description VARCHAR(255) NOT NULL,
    deadline DATE NOT NULL,
    CONSTRAINT ts_pk PRIMARY KEY (id), 
    CONSTRAINT ts_fk FOREIGN KEY (project_id) REFERENCES `projects`(id)
);
CREATE TABLE `task_employee`(
	task_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    state ENUM('open', 'done', 'need work', 'accepted') NOT NULL,
    change_date DATE NOT NULL,
    CONSTRAINT ts_em_pk PRIMARY KEY (task_id, employee_id, change_date), 
    CONSTRAINT ts_em_fk_1 FOREIGN KEY (employee_id) REFERENCES `employees`(id),
    CONSTRAINT ts_em_fk_2 FOREIGN KEY (task_id) REFERENCES `tasks`(id)
);

CREATE TABLE `closed_projects`(
	project_id BIGINT NOT NULL UNIQUE,
    close_date DATE NOT NULL,
    CONSTRAINT cp_pk PRIMARY KEY (project_id), 
    CONSTRAINT cp_fk FOREIGN KEY (project_id) REFERENCES `projects`(id)
);

CREATE TABLE `roles`(
	id BIGINT AUTO_INCREMENT NOT NULL UNIQUE,
    role VARCHAR(255) NOT NULL,
    CONSTRAINT cp_pk PRIMARY KEY (id)
);
