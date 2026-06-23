-- ============================================================================
-- SCHOOL MANAGEMENT SYSTEM (SMS) - CONSOLIDATED DATABASE SCHEMA & SEED SCRIPT
-- SQL Server Express Edition (Modified with custom table/column names)
-- ============================================================================

USE master;
GO

-- STEP 1: DATABASE CREATION
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

-- ============================================================================
-- STEP 2: TABLE CREATION
-- ============================================================================

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


-- ============================================================================
-- STEP 3: CONSTRAINTS CREATION
-- ============================================================================

-- ClassSchedules -> ClassMaster
ALTER TABLE dbo.ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_Classes_ClassId
    FOREIGN KEY (ClassId) REFERENCES dbo.ClassMaster (ClassId);

-- ClassSchedules -> DivisionMaster
ALTER TABLE dbo.ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_Divisions_DivisionId
    FOREIGN KEY (DivisionId) REFERENCES dbo.DivisionMaster (DivisionId);

-- ClassSchedules -> FinancialYear
ALTER TABLE dbo.ClassSchedules
    ADD CONSTRAINT FK_ClassSchedules_FinancialYears_FinancialYearId
    FOREIGN KEY (FinancialYearId) REFERENCES dbo.FinancialYear (FinancialYearId);

-- StudentInfo -> FinancialYear
ALTER TABLE dbo.StudentInfo
    ADD CONSTRAINT FK_Students_FinancialYears_AdmissionFinancialYearId
    FOREIGN KEY (AdmissionFinancialYearId) REFERENCES dbo.FinancialYear (FinancialYearId);

-- StudentMappings -> StudentInfo
ALTER TABLE dbo.StudentMappings
    ADD CONSTRAINT FK_StudentMappings_Students_StudentId
    FOREIGN KEY (StudentId) REFERENCES dbo.StudentInfo (StudentId);

-- StudentMappings -> ClassSchedules
ALTER TABLE dbo.StudentMappings
    ADD CONSTRAINT FK_StudentMappings_ClassSchedules_ClassScheduleId
    FOREIGN KEY (ClassScheduleId) REFERENCES dbo.ClassSchedules (ClassScheduleId);

-- StudentMappings -> FinancialYear
ALTER TABLE dbo.StudentMappings
    ADD CONSTRAINT FK_StudentMappings_FinancialYears_FinancialYearId
    FOREIGN KEY (FinancialYearId) REFERENCES dbo.FinancialYear (FinancialYearId);

-- UserRoles -> Users
ALTER TABLE dbo.UserRoles
    ADD CONSTRAINT FK_UserRoles_Users_UserId
    FOREIGN KEY (UserId) REFERENCES dbo.Users (UserId);

-- UserRoles -> Roles
ALTER TABLE dbo.UserRoles
    ADD CONSTRAINT FK_UserRoles_Roles_RoleId
    FOREIGN KEY (RoleId) REFERENCES dbo.Roles (RoleId);

-- CHECK CONSTRAINTS
ALTER TABLE dbo.FinancialYear
    ADD CONSTRAINT CK_FinancialYears_Dates
    CHECK (StartDate < EndDate);

ALTER TABLE dbo.ClassSchedules
    ADD CONSTRAINT CK_ClassSchedules_MaxCapacity
    CHECK (MaxCapacity > 0);

ALTER TABLE dbo.StudentInfo
    ADD CONSTRAINT CK_Students_Gender
    CHECK (Gender IN ('Male', 'Female', 'Other'));

ALTER TABLE dbo.AuditLogs
    ADD CONSTRAINT CK_AuditLogs_OperationType
    CHECK (OperationType IN ('INSERT', 'UPDATE', 'DELETE'));
GO


-- ============================================================================
-- STEP 4: INDEXES CREATION
-- ============================================================================

-- Unique filtered indexes for Soft-Deletes
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

-- Performance Non-Clustered Indexes
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


-- ============================================================================
-- STEP 5: FUNCTIONS CREATION
-- ============================================================================

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

    SET @Prefix = 'GR-' 
                  + SUBSTRING(@FinancialYear, 3, 2) 
                  + SUBSTRING(@FinancialYear, 8, 2) 
                  + '-';

    SELECT @NextSequence = ISNULL(MAX(CAST(SUBSTRING(GrNo, 9, 4) AS INT)), 0) + 1
    FROM StudentInfo WITH (UPDLOCK, HOLDLOCK)
    WHERE GrNo LIKE @Prefix + '%';

    SET @NextGrNo = @Prefix + RIGHT('0000' + CAST(@NextSequence AS VARCHAR), 4);

    RETURN @NextGrNo;
END;
GO


-- ============================================================================
-- STEP 6: VIEWS CREATION
-- ============================================================================

CREATE VIEW vw_ActiveClassSchedules
AS
SELECT 
    cs.ClassScheduleId,
    cs.ClassId,
    c.ClassName,
    cs.DivisionId,
    d.DivisionName,
    cs.FinancialYearId,
    fy.FinancialYear AS FinancialYear,
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


-- ============================================================================
-- STEP 7: STORED PROCEDURES CREATION
-- ============================================================================

CREATE PROCEDURE usp_Login
    @Username VARCHAR(50),
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @UserId INT;

    BEGIN TRY
        SELECT @UserId = UserId
        FROM Users
        WHERE Username = @Username AND IsDeleted = 0 AND IsActive = 1;

        IF @UserId IS NULL
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Invalid username or password.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (
            SELECT UserId, Username, FullName, EmailAddress, LastLoginDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted
            FROM Users WHERE UserId = @UserId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        UPDATE Users
        SET LastLoginDate = SYSUTCDATETIME(),
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @UserId
        WHERE UserId = @UserId;

        DECLARE @NewValues NVARCHAR(MAX);
        SET @NewValues = (
            SELECT UserId, Username, FullName, EmailAddress, LastLoginDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted
            FROM Users WHERE UserId = @UserId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('Users', @UserId, 'UPDATE', @OldValues, @NewValues, @UserId, @IPAddress, @UserId);

        COMMIT TRANSACTION;

        SELECT 
            @StatusCode AS StatusCode,
            @Message AS Message,
            UserId,
            Username,
            PasswordHash,
            FullName,
            EmailAddress,
            LastLoginDate
        FROM Users
        WHERE UserId = @UserId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

CREATE PROCEDURE usp_ChangePassword
    @UserId INT,
    @NewPasswordHash VARCHAR(255),
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId AND IsDeleted = 0 AND IsActive = 1)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'User not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (
            SELECT UserId, Username, FullName, EmailAddress, LastLoginDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted
            FROM Users WHERE UserId = @UserId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        UPDATE Users
        SET PasswordHash = @NewPasswordHash,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE UserId = @UserId;

        DECLARE @NewValues NVARCHAR(MAX);
        SET @NewValues = (
            SELECT UserId, Username, FullName, EmailAddress, LastLoginDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted
            FROM Users WHERE UserId = @UserId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('Users', @UserId, 'UPDATE', @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

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

CREATE PROCEDURE usp_FinancialYear_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        FinancialYearId,
        FinancialYear,
        StartDate,
        EndDate,
        IsCurrent,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy,
        IsDeleted
    FROM FinancialYear
    WHERE IsDeleted = 0
    ORDER BY StartDate DESC;
END;
GO

CREATE PROCEDURE usp_FinancialYear_GetById
    @FinancialYearId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        FinancialYearId,
        FinancialYear,
        StartDate,
        EndDate,
        IsCurrent,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy,
        IsDeleted
    FROM FinancialYear
    WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0;
END;
GO

CREATE PROCEDURE usp_FinancialYear_Save
    @FinancialYearId INT,
    @FinancialYear VARCHAR(20),
    @StartDate DATE,
    @EndDate DATE,
    @IsCurrent BIT,
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

    BEGIN TRY
        IF @StartDate >= @EndDate
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Start Date must be before End Date.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM FinancialYear WHERE FinancialYear = @FinancialYear AND FinancialYearId <> ISNULL(@FinancialYearId, 0) AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Financial Year name already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @IsCurrent = 1
        BEGIN
            UPDATE FinancialYear
            SET IsCurrent = 0,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE IsCurrent = 1 AND IsDeleted = 0 AND FinancialYearId <> ISNULL(@FinancialYearId, 0);
        END

        IF @FinancialYearId IS NULL OR @FinancialYearId = 0
        BEGIN
            SET @OperationType = 'INSERT';

            INSERT INTO FinancialYear (FinancialYear, StartDate, EndDate, IsCurrent, CreatedBy)
            VALUES (@FinancialYear, @StartDate, @EndDate, @IsCurrent, @PerformedBy);

            SET @FinancialYearId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM FinancialYear WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Financial Year not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM FinancialYear WHERE FinancialYearId = @FinancialYearId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE FinancialYear
            SET FinancialYear = @FinancialYear,
                StartDate = @StartDate,
                EndDate = @EndDate,
                IsCurrent = @IsCurrent,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE FinancialYearId = @FinancialYearId;
        END

        SET @NewValues = (SELECT * FROM FinancialYear WHERE FinancialYearId = @FinancialYearId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('FinancialYear', @FinancialYearId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;

        SELECT @StatusCode AS StatusCode, @Message AS Message, @FinancialYearId AS FinancialYearId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

CREATE PROCEDURE usp_FinancialYear_Delete
    @FinancialYearId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';

    BEGIN TRY
        DECLARE @IsCurrent BIT;
        SELECT @IsCurrent = IsCurrent
        FROM FinancialYear
        WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0;

        IF @IsCurrent IS NULL
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Financial Year not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @IsCurrent = 1
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete the current active Financial Year.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active dependencies in ClassSchedules
        IF EXISTS (SELECT 1 FROM ClassSchedules WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Financial Year as it is linked to active Class Schedules.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active dependencies in StudentInfo
        IF EXISTS (SELECT 1 FROM StudentInfo WHERE AdmissionFinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Financial Year as it is linked to student admissions.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active dependencies in StudentMappings
        IF EXISTS (SELECT 1 FROM StudentMappings WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Financial Year as it is linked to student class mappings.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM FinancialYear WHERE FinancialYearId = @FinancialYearId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE FinancialYear
        SET IsDeleted = 1,
            IsCurrent = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE FinancialYearId = @FinancialYearId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('FinancialYear', @FinancialYearId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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

CREATE PROCEDURE usp_Division_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        DivisionId,
        DivisionName,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy,
        IsDeleted
    FROM DivisionMaster
    WHERE IsDeleted = 0
    ORDER BY DivisionName ASC;
END;
GO

CREATE PROCEDURE usp_Division_GetById
    @DivisionId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        DivisionId,
        DivisionName,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy,
        IsDeleted
    FROM DivisionMaster
    WHERE DivisionId = @DivisionId AND IsDeleted = 0;
END;
GO

CREATE PROCEDURE usp_Division_Save
    @DivisionId INT,
    @DivisionName VARCHAR(50),
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

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM DivisionMaster WHERE DivisionName = @DivisionName AND DivisionId <> ISNULL(@DivisionId, 0) AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Division name already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @DivisionId IS NULL OR @DivisionId = 0
        BEGIN
            SET @OperationType = 'INSERT';

            INSERT INTO DivisionMaster (DivisionName, CreatedBy)
            VALUES (@DivisionName, @PerformedBy);

            SET @DivisionId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM DivisionMaster WHERE DivisionId = @DivisionId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Division not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM DivisionMaster WHERE DivisionId = @DivisionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE DivisionMaster
            SET DivisionName = @DivisionName,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE DivisionId = @DivisionId;
        END

        SET @NewValues = (SELECT * FROM DivisionMaster WHERE DivisionId = @DivisionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('DivisionMaster', @DivisionId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;

        SELECT @StatusCode AS StatusCode, @Message AS Message, @DivisionId AS DivisionId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

CREATE PROCEDURE usp_Division_Delete
    @DivisionId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM DivisionMaster WHERE DivisionId = @DivisionId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Division not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM ClassSchedules WHERE DivisionId = @DivisionId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete division as it is linked to active Class Schedules.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM DivisionMaster WHERE DivisionId = @DivisionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE DivisionMaster
        SET IsDeleted = 1,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE DivisionId = @DivisionId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('DivisionMaster', @DivisionId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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

CREATE PROCEDURE usp_Class_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ClassId,
        ClassName,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy,
        IsDeleted
    FROM ClassMaster
    WHERE IsDeleted = 0
    ORDER BY ClassId ASC;
END;
GO

CREATE PROCEDURE usp_Class_GetById
    @ClassId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ClassId,
        ClassName,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy,
        IsDeleted
    FROM ClassMaster
    WHERE ClassId = @ClassId AND IsDeleted = 0;
END;
GO

CREATE PROCEDURE usp_Class_Save
    @ClassId INT,
    @ClassName VARCHAR(50),
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

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM ClassMaster WHERE ClassName = @ClassName AND ClassId <> ISNULL(@ClassId, 0) AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Class name already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @ClassId IS NULL OR @ClassId = 0
        BEGIN
            SET @OperationType = 'INSERT';

            INSERT INTO ClassMaster (ClassName, CreatedBy)
            VALUES (@ClassName, @PerformedBy);

            SET @ClassId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM ClassMaster WHERE ClassId = @ClassId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Class not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM ClassMaster WHERE ClassId = @ClassId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE ClassMaster
            SET ClassName = @ClassName,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE ClassId = @ClassId;
        END

        SET @NewValues = (SELECT * FROM ClassMaster WHERE ClassId = @ClassId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('ClassMaster', @ClassId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;

        SELECT @StatusCode AS StatusCode, @Message AS Message, @ClassId AS ClassId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

CREATE PROCEDURE usp_Class_Delete
    @ClassId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ClassMaster WHERE ClassId = @ClassId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Class not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM ClassSchedules WHERE ClassId = @ClassId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete class as it is linked to active Class Schedules.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM ClassMaster WHERE ClassId = @ClassId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE ClassMaster
        SET IsDeleted = 1,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE ClassId = @ClassId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('ClassMaster', @ClassId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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

CREATE PROCEDURE usp_ClassSchedule_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ClassScheduleId,
        ClassId,
        ClassName,
        DivisionId,
        DivisionName,
        FinancialYearId,
        FinancialYear,
        IsCurrentFinancialYear,
        MaxCapacity,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy
    FROM vw_ActiveClassSchedules
    ORDER BY FinancialYear DESC, ClassId ASC, DivisionName ASC;
END;
GO

CREATE PROCEDURE usp_ClassSchedule_GetById
    @ClassScheduleId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ClassScheduleId,
        ClassId,
        ClassName,
        DivisionId,
        DivisionName,
        FinancialYearId,
        FinancialYear,
        IsCurrentFinancialYear,
        MaxCapacity,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy
    FROM vw_ActiveClassSchedules
    WHERE ClassScheduleId = @ClassScheduleId;
END;
GO

CREATE PROCEDURE usp_ClassSchedule_Save
    @ClassScheduleId INT,
    @ClassId INT,
    @DivisionId INT,
    @FinancialYearId INT,
    @MaxCapacity INT,
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

    BEGIN TRY
        IF @MaxCapacity <= 0
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Max Capacity must be greater than 0.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM ClassMaster WHERE ClassId = @ClassId AND IsDeleted = 0 AND IsActive = 1)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Class is invalid or inactive.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM DivisionMaster WHERE DivisionId = @DivisionId AND IsDeleted = 0 AND IsActive = 1)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Division is invalid or inactive.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM FinancialYear WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0 AND IsActive = 1)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Financial Year is invalid or inactive.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM ClassSchedules 
            WHERE FinancialYearId = @FinancialYearId 
              AND ClassId = @ClassId 
              AND DivisionId = @DivisionId 
              AND ClassScheduleId <> ISNULL(@ClassScheduleId, 0) 
              AND IsDeleted = 0
        )
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'A class schedule for this Class, Division, and Financial Year combination already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @ClassScheduleId IS NULL OR @ClassScheduleId = 0
        BEGIN
            SET @OperationType = 'INSERT';

            INSERT INTO ClassSchedules (ClassId, DivisionId, FinancialYearId, MaxCapacity, CreatedBy)
            VALUES (@ClassId, @DivisionId, @FinancialYearId, @MaxCapacity, @PerformedBy);

            SET @ClassScheduleId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM ClassSchedules WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Class Schedule not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM ClassSchedules WHERE ClassScheduleId = @ClassScheduleId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE ClassSchedules
            SET ClassId = @ClassId,
                DivisionId = @DivisionId,
                FinancialYearId = @FinancialYearId,
                MaxCapacity = @MaxCapacity,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE ClassScheduleId = @ClassScheduleId;
        END

        SET @NewValues = (SELECT * FROM ClassSchedules WHERE ClassScheduleId = @ClassScheduleId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('ClassSchedules', @ClassScheduleId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;

        SELECT @StatusCode AS StatusCode, @Message AS Message, @ClassScheduleId AS ClassScheduleId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

CREATE PROCEDURE usp_ClassSchedule_Delete
    @ClassScheduleId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ClassSchedules WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Class Schedule not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM StudentMappings WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Class Schedule as active students are assigned to it.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM ClassSchedules WHERE ClassScheduleId = @ClassScheduleId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE ClassSchedules
        SET IsDeleted = 1,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE ClassScheduleId = @ClassScheduleId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('ClassSchedules', @ClassScheduleId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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

CREATE PROCEDURE usp_Student_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        *
    FROM vw_StudentDetails
    ORDER BY GrNo DESC;
END;
GO

CREATE PROCEDURE usp_Student_GetById
    @StudentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        StudentId,
        GrNo,
        AdmissionDate,
        FirstName,
        MiddleName,
        LastName,
        FullName,
        DateOfBirth,
        Gender,
        StudentPhoto,
        PlaceOfBirth,
        Nationality,
        BloodGroup,
        Category,
        Religion,
        AadhaarNumber,
        AddressLine1,
        AddressLine2,
        City,
        State,
        Country,
        PinCode,
        FatherName,
        FatherOccupation,
        FatherMobileNumber,
        MotherName,
        MotherOccupation,
        MotherMobileNumber,
        GuardianName,
        GuardianMobileNumber,
        EmergencyContactNumber,
        PreviousSchoolName,
        AdmissionFinancialYearId,
        AdmissionFinancialYear,
        EmailAddress,
        IsStudentActive,
        StudentMappingId,
        RollNo,
        ClassScheduleId,
        ClassId,
        ClassName,
        DivisionId,
        DivisionName,
        MappingFinancialYearId,
        MappingFinancialYear,
        IsCurrentMappingYear
    FROM vw_StudentDetails
    WHERE StudentId = @StudentId;
END;
GO

CREATE PROCEDURE usp_Student_Search
    @SearchText VARCHAR(100) = NULL,
    @ClassScheduleId INT = NULL,
    @FinancialYearId INT = NULL,
    @Gender VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        *
    FROM vw_StudentDetails
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

    BEGIN TRY
        IF @DateOfBirth >= CAST(SYSUTCDATETIME() AS DATE)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Date of Birth must be in the past.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @Gender NOT IN ('Male', 'Female', 'Other')
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Gender must be Male, Female, or Other.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM FinancialYear WHERE FinancialYearId = @AdmissionFinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Admission Financial Year is invalid.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        DECLARE @MappingFinancialYearId INT = NULL;
        DECLARE @MaxCapacity INT = 0;
        DECLARE @CurrentCapacity INT = 0;
        
        IF @ClassScheduleId IS NOT NULL AND @ClassScheduleId > 0
        BEGIN
            SELECT @MappingFinancialYearId = FinancialYearId, @MaxCapacity = MaxCapacity
            FROM ClassSchedules
            WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0 AND IsActive = 1;

            IF @MappingFinancialYearId IS NULL
            BEGIN
                SET @StatusCode = 400;
                SET @Message = 'Selected Class Schedule is inactive or invalid.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            IF @RollNo IS NULL OR @RollNo <= 0
            BEGIN
                SET @StatusCode = 400;
                SET @Message = 'Roll number must be specified and greater than 0.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            IF EXISTS (
                SELECT 1 FROM StudentMappings 
                WHERE ClassScheduleId = @ClassScheduleId 
                  AND RollNo = @RollNo 
                  AND StudentId <> ISNULL(@StudentId, 0)
                  AND IsDeleted = 0
            )
            BEGIN
                SET @StatusCode = 400;
                SET @Message = 'Roll number ' + CAST(@RollNo AS VARCHAR) + ' is already assigned in this class schedule.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            IF EXISTS (
                SELECT 1 FROM StudentMappings 
                WHERE StudentId = ISNULL(@StudentId, 0) 
                  AND FinancialYearId = @MappingFinancialYearId 
                  AND IsDeleted = 0
                  AND ClassScheduleId <> @ClassScheduleId
            )
            BEGIN
                SET @StatusCode = 400;
                SET @Message = 'Student is already mapped to another class for this Financial Year.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            IF NOT EXISTS (
                SELECT 1 FROM StudentMappings 
                WHERE StudentId = ISNULL(@StudentId, 0) 
                  AND ClassScheduleId = @ClassScheduleId 
                  AND IsDeleted = 0
            )
            BEGIN
                SELECT @CurrentCapacity = COUNT(1) 
                FROM StudentMappings 
                WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0;

                IF @CurrentCapacity >= @MaxCapacity
                BEGIN
                    SET @StatusCode = 400;
                    SET @Message = 'Cannot map student. Class capacity limit reached (' + CAST(@MaxCapacity AS VARCHAR) + ').';
                    SELECT @StatusCode AS StatusCode, @Message AS Message;
                    RETURN;
                END
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
                AadhaarNumber = @AadhaarNumber,
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


IF OBJECT_ID('usp_Student_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_Student_Delete;
GO
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

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE StudentInfo
        SET IsDeleted = 1,
            IsActive = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE StudentId = @StudentId;

        INSERT INTO AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('StudentInfo', @StudentId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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


IF OBJECT_ID('usp_Dashboard_GetSummary', 'P') IS NOT NULL DROP PROCEDURE usp_Dashboard_GetSummary;
GO
CREATE PROCEDURE usp_Dashboard_GetSummary
    @FinancialYearId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @FinancialYearId IS NULL OR @FinancialYearId = 0
    BEGIN
        SELECT @FinancialYearId = FinancialYearId 
        FROM FinancialYear 
        WHERE IsCurrent = 1 AND IsDeleted = 0;
    END

    SELECT 
        (SELECT COUNT(DISTINCT StudentId) FROM StudentMappings WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0 AND IsActive = 1) AS TotalMappedStudents,
        (SELECT COUNT(1) FROM ClassSchedules WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0 AND IsActive = 1) AS TotalActiveClasses,
        (SELECT ISNULL(SUM(MaxCapacity), 0) FROM ClassSchedules WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0 AND IsActive = 1) AS TotalCapacity,
        (SELECT COUNT(1) FROM StudentInfo WHERE IsDeleted = 0 AND IsActive = 1) AS TotalAdmittedStudents;

    SELECT 
        s.Gender, 
        COUNT(1) AS StudentCount
    FROM StudentMappings sm
    INNER JOIN StudentInfo s ON sm.StudentId = s.StudentId AND s.IsDeleted = 0 AND s.IsActive = 1
    WHERE sm.FinancialYearId = @FinancialYearId AND sm.IsDeleted = 0 AND sm.IsActive = 1
    GROUP BY s.Gender;

    SELECT 
        cs.ClassName,
        COUNT(sm.StudentId) AS StudentCount,
        cs.MaxCapacity
    FROM vw_ActiveClassSchedules cs
    LEFT JOIN StudentMappings sm ON cs.ClassScheduleId = sm.ClassScheduleId AND sm.IsDeleted = 0 AND sm.IsActive = 1
    WHERE cs.FinancialYearId = @FinancialYearId
    GROUP BY cs.ClassScheduleId, cs.ClassName, cs.MaxCapacity
    ORDER BY cs.ClassName;

    SELECT 
        cs.DivisionName,
        COUNT(sm.StudentId) AS StudentCount
    FROM vw_ActiveClassSchedules cs
    LEFT JOIN StudentMappings sm ON cs.ClassScheduleId = sm.ClassScheduleId AND sm.IsDeleted = 0 AND sm.IsActive = 1
    WHERE cs.FinancialYearId = @FinancialYearId
    GROUP BY cs.DivisionName
    ORDER BY cs.DivisionName;
END;
GO


