  -- A. Simple Queries

-- 1. List all persons, ordered by last name and then first name.
SELECT
  Person.pid,
  Person.firstName,
  Person.lastName,
  Person.email
FROM
  Person
ORDER BY
  Person.lastName,
  Person.firstName;


-- 2. List all distinct laboratory disciplines.
SELECT DISTINCT
  Laboratory.discipline
FROM
  Laboratory;


-- 3. List all persons whose email address ends with '@um6p.ma'.
SELECT
  Person.pid,
  Person.firstName,
  Person.lastName,
  Person.email
FROM
  Person
WHERE
  Person.email LIKE '%@um6p.ma';


-- 4. List all currently active persons.
SELECT
  Person.pid,
  Person.firstName,
  Person.lastName,
  Person.email
FROM
  Person
WHERE
  Person.endDate IS NULL;


-- 5. List reservations whose planned start falls in November 2026.
SELECT
  Reservation.resId
FROM
  Reservation
WHERE
  Reservation.plannedStart >= '2026-11-01 00:00:00'
  AND Reservation.plannedStart < '2026-12-01 00:00:00';


-- B. Queries Using Joins

-- 6. List participants' full names, project titles, and participation roles.
SELECT
  Person.firstName,
  Person.lastName,
  ResearchProject.title,
  Participates.prole
FROM
  Participates
  JOIN Person ON Participates.pid = Person.pid
  JOIN ResearchProject ON Participates.projectCode = ResearchProject.rpcode;


-- 7. List each budget with the full name of its manager.
SELECT
  Budget.budgetLine,
  Person.firstName,
  Person.lastName
FROM
  Budget
  JOIN Person ON Budget.managerPid = Person.pid;


-- 8. List each reservation with its maker's full name and project title.
SELECT
  Reservation.resId,
  Person.firstName,
  Person.lastName,
  ResearchProject.title
FROM
  Reservation
  JOIN Person ON Reservation.madeByPid = Person.pid
  JOIN ResearchProject ON Reservation.projectCode = ResearchProject.rpcode;


-- 9. List the equipment units included in each reservation.
SELECT
  Reserves.resId,
  EquipmentUnit.serialNo,
  EquipmentModel.commercialName,
  Laboratory.lname
FROM
  Reserves
  JOIN EquipmentUnit ON Reserves.serialNo = EquipmentUnit.serialNo
  JOIN EquipmentModel ON EquipmentUnit.modelId = EquipmentModel.modelId
  JOIN Laboratory ON EquipmentUnit.labId = Laboratory.labId;


-- 10. List approved reservations with the full name of their approver.
SELECT
  Reservation.resId,
  Person.firstName,
  Person.lastName
FROM
  Reservation
  JOIN Person ON Reservation.approverPid = Person.pid
WHERE
  Reservation.resStatus = 'Approved';


-- 11. List each stock with its laboratory, consumable, quantity, and monitor.
SELECT
  Laboratory.lname,
  Consumable.consName,
  Stocks.quantityOnHand,
  Person.firstName,
  Person.lastName
FROM
  Stocks
  JOIN Laboratory ON Stocks.labId = Laboratory.labId
  JOIN Consumable ON Stocks.consId = Consumable.consId
  JOIN Person ON Stocks.technicalPid = Person.pid;


-- C. Aggregation Queries

-- 12. Count equipment units in each laboratory, including laboratories with none.
SELECT
  EquipmentUnit.labId,
  COUNT(*) AS equipmentUnitCount
FROM
  EquipmentUnit
GROUP BY
  EquipmentUnit.labId
UNION
SELECT
  Laboratory.labId,
  0 AS equipmentUnitCount
FROM
  Laboratory
WHERE
  Laboratory.labId NOT IN (
    SELECT
      EquipmentUnit.labId
    FROM
      EquipmentUnit
  );


-- 13. Return the total quantity used of each consumable, including unused ones.
SELECT
  Consumes.consId,
  SUM(Consumes.quantityUsed) AS totalQuantityUsed
FROM
  Consumes
GROUP BY
  Consumes.consId
UNION
SELECT
  Consumable.consId,
  0 AS totalQuantityUsed
FROM
  Consumable
WHERE
  Consumable.consId NOT IN (
    SELECT
      Consumes.consId
    FROM
      Consumes
  );


-- D. Queries Combining Joins and Aggregation

-- 14. List laboratories containing more than three equipment units.
SELECT
  Laboratory.lname,
  COUNT(EquipmentUnit.serialNo) AS equipmentUnitCount
FROM
  Laboratory
  JOIN EquipmentUnit ON Laboratory.labId = EquipmentUnit.labId
GROUP BY
  Laboratory.labId,
  Laboratory.lname
HAVING
  COUNT(EquipmentUnit.serialNo) > 3;


-- 15. Return the total amount granted to each research project.
SELECT
  ResearchProject.title,
  COALESCE(SUM(Budget.amountGranted), 0) AS totalAmountGranted
FROM
  ResearchProject
  LEFT JOIN FundsPrj ON ResearchProject.rpcode = FundsPrj.projectCode
  LEFT JOIN Budget ON FundsPrj.budgetLine = Budget.budgetLine
GROUP BY
  ResearchProject.rpcode,
  ResearchProject.title;


-- 16. Return equipment counts and average costs per laboratory and category.
SELECT
  Laboratory.lname,
  EquipmentModel.category,
  COUNT(EquipmentUnit.serialNo) AS equipmentUnitCount,
  AVG(EquipmentUnit.purchaseCost) AS averagePurchaseCost
FROM
  Laboratory
  JOIN EquipmentUnit ON Laboratory.labId = EquipmentUnit.labId
  JOIN EquipmentModel ON EquipmentUnit.modelId = EquipmentModel.modelId
GROUP BY
  Laboratory.labId,
  Laboratory.lname,
  EquipmentModel.category;


-- 17. Count the distinct consumables each supplier can provide across all labs.
SELECT
  Supplier.suppname,
  COUNT(DISTINCT Supplies.consId) AS consumableCount
FROM
  Supplier
  LEFT JOIN Supplies ON Supplier.suppId = Supplies.suppId
GROUP BY
  Supplier.suppId,
  Supplier.suppname;


-- 18. Return the lowest negotiated price for each supplied lab-consumable pair.
SELECT
  Laboratory.lname,
  Consumable.consName,
  MIN(Supplies.unitPrice) AS lowestUnitPrice
FROM
  Supplies
  JOIN Consumable ON Supplies.consId = Consumable.consId
  JOIN Laboratory ON Supplies.labId = Laboratory.labId
GROUP BY
  Laboratory.labId,
  Laboratory.lname,
  Consumable.consId,
  Consumable.consName;


-- 19. List reservations with consumption, their maker, and total quantity used.
SELECT
  Reservation.resId,
  Person.firstName,
  Person.lastName,
  SUM(Consumes.quantityUsed) AS totalQuantityUsed
FROM
  Reservation
  JOIN Consumes ON Reservation.resId = Consumes.resId
  JOIN Person ON Reservation.madeByPid = Person.pid
GROUP BY
  Reservation.resId,
  Person.firstName,
  Person.lastName;


-- E. Set Operations and Nested Queries

-- 20. List persons who both supervise a laboratory and manage a budget.
SELECT
  Person.pid,
  Person.firstName,
  Person.lastName
FROM
  Laboratory
  JOIN Person ON Laboratory.supervisorPid = Person.pid INTERSECT
SELECT
  Person.pid,
  Person.firstName,
  Person.lastName
FROM
  Budget
  JOIN Person ON Budget.managerPid = Person.pid;


-- 21. List persons who have never made a reservation, using NOT IN.
SELECT
  Person.pid,
  Person.firstName,
  Person.lastName,
  Person.email
FROM
  Person
WHERE
  Person.pid NOT IN (
    SELECT
      Reservation.madeByPid
    FROM
      Reservation
  );


-- 22. List equipment units that have never been reserved, using NOT EXISTS.
SELECT
  EquipmentUnit.serialNo
FROM
  EquipmentUnit
WHERE
  NOT EXISTS (
    SELECT
      1
    FROM
      Reserves
    WHERE
      Reserves.serialNo = EquipmentUnit.serialNo
  );


-- 23. List the most expensive equipment unit(s), using ALL.
SELECT
  EquipmentUnit.serialNo
FROM
  EquipmentUnit
WHERE
  EquipmentUnit.purchaseCost >= ALL (
    SELECT
      EquipmentUnit.purchaseCost
    FROM
      EquipmentUnit
  );


-- F. Division Queries

-- 24. For each model requiring certifications, list persons holding all of them.
SELECT
  EquipmentModel.modelId,
  EquipmentModel.commercialName,
  Person.pid,
  Person.firstName,
  Person.lastName
FROM
  EquipmentModel
  CROSS JOIN Person
WHERE
  EXISTS (
    SELECT
      1
    FROM
      Requires
    WHERE
      Requires.modelId = EquipmentModel.modelId
  )
  AND NOT EXISTS (
    SELECT
      1
    FROM
      Requires
    WHERE
      Requires.modelId = EquipmentModel.modelId
      AND NOT EXISTS (
        SELECT
          1
        FROM
          Holds
        WHERE
          Holds.pid = Person.pid
          AND Holds.certCode = Requires.certCode
      )
  );