-- Domain constraints:

-- 1) Student program
ALTER TABLE Student
ADD CONSTRAINT CHK_Student_Program
CHECK (program IN ('BSc', 'BEng', 'MSc', 'PhD'));

-- rejected statement demonstrating it:
UPDATE Student
SET program = 'Medecine'
WHERE pid = 8;

-- 2) Employee position
ALTER TABLE Employee
ADD CONSTRAINT CHK_Employee_Position
CHECK (position IN (
    'dean', 'faculty', 'scientist', 'postdoc',
    'secretary', 'accountant', 'technician',
    'engineer', 'lab manager'
));

-- rejected statement demonstrating it:
UPDATE Employee
SET position = 'student'
WHERE pid = 1;

-- 3) Research project status
ALTER TABLE ResearchProject
ADD CONSTRAINT CHK_ResearchProject_status
CHECK (status IN (
    'Proposed', 'Active', 'Suspended',
    'Completed', 'Cancelled'
));

-- rejected statement demonstrating it:
UPDATE ResearchProject
SET status = 'InProgress'
WHERE code = 'P1';

-- 4) Participation role
ALTER TABLE Participates
ADD CONSTRAINT CHK_Participates_Role
CHECK (role IN ('PI', 'Co-PI', 'Collaborator'));

-- rejected statement demonstrating it:
UPDATE Participates
SET role = 'Assistant'
WHERE pid = 8
  AND projectCode = 'P1';

-- 5) Equipment status
ALTER TABLE EquipmentUnit
ADD CONSTRAINT CHK_Equipment_Status
CHECK (status IN (
    'InService', 'UnderMaintenance',
    'OutOfService', 'Retired'
));

-- rejected statement demonstrating it:
UPDATE EquipmentUnit
SET status = 'Broken'
WHERE serialNo = 'U1';

-- 6) Reservation status
ALTER TABLE Reservation
ADD CONSTRAINT CHK_Reservation_Status
CHECK (status IN (
    'Pending', 'Approved', 'Rejected',
    'Cancelled', 'Completed'
));

-- rejected statement demonstrating it:
UPDATE Reservation
SET status = 'Waiting'
WHERE resId = 1;

-- 7) Maintenance type
ALTER TABLE Maintenance
ADD CONSTRAINT CHK_Maintenance_Type
CHECK (type IN ('Preventive', 'Corrective'));

-- rejected statement demonstrating it:
UPDATE Maintenance
SET type = 'Emergency'
WHERE serialNo = 'U6'
  AND startTS = '2026-10-01 09:00:00';

-- 8) Maintenance outcome
ALTER TABLE Maintenance
ADD CONSTRAINT CHK_Maintenance_Outcome
CHECK (outcome IN ('Resolved', 'FollowUpRequired'));

-- rejected statement demonstrating it:
UPDATE Maintenance
SET outcome = 'InProgress'
WHERE serialNo = 'U6'
  AND startTS = '2026-10-01 09:00:00';

-- 9) Calibration result
ALTER TABLE CalibrationRecord
ADD CONSTRAINT CHK_Calibration_Result
CHECK (result IN ('Pass', 'Fail', 'Adjusted'));

-- rejected statement demonstrating it:
UPDATE CalibrationRecord
SET result = 'Pending'
WHERE serialNo = 'U3'
  AND calibDate = '2026-03-01';


-- Sanity constraints:

-- 10) Budget amount granted
ALTER TABLE Budget
ADD CONSTRAINT CHK_Budget_AmountGranted
CHECK (amountGranted >= 0);

-- rejected statement demonstrating it:
UPDATE Budget
SET amountGranted = -100
WHERE budgetLine = 'B1';

-- 11) Budget amount disbursed
ALTER TABLE Budget
ADD CONSTRAINT CHK_Budget_AmountDisbursed
CHECK (amountDisbursed >= 0);

-- rejected statement demonstrating it:
UPDATE Budget
SET amountDisbursed = -50
WHERE budgetLine = 'B1';

-- 12) Equipment purchase cost
ALTER TABLE EquipmentUnit
ADD CONSTRAINT CHK_Equipment_PurchaseCost
CHECK (purchaseCost >= 0);

-- rejected statement demonstrating it:
UPDATE EquipmentUnit
SET purchaseCost = -500
WHERE serialNo = 'U1';

-- 13) Maintenance cost
ALTER TABLE Maintenance
ADD CONSTRAINT CHK_Maintenance_Cost
CHECK (cost >= 0);

-- rejected statement demonstrating it:
UPDATE Maintenance
SET cost = -100
WHERE serialNo = 'U6'
  AND startTS = '2026-10-01 09:00:00';

-- 14) Supplier unit price
ALTER TABLE Supplies
ADD CONSTRAINT CHK_Supplies_UnitPrice
CHECK (unitPrice >= 0);

-- rejected statement demonstrating it:
UPDATE Supplies
SET unitPrice = -10
WHERE suppId = 1
  AND consId = 1
  AND labId = 1;

-- 15) Stock quantity
ALTER TABLE Stocks
ADD CONSTRAINT CHK_Stocks_Quantity
CHECK (quantityOnHand >= 0);

-- rejected statement demonstrating it:
UPDATE Stocks
SET quantityOnHand = -5
WHERE labId = 1
  AND consId = 1;

-- 16) Consumable reorder threshold
ALTER TABLE Consumable
ADD CONSTRAINT CHK_Consumable_ReorderThreshold
CHECK (reorderThreshold >= 0);

-- rejected statement demonstrating it:
UPDATE Consumable
SET reorderThreshold = -3
WHERE consId = 1;

-- 17) Quantity used
ALTER TABLE Consumes
ADD CONSTRAINT CHK_Consumes_QuantityUsed
CHECK (quantityUsed > 0);  -- Because a Consumes row represents an actual consumption. If the quantity is zero, nothing has been consumed,
                           -- so there is no reason to record that consumption.

-- rejected statement demonstrating it:
UPDATE Consumes
SET quantityUsed = 0
WHERE resId = 1
  AND labId = 1
  AND consId = 1;


-- Temporal sanity constraints:

-- 18) Reservation planned end must be after planned start
ALTER TABLE Reservation
ADD CONSTRAINT CHK_Reservation_Time
CHECK (plannedEnd > plannedStart); -- Because a reservation with the same start and end time has zero duration, which is not a valid reservation

-- rejected statement demonstrating it:
UPDATE Reservation
SET plannedEnd = plannedStart
WHERE resId = 1;

-- 19) Maintenance end must be at or after start
ALTER TABLE Maintenance
ADD CONSTRAINT CHK_Maintenance_Time
CHECK (endTS >= startTS);

-- rejected statement demonstrating it:
UPDATE Maintenance
SET endTS = '2026-09-30 08:00:00'
WHERE serialNo = 'U6'
  AND startTS = '2026-10-01 09:00:00';


/* Conclude with a short paragraph: which desired RLMS rules can a CHECK constraint not express, and why?
(A CHECK sees one row of one table):

  A CHECK constraint cannot express rules that require examining multiple rows or multiple tables. For example, it cannot ensure that
each project has exactly one PI [CHECK can verify that a row's role is either PI, Co-PI, or Collaborator,But it cannot count how many other
rows have the role PI for the same project,Because that requires examining multiple rows.] , that a person cannot belong to both Student and
Employee [A CHECK on Student cannot look inside Employee to see whether the same person already exists there,Because that requires examining
another table.] , or that a person holds all certifications required to reserve an equipment unit [his requires checking several tables
Reservation,Reserves,EquipmentUnit,EquipmentModel,Requires,Holds] , It also cannot prevent overlapping reservations because this requires
comparing different reservation records

*/