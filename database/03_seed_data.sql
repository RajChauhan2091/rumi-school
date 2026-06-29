-- Seed data script/* Generated from the original seed data SQL file */-- Step 6: Seed Data Script
USE SMS;
GO

-- 1. Seed SMS_Roles
INSERT INTO SMS_Roles (RoleName, CreatedBy)
VALUES 
    ('Administrator', 1),
    ('Clerk', 1);
GO

-- 2. Seed Default Admin User
-- Supply AdminPasswordHash through sqlcmd or your deployment secret store.
INSERT INTO SMS_Users (Username, PasswordHash, FullName, EmailAddress, CreatedBy)
VALUES 
    ('admin', 'AQAAAAEAACcQAAAAEL/5rBAXlEOyPr8qkI3zrkG9s7dxmeW1CavmFnI9hhntrdub38kMW0xsNBhNLh5X3A==', 'System Administrator', 'admin@sms.com', 1);
GO

-- 3. Map Admin User to Administrator Role
INSERT INTO SMS_UserRoles (UserId, RoleId, CreatedBy)
VALUES 
    (1, 1, 1);
GO

-- 4. Seed SMS_FinancialYear
INSERT INTO SMS_FinancialYear (SMS_FinancialYear, StartDate, EndDate, IsCurrent, CreatedBy)
VALUES 
    ('2025-2026', '2025-04-01', '2026-03-31', 0, 1),
    ('2026-2027', '2026-04-01', '2027-03-31', 1, 1);
GO

-- 5. Seed SMS_DivisionMaster
INSERT INTO SMS_DivisionMaster (DivisionName, CreatedBy)
VALUES 
    ('A', 1),
    ('B', 1),
    ('C', 1),
    ('D', 1);
GO

-- 6. Seed SMS_ClassMaster
INSERT INTO SMS_ClassMaster (ClassName, CreatedBy)
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

-- 7. Seed SMS_SemesterMaster
INSERT INTO SMS_SemesterMaster (SemesterName, CreatedBy)
VALUES 
    ('Sem-1', 1),
    ('Sem-2', 1);
GO

-- 8. Seed SMS_StaffTypeMaster
INSERT INTO SMS_StaffTypeMaster (StaffType, CreatedBy)
VALUES 
    ('Teaching Staff', 1),
    ('Non-Teaching Staff', 1),
    ('Admin Support', 1);
GO

-- 9. Seed SMS_FeeMaster
INSERT INTO SMS_FeeMaster (Fee, CreatedBy)
VALUES 
    (3000.00, 1),
    (5000.00, 1),
    (7000.00, 1),
    (10000.00, 1);
GO

-- 10. Seed Staff Details (so we can assign them to Class Schedules)
INSERT INTO SMS_StaffDetail (
    StaffFirstName, StaffMiddleName, StaffLastName, StaffType, Mobileno, 
    EmergencyContact, AddressLine1, AddressLine2, AadhaarNo, BankName, IFSCCode, AccountNo, 
    PanNo, DOB, IsActive, CreatedBy
)
VALUES 
    ('John', 'Robert', 'Doe', 1, '9876543210', '9876543211', '123 Teacher Lane', 'City', '1234-5678-9012', 'State Bank of India', 'SBIN0001234', '100020003000', 'ABCDE1234F', '1985-05-15', 1, 1),
    ('Mary', 'Alice', 'Smith', 1, '9876543220', '9876543221', '456 Faculty Road', 'City', '1234-5678-9023', 'HDFC Bank', 'HDFC0004567', '100020003001', 'FGHIJ5678K', '1990-08-22', 1, 1),
    ('David', 'James', 'Brown', 2, '9876543230', '9876543231', '789 Staff Street', 'City', '1234-5678-9034', 'ICICI Bank', 'ICIC0007890', '100020003002', 'LMNOP9012Q', '1988-12-10', 1, 1);
GO

-- 11. Seed Class Schedules (connecting Classes, Divisions, Financial Year, Staff)
-- Class 10 (ClassId=13), Division A (DivisionId=1), SMS_FinancialYear 2026-2027 (FYId=2), StaffId=1 (John Doe)
-- Class 12 (ClassId=15), Division B (DivisionId=2), SMS_FinancialYear 2026-2027 (FYId=2), StaffId=2 (Mary Smith)
INSERT INTO SMS_ClassSchedules (ClassId, DivisionId, FinancialYearId, MaxCapacity, StaffId, CreatedBy)
VALUES 
    (13, 1, 2, 40, 1, 1),
    (15, 2, 2, 35, 2, 1);
GO

-- 12. Seed Students
INSERT INTO SMS_StudentInfo (
    GrNo, AdmissionDate, FirstName, MiddleName, LastName, DateOfBirth, 
    Gender, Nationality, AddressLine1, City, State, PinCode, 
    FatherName, FatherMobileNumber, MotherName, EmergencyContactNumber, 
    AdmissionFinancialYearId, CreatedBy
)
VALUES 
    ('GR1001', '2026-06-01', 'Alice', 'Marie', 'Johnson', '2011-04-10', 'Female', 'Indian', '789 Student Way', 'City', 'State', '400001', 'Robert Johnson', '9898989801', 'Sarah Johnson', '9898989802', 2, 1),
    ('GR1002', '2026-06-02', 'Bob', 'Edward', 'Miller', '2009-09-15', 'Male', 'Indian', '456 Scholar Ave', 'City', 'State', '400002', 'William Miller', '9898989811', 'Linda Miller', '9898989812', 2, 1);
GO

-- 13. Seed Student Mappings (Alice mapped to Class 10 Div A, Bob to Class 12 Div B)
INSERT INTO SMS_StudentMappings (StudentId, ClassScheduleId, FinancialYearId, RollNo, CreatedBy)
VALUES 
    (1, 1, 2, 1, 1),
    (2, 2, 2, 1, 1);
GO

-- 14. Seed Fee Details (mapping fees to Classes, Semesters, Financial Years)
-- Class 10 (ClassId=13), Sem-1 (SemesterId=1) Fee=7000 (FeeId=3)
-- Class 10 (ClassId=13), Sem-2 (SemesterId=2) Fee=7000 (FeeId=3)
-- Class 12 (ClassId=15), Sem-1 (SemesterId=1) Fee=10000 (FeeId=4)
INSERT INTO SMS_FeeDetail (FeeID, ClassID, FinancialYearID, SemesterID, IsActive, CreatedBy)
VALUES 
    (3, 13, 2, 1, 1, 1),
    (3, 13, 2, 2, 1, 1),
    (4, 15, 2, 1, 1, 1);
GO

-- 15. Seed Student Payments (Alice pays for Class 10 Sem-1)
INSERT INTO SMS_PaymentDetail (StudentID, FinancialYearID, FeeID, SemesterID, PaymentMode, TransactionRef, IsFullyPaid, FeePaid, TotalInstallment, CreatedBy)
VALUES 
    (1, 2, 3, 1, 'Cash', 'CASH-0001', 1, 7000.00, 1, 1);
GO




