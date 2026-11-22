USE RLMS;
-- Q1. Function: 
DROP FUNCTION IF EXISTS availableUnits;

DELIMITER //

CREATE FUNCTION availableUnits(mId INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE result INT;

    SELECT COUNT(*) INTO result
    FROM EquipmentUnit EQ
    WHERE EQ.modelId = mId
      AND EQ.status = 'InService';

    RETURN result;
END//
DELIMITER ;

-- Q1

SELECT commercialName,
       availableUnits(modelId) AS availableUnits
FROM EquipmentModel;


-- Q2. Procedure:
DROP PROCEDURE IF EXISTS RestockLab;
DELIMITER //

CREATE PROCEDURE RestockLab(
    IN p_labId INT,
    IN p_consId INT,
    IN p_qty DECIMAL(12,2),
    OUT newQuantity DECIMAL(12,2)
)
BEGIN
    IF p_qty IS NULL OR p_qty <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be strictly positive';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Stocks
        WHERE labId = p_labId
          AND consId = p_consId
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'No stock exists for this laboratory and consumable';
    END IF;

    UPDATE Stocks
    SET quantityOnHand = quantityOnHand + p_qty,
        lastRestockDate = CURRENT_DATE()
    WHERE labId = p_labId
      AND consId = p_consId;

    SELECT quantityOnHand INTO newQuantity
    FROM Stocks
    WHERE labId = p_labId
      AND consId = p_consId;
END//

DELIMITER ;

-- Q2.  Before table:
SELECT labId, consId, quantityOnHand, lastRestockDate
FROM Stocks
WHERE labId = 1 AND consId = 1;

-- q2. Add 10 units and display the OUT parameter.

CALL RestockLab(1, 1, 10, @newQuantity);
SELECT @newQuantity AS newQuantity;

-- q2. Verification after the procedure

SELECT labId, consId, quantityOnHand, lastRestockDate
FROM Stocks
WHERE labId = 1 AND consId = 1;