-- Consolidated table and schema setup/* Generated from the original split SQL files */-- Step 2: Database Creation Script
CREATE DATABASE SMS;
GO
USE SMS;
GO



-- Step 3: Table Creation Script
-- Note: Contains only table definitions and primary keys. No foreign keys, unique constraints, check constraints, or indexes are included.

USE SMS;
GO

-- 1. FinancialYear Table
CREATE TABLE FinancialYear (
    FinancialYearId INT IDENTITY(1,1) PRIMARY KEY,
    FinancialYear VARCHAR(20) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsCurrent BIT NOT NULL DEFAULT 0,
    
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 2. DivisionMaster Table
CREATE TABLE DivisionMaster (
    DivisionId INT IDENTITY(1,1) PRIMARY KEY,
    DivisionName VARCHAR(50) NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 3. ClassMaster Table
CREATE TABLE ClassMaster (
    ClassId INT IDENTITY(1,1) PRIMARY KEY,
    ClassName VARCHAR(50) NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 4. ClassSchedules Table
CREATE TABLE ClassSchedules (
    ClassScheduleId INT IDENTITY(1,1) PRIMARY KEY,
    ClassId INT NOT NULL,
    DivisionId INT NOT NULL,
    FinancialYearId INT NOT NULL,
    MaxCapacity INT NOT NULL,
    StaffId INT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 5. StudentInfo Table
CREATE TABLE StudentInfo (
    StudentId INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Basic Information
    GrNo VARCHAR(20) NOT NULL,
    AdmissionDate DATE NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50) NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    StudentPhoto VARBINARY(MAX) NULL,
    
    -- Personal Information
    PlaceOfBirth VARCHAR(100) NULL,
    Nationality VARCHAR(50) NOT NULL DEFAULT 'Indian',
    BloodGroup VARCHAR(5) NULL,
    Category VARCHAR(30) NULL,
    Religion VARCHAR(50) NULL,
    AadhaarNumber VARCHAR(12) NULL,
    
    -- Address Information
    AddressLine1 VARCHAR(150) NOT NULL,
    AddressLine2 VARCHAR(150) NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL DEFAULT 'India',
    PinCode VARCHAR(10) NOT NULL,
    
    -- Parent Information
    FatherName VARCHAR(100) NOT NULL,
    FatherOccupation VARCHAR(100) NULL,
    FatherMobileNumber VARCHAR(15) NOT NULL,
    MotherName VARCHAR(100) NOT NULL,
    MotherOccupation VARCHAR(100) NULL,
    MotherMobileNumber VARCHAR(15) NULL,
    
    -- Guardian Information
    GuardianName VARCHAR(100) NULL,
    GuardianMobileNumber VARCHAR(15) NULL,
    EmergencyContactNumber VARCHAR(15) NOT NULL,
    
    -- Academic Information
    PreviousSchoolName VARCHAR(150) NULL,
    AdmissionFinancialYearId INT NOT NULL,
    
    -- Communication Information
    EmailAddress VARCHAR(100) NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 6. StudentMappings Table
CREATE TABLE StudentMappings (
    StudentMappingId INT IDENTITY(1,1) PRIMARY KEY,
    StudentId INT NOT NULL,
    ClassScheduleId INT NOT NULL,
    FinancialYearId INT NOT NULL,
    RollNo INT NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 7. Users Table
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    EmailAddress VARCHAR(100) NULL,
    LastLoginDate DATETIME2 NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 8. Roles Table
CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 9. UserRoles Table
CREATE TABLE UserRoles (
    UserRoleId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    RoleId INT NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 10. AuditLogs Table
CREATE TABLE AuditLogs (
    AuditLogId INT IDENTITY(1,1) PRIMARY KEY,
    TableName VARCHAR(100) NOT NULL,
    RecordId INT NOT NULL,
    OperationType VARCHAR(10) NOT NULL,
    OldValuesJson NVARCHAR(MAX) NULL,
    NewValuesJson NVARCHAR(MAX) NULL,
    PerformedBy INT NOT NULL,
    IPAddress VARCHAR(50) NULL,
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    
    -- Global Audit Columns (including CreatedBy for standardized mapping)
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 11. SemesterMaster Table
CREATE TABLE SemesterMaster (
    SemesterID INT IDENTITY(1,1) PRIMARY KEY,
    SemesterName NVARCHAR(30) NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 12. FeeMaster Table
CREATE TABLE FeeMaster (
    FeeID INT IDENTITY(1,1) PRIMARY KEY,
    Fee DECIMAL(18,2) NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 13. FeeDetail Table
CREATE TABLE FeeDetail (
    FeeDetailID INT IDENTITY(1,1) PRIMARY KEY,
    FeeID INT NOT NULL,
    ClassID INT NOT NULL,
    FinancialYearID INT NOT NULL,
    SemesterID INT NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 14. PaymentDetail Table
CREATE TABLE PaymentDetail (
    PaymentDetailID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    FinancialYearID INT NOT NULL,
    FeeID INT NOT NULL,
    PaymentMode VARCHAR(12) NOT NULL,
    TransactionRef NVARCHAR(50) NULL,
    Transactionphoto NVARCHAR(MAX) NULL, -- stores base64 string
    IsFullyPaid BIT NOT NULL DEFAULT 0,
    SemesterID INT NOT NULL,
    FeePaid DECIMAL(18,2) NOT NULL,
    TotalInstallment INT NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 15. StaffTypeMaster Table
CREATE TABLE StaffTypeMaster (
    StaffTypeID INT IDENTITY(1,1) PRIMARY KEY,
    StaffType NVARCHAR(50) NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

-- 16. StaffDetail Table
CREATE TABLE StaffDetail (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    StaffFirstName NVARCHAR(50) NOT NULL,
    StaffMiddleName NVARCHAR(50) NULL,
    StaffLastName NVARCHAR(50) NOT NULL,
    StaffType INT NOT NULL,
    Mobileno VARCHAR(15) NOT NULL,
    EmergencyContact VARCHAR(15) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    AadhaarNo VARCHAR(12) NOT NULL,
    BankName NVARCHAR(50) NOT NULL,
    IFSCCode NVARCHAR(20) NOT NULL,
    AccountNo NVARCHAR(20) NOT NULL,
    PanNo NVARCHAR(20) NOT NULL,
    StaffPic NVARCHAR(MAX) NULL, -- stores base64 string
    DOB DATE NOT NULL,
    
    -- Global Audit Columns
    CreatedDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO



-- Step 4: Constraints Script (Foreign Keys and Check Constraints)
USE SMS;
GO

-- ============================================================================
-- 1. FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- ClassSchedules Foreign Keys
ALTER TABLE ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_Classes_ClassId 
    FOREIGN KEY (ClassId) REFERENCES ClassMaster(ClassId);

ALTER TABLE ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_Divisions_DivisionId 
    FOREIGN KEY (DivisionId) REFERENCES DivisionMaster(DivisionId);

ALTER TABLE ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_FinancialYears_FinancialYearId 
    FOREIGN KEY (FinancialYearId) REFERENCES FinancialYear(FinancialYearId);

-- StudentInfo Foreign Keys
ALTER TABLE StudentInfo
    ADD CONSTRAINT FK_Students_FinancialYears_AdmissionFinancialYearId 
    FOREIGN KEY (AdmissionFinancialYearId) REFERENCES FinancialYear(FinancialYearId);

-- StudentMappings Foreign Keys
ALTER TABLE StudentMappings
    ADD CONSTRAINT FK_StudentMappings_Students_StudentId 
    FOREIGN KEY (StudentId) REFERENCES StudentInfo(StudentId);

ALTER TABLE StudentMappings
    ADD CONSTRAINT FK_StudentMappings_ClassSchedules_ClassScheduleId 
    FOREIGN KEY (ClassScheduleId) REFERENCES ClassSchedules(ClassScheduleId);

ALTER TABLE StudentMappings
    ADD CONSTRAINT FK_StudentMappings_FinancialYears_FinancialYearId 
    FOREIGN KEY (FinancialYearId) REFERENCES FinancialYear(FinancialYearId);

-- UserRoles Foreign Keys
ALTER TABLE UserRoles
    ADD CONSTRAINT FK_UserRoles_Users_UserId 
    FOREIGN KEY (UserId) REFERENCES Users(UserId);

ALTER TABLE UserRoles
    ADD CONSTRAINT FK_UserRoles_Roles_RoleId 
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId);

-- ClassSchedules -> StaffDetail
ALTER TABLE ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_StaffDetail_StaffId
    FOREIGN KEY (StaffId) REFERENCES StaffDetail(StaffID);

-- FeeDetail Foreign Keys
ALTER TABLE FeeDetail
    ADD CONSTRAINT FK_FeeDetail_FeeMaster_FeeId
    FOREIGN KEY (FeeID) REFERENCES FeeMaster(FeeID);

ALTER TABLE FeeDetail
    ADD CONSTRAINT FK_FeeDetail_ClassMaster_ClassId
    FOREIGN KEY (ClassID) REFERENCES ClassMaster(ClassId);

ALTER TABLE FeeDetail
    ADD CONSTRAINT FK_FeeDetail_FinancialYears_FinancialYearId
    FOREIGN KEY (FinancialYearID) REFERENCES FinancialYear(FinancialYearId);

ALTER TABLE FeeDetail
    ADD CONSTRAINT FK_FeeDetail_SemesterMaster_SemesterId
    FOREIGN KEY (SemesterID) REFERENCES SemesterMaster(SemesterID);

-- PaymentDetail Foreign Keys
ALTER TABLE PaymentDetail
    ADD CONSTRAINT FK_PaymentDetail_Students_StudentId
    FOREIGN KEY (StudentID) REFERENCES StudentInfo(StudentId);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT FK_PaymentDetail_FinancialYears_FinancialYearId
    FOREIGN KEY (FinancialYearID) REFERENCES FinancialYear(FinancialYearId);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT FK_PaymentDetail_FeeMaster_FeeId
    FOREIGN KEY (FeeID) REFERENCES FeeMaster(FeeID);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT FK_PaymentDetail_SemesterMaster_SemesterId
    FOREIGN KEY (SemesterID) REFERENCES SemesterMaster(SemesterID);

-- StaffDetail -> StaffTypeMaster
ALTER TABLE StaffDetail
    ADD CONSTRAINT FK_StaffDetail_StaffTypeMaster_StaffType
    FOREIGN KEY (StaffType) REFERENCES StaffTypeMaster(StaffTypeID);


-- ============================================================================
-- 2. CHECK CONSTRAINTS
-- ============================================================================

-- FinancialYear StartDate & EndDate Check
ALTER TABLE FinancialYear
    ADD CONSTRAINT CK_FinancialYears_Dates 
    CHECK (StartDate < EndDate);

-- ClassSchedules MaxCapacity Check
ALTER TABLE ClassSchedules
    ADD CONSTRAINT CK_ClassSchedules_MaxCapacity 
    CHECK (MaxCapacity > 0);

-- StudentInfo Gender Check
ALTER TABLE StudentInfo
    ADD CONSTRAINT CK_Students_Gender 
    CHECK (Gender IN ('Male', 'Female', 'Other'));

-- AuditLogs OperationType Check
ALTER TABLE AuditLogs
    ADD CONSTRAINT CK_AuditLogs_OperationType 
    CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE'));

-- FeeMaster Fee Check
ALTER TABLE FeeMaster
    ADD CONSTRAINT CK_FeeMaster_Fee
    CHECK (Fee >= 0);

-- PaymentDetail Checks
ALTER TABLE PaymentDetail
    ADD CONSTRAINT CK_PaymentDetail_FeePaid
    CHECK (FeePaid >= 0);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT CK_PaymentDetail_TotalInstallment
    CHECK (TotalInstallment > 0);

ALTER TABLE PaymentDetail
    ADD CONSTRAINT CK_PaymentDetail_PaymentMode
    CHECK (PaymentMode IN ('Cash', 'Card', 'UPI', 'NetBanking', 'Cheque'));
GO



-- Step 5: Indexes Script
USE SMS;
GO

-- ============================================================================
-- 1. UNIQUE FILTERED INDEXES (For Soft-Delete Uniqueness & Logic Enforcements)
-- ============================================================================

-- Enforce only ONE current financial year among active (non-deleted) records
CREATE UNIQUE INDEX UX_FinancialYears_IsCurrent 
ON FinancialYear(IsCurrent) 
WHERE IsCurrent = 1 AND IsDeleted = 0;

-- Enforce unique FinancialYear name among active records
CREATE UNIQUE INDEX UX_FinancialYears_FinancialYear 
ON FinancialYear(FinancialYear) 
WHERE IsDeleted = 0;

-- Enforce unique DivisionName among active records
CREATE UNIQUE INDEX UX_Divisions_DivisionName 
ON DivisionMaster(DivisionName) 
WHERE IsDeleted = 0;

-- Enforce unique ClassName among active records
CREATE UNIQUE INDEX UX_Classes_ClassName 
ON ClassMaster(ClassName) 
WHERE IsDeleted = 0;

-- Enforce unique ClassSchedules (FinancialYearId + ClassId + DivisionId) among active records
CREATE UNIQUE INDEX UX_ClassSchedules_Year_Class_Div 
ON ClassSchedules(FinancialYearId, ClassId, DivisionId) 
WHERE IsDeleted = 0;

-- Enforce unique GrNo (General Register Number) for students among active records
CREATE UNIQUE INDEX UX_Students_GrNo 
ON StudentInfo(GrNo) 
WHERE IsDeleted = 0;

-- Enforce one student can belong to only one class schedule per financial year among active records
CREATE UNIQUE INDEX UX_StudentMappings_Year_Student 
ON StudentMappings(FinancialYearId, StudentId) 
WHERE IsDeleted = 0;

-- Enforce unique RollNo within a ClassSchedule among active records
CREATE UNIQUE INDEX UX_StudentMappings_Schedule_RollNo 
ON StudentMappings(ClassScheduleId, RollNo) 
WHERE IsDeleted = 0;

-- Enforce unique Username among active records
CREATE UNIQUE INDEX UX_Users_Username 
ON Users(Username) 
WHERE IsDeleted = 0;

-- Enforce unique RoleName among active records
CREATE UNIQUE INDEX UX_Roles_RoleName 
ON Roles(RoleName) 
WHERE IsDeleted = 0;

-- Enforce unique mapping between User and Role among active records
CREATE UNIQUE INDEX UX_UserRoles_User_Role 
ON UserRoles(UserId, RoleId) 
WHERE IsDeleted = 0;


-- ============================================================================
-- 2. NON-CLUSTERED INDEXES (For Performance Optimization)
-- ============================================================================

-- Optimize Student Search by Name
CREATE NONCLUSTERED INDEX IX_Students_Name 
ON StudentInfo(LastName, FirstName, MiddleName) 
WHERE IsDeleted = 0;

-- Optimize Student Search by Mobile Number
CREATE NONCLUSTERED INDEX IX_Students_FatherMobileNumber 
ON StudentInfo(FatherMobileNumber) 
WHERE IsDeleted = 0;

-- Optimize Student Search by Email
CREATE NONCLUSTERED INDEX IX_Students_EmailAddress 
ON StudentInfo(EmailAddress) 
WHERE IsDeleted = 0 AND EmailAddress IS NOT NULL;

-- Optimize Dashboard Queries: Student Mappings queries
CREATE NONCLUSTERED INDEX IX_StudentMappings_ClassScheduleId 
ON StudentMappings(ClassScheduleId) 
INCLUDE (StudentId, RollNo) 
WHERE IsDeleted = 0;

-- Optimize Dashboard Queries: Student count by Financial Year
CREATE NONCLUSTERED INDEX IX_StudentMappings_FinancialYearId 
ON StudentMappings(FinancialYearId) 
INCLUDE (StudentId) 
WHERE IsDeleted = 0;

-- Optimize Audit Log Retrieval by Table Name
CREATE NONCLUSTERED INDEX IX_AuditLogs_TableName_RecordId 
ON AuditLogs(TableName, RecordId);

-- Optimize Audit Log Retrieval by Date
CREATE NONCLUSTERED INDEX IX_AuditLogs_CreatedDate 
ON AuditLogs(CreatedDate);
GO




