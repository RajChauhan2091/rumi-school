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
GO

