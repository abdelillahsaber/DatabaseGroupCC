--Slide 2/11

CREATE TABLE Person (
    personId INT PRIMARY KEY,
    firstName VARCHAR,
    lastName VARCHAR,
    email VARCHAR,
    affiliation VARCHAR,
    startDate DATE,
    endDate DATE
);

CREATE TABLE Student (
    studentId INT PRIMARY KEY,
    program VARCHAR,
    FOREIGN KEY (studentId) REFERENCES Person(personId),
);

CREATE TABLE Employee (
    employeeId INT PRIMARY KEY,
    phone VARCHAR,
    office VARCHAR,
    supervisorId VARCHAR,
    FOREIGN KEY (supervisorId) REFERENCES Employee(employeeId),
    FOREIGN KEY (employeeId) REFERENCES Person(personId),
);

CREATE TABLE Academic (
    academicId INT PRIMARY KEY,
    FOREIGN KEY (academicId) REFERENCES Employee(employeeId)
);

CREATE TABLE Faculty (
    facultyId INT PRIMARY KEY,
    FOREIGN KEY (facultyId) REFERENCES Academic(academicId)
);

CREATE TABLE NonAcademic (
    nonAcademicId INT PRIMARY KEY,
    FOREIGN KEY (nonAcademicId) REFERENCES Employee(employeeId)
);

CREATE TABLE Administrative (
    administrativeId INT PRIMARY KEY,
    FOREIGN KEY (administrativeId) REFERENCES NonAcademic(nonAcademicId)
);

CREATE TABLE Technical (
    technicalId INT PRIMARY KEY,
    FOREIGN KEY (administrativeId) REFERENCES NonAcademic(nonAcademicId)
);

CREATE TABLE Advises (
    studentId INT,
    academicId INT NOT NULL,
    PRIMARY KEY (studentId,academicId),
    FOREIGN KEY (studentId) REFERENCES Student(studentId),
    FOREIGN KEY (academicId) REFERENCES Academic(academicId)
);

--Slide 3/11

CREATE TABLE Laboratory (
    labId INT PRIMARY KEY,
    labName VARCHAR,
    building VARCHAR,
    roomNumber INT,
    discipline VARCHAR,
    supervisorId INT NOT NULL,
    FOREIGN KEY (supervisorId) REFERENCES Faculty(facultyId) ON DELETE NO ACTION
);

CREATE TABLE ReaserchProject (
    pCode VARCHAR PRIMARY KEY,
    title VARCHAR,
    startDate DATE,
    endDate DATE,
    pStatus varchar,
);

CREATE TABLE Budget (
    budgetLine INT PRIMARY KEY,
    amountGranted INT,
    amountDisbursed INT,
    startDate DATE,
    endDate DATE,
    managerId INT NOT NULL,
    FOREIGN KEY (managerId) REFERENCES Academic(academicId) ON DELETE NO ACTION
);

CREATE TABLE FundsLab (
    labId INT,
    budgetLine INT NOT NULL,
    PRIMARY KEY (labId,budgetLine),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId),
    FOREIGN KEY (budgetLine) REFERENCES Budget(budgetLine)
);

CREATE TABLE FundsPrj (
    pCode VARCHAR,
    budgetLine INT NOT NULL,
    PRIMARY KEY (pCode,budgetLine),
    FOREIGN KEY (pCode) REFERENCES ResearchProject(pCode),
    FOREIGN KEY (budgetLine) REFERENCES Budget(budgetLine)
);

CREATE TABLE Attached (
    labId INT,
    personId INT NOT NULL,
    PRIMARY KEY (labId,personId),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId),
    FOREIGN KEY (personId) REFERENCES Person(personId)
);

CREATE TABLE Participates (
    pCode VARCHAR,
    personId INT NOT NULL,
    pRole VARCHAR,
    PRIMARY KEY (pCode,personId),
    FOREIGN KEY (pCode) REFERENCES ResearchProject(pCode),
    FOREIGN KEY (personId) REFERENCES Person(personId)
);

--Slide 4/11

CREATE TABLE EquipmentModel (
    modelId INT PRIMARY KEY,
    commercialName VARCHAR,
    manufacturer VARCHAR,
    category VARCHAR,
    requiredEnvironment VARCHAR,
    trainingMandatory BOOLEAN
)

CREATE TABLE EquipmentUnit (
    serialNo INT PRIMARY KEY,
    acquisitionDate DATE,
    purchaseDate DATE,
    euStatus VARCHAR,
    portable BOOLEAN,
    instanceOf INT NOT NULL,
    locatedIn INT NOT NULL,
    FOREIGN KEY (locatedIn) REFERENCES Laboratory(labId) ON DELETE NO ACTION,
    FOREIGN KEY (instanceOf) REFERENCES EquipmentModel(modelId) ON DELETE NO ACTION
)

CREATE TABLE Certification (
    cCode INT PRIMARY KEY,
    cTitle VARCHAR,
    issuingAuthority VARCHAR,
    validityPeriod VARCHAR,
    safetyLevel VARCHAR,
)

CREATE TABLE Requires (
    cCode INT,
    modelId INT,
    PRIMARY KEY (cCode,modelId),
    FOREIGN KEY (cCode) REFERENCES Certification(cCode),
    FOREIGN KEY (modelId) REFERENCES EquipmentModel(modelId),
)

CREATE TABLE Holdes (
    cCode INT,
    personId INT,
    expirationDate DATE,
    issueDate DATE,
    grade VARCHAR,
    PRIMARY KEY (cCode,personId),
    FOREIGN KEY (cCode) REFERENCES Certification(cCode),
    FOREIGN KEY (personId) REFERENCES Person(personId)
)

--Slide 5/11

CREATE TABLE Reservation (
    resId INT PRIMARY KEY,
    submissionTS DATE,
    plannedStart DATE,
    plannedEnd DATE,
    purpose VARCHAR,
    resStatus VARCHAR,
    madeBy INT NOT NULL,
    FOREIGN KEY (madeBy) REFERENCES Person(personId) ON DELETE NO ACTION,
    forRP VARCHAR NOT NULL,
    FOREIGN KEY (forRP) REFERENCES ResearchProject(pCode) ON DELETE NO ACTION,
    approvedBy INT,
    FOREIGN KEY (approvedBy) REFERENCES Person(personId)
)

CREATE TABLE Reserves (
    serialNo INT NOT NULL,
    reservationId INT,
    PRIMARY KEY (serialNo, reservationId),
    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo),
    FOREIGN KEY (reservationId) REFERENCES Reservation(resId)
)

--Slide 6/11

CREATE TABLE Maintenance (
    startTS DATE NOT NULL,
    hasMaint INT NOT NULL,
    FOREIGN KEY (hasMaint) REFERENCES EquipmentUnit(serialNo) ON DELETE CASCADE,
    PRIMARY KEY (startTS, hasMaint),
    endTS DATE,
    maintenanceType VARCHAR,
    maintenanceDescription VARCHAR,
    cost FLOAT,
    outCome VARCHAR,
    doneBy INT NOT NULL,
    FOREIGN KEY (doneBy) REFERENCES Technical(technicalId) ON DELETE NO ACTION
)

CREATE TABLE CalibrationRecord (
    calibDate DATE NOT NULL,
    hasCalib INT NOT NULL,
    FOREIGN KEY (hasCalib) REFERENCES EquipmentUnit(serialNo) ON DELETE CASCADE,
    PRIMARY KEY (calibDate, hasCalib),
    calibrationType VARCHAR,
    result VARCHAR,
    nextDueDate DATE,
    remarks VARCHAR
)

--Slide 7/11

CREATE TABLE Consumable (
    consId INT PRIMARY KEY,
    consName VARCHAR,
    unitOfMeasure VARCHAR,
    hazardLevel VARCHAR,
    reorderThreshold VARCHAR,
);

CREATE TABLE Stocks (
    consId INT,
    labId INT,
    lastRestockDate DATE,
    quantityOnHand INT,
    storageCondition VARCHAR,
    monitoredBy INT NOT NULL,
    monitoredSince DATE,
    FOREIGN KEY (monitoredBy) REFERENCES Technical(technicalId) ON DELETE NO ACTION,
    PRIMARY KEY (consId,labId),
    FOREIGN KEY (consId) REFERENCES Consumable(consId),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId)
);

CREATE TABLE Consumes (
    consId INT,
    labId INT,
    resId INT,
    quantityUsed INT,
    PRIMARY KEY (consId,labId,resId),
    FOREIGN KEY (consId,labId) REFERENCES Stocks(consId,labId),
    FOREIGN KEY (resId) REFERENCES Reservation(resId)
);

CREATE TABLE Supplier (
    suppId INT PRIMARY KEY,
    supName VARCHAR,
    contactEmail VARCHAR,
    phone INT,
);

CREATE TABLE Supplies (
    consId INT,
    labId INT,
    suppId INT,
    unitPrice INT,
    PRIMARY KEY (consId,labId,suppId),
    FOREIGN KEY (consId) REFERENCES Consumable(consId),
    FOREIGN KEY (labId) REFERENCES Laboratory(labId),
    FOREIGN KEY (suppId) REFERENCES Supplier(suppId)
);