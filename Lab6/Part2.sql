-- DATA GENERATED USING ARTIFICIAL INTELLIGENCE
-- Extended to test every Part 3 query, including boundary and exclusion cases.
-- Dates are fixed in November 2026 to match Query 5.
-- Persons & Subtypes
-- Shared last names test ordering. Persons 9 and 13 are inactive.
-- Person 9 has an external email; Person 12 has a misleading email suffix.
-- Person 6 is inserted later by the requested DML operation.
INSERT INTO
  Person (
    pid,
    firstName,
    lastName,
    email,
    affiliation,
    startDate,
    endDate
  )
VALUES
  (
    1,
    'Dr. Amina',
    'Benali',
    'amina.benali@um6p.ma',
    'UM6P Benguerir',
    '2020-01-01',
    NULL
  ),
  (
    2,
    'Karim',
    'Tazi',
    'karim.tazi@um6p.ma',
    'UM6P Benguerir',
    '2019-01-01',
    NULL
  ),
  (
    3,
    'Nadia',
    'Fassi',
    'nadia.fassi@um6p.ma',
    'UM6P Benguerir',
    '2021-01-01',
    NULL
  ),
  (
    4,
    'Omar',
    'Jazouli',
    'omar.jazouli@um6p.ma',
    'UM6P Benguerir',
    '2022-01-01',
    NULL
  ),
  (
    5,
    'Sara',
    'Alami',
    'sara.alami@um6p.ma',
    'UM6P Benguerir',
    '2023-01-01',
    NULL
  ),
  (
    7,
    'Amal',
    'Benali',
    'amal.benali@um6p.ma',
    'UM6P Benguerir',
    '2020-01-01',
    NULL
  ),
  (
    8,
    'Yassine',
    'Idrissi',
    'yassine.idrissi@um6p.ma',
    'UM6P Benguerir',
    '2021-01-01',
    NULL
  ),
  (
    9,
    'Lina',
    'Benali',
    'lina.benali@example.com',
    'Visiting Student',
    '2023-01-01',
    '2025-06-30'
  ),
  (
    10,
    'Hamza',
    'Tazi',
    'hamza.tazi@um6p.ma',
    'UM6P Benguerir',
    '2022-01-01',
    NULL
  ),
  (
    11,
    'Salma',
    'Fassi',
    'salma.fassi@um6p.ma',
    'UM6P Benguerir',
    '2022-01-01',
    NULL
  ),
  (
    12,
    'Adam',
    'Benali',
    'adam.benali@um6p.ma.example.com',
    'Visiting Student',
    '2024-01-01',
    NULL
  ),
  (
    13,
    'Leila',
    'Mansouri',
    'leila.mansouri@um6p.ma',
    'UM6P Benguerir',
    '2023-01-01',
    '2026-10-31'
  );


INSERT INTO
  Employee (pid, phone, office, position)
VALUES
  (1, '0525-070001', 'MSN Office 10', 'Professor'),
  (
    2,
    '0525-070002',
    'MSN Office 11',
    'Senior Technician'
  ),
  (
    3,
    '0525-070003',
    'Admin Block A',
    'Administrator'
  ),
  (7, '0525-070007', 'Riad5 Office 12', 'Professor'),
  (8, '0525-070008', 'MSN Office 15', 'Scientist'),
  (10, '0525-070010', 'Annex Office 2', 'Technician'),
  (
    11,
    '0525-070011',
    'Admin Block B',
    'Administrator'
  );


INSERT INTO
  Academic (pid)
VALUES
  (1),
  (7),
  (8);


INSERT INTO
  Faculty (pid)
VALUES
  (1),
  (7);


INSERT INTO
  Technical (pid)
VALUES
  (2),
  (10);


INSERT INTO
  Administrative (pid)
VALUES
  (3),
  (11);


INSERT INTO
  Student (pid, program)
VALUES
  (4, 'PhD Materials Sci'),
  (5, 'MSc AgriTech'),
  (9, 'MSc Physics'),
  (12, 'BSc Computer Science'),
  (13, 'MSc Chemistry');


INSERT INTO
  Advises (academicPid, studentPid)
VALUES
  (1, 4),
  (1, 5),
  (1, 9),
  (7, 12),
  (7, 13);


-- Laboratories: repeated disciplines, an empty lab, and two labs with the same name.
-- Person 1 supervises and manages budgets; Person 7 only supervises.
INSERT INTO
  Laboratory (
    labId,
    lname,
    building,
    roomNumber,
    discipline,
    supervisorPid
  )
VALUES
  (
    1,
    'Physics Laboratory',
    'Riad5',
    'Lab 101',
    'Physics',
    1
  ),
  (
    2,
    'Materials Science Lab',
    'MSN Building',
    'Lab 202',
    'Nano-engineering',
    1
  ),
  (
    3,
    'Electronics Laboratory',
    'Technology Building',
    'Lab 303',
    'Physics',
    7
  ),
  (
    4,
    'Physics Laboratory',
    'Research Annex',
    'Lab 402',
    'Physics',
    7
  );


INSERT INTO
  Attached (pid, labId)
VALUES
  (1, 1),
  (2, 1),
  (4, 1),
  (5, 2),
  (7, 3),
  (10, 4),
  (12, 4);


-- Research Projects: PRJ4 has no reservations or budget; PRJ5 repeats PRJ1's title.
-- PRJ4 deliberately exercises the zero-funding case in Query 15.
INSERT INTO
  ResearchProject (rpcode, title, startDate, researchStatus)
VALUES
  (
    'PRJ1',
    'Phosphates Valorization & Extraction',
    '2023-01-01',
    'Active'
  ),
  (
    'PRJ2',
    'AgriTech Soil AI',
    '2023-05-01',
    'Active'
  ),
  (
    'PRJ3',
    'Solar Desalination Tech',
    '2023-06-01',
    'Cancelled'
  ),
  ('PRJ4', 'Empty Project', '2024-01-01', 'Proposed'),
  (
    'PRJ5',
    'Phosphates Valorization & Extraction',
    '2024-06-01',
    'Active'
  );


INSERT INTO
  Participates (pid, projectCode, prole)
VALUES
  (1, 'PRJ1', 'PI'),
  (4, 'PRJ1', 'Researcher'),
  (1, 'PRJ2', 'PI'),
  (5, 'PRJ3', 'Assistant'),
  (7, 'PRJ3', 'PI'),
  (8, 'PRJ4', 'PI'),
  (7, 'PRJ5', 'PI'),
  (5, 'PRJ2', 'Researcher'),
  (12, 'PRJ5', 'Assistant'),
  (9, 'PRJ1', 'Researcher');


-- Budgets: Person 8 manages budgets but supervises no laboratory.
-- PRJ1 has two separate grants of 150000: both must be included in SUM.
INSERT INTO
  Budget (
    budgetLine,
    amountGranted,
    amountDisbursed,
    startDate,
    managerPid
  )
VALUES
  ('UM6P-B1', 150000.00, 50000.00, '2023-01-01', 1),
  ('UM6P-B2', 200000.00, 100000.00, '2023-01-01', 1),
  ('UM6P-B3', 150000.00, 25000.00, '2024-01-01', 8),
  ('UM6P-B4', 75000.00, 10000.00, '2024-06-01', 8);


INSERT INTO
  FundsPrj (budgetLine, projectCode)
VALUES
  ('UM6P-B1', 'PRJ1'),
  ('UM6P-B2', 'PRJ2'),
  ('UM6P-B3', 'PRJ1'),
  ('UM6P-B4', 'PRJ3'),
  ('UM6P-B4', 'PRJ5');


INSERT INTO
  FundsLab (budgetLine, labId)
VALUES
  ('UM6P-B1', 1),
  ('UM6P-B2', 2),
  ('UM6P-B3', 3),
  ('UM6P-B4', 4);


-- Equipment Models: Models 1 and 4 share a category; Models 3 and 5 have no units.
INSERT INTO
  EquipmentModel (
    modelId,
    commercialName,
    manufacturer,
    category,
    requiredEnvironment,
    trainingMandatory
  )
VALUES
  (
    1,
    'Zeiss X1',
    'Zeiss',
    'Optical Microscope',
    'Clean Room',
    TRUE
  ),
  (
    2,
    'Fluke T1',
    'Fluke',
    'Thermometer',
    'Standard Lab',
    FALSE
  ),
  (
    3,
    'Unused Scope',
    'BrandX',
    'Telescope',
    'Outside',
    TRUE
  ),
  (
    4,
    'Zeiss X2',
    'Zeiss',
    'Optical Microscope',
    'Clean Room',
    TRUE
  ),
  (
    5,
    'Reference Balance',
    'LabTech',
    'Balance',
    'Standard Lab',
    TRUE
  );


-- Final counts after DML: Lab 1 has 5 units, Lab 2 has 1, Lab 3 has 0, Lab 4 has 3.
-- Units 003 and 005 share the maximum purchase cost. Unit 004 is inserted later.
INSERT INTO
  EquipmentUnit (
    serialNo,
    acquisitionDate,
    purchaseCost,
    modelId,
    labId,
    portable
  )
VALUES
  (
    'SN-UM6P-001',
    '2022-01-01',
    50000.00,
    1,
    1,
    FALSE
  ),
  ('SN-UM6P-002', '2022-02-01', 5000.00, 2, 1, TRUE),
  (
    'SN-UM6P-003',
    '2023-01-01',
    60000.00,
    1,
    2,
    FALSE
  ),
  (
    'SN-UM6P-005',
    '2023-02-01',
    60000.00,
    4,
    1,
    FALSE
  ),
  ('SN-UM6P-006', '2023-03-01', 50000.00, 1, 1, TRUE),
  (
    'SN-UM6P-007',
    '2024-01-01',
    12000.00,
    1,
    4,
    FALSE
  ),
  ('SN-UM6P-008', '2024-02-01', 8000.00, 2, 4, TRUE),
  (
    'SN-UM6P-009',
    '2024-03-01',
    18000.00,
    4,
    4,
    FALSE
  );


-- Certifications: Model 1 requires two; Model 2 requires none.
-- Nobody holds Certification 3; Certification 4 is unrelated to all models.
INSERT INTO
  Certification (
    certCode,
    title,
    issuingAuthority,
    validityPeriod,
    safetyLevel
  )
VALUES
  (
    'CERT-UM6P-1',
    'Advanced Microscopy',
    'UM6P Safety Board',
    24,
    'High'
  ),
  (
    'CERT-UM6P-2',
    'Basic Lab Protocol',
    'UM6P Admin',
    36,
    'Low'
  ),
  (
    'CERT-UM6P-3',
    'Telescope Operation',
    'UM6P Safety Board',
    24,
    'Medium'
  ),
  (
    'CERT-UM6P-4',
    'Chemical Safety',
    'UM6P Safety Board',
    24,
    'High'
  );


INSERT INTO
  Requires (modelId, certCode)
VALUES
  (1, 'CERT-UM6P-1'),
  (1, 'CERT-UM6P-2'),
  (3, 'CERT-UM6P-3'),
  (4, 'CERT-UM6P-2'),
  (5, 'CERT-UM6P-1');


-- Persons 1 and 4 hold all Model 1 requirements; Person 1 also holds an extra.
-- Persons 5 and 7 hold only part of Model 1's requirements; Person 8 holds neither.
INSERT INTO
  Holds (pid, certCode, issueDate, expirationDate)
VALUES
  (1, 'CERT-UM6P-1', '2026-01-01', '2028-01-01'),
  (4, 'CERT-UM6P-1', '2026-05-01', '2028-05-01'),
  (1, 'CERT-UM6P-2', '2026-01-01', '2029-01-01'),
  (1, 'CERT-UM6P-4', '2026-01-01', '2028-01-01'),
  (4, 'CERT-UM6P-2', '2026-05-01', '2029-05-01'),
  (5, 'CERT-UM6P-1', '2026-05-01', '2028-05-01'),
  (7, 'CERT-UM6P-2', '2026-01-01', '2029-01-01'),
  (8, 'CERT-UM6P-4', '2026-01-01', '2028-01-01');


-- Reservations: all statuses, multiple makers and approvers, and month boundaries.
-- Query 5 must include 9 and 10, but exclude 8 and 11. Reservation 7 is inserted later.
INSERT INTO
  Reservation (
    resId,
    submissionTS,
    plannedStart,
    plannedEnd,
    purpose,
    resStatus,
    madeByPid,
    projectCode,
    approverPid
  )
VALUES
  (
    1,
    '2026-11-01 10:00:00',
    '2026-11-15 10:00:00',
    '2026-11-15 12:00:00',
    'Phosphate Optics Test',
    'Approved',
    4,
    'PRJ1',
    1
  ),
  (
    2,
    '2026-11-01 11:00:00',
    '2026-11-20 10:00:00',
    '2026-11-20 12:00:00',
    'AgriTech Soil Temp',
    'Pending',
    4,
    'PRJ1',
    NULL
  ),
  (
    3,
    '2026-10-01 10:00:00',
    '2026-10-05 10:00:00',
    '2026-10-05 12:00:00',
    'Past Optics Test',
    'Completed',
    4,
    'PRJ2',
    1
  ),
  (
    4,
    '2026-10-01 10:00:00',
    '2026-10-06 10:00:00',
    '2026-10-06 12:00:00',
    'Rejected Test',
    'Rejected',
    4,
    'PRJ2',
    1
  ),
  (
    5,
    '2026-10-01 10:00:00',
    '2026-10-07 10:00:00',
    '2026-10-07 12:00:00',
    'Cancelled Test',
    'Cancelled',
    4,
    'PRJ2',
    1
  ),
  (
    6,
    '2026-11-08 09:00:00',
    '2026-11-10 09:00:00',
    '2026-11-10 11:00:00',
    'Desalination Pending Test',
    'Pending',
    5,
    'PRJ3',
    NULL
  ),
  (
    8,
    '2026-10-30 09:00:00',
    '2026-10-31 23:59:59',
    '2026-11-01 00:59:59',
    'Before November Boundary',
    'Completed',
    5,
    'PRJ2',
    7
  ),
  (
    9,
    '2026-10-30 10:00:00',
    '2026-11-01 00:00:00',
    '2026-11-01 01:00:00',
    'Start of November',
    'Approved',
    12,
    'PRJ5',
    7
  ),
  (
    10,
    '2026-11-01 10:00:00',
    '2026-11-30 23:59:59',
    '2026-12-01 00:59:59',
    'End of November',
    'Approved',
    5,
    'PRJ2',
    7
  ),
  (
    11,
    '2026-11-01 10:00:00',
    '2026-12-01 00:00:00',
    '2026-12-01 01:00:00',
    'Start of December',
    'Pending',
    12,
    'PRJ5',
    NULL
  ),
  (
    12,
    '2026-11-01 10:00:00',
    '2026-11-12 10:00:00',
    '2026-11-12 12:00:00',
    'Multiple Consumables Test',
    'Approved',
    5,
    'PRJ2',
    1
  ),
  (
    13,
    '2026-11-01 10:00:00',
    '2026-11-29 08:00:00',
    '2026-11-29 10:00:00',
    'Second Cancelled Project Test',
    'Pending',
    4,
    'PRJ3',
    NULL
  );


-- Reservation 1 includes different models and laboratories.
-- Units 004, 006 and 009 are never reserved.
INSERT INTO
  Reserves (resId, serialNo)
VALUES
  (1, 'SN-UM6P-001'),
  (1, 'SN-UM6P-002'),
  (1, 'SN-UM6P-003'),
  (2, 'SN-UM6P-001'),
  (3, 'SN-UM6P-002'),
  (4, 'SN-UM6P-001'),
  (5, 'SN-UM6P-002'),
  (6, 'SN-UM6P-002'),
  (8, 'SN-UM6P-007'),
  (9, 'SN-UM6P-005'),
  (10, 'SN-UM6P-008'),
  (11, 'SN-UM6P-005'),
  (12, 'SN-UM6P-001'),
  (12, 'SN-UM6P-005'),
  (13, 'SN-UM6P-002');


-- Maintenance and Calibration
INSERT INTO
  Maintenance (
    serialNo,
    startTS,
    endTS,
    mtype,
    mdescription,
    cost,
    outcome,
    technicalPid
  )
VALUES
  (
    'SN-UM6P-001',
    '2025-01-01 08:00:00',
    '2025-01-01 12:00:00',
    'Preventive',
    'Routine optical alignment by tech',
    1500.00,
    'Success',
    2
  );


INSERT INTO
  CalibrationRecord (
    serialNo,
    calibDate,
    calibrationType,
    result,
    nextDueDate,
    remarks
  )
VALUES
  (
    'SN-UM6P-002',
    '2025-06-01',
    'Temperature Validation',
    'Pass',
    '2026-06-01',
    'Within tolerance for Benguerir climate'
  );


-- Consumables: 1 and 4 share a name; 3 and 5 are never consumed.
INSERT INTO
  Consumable (
    consId,
    consName,
    unitOfMeasure,
    hazardLevel,
    reorderThreshold
  )
VALUES
  (1, 'Ethanol', 'Liters', 'High', 10.00),
  (2, 'Lens Wipes', 'Boxes', 'Low', 5.00),
  (3, 'Acetone', 'Liters', 'High', 5.00),
  (4, 'Ethanol', 'Bottles', 'High', 4.00),
  (5, 'Filter Paper', 'Sheets', 'Low', 20.00);


-- Suppliers 1 and 4 share a name. Supplier 3 has no supply arrangements.
INSERT INTO
  Supplier (suppId, suppname, contactEmail, phone)
VALUES
  (
    1,
    'OCP Maintenance Solutions',
    'contact@ocpms.ma',
    '0525-112233'
  ),
  (
    2,
    'Maghreb Labo',
    'sales@maghreblabo.ma',
    '0522-445566'
  ),
  (
    3,
    'Atlas Lab',
    'contact@atlaslab.example',
    '0525-112234'
  ),
  (
    4,
    'OCP Maintenance Solutions',
    'annex@ocpms.ma',
    '0525-112235'
  );


-- Competing prices, tied lowest prices, and the same consumable in several labs.
-- Consumable 3 has a supply arrangement but is not stocked anywhere.
INSERT INTO
  Supplies (suppId, consId, labId, unitPrice)
VALUES
  (1, 1, 1, 200.00),
  (2, 2, 1, 50.00),
  (1, 1, 2, 220.00),
  (1, 3, 1, 250.00),
  (2, 1, 1, 180.00),
  (4, 1, 1, 180.00),
  (2, 1, 2, 240.00),
  (1, 2, 1, 45.00),
  (2, 1, 4, 300.00),
  (1, 4, 1, 90.00),
  (2, 4, 1, 95.00),
  (4, 1, 4, 310.00);


-- Stocks: different monitors, repeated consumables across labs, and low stock.
INSERT INTO
  Stocks (
    labId,
    consId,
    quantityOnHand,
    lastRestockDate,
    storageCondition,
    technicalPid,
    monitoringSince
  )
VALUES
  (
    1,
    1,
    50.00,
    '2026-10-01',
    'Flammable Cabinet',
    2,
    '2023-01-01'
  ),
  (
    2,
    1,
    20.00,
    '2026-10-01',
    'Flammable Cabinet',
    10,
    '2023-01-01'
  ),
  (
    1,
    2,
    3.00,
    '2026-10-01',
    'Shelf A',
    2,
    '2023-01-01'
  ),
  (
    4,
    1,
    15.00,
    '2026-10-01',
    'Flammable Cabinet',
    10,
    '2024-01-01'
  ),
  (
    1,
    4,
    12.00,
    '2026-10-01',
    'Flammable Cabinet',
    10,
    '2024-01-01'
  ),
  (
    3,
    5,
    100.00,
    '2026-10-01',
    'Shelf B',
    2,
    '2024-01-01'
  );


-- Consumptions: repeated consumables, different stocks, and multiple rows per reservation.
-- The requested DML operation later adds (1, 1, 2, 1.00).
INSERT INTO
  Consumes (resId, labId, consId, quantityUsed)
VALUES
  (3, 1, 1, 2.00),
  (3, 2, 1, 3.00),
  (1, 1, 1, 4.00),
  (10, 4, 1, 2.00),
  (10, 1, 4, 3.00),
  (12, 1, 2, 2.00),
  (12, 1, 1, 1.00);


-- ============================================================================
-- REQUESTED DML OPERATIONS (1 through 8)
-- ============================================================================
-- 1. Insert at least one new Person and the corresponding subtype record
INSERT INTO
  Person (
    pid,
    firstName,
    lastName,
    email,
    affiliation,
    startDate
  )
VALUES
  (
    6,
    'Youssef',
    'Berrada',
    'youssef.berrada@um6p.ma',
    'UM6P Benguerir',
    '2026-11-08'
  );


INSERT INTO
  Student (pid, program)
VALUES
  (6, 'BSc Computer Science');


-- 2. Insert a new EquipmentUnit associated with an existing EquipmentModel and Laboratory
INSERT INTO
  EquipmentUnit (
    serialNo,
    acquisitionDate,
    purchaseCost,
    modelId,
    labId,
    portable
  )
VALUES
  ('SN-UM6P-004', '2026-11-08', 20000.00, 1, 1, TRUE);


-- 3. Insert a new Reservation together with at least one corresponding tuple in Reserves
INSERT INTO
  Reservation (
    resId,
    submissionTS,
    plannedStart,
    plannedEnd,
    purpose,
    resStatus,
    madeByPid,
    projectCode,
    approverPid
  )
VALUES
  (
    7,
    '2026-11-08 12:00:00',
    '2026-11-20 12:00:00',
    '2026-11-20 14:00:00',
    'Validation Check',
    'Pending',
    4,
    'PRJ1',
    NULL
  );


INSERT INTO
  Reserves (resId, serialNo)
VALUES
  (7, 'SN-UM6P-001');


-- 4. Update the status of one reservation from 'Pending' to 'Approved', recording the approver
UPDATE Reservation
SET
  resStatus = 'Approved',
  approverPid = 1
WHERE
  resId = 2
  AND resStatus = 'Pending';


-- 5. Update the quantity of one laboratory-consumable stock occurrence
UPDATE Stocks
SET
  quantityOnHand = quantityOnHand + 10
WHERE
  labId = 1
  AND consId = 1;


-- 6. Insert a tuple recording that an approved reservation consumed a given quantity of a consumable
INSERT INTO
  Consumes (resId, labId, consId, quantityUsed)
VALUES
  (1, 1, 2, 1.00);


-- 7. Using an UPDATE with a nested subquery, cancel all pending reservations for 'Cancelled' research projects
UPDATE Reservation
SET
  resStatus = 'Cancelled'
WHERE
  resStatus = 'Pending'
  AND projectCode IN (
    SELECT
      rpcode
    FROM
      ResearchProject
    WHERE
      researchStatus = 'Cancelled'
  );


-- 8. Delete one test tuple without violating referential integrity (Deleting Administrative Employee)
DELETE FROM Person
WHERE
  pid = 3;