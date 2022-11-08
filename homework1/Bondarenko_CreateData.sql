INSERT INTO `employees` VALUES 
(DEFAULT, 'Daniil Bondarenko', current_date(), '2022-08-10', 26, 20000),
(DEFAULT, 'Maks Kuhlenko', current_date()-10, '2022-02-10', 12, 17000),
(DEFAULT, 'Daria Lavrinenko', current_date()-12, '2022-03-17', 27, 20000),
(DEFAULT, 'Dasha Ivanova', current_date()-6, '2021-12-5', 15, 17000),
(DEFAULT, 'Pasha Petrov', current_date()-7, '2022-01-9', 13, 20000);

INSERT INTO `projects` VALUES 
(DEFAULT, 'Taxi service',  '2021-06-10', 'Online car call service', 'open'),
(DEFAULT, 'Post app',  '2022-08-9', 'Service for sending and receiving electronic mails', 'open'),
(DEFAULT, 'Dating app', '2020-05-17', 'Service for dating', 'closed'),
(DEFAULT, 'IOS Game', '2021-11-8', 'Puzzle game for IOS devices', 'closed'),
(DEFAULT, 'Music app', '2022-03-10', 'Digital music service that gives access to millions of songs', 'open');

INSERT INTO `employee_project` VALUES
(1, 2, 3), (2, 2, 6), (3, 2, 7), (4, 3, 6), 
(4, 1, 4), (5, 1, 5), (5, 2, 5), 
(1, 1, 1), (1, 3, 1), (4, 2, 4), (3, 1, 7);

INSERT INTO `closed_projects` VALUES (3, current_date() - 3), (4, current_date() - 10);

INSERT INTO `tasks` VALUES
(DEFAULT, 1, 'Add button \'Change route\'', current_date()),
(DEFAULT, 2, 'Add emoji to the mails', current_date()-1),
(DEFAULT, 5, 'Add palylist of the day', current_date()-2),
(DEFAULT, 1, 'Add discounts for regular users', current_date()-3),
(DEFAULT, 5, 'Increase trial period for new users', current_date()-4),
(DEFAULT, 1, "Add EXIT button", '2022-08-27'),
(DEFAULT, 5, "Add donations", '2022-08-22');

INSERT INTO `task_employee` VALUES
(2, 3, 'open', current_date()-4), (2, 4, 'done', current_date()),
(2, 3, 'accepted', current_date()), (1, 3, 'open', current_date()-10),
(4, 3, 'open', current_date()-12), (4, 1, 'done', current_date()),
(2, 4, 'need work', current_date()-4),
(4, 1, 'done', current_date()-12),
(1, 4, 'need work', current_date()-1),
(1, 4, 'done', current_date()),
(3, 4, 'open', current_date()-5),
(3, 1, 'need work', current_date()-5),
(5, 4, 'open', current_date()-5),
(5, 1, 'need work', current_date()-5),
(6, 3, "open", '2022-08-17'),
(7, 4, "open", '2022-08-17');

INSERT INTO `roles`(role) VALUES
('business analyst'), ('project manager'), 
('QA engineer'), ('software developer'), 
('product manager'), ('architect'), ('team lead');


