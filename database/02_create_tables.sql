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

