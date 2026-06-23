# School Management System (SMS) - Database Schema & Objects

This document contains the consolidated SQL scripts for creating and seeding the SQL Server database schema. It reflects the updated architecture where the student photo is stored as binary data (`VARBINARY(MAX)`) rather than file paths, and uses the correct `StudentInfo` table mappings.

---

## 1. Database & Tables Creation

```sql
-- DATABASE CREATION
USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SMS')
BEGIN
    ALTER DATABASE SMS SET MULTI_USER WITH ROLLBACK IMMEDIATE;
    ALTER DATABASE SMS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SMS;
END
GO

CREATE DATABASE SMS;
GO

USE SMS;
GO

-- 1. FinancialYear Table
CREATE TABLE FinancialYear (
    FinancialYearId INT IDENTITY(1,1) PRIMARY KEY,
    FinancialYear VARCHAR(20) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsCurrent BIT NOT NULL DEFAULT 0,
    
    -- Global Audit Columns
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

-- 5. StudentInfo Table (Stores Binary StudentPhoto)
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
    StudentPhoto VARBINARY(MAX) NULL, -- Stores compressed photo byte arrays
    
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
    
    -- Global Audit Columns
    CreatedBy INT NOT NULL,
    UpdatedDate DATETIME2 NULL,
    UpdatedBy INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO
```

---

## 2. Constraints & Indexes

```sql
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

-- Students Foreign Keys
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

-- ============================================================================
-- CHECK CONSTRAINTS
-- ============================================================================
ALTER TABLE FinancialYear
    ADD CONSTRAINT CK_FinancialYears_Dates 
    CHECK (StartDate < EndDate);

ALTER TABLE ClassSchedules
    ADD CONSTRAINT CK_ClassSchedules_MaxCapacity 
    CHECK (MaxCapacity > 0);

ALTER TABLE StudentInfo
    ADD CONSTRAINT CK_Students_Gender 
    CHECK (Gender IN ('Male', 'Female', 'Other'));

ALTER TABLE AuditLogs
    ADD CONSTRAINT CK_AuditLogs_OperationType 
    CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE'));

-- ============================================================================
-- UNIQUE & PERFORMANCE INDEXES
-- ============================================================================
CREATE UNIQUE INDEX UX_FinancialYears_IsCurrent 
ON FinancialYear(IsCurrent) 
WHERE IsCurrent = 1 AND IsDeleted = 0;

CREATE UNIQUE INDEX UX_FinancialYears_FinancialYear 
ON FinancialYear(FinancialYear) 
WHERE IsDeleted = 0;

CREATE UNIQUE INDEX UX_Divisions_DivisionName 
ON DivisionMaster(DivisionName) 
WHERE IsDeleted = 0;

CREATE UNIQUE INDEX UX_Classes_ClassName 
ON ClassMaster(ClassName) 
WHERE IsDeleted = 0;

CREATE UNIQUE INDEX UX_ClassSchedules_Year_Class_Div 
ON ClassSchedules(FinancialYearId, ClassId, DivisionId) 
WHERE IsDeleted = 0;

CREATE UNIQUE INDEX UX_Students_GrNo 
ON StudentInfo(GrNo) 
WHERE IsDeleted = 0;

CREATE UNIQUE INDEX UX_StudentMappings_Year_Student 
ON StudentMappings(FinancialYearId, StudentId) 
WHERE IsDeleted = 0;

CREATE UNIQUE INDEX UX_StudentMappings_Schedule_RollNo 
ON StudentMappings(ClassScheduleId, RollNo) 
WHERE IsDeleted = 0;

CREATE UNIQUE INDEX UX_Users_Username 
ON Users(Username) 
WHERE IsDeleted = 0;

CREATE UNIQUE INDEX UX_Roles_RoleName 
ON Roles(RoleName) 
WHERE IsDeleted = 0;

CREATE UNIQUE INDEX UX_UserRoles_User_Role 
ON UserRoles(UserId, RoleId) 
WHERE IsDeleted = 0;

CREATE NONCLUSTERED INDEX IX_Students_Name 
ON StudentInfo(LastName, FirstName, MiddleName) 
WHERE IsDeleted = 0;

CREATE NONCLUSTERED INDEX IX_Students_FatherMobileNumber 
ON StudentInfo(FatherMobileNumber) 
WHERE IsDeleted = 0;

CREATE NONCLUSTERED INDEX IX_Students_EmailAddress 
ON StudentInfo(EmailAddress) 
WHERE IsDeleted = 0 AND EmailAddress IS NOT NULL;

CREATE NONCLUSTERED INDEX IX_StudentMappings_ClassScheduleId 
ON StudentMappings(ClassScheduleId) 
INCLUDE (StudentId, RollNo) 
WHERE IsDeleted = 0;

CREATE NONCLUSTERED INDEX IX_StudentMappings_FinancialYearId 
ON StudentMappings(FinancialYearId) 
INCLUDE (StudentId) 
WHERE IsDeleted = 0;

CREATE NONCLUSTERED INDEX IX_AuditLogs_TableName_RecordId 
ON AuditLogs(TableName, RecordId);

CREATE NONCLUSTERED INDEX IX_AuditLogs_CreatedDate 
ON AuditLogs(CreatedDate);
GO
```

---

## 3. Seed Data

```sql
-- 1. Seed Roles
INSERT INTO Roles (RoleName, CreatedBy)
VALUES 
    ('Administrator', 1),
    ('Clerk', 1);

-- 2. Seed Default Admin User
-- Supply AdminPasswordHash through sqlcmd or your deployment secret store.
INSERT INTO Users (Username, PasswordHash, FullName, EmailAddress, CreatedBy)
VALUES 
    ('admin', '$(AdminPasswordHash)', 'System Administrator', 'admin@sms.com', 1);

-- 3. Map Admin User to Administrator Role
INSERT INTO UserRoles (UserId, RoleId, CreatedBy)
VALUES 
    (1, 1, 1);

-- 4. Seed FinancialYear
INSERT INTO FinancialYear (FinancialYear, StartDate, EndDate, IsCurrent, CreatedBy)
VALUES 
    ('2025-2026', '2025-04-01', '2026-03-31', 0, 1),
    ('2026-2027', '2026-04-01', '2027-03-31', 1, 1);

-- 5. Seed DivisionMaster
INSERT INTO DivisionMaster (DivisionName, CreatedBy)
VALUES 
    ('A', 1),
    ('B', 1),
    ('C', 1),
    ('D', 1);

-- 6. Seed ClassMaster
INSERT INTO ClassMaster (ClassName, CreatedBy)
VALUES 
    ('Nursery', 1),
    ('Jr KG', 1),
    ('Sr KG', 1),
    ('Class 1', 1),
    ('Class 2', 1),
    ('Class 3', 1),
    ('Class 4', 1),
    ('Class 5', 1),
    ('Class 6', 1),
    ('Class 7', 1),
    ('Class 8', 1),
    ('Class 9', 1),
    ('Class 10', 1),
    ('Class 11', 1),
    ('Class 12', 1);
GO
```

---

## 4. Functions & Views

```sql
-- 1. GR Number Generation Function
CREATE FUNCTION fn_GenerateGrNo (
    @AdmissionFinancialYearId INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @FinancialYear VARCHAR(20);
    DECLARE @Prefix VARCHAR(10);
    DECLARE @NextSequence INT = 1;
    DECLARE @NextGrNo VARCHAR(20);

    SELECT @FinancialYear = FinancialYear 
    FROM FinancialYear 
    WHERE FinancialYearId = @AdmissionFinancialYearId;

    IF @FinancialYear IS NULL
        RETURN NULL;

    -- GR-2627- (From '2026-2027')
    SET @Prefix = 'GR-' 
                  + SUBSTRING(@FinancialYear, 3, 2) 
                  + SUBSTRING(@FinancialYear, 8, 2) 
                  + '-';

    SELECT @NextSequence = ISNULL(MAX(CAST(SUBSTRING(GrNo, 9, 4) AS INT)), 0) + 1
    FROM StudentInfo
    WHERE GrNo LIKE @Prefix + '%';

    SET @NextGrNo = @Prefix + RIGHT('0000' + CAST(@NextSequence AS VARCHAR), 4);

    RETURN @NextGrNo;
END;
GO

-- 2. Active Class Schedules View
CREATE VIEW vw_ActiveClassSchedules
AS
SELECT 
    cs.ClassScheduleId,
    cs.ClassId,
    c.ClassName,
    cs.DivisionId,
    d.DivisionName,
    cs.FinancialYearId,
    fy.FinancialYear,
    fy.IsCurrent AS IsCurrentFinancialYear,
    cs.MaxCapacity,
    cs.IsActive,
    cs.CreatedDate,
    cs.CreatedBy,
    cs.UpdatedDate,
    cs.UpdatedBy
FROM ClassSchedules cs
INNER JOIN ClassMaster c ON cs.ClassId = c.ClassId AND c.IsDeleted = 0 AND c.IsActive = 1
INNER JOIN DivisionMaster d ON cs.DivisionId = d.DivisionId AND d.IsDeleted = 0 AND d.IsActive = 1
INNER JOIN FinancialYear fy ON cs.FinancialYearId = fy.FinancialYearId AND fy.IsDeleted = 0 AND fy.IsActive = 1
WHERE cs.IsDeleted = 0 AND cs.IsActive = 1;
GO

-- 3. Student Details View (Exposes StudentPhoto VARBINARY)
CREATE VIEW vw_StudentDetails
AS
SELECT 
    s.StudentId,
    s.GrNo,
    s.AdmissionDate,
    s.FirstName,
    s.MiddleName,
    s.LastName,
    (s.FirstName + ' ' + ISNULL(s.MiddleName + ' ', '') + s.LastName) AS FullName,
    s.DateOfBirth,
    s.Gender,
    s.StudentPhoto,
    s.PlaceOfBirth,
    s.Nationality,
    s.BloodGroup,
    s.Category,
    s.Religion,
    s.AadhaarNumber,
    s.AddressLine1,
    s.AddressLine2,
    s.City,
    s.State,
    s.Country,
    s.PinCode,
    s.FatherName,
    s.FatherOccupation,
    s.FatherMobileNumber,
    s.MotherName,
    s.MotherOccupation,
    s.MotherMobileNumber,
    s.GuardianName,
    s.GuardianMobileNumber,
    s.EmergencyContactNumber,
    s.PreviousSchoolName,
    s.AdmissionFinancialYearId,
    fy_adm.FinancialYear AS AdmissionFinancialYear,
    s.EmailAddress,
    s.IsActive AS IsStudentActive,
    
    -- Mapping & Classroom details
    sm.StudentMappingId,
    sm.RollNo,
    cs.ClassScheduleId,
    cs.ClassId,
    c.ClassName,
    cs.DivisionId,
    d.DivisionName,
    sm.FinancialYearId AS MappingFinancialYearId,
    fy_map.FinancialYear AS MappingFinancialYear,
    fy_map.IsCurrent AS IsCurrentMappingYear
FROM StudentInfo s
INNER JOIN FinancialYear fy_adm ON s.AdmissionFinancialYearId = fy_adm.FinancialYearId AND fy_adm.IsDeleted = 0
LEFT JOIN StudentMappings sm ON s.StudentId = sm.StudentId AND sm.IsDeleted = 0 AND sm.IsActive = 1
LEFT JOIN ClassSchedules cs ON sm.ClassScheduleId = cs.ClassScheduleId AND cs.IsDeleted = 0 AND cs.IsActive = 1
LEFT JOIN ClassMaster c ON cs.ClassId = c.ClassId AND c.IsDeleted = 0
LEFT JOIN DivisionMaster d ON cs.DivisionId = d.DivisionId AND d.IsDeleted = 0
LEFT JOIN FinancialYear fy_map ON sm.FinancialYearId = fy_map.FinancialYearId AND fy_map.IsDeleted = 0
WHERE s.IsDeleted = 0;
GO
```

---

## 5. Stored Procedures

Below are the key stored procedures configured for authentication and student enrollment:

```sql
-- 1. Stored Procedure: User Authentication
CREATE PROCEDURE usp_Login
    @Username VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        u.UserId,
        u.Username,
        u.PasswordHash,
        u.FullName,
        u.EmailAddress,
        r.RoleName
    FROM Users u
    LEFT JOIN UserRoles ur ON u.UserId = ur.UserId AND ur.IsDeleted = 0
    LEFT JOIN Roles r ON ur.RoleId = r.RoleId AND r.IsDeleted = 0
    WHERE u.Username = @Username AND u.IsActive = 1 AND u.IsDeleted = 0;
END;
GO

-- 2. Stored Procedure: Save/Update Student & Binary Photo
CREATE PROCEDURE usp_Student_Save
    @StudentId INT,
    @AdmissionDate DATE,
    @FirstName VARCHAR(50),
    @MiddleName VARCHAR(50) = NULL,
    @LastName VARCHAR(50),
    @DateOfBirth DATE,
    @Gender VARCHAR(10),
    @StudentPhoto VARBINARY(MAX) = NULL,
    @PlaceOfBirth VARCHAR(100) = NULL,
    @Nationality VARCHAR(50) = 'Indian',
    @BloodGroup VARCHAR(5) = NULL,
    @Category VARCHAR(30) = NULL,
    @Religion VARCHAR(50) = NULL,
    @AadhaarNumber VARCHAR(12) = NULL,
    @AddressLine1 VARCHAR(150),
    @AddressLine2 VARCHAR(150) = NULL,
    @City VARCHAR(50),
    @State VARCHAR(50),
    @Country VARCHAR(50) = 'India',
    @PinCode VARCHAR(10),
    @FatherName VARCHAR(100),
    @FatherOccupation VARCHAR(100) = NULL,
    @FatherMobileNumber VARCHAR(15),
    @MotherName VARCHAR(100),
    @MotherOccupation VARCHAR(100) = NULL,
    @MotherMobileNumber VARCHAR(15) = NULL,
    @GuardianName VARCHAR(100) = NULL,
    @GuardianMobileNumber VARCHAR(15) = NULL,
    @EmergencyContactNumber VARCHAR(15),
    @PreviousSchoolName VARCHAR(150) = NULL,
    @AdmissionFinancialYearId INT,
    @EmailAddress VARCHAR(100) = NULL,
    @ClassScheduleId INT = NULL,
    @RollNo INT = NULL,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OperationType VARCHAR(10) = 'UPDATE';
    DECLARE @OldValues NVARCHAR(MAX) = NULL;
    DECLARE @NewValues NVARCHAR(MAX) = NULL;
    DECLARE @GrNo VARCHAR(20) = NULL;
    DECLARE @MappingFinancialYearId INT = NULL;
    BEGIN TRY
        IF @ClassScheduleId IS NOT NULL AND @ClassScheduleId > 0
        BEGIN
            SELECT @MappingFinancialYearId = FinancialYearId 
            FROM ClassSchedules 
            WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0 AND IsActive = 1;
            IF @MappingFinancialYearId IS NULL
            BEGIN
                SET @StatusCode = 400;
                SET @Message = 'Selected Class Schedule is invalid or inactive.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END
        END
        BEGIN TRANSACTION;
        IF @StudentId IS NULL OR @StudentId = 0
        BEGIN
            SET @OperationType = 'INSERT';
            SET @GrNo = dbo.fn_GenerateGrNo(@AdmissionFinancialYearId);
            INSERT INTO StudentInfo (
                GrNo, AdmissionDate, FirstName, MiddleName, LastName, DateOfBirth, Gender, StudentPhoto,
                PlaceOfBirth, Nationality, BloodGroup, Category, Religion, AadhaarNumber,
                AddressLine1, AddressLine2, City, State, Country, PinCode,
                FatherName, FatherOccupation, FatherMobileNumber, MotherName, MotherOccupation, MotherMobileNumber,
                GuardianName, GuardianMobileNumber, EmergencyContactNumber,
                PreviousSchoolName, AdmissionFinancialYearId, EmailAddress, CreatedBy
            )
            VALUES (
                @GrNo, @AdmissionDate, @FirstName, @MiddleName, @LastName, @DateOfBirth, @Gender, @StudentPhoto,
                @PlaceOfBirth, @Nationality, @BloodGroup, @Category, @Religion, @AadhaarNumber,
                @AddressLine1, @AddressLine2, @City, @State, @Country, @PinCode,
                @FatherName, @FatherOccupation, @FatherMobileNumber, @MotherName, @MotherOccupation, @MotherMobileNumber,
                @GuardianName, @GuardianMobileNumber, @EmergencyContactNumber,
                @PreviousSchoolName, @AdmissionFinancialYearId, @EmailAddress, @PerformedBy
            );
            SET @StudentId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            SELECT @GrNo = GrNo FROM StudentInfo WHERE StudentId = @StudentId AND IsDeleted = 0;
            IF @GrNo IS NULL
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Student not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END
            SET @OldValues = (SELECT * FROM StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
            UPDATE StudentInfo
            SET AdmissionDate = @AdmissionDate,
                FirstName = @FirstName,
                MiddleName = @MiddleName,
                LastName = @LastName,
                DateOfBirth = @DateOfBirth,
                Gender = @Gender,
                StudentPhoto = @StudentPhoto,
                PlaceOfBirth = @PlaceOfBirth,
                Nationality = @Nationality,
                BloodGroup = @BloodGroup,
                Category = @Category,
                Religion = @Religion,
                AddressLine1 = @AddressLine1,
                AddressLine2 = @AddressLine2,
                City = @City,
                State = @State,
                Country = @Country,
                PinCode = @PinCode,
                FatherName = @FatherName,
                FatherOccupation = @FatherOccupation,
                FatherMobileNumber = @FatherMobileNumber,
                MotherName = @MotherName,
                MotherOccupation = @MotherOccupation,
                MotherMobileNumber = @MotherMobileNumber,
                GuardianName = @GuardianName,
                GuardianMobileNumber = @GuardianMobileNumber,
                EmergencyContactNumber = @EmergencyContactNumber,
                PreviousSchoolName = @PreviousSchoolName,
                AdmissionFinancialYearId = @AdmissionFinancialYearId,
                EmailAddress = @EmailAddress,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE StudentId = @StudentId;
        END
        SET @NewValues = (SELECT * FROM StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('StudentInfo', @StudentId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);
        IF @ClassScheduleId IS NOT NULL AND @ClassScheduleId > 0
        BEGIN
            DECLARE @MappingId INT = NULL;
            DECLARE @MapOldValues NVARCHAR(MAX) = NULL;
            DECLARE @MapNewValues NVARCHAR(MAX) = NULL;
            DECLARE @MapOpType VARCHAR(10) = 'UPDATE';
            SELECT @MappingId = StudentMappingId
            FROM StudentMappings
            WHERE StudentId = @StudentId AND FinancialYearId = @MappingFinancialYearId AND IsDeleted = 0;
            IF @MappingId IS NULL
            BEGIN
                SET @MapOpType = 'INSERT';
                INSERT INTO StudentMappings (StudentId, ClassScheduleId, FinancialYearId, RollNo, CreatedBy)
                VALUES (@StudentId, @ClassScheduleId, @MappingFinancialYearId, @RollNo, @PerformedBy);
                SET @MappingId = SCOPE_IDENTITY();
            END
            ELSE
            BEGIN
                SET @MapOldValues = (SELECT * FROM StudentMappings WHERE StudentMappingId = @MappingId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
                UPDATE StudentMappings
                SET ClassScheduleId = @ClassScheduleId,
                    RollNo = @RollNo,
                    UpdatedDate = SYSUTCDATETIME(),
                    UpdatedBy = @PerformedBy
                WHERE StudentMappingId = @MappingId;
            END
            SET @MapNewValues = (SELECT * FROM StudentMappings WHERE StudentMappingId = @MappingId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
            INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
            VALUES ('StudentMappings', @MappingId, @MapOpType, @MapOldValues, @MapNewValues, @PerformedBy, @IPAddress, @PerformedBy);
        END
        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message, @StudentId AS StudentId, @GrNo AS GrNo;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- 3. Stored Procedure: Fetch Student Profile by ID
CREATE PROCEDURE usp_Student_GetById
    @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        StudentId, GrNo, AdmissionDate, FirstName, MiddleName, LastName, FullName, DateOfBirth, Gender,
        StudentPhoto, PlaceOfBirth, Nationality, BloodGroup, Category, Religion, AadhaarNumber,
        AddressLine1, AddressLine2, City, State, Country, PinCode, FatherName, FatherOccupation, FatherMobileNumber,
        MotherName, MotherOccupation, MotherMobileNumber, GuardianName, GuardianMobileNumber, EmergencyContactNumber,
        PreviousSchoolName, AdmissionFinancialYearId, AdmissionFinancialYear, EmailAddress, IsStudentActive,
        StudentMappingId, RollNo, ClassScheduleId, ClassId, ClassName, DivisionId, DivisionName,
        MappingFinancialYearId, MappingFinancialYear, IsCurrentMappingYear
    FROM vw_StudentDetails
    WHERE StudentId = @StudentId;
END;
GO

-- 4. Stored Procedure: Fetch All Student Profiles
CREATE PROCEDURE usp_Student_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_StudentDetails ORDER BY GrNo DESC;
END;
GO

-- 5. Stored Procedure: Search Student Profiles
CREATE PROCEDURE usp_Student_Search
    @SearchText VARCHAR(100) = NULL,
    @ClassScheduleId INT = NULL,
    @FinancialYearId INT = NULL,
    @Gender VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_StudentDetails
    WHERE 
        (@SearchText IS NULL OR 
         GrNo LIKE '%' + @SearchText + '%' OR 
         FirstName LIKE '%' + @SearchText + '%' OR 
         LastName LIKE '%' + @SearchText + '%' OR 
         FatherName LIKE '%' + @SearchText + '%')
        AND (@ClassScheduleId IS NULL OR ClassScheduleId = @ClassScheduleId)
        AND (@FinancialYearId IS NULL OR MappingFinancialYearId = @FinancialYearId OR (MappingFinancialYearId IS NULL AND AdmissionFinancialYearId = @FinancialYearId))
        AND (@Gender IS NULL OR Gender = @Gender)
    ORDER BY GrNo DESC;
END;
GO

-- 6. Stored Procedure: Soft Delete Student (Enforces Class Mappings Check First)
CREATE PROCEDURE usp_Student_Delete
    @StudentId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM StudentInfo WHERE StudentId = @StudentId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Student not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active mappings dependency
        IF EXISTS (SELECT 1 FROM StudentMappings WHERE StudentId = @StudentId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Student as they have active class mappings. Remove class mappings first.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;
        SET @OldValues = (SELECT * FROM StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        UPDATE StudentInfo
        SET IsDeleted = 1,
            IsActive = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE StudentId = @StudentId;
        SET @NewValues = (SELECT * FROM StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('StudentInfo', @StudentId, 'DELETE', @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);
        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- 7. Stored Procedure: Dashboard Metrics summary
CREATE PROCEDURE usp_Dashboard_GetSummary
    @FinancialYearId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Result Set 1: Total Students count (in mappings for specific year + overall registered)
    SELECT 
        (SELECT COUNT(1) FROM StudentInfo WHERE IsDeleted = 0 AND IsActive = 1) AS TotalRegisteredStudents,
        (SELECT COUNT(1) FROM StudentMappings WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0 AND IsActive = 1) AS ActiveMappedStudents;

    -- Result Set 2: Class Allocations summary
    SELECT 
        cs.ClassScheduleId,
        c.ClassName,
        d.DivisionName,
        cs.MaxCapacity,
        COUNT(sm.StudentMappingId) AS AllocatedCount
    FROM ClassSchedules cs
    INNER JOIN ClassMaster c ON cs.ClassId = c.ClassId AND c.IsDeleted = 0
    INNER JOIN DivisionMaster d ON cs.DivisionId = d.DivisionId AND d.IsDeleted = 0
    LEFT JOIN StudentMappings sm ON cs.ClassScheduleId = sm.ClassScheduleId AND sm.IsDeleted = 0 AND sm.IsActive = 1
    WHERE cs.FinancialYearId = @FinancialYearId AND cs.IsDeleted = 0 AND cs.IsActive = 1
    GROUP BY cs.ClassScheduleId, c.ClassName, d.DivisionName, cs.MaxCapacity
    ORDER BY c.ClassName, d.DivisionName;
END;
GO
```
