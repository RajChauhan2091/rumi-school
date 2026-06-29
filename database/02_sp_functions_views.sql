-- Consolidated stored procedures, views, and functions/* Generated from the original split SQL files */-- Step 7: Functions Script
USE SMS;
GO

CREATE FUNCTION fn_GenerateGrNo (
    @AdmissionFinancialYearId INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @SMS_FinancialYear VARCHAR(20);
    DECLARE @Prefix VARCHAR(10);
    DECLARE @NextSequence INT = 1;
    DECLARE @NextGrNo VARCHAR(20);

    -- 1. Fetch the Financial Year Name (using the new column and table name)
    SELECT @SMS_FinancialYear = SMS_FinancialYear 
    FROM SMS_FinancialYear 
    WHERE FinancialYearId = @AdmissionFinancialYearId;

    -- If the financial year is not found, return NULL
    IF @SMS_FinancialYear IS NULL
        RETURN NULL;

    -- 2. Extract prefix: GR-{StartYearLastTwoDigits}{EndYearLastTwoDigits}-
    -- Example: '2026-2027' -> 'GR-2627-'
    -- Format: 'yyyy-yyyy' -> Length = 9. StartYear starts at index 1, EndYear starts at index 6.
    SET @Prefix = 'GR-' 
                  + SUBSTRING(@SMS_FinancialYear, 3, 2) 
                  + SUBSTRING(@SMS_FinancialYear, 8, 2) 
                  + '-';

    -- 3. Determine the next sequence number by searching the SMS_StudentInfo table
    SELECT @NextSequence = ISNULL(MAX(CAST(SUBSTRING(GrNo, 9, 4) AS INT)), 0) + 1
    FROM SMS_StudentInfo
    WHERE GrNo LIKE @Prefix + '%';

    -- 4. Format: Prefix + 4-digit zero-padded sequence (e.g., GR-2627-0001)
    SET @NextGrNo = @Prefix + RIGHT('0000' + CAST(@NextSequence AS VARCHAR), 4);

    RETURN @NextGrNo;
END;
GO



-- Step 8: Views Script
USE SMS;
GO

-- ============================================================================
-- 1. vw_ActiveClassSchedules
-- Exposes all active class schedules joined with Class, Division, and Financial Year details.
-- ============================================================================
IF OBJECT_ID('vw_ActiveClassSchedules', 'V') IS NOT NULL DROP VIEW vw_ActiveClassSchedules;
GO
CREATE VIEW vw_ActiveClassSchedules
AS
SELECT 
    cs.ClassScheduleId,
    cs.ClassId,
    c.ClassName,
    cs.DivisionId,
    d.DivisionName,
    cs.FinancialYearId,
    fy.SMS_FinancialYear,
    fy.IsCurrent AS IsCurrentFinancialYear,
    cs.MaxCapacity,
    cs.StaffId,
    (s.StaffFirstName + ' ' + ISNULL(s.StaffMiddleName + ' ', '') + s.StaffLastName) AS StaffFullName,
    cs.IsActive,
    cs.CreatedDate,
    cs.CreatedBy,
    cs.UpdatedDate,
    cs.UpdatedBy
FROM SMS_ClassSchedules cs
INNER JOIN SMS_ClassMaster c ON cs.ClassId = c.ClassId AND c.IsDeleted = 0 AND c.IsActive = 1
INNER JOIN SMS_DivisionMaster d ON cs.DivisionId = d.DivisionId AND d.IsDeleted = 0 AND d.IsActive = 1
INNER JOIN SMS_FinancialYear fy ON cs.FinancialYearId = fy.FinancialYearId AND fy.IsDeleted = 0 AND fy.IsActive = 1
LEFT JOIN SMS_StaffDetail s ON cs.StaffId = s.StaffID AND s.IsDeleted = 0
WHERE cs.IsDeleted = 0 AND cs.IsActive = 1;
GO

-- ============================================================================
-- 2. vw_StudentDetails
-- Exposes student profiles, including their active class mapping and current class/roll details.
-- Supports students with or without current active class mappings (LEFT JOIN on mapping tables).
-- ============================================================================
IF OBJECT_ID('vw_StudentDetails', 'V') IS NOT NULL DROP VIEW vw_StudentDetails;
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
    s.Guardian2Name,
    s.Guardian2MobileNumber,
    s.EmergencyContactNumber,
    s.PreviousSchoolName,
    s.AdmissionFinancialYearId,
    fy_adm.SMS_FinancialYear AS AdmissionFinancialYear,
    s.EmailAddress,
    s.IsActive AS IsStudentActive,
    
    -- Mapping & Classroom details (for the current financial year or mapping record)
    sm.StudentMappingId,
    sm.RollNo,
    cs.ClassScheduleId,
    cs.ClassId,
    c.ClassName,
    cs.DivisionId,
    d.DivisionName,
    sm.FinancialYearId AS MappingFinancialYearId,
    fy_map.SMS_FinancialYear AS MappingFinancialYear,
    fy_map.IsCurrent AS IsCurrentMappingYear
FROM SMS_StudentInfo s
INNER JOIN SMS_FinancialYear fy_adm ON s.AdmissionFinancialYearId = fy_adm.FinancialYearId AND fy_adm.IsDeleted = 0
LEFT JOIN SMS_StudentMappings sm ON s.StudentId = sm.StudentId AND sm.IsDeleted = 0 AND sm.IsActive = 1
LEFT JOIN SMS_ClassSchedules cs ON sm.ClassScheduleId = cs.ClassScheduleId AND cs.IsDeleted = 0 AND cs.IsActive = 1
LEFT JOIN SMS_ClassMaster c ON cs.ClassId = c.ClassId AND c.IsDeleted = 0
LEFT JOIN SMS_DivisionMaster d ON cs.DivisionId = d.DivisionId AND d.IsDeleted = 0
LEFT JOIN SMS_FinancialYear fy_map ON sm.FinancialYearId = fy_map.FinancialYearId AND fy_map.IsDeleted = 0
WHERE s.IsDeleted = 0;
GO



-- ============================================================================
-- STORED PROCEDURES
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
        FROM SMS_Users
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
            FROM SMS_Users WHERE UserId = @UserId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        UPDATE SMS_Users
        SET LastLoginDate = SYSUTCDATETIME(),
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @UserId
        WHERE UserId = @UserId;

        DECLARE @NewValues NVARCHAR(MAX);
        SET @NewValues = (
            SELECT UserId, Username, FullName, EmailAddress, LastLoginDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted
            FROM SMS_Users WHERE UserId = @UserId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_Users', @UserId, 'UPDATE', @OldValues, @NewValues, @UserId, @IPAddress, @UserId);

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
        FROM SMS_Users
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
        IF NOT EXISTS (SELECT 1 FROM SMS_Users WHERE UserId = @UserId AND IsDeleted = 0 AND IsActive = 1)
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
            FROM SMS_Users WHERE UserId = @UserId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        UPDATE SMS_Users
        SET PasswordHash = @NewPasswordHash,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE UserId = @UserId;

        DECLARE @NewValues NVARCHAR(MAX);
        SET @NewValues = (
            SELECT UserId, Username, FullName, EmailAddress, LastLoginDate, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted
            FROM SMS_Users WHERE UserId = @UserId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_Users', @UserId, 'UPDATE', @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

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
        SMS_FinancialYear,
        StartDate,
        EndDate,
        IsCurrent,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy,
        IsDeleted
    FROM SMS_FinancialYear
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
        SMS_FinancialYear,
        StartDate,
        EndDate,
        IsCurrent,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy,
        IsDeleted
    FROM SMS_FinancialYear
    WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0;
END;
GO

CREATE PROCEDURE usp_FinancialYear_Save
    @FinancialYearId INT,
    @SMS_FinancialYear VARCHAR(20),
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

        IF EXISTS (SELECT 1 FROM SMS_FinancialYear WHERE SMS_FinancialYear = @SMS_FinancialYear AND FinancialYearId <> ISNULL(@FinancialYearId, 0) AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Financial Year name already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @IsCurrent = 1
        BEGIN
            UPDATE SMS_FinancialYear
            SET IsCurrent = 0,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE IsCurrent = 1 AND IsDeleted = 0 AND FinancialYearId <> ISNULL(@FinancialYearId, 0);
        END

        IF @FinancialYearId IS NULL OR @FinancialYearId = 0
        BEGIN
            SET @OperationType = 'INSERT';

            INSERT INTO SMS_FinancialYear (SMS_FinancialYear, StartDate, EndDate, IsCurrent, CreatedBy)
            VALUES (@SMS_FinancialYear, @StartDate, @EndDate, @IsCurrent, @PerformedBy);

            SET @FinancialYearId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SMS_FinancialYear WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Financial Year not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM SMS_FinancialYear WHERE FinancialYearId = @FinancialYearId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE SMS_FinancialYear
            SET SMS_FinancialYear = @SMS_FinancialYear,
                StartDate = @StartDate,
                EndDate = @EndDate,
                IsCurrent = @IsCurrent,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE FinancialYearId = @FinancialYearId;
        END

        SET @NewValues = (SELECT * FROM SMS_FinancialYear WHERE FinancialYearId = @FinancialYearId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_FinancialYear', @FinancialYearId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

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
        FROM SMS_FinancialYear
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

        -- Check active dependencies in SMS_ClassSchedules
        IF EXISTS (SELECT 1 FROM SMS_ClassSchedules WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Financial Year as it is linked to active Class Schedules.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active dependencies in SMS_StudentInfo
        IF EXISTS (SELECT 1 FROM SMS_StudentInfo WHERE AdmissionFinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Financial Year as it is linked to student admissions.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active dependencies in SMS_StudentMappings
        IF EXISTS (SELECT 1 FROM SMS_StudentMappings WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Financial Year as it is linked to student class mappings.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM SMS_FinancialYear WHERE FinancialYearId = @FinancialYearId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE SMS_FinancialYear
        SET IsDeleted = 1,
            IsCurrent = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE FinancialYearId = @FinancialYearId;

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_FinancialYear', @FinancialYearId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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
    FROM SMS_DivisionMaster
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
    FROM SMS_DivisionMaster
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
        IF EXISTS (SELECT 1 FROM SMS_DivisionMaster WHERE DivisionName = @DivisionName AND DivisionId <> ISNULL(@DivisionId, 0) AND IsDeleted = 0)
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

            INSERT INTO SMS_DivisionMaster (DivisionName, CreatedBy)
            VALUES (@DivisionName, @PerformedBy);

            SET @DivisionId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SMS_DivisionMaster WHERE DivisionId = @DivisionId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Division not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM SMS_DivisionMaster WHERE DivisionId = @DivisionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE SMS_DivisionMaster
            SET DivisionName = @DivisionName,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE DivisionId = @DivisionId;
        END

        SET @NewValues = (SELECT * FROM SMS_DivisionMaster WHERE DivisionId = @DivisionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_DivisionMaster', @DivisionId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

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
        IF NOT EXISTS (SELECT 1 FROM SMS_DivisionMaster WHERE DivisionId = @DivisionId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Division not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM SMS_ClassSchedules WHERE DivisionId = @DivisionId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete division as it is linked to active Class Schedules.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM SMS_DivisionMaster WHERE DivisionId = @DivisionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE SMS_DivisionMaster
        SET IsDeleted = 1,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE DivisionId = @DivisionId;

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_DivisionMaster', @DivisionId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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
    FROM SMS_ClassMaster
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
    FROM SMS_ClassMaster
    WHERE ClassId = @ClassId AND IsDeleted = 0;
END;
GO

CREATE PROCEDURE usp_Class_Save
    @ClassId INT,
    @ClassName VARCHAR(50),
    @IsActive BIT = 1,
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
        IF EXISTS (SELECT 1 FROM SMS_ClassMaster WHERE ClassName = @ClassName AND ClassId <> ISNULL(@ClassId, 0) AND IsDeleted = 0)
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

            INSERT INTO SMS_ClassMaster (ClassName, IsActive, CreatedBy)
            VALUES (@ClassName, @IsActive, @PerformedBy);

            SET @ClassId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SMS_ClassMaster WHERE ClassId = @ClassId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Class not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM SMS_ClassMaster WHERE ClassId = @ClassId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE SMS_ClassMaster
            SET ClassName = @ClassName,
                IsActive = @IsActive,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE ClassId = @ClassId;
        END

        SET @NewValues = (SELECT * FROM SMS_ClassMaster WHERE ClassId = @ClassId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_ClassMaster', @ClassId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

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
        IF NOT EXISTS (SELECT 1 FROM SMS_ClassMaster WHERE ClassId = @ClassId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Class not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM SMS_ClassSchedules WHERE ClassId = @ClassId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete class as it is linked to active Class Schedules.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM SMS_ClassMaster WHERE ClassId = @ClassId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE SMS_ClassMaster
        SET IsDeleted = 1,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE ClassId = @ClassId;

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_ClassMaster', @ClassId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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
        SMS_FinancialYear,
        IsCurrentFinancialYear,
        MaxCapacity,
        StaffId,
        StaffFullName,
        IsActive,
        CreatedDate,
        CreatedBy,
        UpdatedDate,
        UpdatedBy
    FROM vw_ActiveClassSchedules
    ORDER BY SMS_FinancialYear DESC, ClassId ASC, DivisionName ASC;
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
        SMS_FinancialYear,
        IsCurrentFinancialYear,
        MaxCapacity,
        StaffId,
        StaffFullName,
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
    @StaffId INT = NULL,
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

        IF NOT EXISTS (SELECT 1 FROM SMS_ClassMaster WHERE ClassId = @ClassId AND IsDeleted = 0 AND IsActive = 1)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Class is invalid or inactive.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SMS_DivisionMaster WHERE DivisionId = @DivisionId AND IsDeleted = 0 AND IsActive = 1)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Division is invalid or inactive.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SMS_FinancialYear WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0 AND IsActive = 1)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Financial Year is invalid or inactive.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @StaffId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM SMS_StaffDetail WHERE StaffID = @StaffId AND IsDeleted = 0 AND IsActive = 1)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Staff is invalid or inactive.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM SMS_ClassSchedules 
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

            INSERT INTO SMS_ClassSchedules (ClassId, DivisionId, FinancialYearId, MaxCapacity, StaffId, CreatedBy)
            VALUES (@ClassId, @DivisionId, @FinancialYearId, @MaxCapacity, @StaffId, @PerformedBy);

            SET @ClassScheduleId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SMS_ClassSchedules WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Class Schedule not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM SMS_ClassSchedules WHERE ClassScheduleId = @ClassScheduleId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE SMS_ClassSchedules
            SET ClassId = @ClassId,
                DivisionId = @DivisionId,
                FinancialYearId = @FinancialYearId,
                MaxCapacity = @MaxCapacity,
                StaffId = @StaffId,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE ClassScheduleId = @ClassScheduleId;
        END

        SET @NewValues = (SELECT * FROM SMS_ClassSchedules WHERE ClassScheduleId = @ClassScheduleId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_ClassSchedules', @ClassScheduleId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

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
        IF NOT EXISTS (SELECT 1 FROM SMS_ClassSchedules WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Class Schedule not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM SMS_StudentMappings WHERE ClassScheduleId = @ClassScheduleId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Class Schedule as active students are assigned to it.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM SMS_ClassSchedules WHERE ClassScheduleId = @ClassScheduleId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE SMS_ClassSchedules
        SET IsDeleted = 1,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE ClassScheduleId = @ClassScheduleId;

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_ClassSchedules', @ClassScheduleId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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
        Guardian2Name,
        Guardian2MobileNumber,
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
    @GrNo VARCHAR(20) = NULL,
    @AdmissionDate DATE,
    @FirstName VARCHAR(50),
    @MiddleName VARCHAR(50) = NULL,
    @LastName VARCHAR(50),
    @DateOfBirth DATE,
    @Gender VARCHAR(10),
    @StudentPhoto VARBINARY(MAX) = NULL,
    
    @PlaceOfBirth VARCHAR(100) = NULL,
    @Nationality VARCHAR(50) = NULL,
    @BloodGroup VARCHAR(5) = NULL,
    @Category VARCHAR(30) = NULL,
    @Religion VARCHAR(50) = NULL,
    @AadhaarNumber VARCHAR(15) = NULL,
    
    @AddressLine1 VARCHAR(150),
    @AddressLine2 VARCHAR(150) = NULL,
    @City VARCHAR(50),
    @State VARCHAR(50) = NULL,
    @Country VARCHAR(50) = NULL,
    @PinCode VARCHAR(10),
    
    @FatherName VARCHAR(100),
    @FatherOccupation VARCHAR(100) = NULL,
    @FatherMobileNumber VARCHAR(15),
    @MotherName VARCHAR(100),
    @MotherOccupation VARCHAR(100) = NULL,
    @MotherMobileNumber VARCHAR(15) = NULL,
    @GuardianName VARCHAR(100) = NULL,
    @GuardianMobileNumber VARCHAR(15) = NULL,
    @Guardian2Name VARCHAR(100) = NULL,
    @Guardian2MobileNumber VARCHAR(15) = NULL,
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

        IF NOT EXISTS (SELECT 1 FROM SMS_FinancialYear WHERE FinancialYearId = @AdmissionFinancialYearId AND IsDeleted = 0)
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
            FROM SMS_ClassSchedules
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
                SELECT 1 FROM SMS_StudentMappings 
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
                SELECT 1 FROM SMS_StudentMappings 
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
                SELECT 1 FROM SMS_StudentMappings 
                WHERE StudentId = ISNULL(@StudentId, 0) 
                  AND ClassScheduleId = @ClassScheduleId 
                  AND IsDeleted = 0
            )
            BEGIN
                SELECT @CurrentCapacity = COUNT(1) 
                FROM SMS_StudentMappings 
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

            -- Check for duplicate GR Number
            IF @GrNo IS NOT NULL AND EXISTS (SELECT 1 FROM SMS_StudentInfo WHERE GrNo = @GrNo AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 400;
                SET @Message = 'GR Number already exists.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            INSERT INTO SMS_StudentInfo (
                GrNo, AdmissionDate, FirstName, MiddleName, LastName, DateOfBirth, Gender, StudentPhoto,
                PlaceOfBirth, Nationality, BloodGroup, Category, Religion, AadhaarNumber,
                AddressLine1, AddressLine2, City, State, Country, PinCode,
                FatherName, FatherOccupation, FatherMobileNumber, MotherName, MotherOccupation, MotherMobileNumber,
                GuardianName, GuardianMobileNumber, Guardian2Name, Guardian2MobileNumber, EmergencyContactNumber,
                PreviousSchoolName, AdmissionFinancialYearId, EmailAddress, CreatedBy
            )
            VALUES (
                @GrNo, @AdmissionDate, @FirstName, @MiddleName, @LastName, @DateOfBirth, @Gender, @StudentPhoto,
                @PlaceOfBirth, @Nationality, @BloodGroup, @Category, @Religion, @AadhaarNumber,
                @AddressLine1, @AddressLine2, @City, @State, @Country, @PinCode,
                @FatherName, @FatherOccupation, @FatherMobileNumber, @MotherName, @MotherOccupation, @MotherMobileNumber,
                @GuardianName, @GuardianMobileNumber, @Guardian2Name, @Guardian2MobileNumber, @EmergencyContactNumber,
                @PreviousSchoolName, @AdmissionFinancialYearId, @EmailAddress, @PerformedBy
            );

            SET @StudentId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SMS_StudentInfo WHERE StudentId = @StudentId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Student not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM SMS_StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE SMS_StudentInfo
            SET AdmissionDate = @AdmissionDate,
                GrNo = @GrNo,
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
                Guardian2Name = @Guardian2Name,
                Guardian2MobileNumber = @Guardian2MobileNumber,
                EmergencyContactNumber = @EmergencyContactNumber,
                PreviousSchoolName = @PreviousSchoolName,
                AdmissionFinancialYearId = @AdmissionFinancialYearId,
                EmailAddress = @EmailAddress,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE StudentId = @StudentId;
        END

        SET @NewValues = (SELECT * FROM SMS_StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_StudentInfo', @StudentId, @OperationType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        IF @ClassScheduleId IS NOT NULL AND @ClassScheduleId > 0
        BEGIN
            DECLARE @MappingId INT = NULL;
            DECLARE @MapOldValues NVARCHAR(MAX) = NULL;
            DECLARE @MapNewValues NVARCHAR(MAX) = NULL;
            DECLARE @MapOpType VARCHAR(10) = 'UPDATE';

            SELECT @MappingId = StudentMappingId
            FROM SMS_StudentMappings
            WHERE StudentId = @StudentId AND FinancialYearId = @MappingFinancialYearId AND IsDeleted = 0;

            IF @MappingId IS NULL
            BEGIN
                SET @MapOpType = 'INSERT';
                INSERT INTO SMS_StudentMappings (StudentId, ClassScheduleId, FinancialYearId, RollNo, CreatedBy)
                VALUES (@StudentId, @ClassScheduleId, @MappingFinancialYearId, @RollNo, @PerformedBy);
                SET @MappingId = SCOPE_IDENTITY();
            END
            ELSE
            BEGIN
                SET @MapOldValues = (SELECT * FROM SMS_StudentMappings WHERE StudentMappingId = @MappingId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

                UPDATE SMS_StudentMappings
                SET ClassScheduleId = @ClassScheduleId,
                    RollNo = @RollNo,
                    UpdatedDate = SYSUTCDATETIME(),
                    UpdatedBy = @PerformedBy
                WHERE StudentMappingId = @MappingId;
            END

            SET @MapNewValues = (SELECT * FROM SMS_StudentMappings WHERE StudentMappingId = @MappingId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
            VALUES ('SMS_StudentMappings', @MappingId, @MapOpType, @MapOldValues, @MapNewValues, @PerformedBy, @IPAddress, @PerformedBy);
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
        IF NOT EXISTS (SELECT 1 FROM SMS_StudentInfo WHERE StudentId = @StudentId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Student not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check active mappings dependency
        IF EXISTS (SELECT 1 FROM SMS_StudentMappings WHERE StudentId = @StudentId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete Student as they have active class mappings. Remove class mappings first.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @OldValues NVARCHAR(MAX);
        SET @OldValues = (SELECT * FROM SMS_StudentInfo WHERE StudentId = @StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE SMS_StudentInfo
        SET IsDeleted = 1,
            IsActive = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE StudentId = @StudentId;

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_StudentInfo', @StudentId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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
        FROM SMS_FinancialYear 
        WHERE IsCurrent = 1 AND IsDeleted = 0;
    END

    -- Calculate pending fees details for the selected Financial Year
    DECLARE @TotalPendingStudents INT = 0;
    DECLARE @TotalPendingAmount DECIMAL(18,2) = 0.00;

    ;WITH PendingFeesCTE AS (
        SELECT 
            sm.StudentId,
            (fm.Fee - ISNULL(paid.TotalPaid, 0)) AS Remaining
        FROM SMS_StudentMappings sm
        INNER JOIN SMS_ClassSchedules cs ON sm.ClassScheduleId = cs.ClassScheduleId AND cs.IsDeleted = 0 AND cs.IsActive = 1
        INNER JOIN SMS_FeeDetail fd ON cs.ClassId = fd.ClassID AND fd.FinancialYearID = sm.FinancialYearId AND fd.IsDeleted = 0 AND fd.IsActive = 1
        INNER JOIN SMS_FeeMaster fm ON fd.FeeID = fm.FeeID AND fm.IsDeleted = 0
        LEFT JOIN (
            SELECT StudentID, FinancialYearID, FeeID, SemesterID, SUM(FeePaid) AS TotalPaid
            FROM SMS_PaymentDetail
            WHERE IsDeleted = 0
            GROUP BY StudentID, FinancialYearID, FeeID, SemesterID
        ) paid ON sm.StudentId = paid.StudentID 
              AND sm.FinancialYearId = paid.FinancialYearID 
              AND fd.FeeID = paid.FeeID 
              AND fd.SemesterID = paid.SemesterID
        WHERE sm.FinancialYearId = @FinancialYearId AND sm.IsDeleted = 0 AND sm.IsActive = 1
          AND (fm.Fee - ISNULL(paid.TotalPaid, 0)) > 0
    )
    SELECT 
        @TotalPendingStudents = COUNT(DISTINCT StudentId),
        @TotalPendingAmount = ISNULL(SUM(Remaining), 0)
    FROM PendingFeesCTE;

    -- 1. Main KPI summaries (admitted students, active schedules, capacity, staff count, collection figures)
    SELECT 
        (SELECT COUNT(DISTINCT StudentId) FROM SMS_StudentMappings WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0 AND IsActive = 1) AS TotalMappedStudents,
        (SELECT COUNT(1) FROM SMS_ClassSchedules WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0 AND IsActive = 1) AS TotalActiveClasses,
        (SELECT ISNULL(SUM(MaxCapacity), 0) FROM SMS_ClassSchedules WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0 AND IsActive = 1) AS TotalCapacity,
        (SELECT COUNT(1) FROM SMS_StudentInfo WHERE IsDeleted = 0 AND IsActive = 1) AS TotalAdmittedStudents,
        (SELECT COUNT(1) FROM SMS_StaffDetail WHERE IsDeleted = 0 AND IsActive = 1) AS TotalStaff,
        (SELECT ISNULL(SUM(FeePaid), 0) FROM SMS_PaymentDetail WHERE FinancialYearID = @FinancialYearId AND IsDeleted = 0) AS TotalFeesCollected,
        ISNULL(@TotalPendingStudents, 0) AS TotalPendingFeesStudents,
        ISNULL(@TotalPendingAmount, 0) AS TotalPendingFeesAmount;

    -- 2. Gender distribution
    SELECT 
        s.Gender, 
        COUNT(1) AS StudentCount
    FROM SMS_StudentMappings sm
    INNER JOIN SMS_StudentInfo s ON sm.StudentId = s.StudentId AND s.IsDeleted = 0 AND s.IsActive = 1
    WHERE sm.FinancialYearId = @FinancialYearId AND sm.IsDeleted = 0 AND sm.IsActive = 1
    GROUP BY s.Gender;

    -- 3. Classroom capacity vs student count
    SELECT 
        cs.ClassName,
        COUNT(sm.StudentId) AS StudentCount,
        cs.MaxCapacity
    FROM vw_ActiveClassSchedules cs
    LEFT JOIN SMS_StudentMappings sm ON cs.ClassScheduleId = sm.ClassScheduleId AND sm.IsDeleted = 0 AND sm.IsActive = 1
    WHERE cs.FinancialYearId = @FinancialYearId
    GROUP BY cs.ClassScheduleId, cs.ClassName, cs.MaxCapacity
    ORDER BY cs.ClassName;

    -- 4. Division wise distribution
    SELECT 
        cs.DivisionName,
        COUNT(sm.StudentId) AS StudentCount
    FROM vw_ActiveClassSchedules cs
    LEFT JOIN SMS_StudentMappings sm ON cs.ClassScheduleId = sm.ClassScheduleId AND sm.IsDeleted = 0 AND sm.IsActive = 1
    WHERE cs.FinancialYearId = @FinancialYearId
    GROUP BY cs.DivisionName
    ORDER BY cs.DivisionName;

    -- 5. Staff distribution by role type
    SELECT 
        st.StaffType,
        COUNT(sd.StaffID) AS StaffCount
    FROM SMS_StaffTypeMaster st
    LEFT JOIN SMS_StaffDetail sd ON st.StaffTypeID = sd.StaffType AND sd.IsDeleted = 0 AND sd.IsActive = 1
    WHERE st.IsDeleted = 0 AND st.IsActive = 1
    GROUP BY st.StaffTypeID, st.StaffType;
END;
GO




-- Step 9: Staff and Fees Stored Procedures & Views Script
USE SMS;
GO

-- ============================================================================
-- 1. VIEWS FOR STAFF AND FEES
-- ============================================================================

-- View to retrieve active staff details along with staff type name
IF OBJECT_ID('vw_StaffDetails', 'V') IS NOT NULL DROP VIEW vw_StaffDetails;
GO
CREATE VIEW vw_StaffDetails
AS
SELECT 
    s.StaffID,
    s.StaffFirstName,
    s.StaffMiddleName,
    s.StaffLastName,
    (s.StaffFirstName + ' ' + ISNULL(s.StaffMiddleName + ' ', '') + s.StaffLastName) AS StaffFullName,
    s.StaffType AS StaffTypeID,
    st.StaffType AS StaffTypeName,
    s.Mobileno,
    s.EmergencyContact,
    s.AddressLine1,
    s.AddressLine2,
    (s.AddressLine1 + ISNULL(', ' + s.AddressLine2, '')) AS Address,
    s.AadhaarNo,
    s.BankName,
    s.IFSCCode,
    s.AccountNo,
    s.PanNo,
    s.StaffPic,
    s.DOB,
    s.IsActive,
    s.CreatedDate,
    s.CreatedBy
FROM SMS_StaffDetail s
INNER JOIN SMS_StaffTypeMaster st ON s.StaffType = st.StaffTypeID AND st.IsDeleted = 0
WHERE s.IsDeleted = 0;
GO

-- View to retrieve fee details mapped with Class, Semester, and Financial Year names
IF OBJECT_ID('vw_FeeDetails', 'V') IS NOT NULL DROP VIEW vw_FeeDetails;
GO
CREATE VIEW vw_FeeDetails
AS
SELECT 
    fd.FeeDetailID,
    fd.FeeID,
    fm.Fee AS FeeAmount,
    fd.ClassID,
    c.ClassName,
    fd.FinancialYearID,
    fy.SMS_FinancialYear,
    fy.IsCurrent AS IsCurrentFinancialYear,
    fd.SemesterID,
    sem.SemesterName,
    fd.IsActive,
    fd.CreatedDate,
    fd.CreatedBy
FROM SMS_FeeDetail fd
INNER JOIN SMS_FeeMaster fm ON fd.FeeID = fm.FeeID AND fm.IsDeleted = 0
INNER JOIN SMS_ClassMaster c ON fd.ClassID = c.ClassId AND c.IsDeleted = 0
INNER JOIN SMS_FinancialYear fy ON fd.FinancialYearID = fy.FinancialYearId AND fy.IsDeleted = 0
INNER JOIN SMS_SemesterMaster sem ON fd.SemesterID = sem.SemesterID AND sem.IsDeleted = 0
WHERE fd.IsDeleted = 0;
GO

-- View to retrieve student payments mapped with student, class, semester and financial year
IF OBJECT_ID('vw_StudentPayments', 'V') IS NOT NULL DROP VIEW vw_StudentPayments;
GO
CREATE VIEW vw_StudentPayments
AS
SELECT 
    pd.PaymentDetailID,
    pd.StudentID,
    (s.FirstName + ' ' + ISNULL(s.MiddleName + ' ', '') + s.LastName) AS StudentFullName,
    s.GrNo,
    pd.FinancialYearID,
    fy.SMS_FinancialYear,
    pd.FeeID,
    fm.Fee AS TotalFeeAmount,
    pd.SemesterID,
    sem.SemesterName,
    pd.PaymentMode,
    pd.TransactionRef,
    pd.Transactionphoto,
    pd.IsFullyPaid,
    pd.FeePaid,
    pd.TotalInstallment,
    pd.Remarks,
    pd.CreatedDate,
    pd.CreatedBy,
    (fm.Fee - ISNULL((
        SELECT SUM(pd2.FeePaid)
        FROM SMS_PaymentDetail pd2
        WHERE pd2.StudentID = pd.StudentID
          AND pd2.FinancialYearID = pd.FinancialYearID
          AND pd2.SemesterID = pd.SemesterID
          AND pd2.IsDeleted = 0
    ), 0)) AS FeeRemaining
FROM SMS_PaymentDetail pd
INNER JOIN SMS_StudentInfo s ON pd.StudentID = s.StudentId AND s.IsDeleted = 0
INNER JOIN SMS_FinancialYear fy ON pd.FinancialYearID = fy.FinancialYearId AND fy.IsDeleted = 0
INNER JOIN SMS_FeeMaster fm ON pd.FeeID = fm.FeeID AND fm.IsDeleted = 0
INNER JOIN SMS_SemesterMaster sem ON pd.SemesterID = sem.SemesterID AND sem.IsDeleted = 0
WHERE pd.IsDeleted = 0;
GO


-- ============================================================================
-- 2. DROPDOWN SP's (For UI Dropdown selection inputs)
-- ============================================================================

-- Dropdown list for Classes
IF OBJECT_ID('usp_Dropdown_GetClasses', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetClasses;
GO
CREATE PROCEDURE usp_Dropdown_GetClasses
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ClassId, ClassName 
    FROM SMS_ClassMaster 
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY ClassName;
END;
GO

-- Dropdown list for Semesters
IF OBJECT_ID('usp_Dropdown_GetSemesters', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetSemesters;
GO
CREATE PROCEDURE usp_Dropdown_GetSemesters
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SemesterID, SemesterName, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted 
    FROM SMS_SemesterMaster 
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY SemesterName;
END;
GO

-- Dropdown list for Staff Types
IF OBJECT_ID('usp_Dropdown_GetStaffTypes', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetStaffTypes;
GO
CREATE PROCEDURE usp_Dropdown_GetStaffTypes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT StaffTypeID, StaffType, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted 
    FROM SMS_StaffTypeMaster 
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY StaffType;
END;
GO

-- Dropdown list for Fees (Distinct Fee Amounts available)
IF OBJECT_ID('usp_Dropdown_GetFees', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetFees;
GO
CREATE PROCEDURE usp_Dropdown_GetFees
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FeeID, Fee AS FeeAmount
    FROM SMS_FeeMaster 
    WHERE IsDeleted = 0 AND IsActive = 1
    ORDER BY Fee;
END;
GO

-- Dropdown list for Staff (with optional type filtering, e.g., to assign teaching staff to classes)
IF OBJECT_ID('usp_Dropdown_GetStaff', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetStaff;
GO
CREATE PROCEDURE usp_Dropdown_GetStaff
    @StaffTypeId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        *
    FROM vw_StaffDetails
    WHERE IsActive = 1
      AND (@StaffTypeId IS NULL OR StaffTypeID = @StaffTypeId)
    ORDER BY StaffTypeID, StaffFirstName, StaffLastName;
END;
GO

-- Dropdown list for mapped fees of a selected class for student payment screen
IF OBJECT_ID('usp_Dropdown_GetAvailableFeesForClass', 'P') IS NOT NULL DROP PROCEDURE usp_Dropdown_GetAvailableFeesForClass;
GO
CREATE PROCEDURE usp_Dropdown_GetAvailableFeesForClass
    @ClassId INT,
    @FinancialYearId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        fd.FeeDetailID,
        fd.FeeID,
        fm.Fee AS FeeAmount,
        fd.ClassID,
        c.ClassName,
        fd.FinancialYearID,
        fy.SMS_FinancialYear,
        fy.IsCurrent AS IsCurrentFinancialYear,
        fd.SemesterID,
        sem.SemesterName,
        fd.IsActive
    FROM SMS_FeeDetail fd
    INNER JOIN SMS_FeeMaster fm ON fd.FeeID = fm.FeeID AND fm.IsDeleted = 0
    INNER JOIN SMS_ClassMaster c ON fd.ClassID = c.ClassId AND c.IsDeleted = 0
    INNER JOIN SMS_FinancialYear fy ON fd.FinancialYearID = fy.FinancialYearId AND fy.IsDeleted = 0
    INNER JOIN SMS_SemesterMaster sem ON fd.SemesterID = sem.SemesterID AND sem.IsDeleted = 0
    WHERE fd.ClassID = @ClassId 
      AND fd.FinancialYearID = @FinancialYearId
      AND fd.IsDeleted = 0 AND fd.IsActive = 1
    ORDER BY sem.SemesterName;
END;
GO


-- ============================================================================
-- 3. CRUD PROCEDURES - STAFF DETAIL
-- ============================================================================

-- GetAll Staff
IF OBJECT_ID('usp_StaffDetail_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_StaffDetail_GetAll;
GO
CREATE PROCEDURE usp_StaffDetail_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_StaffDetails ORDER BY StaffFirstName, StaffLastName;
END;
GO

-- GetById Staff
IF OBJECT_ID('usp_StaffDetail_GetById', 'P') IS NOT NULL DROP PROCEDURE usp_StaffDetail_GetById;
GO
CREATE PROCEDURE usp_StaffDetail_GetById
    @StaffId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_StaffDetails WHERE StaffID = @StaffId;
END;
GO

-- Insert/Update Staff Detail (Upsert)
IF OBJECT_ID('usp_StaffDetail_Save', 'P') IS NOT NULL DROP PROCEDURE usp_StaffDetail_Save;
GO
CREATE PROCEDURE usp_StaffDetail_Save
    @StaffId INT,
    @StaffFirstName NVARCHAR(50),
    @StaffMiddleName NVARCHAR(50) = NULL,
    @StaffLastName NVARCHAR(50),
    @StaffType INT,
    @Mobileno VARCHAR(15),
    @EmergencyContact VARCHAR(15),
    @AddressLine1 NVARCHAR(150),
    @AddressLine2 NVARCHAR(150) = NULL,
    @AadhaarNo VARCHAR(15) = NULL,
    @BankName NVARCHAR(50) = NULL,
    @IFSCCode NVARCHAR(20) = NULL,
    @AccountNo NVARCHAR(20) = NULL,
    @PanNo NVARCHAR(20) = NULL,
    @StaffPic NVARCHAR(MAX) = NULL,
    @DOB DATE,
    @IsActive BIT = 1,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OpType VARCHAR(10);
    DECLARE @OldValues NVARCHAR(MAX);
    DECLARE @NewValues NVARCHAR(MAX);

    BEGIN TRY
        -- Validate Aadhaar Number length (either 12 raw digits or 14 formatted digits) if provided
        IF ISNULL(@AadhaarNo, '') <> '' AND LEN(@AadhaarNo) NOT IN (12, 14)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Aadhaar Number must be 12 digits (or 14 characters with formatting).';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Validate Aadhaar uniqueness if provided
        IF ISNULL(@AadhaarNo, '') <> '' AND EXISTS (SELECT 1 FROM SMS_StaffDetail WHERE AadhaarNo = @AadhaarNo AND StaffID <> @StaffId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'A staff member with this Aadhaar Number already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check if Staff Type exists
        IF NOT EXISTS (SELECT 1 FROM SMS_StaffTypeMaster WHERE StaffTypeID = @StaffType AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Invalid Staff Type selected.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @StaffId = 0 OR @StaffId IS NULL
        BEGIN
            -- INSERT
            SET @OpType = 'INSERT';
            INSERT INTO SMS_StaffDetail (
                StaffFirstName, StaffMiddleName, StaffLastName, StaffType, Mobileno,
                EmergencyContact, AddressLine1, AddressLine2, AadhaarNo, BankName, IFSCCode, AccountNo,
                PanNo, StaffPic, DOB, IsActive, CreatedBy
            )
            VALUES (
                @StaffFirstName, @StaffMiddleName, @StaffLastName, @StaffType, @Mobileno,
                @EmergencyContact, @AddressLine1, @AddressLine2, @AadhaarNo, @BankName, @IFSCCode, @AccountNo,
                @PanNo, @StaffPic, @DOB, @IsActive, @PerformedBy
            );
            
            SET @StaffId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- UPDATE
            SET @OpType = 'UPDATE';
            IF NOT EXISTS (SELECT 1 FROM SMS_StaffDetail WHERE StaffID = @StaffId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Staff member not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            -- Get Old values for Audit Log
            SET @OldValues = (SELECT * FROM SMS_StaffDetail WHERE StaffID = @StaffId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE SMS_StaffDetail
            SET StaffFirstName = @StaffFirstName,
                StaffMiddleName = @StaffMiddleName,
                StaffLastName = @StaffLastName,
                StaffType = @StaffType,
                Mobileno = @Mobileno,
                EmergencyContact = @EmergencyContact,
                AddressLine1 = @AddressLine1,
                AddressLine2 = @AddressLine2,
                AadhaarNo = @AadhaarNo,
                BankName = @BankName,
                IFSCCode = @IFSCCode,
                AccountNo = @AccountNo,
                PanNo = @PanNo,
                StaffPic = ISNULL(@StaffPic, StaffPic), -- Retain old picture if not uploaded new
                DOB = @DOB,
                IsActive = @IsActive,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE StaffID = @StaffId;
        END

        -- Capture new values and write Audit Log
        SET @NewValues = (SELECT * FROM SMS_StaffDetail WHERE StaffID = @StaffId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_StaffDetail', @StaffId, @OpType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message, @StaffId AS StaffId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- Delete Staff
IF OBJECT_ID('usp_StaffDetail_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_StaffDetail_Delete;
GO
CREATE PROCEDURE usp_StaffDetail_Delete
    @StaffId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OldValues NVARCHAR(MAX);

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM SMS_StaffDetail WHERE StaffID = @StaffId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Staff member not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Prevent deletion if assigned to class schedules
        IF EXISTS (SELECT 1 FROM SMS_ClassSchedules WHERE StaffId = @StaffId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete staff member as they are actively assigned to a class schedule.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        SET @OldValues = (SELECT * FROM SMS_StaffDetail WHERE StaffID = @StaffId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE SMS_StaffDetail
        SET IsDeleted = 1,
            IsActive = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE StaffID = @StaffId;

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_StaffDetail', @StaffId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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


-- ============================================================================
-- 4. CRUD PROCEDURES - FEE MASTER
-- ============================================================================

-- GetAll SMS_FeeMaster
IF OBJECT_ID('usp_FeeMaster_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_FeeMaster_GetAll;
GO
CREATE PROCEDURE usp_FeeMaster_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FeeID, Fee, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy, IsActive, IsDeleted 
    FROM SMS_FeeMaster 
    WHERE IsDeleted = 0 
    ORDER BY Fee;
END;
GO

-- Save (Upsert) SMS_FeeMaster
IF OBJECT_ID('usp_FeeMaster_Save', 'P') IS NOT NULL DROP PROCEDURE usp_FeeMaster_Save;
GO
CREATE PROCEDURE usp_FeeMaster_Save
    @FeeId INT,
    @Fee DECIMAL(18,2),
    @IsActive BIT = 1,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OpType VARCHAR(10);
    DECLARE @OldValues NVARCHAR(MAX);
    DECLARE @NewValues NVARCHAR(MAX);

    BEGIN TRY
        IF @Fee < 0
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Fee amount cannot be negative.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Check unique fee value
        IF EXISTS (SELECT 1 FROM SMS_FeeMaster WHERE Fee = @Fee AND FeeID <> @FeeId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'This fee amount already exists.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @FeeId = 0 OR @FeeId IS NULL
        BEGIN
            SET @OpType = 'INSERT';
            INSERT INTO SMS_FeeMaster (Fee, IsActive, CreatedBy)
            VALUES (@Fee, @IsActive, @PerformedBy);
            SET @FeeId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            SET @OpType = 'UPDATE';
            IF NOT EXISTS (SELECT 1 FROM SMS_FeeMaster WHERE FeeID = @FeeId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Fee not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM SMS_FeeMaster WHERE FeeID = @FeeId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE SMS_FeeMaster
            SET Fee = @Fee,
                IsActive = @IsActive,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE FeeID = @FeeId;
        END

        SET @NewValues = (SELECT * FROM SMS_FeeMaster WHERE FeeID = @FeeId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_FeeMaster', @FeeId, @OpType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message, @FeeId AS FeeId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO


-- ============================================================================
-- 5. CRUD PROCEDURES - FEE DETAIL (CLASS FEE SCHEDULING)
-- ============================================================================

-- GetAll mapped SMS_FeeDetail
IF OBJECT_ID('usp_FeeDetail_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_FeeDetail_GetAll;
GO
CREATE PROCEDURE usp_FeeDetail_GetAll
    @FinancialYearId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * 
    FROM vw_FeeDetails
    WHERE (@FinancialYearId IS NULL OR FinancialYearID = @FinancialYearId)
    ORDER BY ClassName, SemesterName;
END;
GO

-- GetById SMS_FeeDetail
IF OBJECT_ID('usp_FeeDetail_GetById', 'P') IS NOT NULL DROP PROCEDURE usp_FeeDetail_GetById;
GO
CREATE PROCEDURE usp_FeeDetail_GetById
    @FeeDetailId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_FeeDetails WHERE FeeDetailID = @FeeDetailId;
END;
GO

-- Save mapped SMS_FeeDetail
IF OBJECT_ID('usp_FeeDetail_Save', 'P') IS NOT NULL DROP PROCEDURE usp_FeeDetail_Save;
GO
CREATE PROCEDURE usp_FeeDetail_Save
    @FeeDetailId INT,
    @FeeId INT,
    @ClassId INT,
    @FinancialYearId INT,
    @SemesterId INT,
    @IsActive BIT = 1,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OpType VARCHAR(10);
    DECLARE @OldValues NVARCHAR(MAX);
    DECLARE @NewValues NVARCHAR(MAX);

    BEGIN TRY
        -- Verify FKs
        IF NOT EXISTS (SELECT 1 FROM SMS_FeeMaster WHERE FeeID = @FeeId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Fee amount is invalid.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SMS_ClassMaster WHERE ClassId = @ClassId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Class is invalid.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SMS_SemesterMaster WHERE SemesterID = @SemesterId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Semester is invalid.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SMS_FinancialYear WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Selected Financial Year is invalid.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Prevent duplicate fee mappings for the same Class, Semester, and Financial Year
        IF EXISTS (
            SELECT 1 FROM SMS_FeeDetail 
            WHERE ClassID = @ClassId 
              AND SemesterID = @SemesterId 
              AND FinancialYearID = @FinancialYearId 
              AND FeeDetailID <> @FeeDetailId
              AND IsDeleted = 0
        )
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'A fee mapping already exists for this Class, Semester, and Financial Year combination.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @FeeDetailId = 0 OR @FeeDetailId IS NULL
        BEGIN
            SET @OpType = 'INSERT';
            INSERT INTO SMS_FeeDetail (FeeID, ClassID, FinancialYearID, SemesterID, IsActive, CreatedBy)
            VALUES (@FeeId, @ClassId, @FinancialYearId, @SemesterId, @IsActive, @PerformedBy);
            SET @FeeDetailId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            SET @OpType = 'UPDATE';
            IF NOT EXISTS (SELECT 1 FROM SMS_FeeDetail WHERE FeeDetailID = @FeeDetailId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Fee mapping record not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM SMS_FeeDetail WHERE FeeDetailID = @FeeDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE SMS_FeeDetail
            SET FeeID = @FeeId,
                ClassID = @ClassId,
                FinancialYearID = @FinancialYearId,
                SemesterID = @SemesterId,
                IsActive = @IsActive,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE FeeDetailID = @FeeDetailId;
        END

        SET @NewValues = (SELECT * FROM SMS_FeeDetail WHERE FeeDetailID = @FeeDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_FeeDetail', @FeeDetailId, @OpType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message, @FeeDetailId AS FeeDetailId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- Delete SMS_FeeDetail mapping
IF OBJECT_ID('usp_FeeDetail_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_FeeDetail_Delete;
GO
CREATE PROCEDURE usp_FeeDetail_Delete
    @FeeDetailId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OldValues NVARCHAR(MAX);

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM SMS_FeeDetail WHERE FeeDetailID = @FeeDetailId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Fee mapping record not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- Prevent delete if payments exist for this combination
        DECLARE @FeeId INT, @ClassId INT, @SemesterId INT, @FinancialYearId INT;
        SELECT @FeeId = FeeID, @ClassId = ClassID, @SemesterId = SemesterID, @FinancialYearId = FinancialYearID 
        FROM SMS_FeeDetail 
        WHERE FeeDetailID = @FeeDetailId;

        IF EXISTS (
            SELECT 1 FROM SMS_PaymentDetail pd
            INNER JOIN SMS_StudentMappings sm ON pd.StudentID = sm.StudentId AND sm.IsDeleted = 0
            INNER JOIN SMS_ClassSchedules cs ON sm.ClassScheduleId = cs.ClassScheduleId AND cs.IsDeleted = 0
            WHERE pd.FeeID = @FeeId 
              AND pd.SemesterID = @SemesterId 
              AND pd.FinancialYearID = @FinancialYearId
              AND cs.ClassId = @ClassId
              AND pd.IsDeleted = 0
        )
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Cannot delete fee mapping because payments have already been collected for this fee config.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        SET @OldValues = (SELECT * FROM SMS_FeeDetail WHERE FeeDetailID = @FeeDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE SMS_FeeDetail
        SET IsDeleted = 1,
            IsActive = 0,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE FeeDetailID = @FeeDetailId;

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_FeeDetail', @FeeDetailId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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


-- ============================================================================
-- 6. PROCEDURES - STUDENT PAYMENT DETAIL
-- ============================================================================

-- Get all payments history for a student
IF OBJECT_ID('usp_PaymentDetail_GetByStudent', 'P') IS NOT NULL DROP PROCEDURE usp_PaymentDetail_GetByStudent;
GO
CREATE PROCEDURE usp_PaymentDetail_GetByStudent
    @StudentId INT,
    @FinancialYearId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- If no financial year passed, use current
    IF @FinancialYearId IS NULL OR @FinancialYearId = 0
    BEGIN
        SELECT @FinancialYearId = FinancialYearId 
        FROM SMS_FinancialYear 
        WHERE IsCurrent = 1 AND IsDeleted = 0;
    END

    -- List what the student has paid so far
    SELECT * 
    FROM vw_StudentPayments
    WHERE StudentID = @StudentId 
      AND FinancialYearID = @FinancialYearId
    ORDER BY CreatedDate DESC;
END;
GO

-- Save Student Payment Record
IF OBJECT_ID('usp_PaymentDetail_Save', 'P') IS NOT NULL DROP PROCEDURE usp_PaymentDetail_Save;
GO
CREATE PROCEDURE usp_PaymentDetail_Save
    @PaymentDetailId INT,
    @StudentId INT,
    @FinancialYearId INT,
    @FeeId INT,
    @PaymentMode VARCHAR(12),
    @TransactionRef NVARCHAR(50) = NULL,
    @Transactionphoto NVARCHAR(MAX) = NULL,
    @IsFullyPaid BIT = 0,
    @SemesterId INT,
    @FeePaid DECIMAL(18,2),
    @TotalInstallment INT,
    @Remarks NVARCHAR(250) = NULL,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OpType VARCHAR(10);
    DECLARE @OldValues NVARCHAR(MAX);
    DECLARE @NewValues NVARCHAR(MAX);

    BEGIN TRY
        -- Validation checks
        IF NOT EXISTS (SELECT 1 FROM SMS_StudentInfo WHERE StudentId = @StudentId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Student not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SMS_FinancialYear WHERE FinancialYearId = @FinancialYearId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Financial Year not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SMS_FeeMaster WHERE FeeID = @FeeId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Fee configuration not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM SMS_SemesterMaster WHERE SemesterID = @SemesterId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Semester not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        IF @FeePaid < 0
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Fee paid amount cannot be negative.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        -- If online mode, Reference Number is mandatory
        IF @PaymentMode IN ('Card', 'UPI', 'NetBanking') AND ISNULL(@TransactionRef, '') = ''
        BEGIN
            SET @StatusCode = 400;
            SET @Message = 'Transaction reference number is required for online/card payments.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @PaymentDetailId = 0 OR @PaymentDetailId IS NULL
        BEGIN
            SET @OpType = 'INSERT';
            INSERT INTO SMS_PaymentDetail (
                StudentID, FinancialYearID, FeeID, PaymentMode, TransactionRef,
                Transactionphoto, IsFullyPaid, SemesterID, FeePaid, TotalInstallment, Remarks, CreatedBy
            )
            VALUES (
                @StudentId, @FinancialYearId, @FeeId, @PaymentMode, @TransactionRef,
                @Transactionphoto, @IsFullyPaid, @SemesterId, @FeePaid, @TotalInstallment, @Remarks, @PerformedBy
            );
            SET @PaymentDetailId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            SET @OpType = 'UPDATE';
            IF NOT EXISTS (SELECT 1 FROM SMS_PaymentDetail WHERE PaymentDetailID = @PaymentDetailId AND IsDeleted = 0)
            BEGIN
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                SET @StatusCode = 404;
                SET @Message = 'Payment record not found.';
                SELECT @StatusCode AS StatusCode, @Message AS Message;
                RETURN;
            END

            SET @OldValues = (SELECT * FROM SMS_PaymentDetail WHERE PaymentDetailID = @PaymentDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

            UPDATE SMS_PaymentDetail
            SET StudentID = @StudentId,
                FinancialYearID = @FinancialYearId,
                FeeID = @FeeId,
                PaymentMode = @PaymentMode,
                TransactionRef = @TransactionRef,
                Transactionphoto = ISNULL(@Transactionphoto, Transactionphoto), -- Retain old receipt photo if not updated
                IsFullyPaid = @IsFullyPaid,
                SemesterID = @SemesterId,
                FeePaid = @FeePaid,
                TotalInstallment = @TotalInstallment,
                Remarks = @Remarks,
                UpdatedDate = SYSUTCDATETIME(),
                UpdatedBy = @PerformedBy
            WHERE PaymentDetailID = @PaymentDetailId;
        END

        SET @NewValues = (SELECT * FROM SMS_PaymentDetail WHERE PaymentDetailID = @PaymentDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_PaymentDetail', @PaymentDetailId, @OpType, @OldValues, @NewValues, @PerformedBy, @IPAddress, @PerformedBy);

        COMMIT TRANSACTION;
        SELECT @StatusCode AS StatusCode, @Message AS Message, @PaymentDetailId AS PaymentDetailId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @StatusCode = 500;
        SET @Message = ERROR_MESSAGE();
        SELECT @StatusCode AS StatusCode, @Message AS Message;
    END CATCH
END;
GO

-- GetAll Payments (standalone Payments list page)
IF OBJECT_ID('usp_PaymentDetail_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_PaymentDetail_GetAll;
GO
CREATE PROCEDURE usp_PaymentDetail_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_StudentPayments ORDER BY CreatedDate DESC;
END;
GO

-- Soft-Delete a Payment
IF OBJECT_ID('usp_PaymentDetail_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_PaymentDetail_Delete;
GO
CREATE PROCEDURE usp_PaymentDetail_Delete
    @PaymentDetailId INT,
    @PerformedBy INT,
    @IPAddress VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StatusCode INT = 200;
    DECLARE @Message VARCHAR(255) = 'Success';
    DECLARE @OldValues NVARCHAR(MAX);

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM SMS_PaymentDetail WHERE PaymentDetailID = @PaymentDetailId AND IsDeleted = 0)
        BEGIN
            SET @StatusCode = 404;
            SET @Message = 'Payment record not found.';
            SELECT @StatusCode AS StatusCode, @Message AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        SET @OldValues = (SELECT * FROM SMS_PaymentDetail WHERE PaymentDetailID = @PaymentDetailId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

        UPDATE SMS_PaymentDetail
        SET IsDeleted = 1,
            UpdatedDate = SYSUTCDATETIME(),
            UpdatedBy = @PerformedBy
        WHERE PaymentDetailID = @PaymentDetailId;

        INSERT INTO SMS_AuditLogs (TableName, RecordId, OperationType, OldValuesJson, NewValuesJson, PerformedBy, IPAddress, CreatedBy)
        VALUES ('SMS_PaymentDetail', @PaymentDetailId, 'DELETE', @OldValues, NULL, @PerformedBy, @IPAddress, @PerformedBy);

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

-- Retrieve students with pending fees
IF OBJECT_ID('usp_Report_GetPendingFees', 'P') IS NOT NULL DROP PROCEDURE usp_Report_GetPendingFees;
GO
CREATE PROCEDURE usp_Report_GetPendingFees
    @ClassId INT = NULL,
    @SemesterId INT = NULL,
    @FinancialYearId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- If financial year is not provided, use the active one
    IF @FinancialYearId IS NULL
    BEGIN
        SELECT TOP 1 @FinancialYearId = FinancialYearId 
        FROM SMS_FinancialYear 
        WHERE IsCurrent = 1 AND IsDeleted = 0;
    END

    SELECT 
        s.StudentId,
        (s.FirstName + ' ' + ISNULL(s.MiddleName + ' ', '') + s.LastName) AS StudentFullName,
        s.GrNo,
        c.ClassId,
        c.ClassName,
        d.DivisionName,
        sm.RollNo,
        (st.StaffFirstName + ' ' + ISNULL(st.StaffMiddleName + ' ', '') + st.StaffLastName) AS StaffName,
        sm.FinancialYearId,
        fy.SMS_FinancialYear,
        fd.FeeID AS FeeId,
        fd.SemesterID AS SemesterId,
        sem.SemesterName,
        fm.Fee AS TotalFeeAmount,
        ISNULL(paid.TotalPaid, 0) AS AmountPaid,
        (fm.Fee - ISNULL(paid.TotalPaid, 0)) AS RemainingBalance
    FROM SMS_StudentMappings sm
    INNER JOIN SMS_StudentInfo s ON sm.StudentId = s.StudentId AND s.IsDeleted = 0
    INNER JOIN SMS_ClassSchedules cs ON sm.ClassScheduleId = cs.ClassScheduleId AND cs.IsDeleted = 0
    INNER JOIN SMS_ClassMaster c ON cs.ClassId = c.ClassId AND c.IsDeleted = 0
    INNER JOIN SMS_DivisionMaster d ON cs.DivisionId = d.DivisionId AND d.IsDeleted = 0
    INNER JOIN SMS_FinancialYear fy ON sm.FinancialYearId = fy.FinancialYearId AND fy.IsDeleted = 0
    INNER JOIN SMS_FeeDetail fd ON cs.ClassId = fd.ClassID AND fd.FinancialYearID = sm.FinancialYearId AND fd.IsDeleted = 0 AND fd.IsActive = 1
    INNER JOIN SMS_FeeMaster fm ON fd.FeeID = fm.FeeID AND fm.IsDeleted = 0
    INNER JOIN SMS_SemesterMaster sem ON fd.SemesterID = sem.SemesterID AND sem.IsDeleted = 0
    LEFT JOIN SMS_StaffDetail st ON cs.StaffId = st.StaffID AND st.IsDeleted = 0
    LEFT JOIN (
        SELECT StudentID, FinancialYearID, FeeID, SemesterID, SUM(FeePaid) AS TotalPaid
        FROM SMS_PaymentDetail
        WHERE IsDeleted = 0
        GROUP BY StudentID, FinancialYearID, FeeID, SemesterID
    ) paid ON sm.StudentId = paid.StudentID 
          AND sm.FinancialYearId = paid.FinancialYearID 
          AND fd.FeeID = paid.FeeID 
          AND fd.SemesterID = paid.SemesterID
    WHERE sm.IsDeleted = 0 AND sm.IsActive = 1
      AND sm.FinancialYearId = @FinancialYearId
      AND (@ClassId IS NULL OR cs.ClassId = @ClassId)
      AND (@SemesterId IS NULL OR fd.SemesterID = @SemesterId)
      AND (fm.Fee - ISNULL(paid.TotalPaid, 0)) > 0
    ORDER BY c.ClassName, s.FirstName, sem.SemesterName;
END;
GO




