-- Step 6: Seed Data Script
USE SMS;
GO

-- 1. Seed Roles
INSERT INTO Roles (RoleName, CreatedBy)
VALUES 
    ('Administrator', 1),
    ('Clerk', 1);
GO

-- 2. Seed Default Admin User
-- Supply AdminPasswordHash through sqlcmd or your deployment secret store.
INSERT INTO Users (Username, PasswordHash, FullName, EmailAddress, CreatedBy)
VALUES 
    ('admin', '$(AdminPasswordHash)', 'System Administrator', 'admin@sms.com', 1);
GO

-- 3. Map Admin User to Administrator Role
INSERT INTO UserRoles (UserId, RoleId, CreatedBy)
VALUES 
    (1, 1, 1);
GO

-- 4. Seed FinancialYear
INSERT INTO FinancialYear (FinancialYear, StartDate, EndDate, IsCurrent, CreatedBy)
VALUES 
    ('2025-2026', '2025-04-01', '2026-03-31', 0, 1),
    ('2026-2027', '2026-04-01', '2027-03-31', 1, 1);
GO

-- 5. Seed DivisionMaster
INSERT INTO DivisionMaster (DivisionName, CreatedBy)
VALUES 
    ('A', 1),
    ('B', 1),
    ('C', 1),
    ('D', 1);
GO

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

