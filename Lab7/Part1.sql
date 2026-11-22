-- Query 1
SELECT CONCAT(P1.firstName, ' ', P1.lastName) as Supervisee, CONCAT(P2.firstName, ' ', P2.lastName) as Supervisor
FROM Employee E1 LEFT JOIN Employee E2 ON E1.supervisorPid = E2.pid
LEFT JOIN Person P1 ON E1.pid = P1.pid
LEFT JOIN Person P2 ON E2.pid = P2.pid;

-- Query 2
SELECT R.resId, CONCAT(P.firstName, ' ', P.lastName) as Approver
FROM Reservation R LEFT JOIN Person P on R.approverPid = P.pid
ORDER BY R.resId;

-- Query 3
SELECT EQ1.serialNo AS Unit1, EQ2.serialNo AS Unit2
FROM Equipmentunit EQ1, Equipmentunit EQ2
WHERE EQ1.modelId = EQ2.modelId AND EQ1.labId < EQ2.labId;

-- Query 4: Using an outer join, return for each equipment model its commercial name and the
-- number of physical units of that model. Models with no units must appear with a count of 0.
SELECT EM.commercialName, COUNT(EQ.serialNo) as NumberOfUnits
FROM Equipmentmodel EM LEFT JOIN Equipmentunit EQ ON EQ.modelId = EM.modelId
GROUP BY EM.modelId;

-- Query 5: Using a correlated subquery, return for each laboratory the serial number(s) of the
-- most expensive equipment unit(s) it currently hosts.
SELECT EQ.labId, EQ.serialNo
FROM Equipmentunit EQ
WHERE EQ.purchaseCost >= ALL (
    -- MAX OF THE PURCHASES OF THE LAB WITH ID EQ.labId
    SELECT MAX(EQ2.purchaseCost)
    FROM Equipmentunit EQ2
    WHERE EQ2.labId = EQ.labId
);

-- Query 6: List the laboratories whose total quantity of stocked consumables is strictly greater
-- than the average of this total over all laboratories.
SELECT S.labId
FROM Stocks S
GROUP BY S.labId
HAVING SUM(S.quantityOnHand) > (SELECT AVG(T.totalQnty)
    FROM (
    -- Calculate the average for each labId
    SELECT SUM(S1.quantityOnHand) AS totalQnty
    FROM Stocks S1
    GROUP BY S1.labId
    ) T);

-- Query 7: List the consumables that are stocked in EVERY laboratory (division).
SELECT C.consId
FROM Consumable C
WHERE NOT EXISTS(
    (SELECT L.labId
     FROM laboratory L)
    EXCEPT
    (SELECT S.labId
     FROM Stocks S
     WHERE S.consId = C.consId));
