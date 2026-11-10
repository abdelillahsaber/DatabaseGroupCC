DROP DATABASE IF EXISTS RLMS;


CREATE DATABASE RLMS;


USE RLMS;


CREATE TABLE Person (
  pid int PRIMARY KEY,
  firstName varchar(100) NOT NULL,
  lastName varchar(100) NOT NULL,
  email varchar(150) NOT NULL UNIQUE,
  affiliation varchar(150) NOT NULL,
  startDate DATE NOT NULL,
  endDate DATE DEFAULT NULL
);


CREATE TABLE Student (
  pid int PRIMARY KEY,
  program varchar(20) NOT NULL,
  FOREIGN KEY (pid) REFERENCES Person (pid) ON DELETE CASCADE
);


CREATE TABLE Employee (
  pid int PRIMARY KEY,
  phone varchar(30) NULL,
  office varchar(100) NULL,
  position varchar(30) NOT NULL,
  supervisorPid int DEFAULT NULL,
  FOREIGN KEY (pid) REFERENCES Person (pid) ON DELETE CASCADE,
  FOREIGN KEY (supervisorPid) REFERENCES Employee (pid)
);


CREATE TABLE Academic (
  pid int PRIMARY KEY,
  FOREIGN KEY (pid) REFERENCES Employee (pid) ON DELETE CASCADE
);


CREATE TABLE Faculty (
  pid int PRIMARY KEY,
  FOREIGN KEY (pid) REFERENCES Academic (pid) ON DELETE CASCADE
);


CREATE TABLE Administrative (
  pid int PRIMARY KEY,
  FOREIGN KEY (pid) REFERENCES Employee (pid) ON DELETE CASCADE
);


CREATE TABLE Technical (
  pid int PRIMARY KEY,
  FOREIGN KEY (pid) REFERENCES Employee (pid) ON DELETE CASCADE
);


CREATE TABLE Advises (
  academicPid int NOT NULL,
  studentPid int NOT NULL,
  PRIMARY KEY (academicPid, studentPid),
  FOREIGN KEY (academicPid) REFERENCES Academic (pid),
  FOREIGN KEY (studentPid) REFERENCES Student (pid)
);


CREATE TABLE Laboratory (
  labId int PRIMARY KEY,
  lname varchar(150) NOT NULL,
  building varchar(100) NOT NULL,
  roomNumber varchar(50) NOT NULL,
  discipline varchar(150) NOT NULL,
  supervisorPid int NOT NULL,
  FOREIGN KEY (supervisorPid) REFERENCES Faculty (pid) ON DELETE NO ACTION
);


CREATE TABLE Attached (
  pid int NOT NULL,
  labId int NOT NULL,
  PRIMARY KEY (pid, labId),
  FOREIGN KEY (pid) REFERENCES Person (pid),
  FOREIGN KEY (labId) REFERENCES Laboratory (labId)
);


CREATE TABLE ResearchProject (
  rpcode varchar(50) PRIMARY KEY,
  title varchar(200) NOT NULL,
  startDate DATE NOT NULL,
  endDate DATE NULL,
  researchStatus varchar(20) NOT NULL DEFAULT 'Proposed'
);


CREATE TABLE Participates (
  pid int NOT NULL,
  projectCode varchar(50) NOT NULL,
  prole varchar(30) NOT NULL,
  PRIMARY KEY (pid, projectCode),
  FOREIGN KEY (pid) REFERENCES Person (pid),
  FOREIGN KEY (projectCode) REFERENCES ResearchProject (rpcode)
);


CREATE TABLE Budget (
  budgetLine varchar(50) PRIMARY KEY,
  amountGranted decimal(12, 2) NOT NULL,
  amountDisbursed decimal(12, 2) NOT NULL,
  startDate DATE NOT NULL,
  endDate DATE NULL,
  managerPid int NOT NULL,
  FOREIGN KEY (managerPid) REFERENCES Academic (pid) ON DELETE NO ACTION
);


CREATE TABLE FundsPrj (
  budgetLine varchar(50) NOT NULL,
  projectCode varchar(50) NOT NULL,
  PRIMARY KEY (budgetLine, projectCode),
  FOREIGN KEY (budgetLine) REFERENCES Budget (budgetLine),
  FOREIGN KEY (projectCode) REFERENCES ResearchProject (rpcode)
);


CREATE TABLE FundsLab (
  budgetLine varchar(50) NOT NULL,
  labId int NOT NULL,
  PRIMARY KEY (budgetLine, labId),
  FOREIGN KEY (budgetLine) REFERENCES Budget (budgetLine),
  FOREIGN KEY (labId) REFERENCES Laboratory (labId)
);


CREATE TABLE EquipmentModel (
  modelId int PRIMARY KEY,
  commercialName varchar(150) NOT NULL,
  manufacturer varchar(150) NOT NULL,
  category varchar(100) NOT NULL,
  requiredEnvironment varchar(200) NOT NULL,
  trainingMandatory boolean NOT NULL
);


CREATE TABLE EquipmentUnit (
  serialNo varchar(100) PRIMARY KEY,
  acquisitionDate DATE NOT NULL,
  purchaseCost decimal(12, 2) NOT NULL,
  operational_status varchar(30) NOT NULL DEFAULT 'InService',
  portable boolean NOT NULL,
  modelId int NOT NULL,
  labId int NOT NULL,
  FOREIGN KEY (modelId) REFERENCES EquipmentModel (modelId) ON DELETE NO ACTION,
  FOREIGN KEY (labId) REFERENCES Laboratory (labId) ON DELETE NO ACTION
);


CREATE TABLE Certification (
  certCode varchar(50) PRIMARY KEY,
  title varchar(150) NOT NULL,
  issuingAuthority varchar(150) NOT NULL,
  validityPeriod int NOT NULL,
  safetyLevel varchar(100) NOT NULL
);


CREATE TABLE Requires (
  modelId int NOT NULL,
  certCode varchar(50) NOT NULL,
  PRIMARY KEY (modelId, certCode),
  FOREIGN KEY (modelId) REFERENCES EquipmentModel (modelId),
  FOREIGN KEY (certCode) REFERENCES Certification (certCode)
);


CREATE TABLE Holds (
  pid int NOT NULL,
  certCode varchar(50) NOT NULL,
  issueDate DATE NOT NULL,
  expirationDate DATE NOT NULL,
  grade varchar(50),
  PRIMARY KEY (pid, certCode),
  FOREIGN KEY (pid) REFERENCES Person (pid),
  FOREIGN KEY (certCode) REFERENCES Certification (certCode)
);


CREATE TABLE Reservation (
  resId int PRIMARY KEY,
  submissionTS TIMESTAMP NOT NULL,
  plannedStart TIMESTAMP NOT NULL,
  plannedEnd TIMESTAMP NOT NULL,
  purpose varchar(255) NOT NULL,
  resStatus varchar(20) NOT NULL DEFAULT 'Pending',
  madeByPid int NOT NULL,
  projectCode varchar(50) NOT NULL,
  approverPid int,
  FOREIGN KEY (madeByPid) REFERENCES Person (pid) ON DELETE NO ACTION,
  FOREIGN KEY (projectCode) REFERENCES ResearchProject (rpcode) ON DELETE NO ACTION,
  FOREIGN KEY (approverPid) REFERENCES Person (pid) ON DELETE SET NULL
);


CREATE TABLE Reserves (
  resId int NOT NULL,
  serialNo varchar(100) NOT NULL,
  PRIMARY KEY (resId, serialNo),
  FOREIGN KEY (resId) REFERENCES Reservation (resId) ON DELETE CASCADE,
  FOREIGN KEY (serialNo) REFERENCES EquipmentUnit (serialNo)
);


CREATE TABLE Maintenance (
  serialNo varchar(100) NOT NULL,
  startTS TIMESTAMP NOT NULL,
  endTS TIMESTAMP NOT NULL,
  mtype varchar(20) NOT NULL,
  mdescription varchar(255) NOT NULL,
  cost decimal(12, 2) NOT NULL,
  outcome varchar(30) NOT NULL,
  technicalPid int NOT NULL,
  PRIMARY KEY (serialNo, startTS),
  FOREIGN KEY (serialNo) REFERENCES EquipmentUnit (serialNo) ON DELETE CASCADE,
  FOREIGN KEY (technicalPid) REFERENCES Technical (pid) ON DELETE NO ACTION
);


CREATE TABLE CalibrationRecord (
  serialNo varchar(100),
  calibDate DATE NOT NULL,
  calibrationType varchar(100) NOT NULL,
  result varchar(20) NOT NULL,
  nextDueDate DATE NOT NULL,
  remarks varchar(255) NOT NULL,
  PRIMARY KEY (serialNo, calibDate),
  FOREIGN KEY (serialNo) REFERENCES EquipmentUnit (serialNo) ON DELETE CASCADE
);


CREATE TABLE Consumable (
  consId int PRIMARY KEY,
  consName varchar(150) NOT NULL,
  unitOfMeasure varchar(50) NOT NULL,
  hazardLevel varchar(100) NOT NULL,
  reorderThreshold decimal(12, 2) NOT NULL
);


CREATE TABLE Supplier (
  suppId int PRIMARY KEY,
  suppname varchar(150) NOT NULL,
  contactEmail varchar(150) NOT NULL,
  phone varchar(30) NOT NULL
);


CREATE TABLE Supplies (
  suppId int NOT NULL,
  consId int NOT NULL,
  labId int NOT NULL,
  unitPrice decimal(12, 2) NOT NULL,
  PRIMARY KEY (suppId, consId, labId),
  FOREIGN KEY (suppId) REFERENCES Supplier (suppId),
  FOREIGN KEY (consId) REFERENCES Consumable (consId),
  FOREIGN KEY (labId) REFERENCES Laboratory (labId)
);


CREATE TABLE Stocks (
  labId int NOT NULL,
  consId int NOT NULL,
  quantityOnHand decimal(12, 2) NOT NULL,
  lastRestockDate DATE NOT NULL,
  storageCondition varchar(150),
  technicalPid int NOT NULL,
  monitoringSince DATE NOT NULL,
  PRIMARY KEY (labId, consId),
  FOREIGN KEY (labId) REFERENCES Laboratory (labId),
  FOREIGN KEY (consId) REFERENCES Consumable (consId),
  FOREIGN KEY (technicalPid) REFERENCES Technical (pid) ON DELETE NO ACTION
);


CREATE TABLE Consumes (
  resId int NOT NULL,
  labId int NOT NULL,
  consId int NOT NULL,
  quantityUsed decimal(12, 2) NOT NULL,
  PRIMARY KEY (resId, labId, consId),
  FOREIGN KEY (resId) REFERENCES Reservation (resId),
  FOREIGN KEY (labId, consId) REFERENCES Stocks (labId, consId)
);