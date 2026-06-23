-- Step 8: Views Script
USE SMS;
GO

-- ============================================================================
-- 1. vw_ActiveClassSchedules
-- Exposes all active class schedules joined with Class, Division, and Financial Year details.
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

-- ============================================================================
-- 2. vw_StudentDetails
-- Exposes student profiles, including their active class mapping and current class/roll details.
-- Supports students with or without current active class mappings (LEFT JOIN on mapping tables).
-- ============================================================================
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
    
    -- Mapping & Classroom details (for the current financial year or mapping record)
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

