-- Q1:

-- Before Insert
DELIMITER //

CREATE TRIGGER project_participation_rules_before_insert
BEFORE INSERT ON Participates
FOR EACH ROW
BEGIN
    -- Administrative staff cannot participate in research projects
    IF EXISTS (
        SELECT 1
        FROM Administrative
        WHERE pid = NEW.pid
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Administrative staff cannot participate in research projects';
    END IF;

    -- A participant with role 'PI' or 'Co-PI' must belong to Academic
    IF NEW.role IN ('PI', 'Co-PI')
       AND NOT EXISTS (
           SELECT 1
           FROM Academic
           WHERE NEW.pid = pid
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'a participant with role ''PI'' or ''Co-PI'' must belong to Academic';
    END IF;

    -- A research project cannot have more than one 'PI'
    IF NEW.role = 'PI'
       AND EXISTS (
           SELECT 1
           FROM Participates
           WHERE role = 'PI'
             AND NEW.projectCode = projectCode
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'a research project cannot have more than one ''PI''';
    END IF;

    -- A research project cannot have more than one 'Co-PI'
    IF NEW.role = 'Co-PI'
       AND EXISTS (
           SELECT 1
           FROM Participates
           WHERE role = 'Co-PI'
             AND NEW.projectCode = projectCode
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'a research project cannot have more than one ''Co-PI''';
    END IF;
END //

-- Before Update
CREATE TRIGGER project_participation_rules_before_update
BEFORE UPDATE ON Participates
FOR EACH ROW
BEGIN
    -- Administrative staff cannot participate in research projects
    IF EXISTS (
        SELECT 1
        FROM Administrative
        WHERE pid = NEW.pid
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Administrative staff cannot participate in research projects';
    END IF;

    -- A participant with role 'PI' or 'Co-PI' must belong to Academic
    IF NEW.role IN ('PI', 'Co-PI')
       AND NOT EXISTS (
           SELECT 1
           FROM Academic
           WHERE NEW.pid = pid
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'a participant with role ''PI'' or ''Co-PI'' must belong to Academic';
    END IF;

    -- A research project cannot have more than one 'PI'
    IF NEW.role = 'PI'
       AND EXISTS (
           SELECT 1
           FROM Participates
           WHERE role = 'PI'
             AND NEW.projectCode = projectCode
             AND NOT (pid = OLD.pid AND projectCode = OLD.projectCode)
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'a research project cannot have more than one ''PI''';
    END IF;

    -- A research project cannot have more than one 'Co-PI'
    IF NEW.role = 'Co-PI'
       AND EXISTS (
           SELECT 1
           FROM Participates
           WHERE role = 'Co-PI'
             AND NEW.projectCode = projectCode
             AND NOT (pid = OLD.pid AND projectCode = OLD.projectCode)
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'a research project cannot have more than one ''Co-PI''';
    END IF;
END //

DELIMITER ;

-- Valid operations:
INSERT INTO Participates (pid, projectCode, role)
VALUES (4, 'P2', 'Co-PI');

UPDATE Participates
SET role = 'Co-PI'
WHERE pid = 4 AND projectCode = 'P2';

-- Enforced rules:
INSERT INTO Participates (pid, projectCode, role)
VALUES (5, 'P1', 'Collaborator');

INSERT INTO Participates (pid, projectCode, role)
VALUES (8, 'P4', 'Co-PI');

INSERT INTO Participates (pid, projectCode, role)
VALUES (2, 'P2', 'PI');

UPDATE Participates
SET role = 'Co-PI'
WHERE pid = 8 AND projectCode = 'P1';


-- Q2:

-- Before Insert
DELIMITER //

CREATE TRIGGER adding_an_equipment_unit_to_a_reservation
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
    DECLARE status1 VARCHAR(20);
    DECLARE start1 TIMESTAMP;
    DECLARE end1 TIMESTAMP;

    SELECT status, plannedStart, plannedEnd
    INTO status1, start1, end1
    FROM Reservation
    WHERE resId = NEW.resId;

    IF status1 = 'Approved'
       AND EXISTS (
           SELECT 1
           FROM Reserves rs
           JOIN Reservation r ON r.resId = rs.resId
           WHERE rs.serialNo = NEW.serialNo
             AND r.status = 'Approved'
             AND r.resId <> NEW.resId
             AND start1 < r.plannedEnd
             AND end1 > r.plannedStart
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Equipment unit is already booked in an overlapping time approved reservation.';
    END IF;
END //

-- Before Update
CREATE TRIGGER approving_or_rescheduling_and_existing_reservation
BEFORE UPDATE ON Reservation
FOR EACH ROW
BEGIN
    IF NEW.status = 'Approved'
       AND EXISTS (
           SELECT 1
           FROM Reserves rs1
           JOIN Reserves rs2 ON rs1.serialNo = rs2.serialNo
           JOIN Reservation r2 ON r2.resId = rs2.resId
           WHERE rs1.resId = NEW.resId
             AND r2.status = 'Approved'
             AND r2.resId <> NEW.resId
             AND NEW.plannedStart < r2.plannedEnd
             AND NEW.plannedEnd > r2.plannedStart
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Equipment unit is already booked in an overlapping time approved reservation';
    END IF;
END //

DELIMITER ;

-- Valid operations:
INSERT INTO Reserves (resId, serialNo)
VALUES (9, 'U1');

UPDATE Reservation
SET status = 'Approved', approverPid = 3
WHERE resId = 13;

-- Enforced rules:
INSERT INTO Reservation (resId, submissionTS, plannedStart, plannedEnd, purpose, status, madeByPid, projectCode, approverPid)
VALUES (16, NOW(), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 2 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 2 DAY), '11:00:00'), 'Overlap booking test', 'Approved', 2, 'P1', 3);

INSERT INTO Reserves (resId, serialNo)
VALUES (16, 'U1');

UPDATE Reservation
SET status = 'Approved', approverPid = 3
WHERE resId = 12;


-- Q3:

-- Before Insert
DELIMITER //

CREATE TRIGGER Enfor_Certification
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
    IF (
        EXISTS (
            SELECT certCode
            FROM EquipmentUnit E
            JOIN Requires R ON R.modelId = E.modelId
            WHERE E.serialNo = NEW.serialNo
        )
        AND (
            SELECT A.madeByPid, B.modelId
            FROM (
                SELECT R.madeByPid
                FROM Reservation R
                WHERE NEW.resId = R.resId
            ) AS A
            CROSS JOIN (
                SELECT E.modelId
                FROM EquipmentUnit E
                WHERE E.serialNo = NEW.serialNo
            ) AS B
        ) NOT IN (
            SELECT Person.pid, EquipmentModel.modelId
            FROM EquipmentModel
            CROSS JOIN Person
            WHERE EXISTS (
                SELECT 1
                FROM Requires
                WHERE Requires.modelId = EquipmentModel.modelId
            )
            AND NOT EXISTS (
                SELECT 1
                FROM Requires
                WHERE Requires.modelId = EquipmentModel.modelId
                  AND NOT EXISTS (
                      SELECT 1
                      FROM Holds
                      WHERE Holds.pid = Person.pid
                        AND Holds.certCode = Requires.certCode
                        AND Holds.expirationDate >= (
                            SELECT R.plannedStart
                            FROM Reservation R
                            WHERE R.resId = NEW.resId
                        )
                  )
            )
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Required certification missing or expired';
    END IF;
END //

DELIMITER ;

-- Valid operations:
INSERT INTO Reserves (resId, serialNo)
VALUES (14, 'U1');

INSERT INTO Reserves (resId, serialNo)
VALUES (14, 'U5');

-- Enforced rules:
INSERT INTO Reserves (resId, serialNo)
VALUES (14, 'U3');

INSERT INTO Reserves (resId, serialNo)
VALUES (15, 'U3');


-- Q4:

-- Before Insert
DELIMITER //

CREATE TRIGGER validate_consumption
BEFORE INSERT ON Consumes
FOR EACH ROW
BEGIN
    DECLARE qtOnHand DECIMAL(12,2);

    IF NEW.quantityUsed <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'quantityUsed must be strictly greater than 0';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Stocks
        WHERE labId = NEW.labId AND consId = NEW.consId
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No stock occurrence exists for this consumable in the specified laboratory';
    END IF;

    SELECT quantityOnHand
    INTO qtOnHand
    FROM Stocks
    WHERE labId = NEW.labId AND consId = NEW.consId;

    IF NEW.quantityUsed > qtOnHand THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Requested quantityUsed exceeds current quantityOnHand in stock';
    END IF;
END //

-- After Insert
CREATE TRIGGER update_stock
AFTER INSERT ON Consumes
FOR EACH ROW
BEGIN
    UPDATE Stocks
    SET quantityOnHand = quantityOnHand - NEW.quantityUsed
    WHERE labId = NEW.labId AND consId = NEW.consId;
END //

DELIMITER ;

-- Valid operations:
SELECT quantityOnHand AS beforeQty
FROM Stocks
WHERE labId = 1 AND consId = 1;

INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (2, 1, 1, 5.00);

SELECT quantityOnHand AS afterQty
FROM Stocks
WHERE labId = 1 AND consId = 1;

-- Enforced rules:
INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (2, 1, 2, -2.00);

INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (2, 3, 3, 1.00);

INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (2, 2, 1, 50.00);


-- Q5:

-- After Insert (a)
DELIMITER //

CREATE TRIGGER maintenance_start
AFTER INSERT ON Maintenance
FOR EACH ROW
BEGIN
    UPDATE EquipmentUnit EQ
    SET EQ.status = 'UnderMaintenance'
    WHERE EQ.serialNo = NEW.serialNo;
END //

-- After Update (b)
CREATE TRIGGER maintenance_resolved
AFTER UPDATE ON Maintenance
FOR EACH ROW
BEGIN
    UPDATE EquipmentUnit EQ
    SET EQ.status = 'InService'
    WHERE EQ.serialNo = NEW.serialNo
      AND OLD.outcome <> 'Resolved'
      AND NEW.outcome = 'Resolved';
END //

DELIMITER ;

-- Test:
SELECT serialNo, status FROM EquipmentUnit WHERE serialNo = 'U2';

INSERT INTO Maintenance VALUES
  ('U2', '2026-11-22 09:00:00', '2026-11-22 14:00:00', 'Corrective', 'Lamp alignment', 200.00, 'InProgress', 6);

SELECT serialNo, status FROM EquipmentUnit WHERE serialNo = 'U2';

UPDATE Maintenance
SET outcome = 'Resolved'
WHERE serialNo = 'U2' AND startTS = '2026-11-22 09:00:00';

SELECT serialNo, status FROM EquipmentUnit WHERE serialNo = 'U2';

-- Q6:

-- Before Insert on Student
DELIMITER //

CREATE TRIGGER CHECK_Student_Emp
BEFORE INSERT ON Student
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM Employee
        WHERE Employee.pid = NEW.pid
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This person is already an employee and cannot be a student at the same time.';
    END IF;
END //

-- Before Insert on Employee
CREATE TRIGGER CHECK_Employee_Stu
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM Student
        WHERE Student.pid = NEW.pid
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This person is already a student and cannot be an employee at the same time.';
    END IF;
END //

-- Before Insert on Faculty
CREATE TRIGGER CHECK_Faculty_Dean
BEFORE INSERT ON Faculty
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM Employee E
        JOIN Employee S ON E.supervisorPid = S.pid
        WHERE E.pid = NEW.pid AND S.position = 'dean'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A faculty member must report to the dean.';
    END IF;
END //

-- Before Insert on Administrative
CREATE TRIGGER CHECK_Administrative_Dean
BEFORE INSERT ON Administrative
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM Employee E
        JOIN Employee S ON E.supervisorPid = S.pid
        WHERE E.pid = NEW.pid AND S.position = 'dean'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'An administrative employee must report to the dean.';
    END IF;
END //

-- Before Update on Employee
CREATE TRIGGER CHECK_Employee_Supervisor
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.supervisorPid <> OLD.supervisorPid
       OR (NEW.supervisorPid IS NULL AND OLD.supervisorPid IS NOT NULL)
       OR (NEW.supervisorPid IS NOT NULL AND OLD.supervisorPid IS NULL)
    THEN
        IF EXISTS (
            SELECT *
            FROM Faculty
            WHERE pid = NEW.pid
        )
        OR EXISTS (
            SELECT *
            FROM Administrative
            WHERE pid = NEW.pid
        )
        THEN
            IF NOT EXISTS (
                SELECT *
                FROM Employee S
                WHERE S.pid = NEW.supervisorPid
                  AND S.position = 'dean'
            ) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Faculty and administrative employees must report to the dean.';
            END IF;
        END IF;
    END IF;
END //

-- Before Insert on Employee
CREATE TRIGGER CHECK_Dean_Insert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.position = 'dean'
       AND NEW.supervisorPid IS NOT NULL
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The dean cannot have a supervisor.';
    END IF;
END //

-- Before Update on Employee
CREATE TRIGGER CHECK_Dean_Update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.position = 'dean'
       AND NEW.supervisorPid IS NOT NULL
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The dean cannot have a supervisor.';
    END IF;
END //

DELIMITER ;

-- Valid operations:
INSERT INTO Person VALUES
(12, 'Yassine', 'Mansouri', 'yassine.mansouri@um6p.ma', 'UM6P', '2026-11-22', NULL);

INSERT INTO Student (pid, program)
VALUES (12, 'BSc');

INSERT INTO Person VALUES
(13, 'Leila', 'Berrada', 'leila.berrada@um6p.ma', 'UM6P', '2026-11-22', NULL);

INSERT INTO Employee VALUES
(13, '0613', 'B-205', 'faculty', 1);

INSERT INTO Academic VALUES (13);

INSERT INTO Faculty VALUES (13);

UPDATE Employee
SET office = 'A-100'
WHERE pid = 1;

UPDATE Employee
SET supervisorPid = 1
WHERE pid = 2;

-- Enforced rules:
INSERT INTO Student (pid, program)
VALUES (2, 'BSc');

INSERT INTO Employee VALUES
(8, '0608', 'C-010', 'technician', 2);

UPDATE Employee
SET supervisorPid = 2
WHERE pid = 1;

UPDATE Employee
SET supervisorPid = 3
WHERE pid = 2;