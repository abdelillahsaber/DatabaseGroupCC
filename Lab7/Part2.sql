-- VIEW 1
CREATE OR REPLACE VIEW UpcomingApprovedReservationsByLab AS
SELECT L.labId, L.name AS labName,
      DATE(R.plannedStart) AS reservationDate,
      COUNT(DISTINCT R.resId) AS distinctApprovedReservations
FROM Reservation R
JOIN Reserves RS ON R.resId = RS.resId
JOIN EquipmentUnit EU ON RS.serialNo = EU.serialNo
JOIN Laboratory L ON EU.labId = L.labId
WHERE R.status = 'Approved'
  AND R.plannedStart >= NOW()
  AND R.plannedStart <= DATE_ADD(NOW(), INTERVAL 14 DAY)
GROUP BY L.labId, L.name, DATE(R.plannedStart);

-- TEST VIEW 1
SELECT *
FROM UpcomingApprovedReservationsByLab
ORDER BY reservationDate ASC, distinctApprovedReservations DESC;

-- Count the distinct 'Approved' reservations scheduled in each laboratory over the next 14 days.
-- Allows us to instantly grab the approved reservations in the next 14 days.

-- VIEW 2
CREATE OR REPLACE VIEW EquipmentInventoryByLab AS
SELECT L.labId, L.name labName, EM.modelId, EM.commercialName, EM.category,
        COUNT(EU.serialNo) totalUnits,
        COUNT(EU_IS.serialNo) inServiceUnits,
        COUNT(EU_UM.serialNo) underMaintenanceUnits
FROM Equipmentunit EU
JOIN Laboratory L ON EU.labId = L.labId
JOIN Equipmentmodel EM ON EU.modelId = EM.modelId
LEFT JOIN Equipmentunit EU_IS ON EU.serialNo = EU_IS.serialNo AND EU_IS.status = 'InService'
LEFT JOIN Equipmentunit EU_UM ON EU.serialNo = EU_UM.serialNo AND EU_UM.status = 'UnderMaintenance'
GROUP BY L.labId, L.name, EM.modelId, EM.commercialName, EM.category;

-- TEST VIEW 2
SELECT labName, commercialName, category, totalUnits, inServiceUnits, underMaintenanceUnits
FROM EquipmentInventoryByLab
WHERE underMaintenanceUnits > 0
ORDER BY labId, modelId;

-- Summarizes the total number of equipment units per equipment model inside each laboratory, broken down by 'InService' and 'UnderMaintenance' counts.
-- We can easily check how many working units of a given instrument are available in each room versus currently undergoing maintenance

-- VIEW 3
CREATE OR REPLACE VIEW PersonReservationSummary AS
SELECT P.pid, P.firstName, P.lastName,
        COUNT(R.resId) totalReservations,
        COUNT(R_A.resId) approvedReservations,
        COUNT(R_P.resId) pendingReservations,
        COUNT(R_C.resId) cancelledReservations
FROM Person P
LEFT JOIN Reservation R ON P.pid = R.madeByPid
LEFT JOIN Reservation R_A ON R.resId = R_A.resId AND R_A.status = 'Approved'
LEFT JOIN Reservation R_P ON R.resId = R_P.resId AND R_P.status = 'Pending'
LEFT JOIN Reservation R_C ON R.resId = R_C.resId AND R_C.status = 'Cancelled'
GROUP BY P.pid, P.firstName, P.lastName;

-- TEST VIEW 3
SELECT pid, firstName, lastName, totalReservations, approvedReservations, pendingReservations, cancelledReservations
FROM PersonReservationSummary
WHERE totalReservations > 0
ORDER BY totalReservations DESC, lastName ASC;

-- Hold each person's total reservations with separate counts for 'Approved', 'Pending', and 'Cancelled' statuses
-- Lets HR track a persons reservation with ease

-- VIEW 4
CREATE OR REPLACE VIEW ProjectReservationSummary AS
SELECT RP.code, RP.title, RP.status,
       COUNT(R.resId) TotalReservations,
       COUNT(R_A.resId) NumberOfApprovedReservations,
       MIN(R_next.plannedStart) AS NextApprovedReservation
FROM researchproject RP LEFT JOIN Reservation R ON RP.code = R.projectCode
LEFT JOIN Reservation R_A ON R.resId = R_A.resId AND R_A.status = 'Approved'
LEFT JOIN Reservation R_next ON R_A.resId = R_next.resId AND R_next.plannedStart >= NOW()
GROUP BY RP.code, RP.title, RP.status;

-- TEST VIEW 4
SELECT code, title, status, TotalReservations, NumberOfApprovedReservations, NextApprovedReservation
FROM ProjectReservationSummary
WHERE status = 'Active'
ORDER BY NextApprovedReservation ASC;

-- Summarizes total reservations, approved reservations, and the earliest upcoming approved session timestamp for every project
-- Lets us monitor equipment utilization per project and see when each active project's next confirmed lab session is scheduled.

-- VIEW 5
CREATE OR REPLACE VIEW LaboratoryStockSummary AS
SELECT
    Laboratory.name AS labName,
    Laboratory.labId,
    Consumable.name AS consumableName,
    Consumable.consId,
    Consumable.unitOfMeasure,
    Consumable.reorderThreshold,
    Stocks.quantityOnHand,
    Stocks.technicalPid,
    Stocks.monitoringSince,
    'LOW' AS stockLevel
FROM
Stocks
JOIN Laboratory ON Stocks.labId = Laboratory.labId
JOIN Consumable ON Stocks.consId = Consumable.consId
WHERE
Stocks.quantityOnHand <= Consumable.reorderThreshold
UNION ALL
SELECT
Laboratory.name AS labName,
Laboratory.labId,
Consumable.name AS consumableName,
Consumable.consId,
Consumable.unitOfMeasure,
Consumable.reorderThreshold,
Stocks.quantityOnHand,
Stocks.technicalPid,
Stocks.monitoringSince,
'OK' AS stockLevel
FROM
Stocks
JOIN Laboratory ON Stocks.labId = Laboratory.labId
JOIN Consumable ON Stocks.consId = Consumable.consId
WHERE
Stocks.quantityOnHand > Consumable.reorderThreshold;

-- TEST VIEW 5
SELECT labId, labName, consId, consumableName, quantityOnHand, reorderThreshold, unitOfMeasure, stockLevel
FROM LaboratoryStockSummary
WHERE stockLevel = 'LOW'
ORDER BY labId, consId;

-- Displays each laboratory's inventory levels, reorder thresholds, responsible technician, monitoring start date, and a derived stockLevel flag
-- Centralizes restock threshold logic so it enables us to query low-stock alerts directly