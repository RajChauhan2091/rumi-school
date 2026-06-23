# School Management System (SMS) - Database Design Document

This document outlines the database design for the School Management System (SMS) database, designed using a Database-First approach.

---

## 1. Naming Conventions

To ensure consistency, readability, and compatibility with Entity Framework Core, we adhere to the following naming conventions:

*   **Database Name**: `SMS`
*   **Tables**: PascalCase, Singular/Plural as defined by master schema (e.g., `StudentInfo`, `ClassMaster`, `DivisionMaster`, `FinancialYear`, `ClassSchedules`).
*   **Columns**: PascalCase, Singular (e.g., `FirstName`, `AdmissionDate`, `FinancialYear`).
*   **Primary Keys**: Explicitly marked `{TableName}Id`, typed as `INT IDENTITY(1,1) PRIMARY KEY` (e.g., `StudentId`).
*   **Foreign Keys**: `{TargetTableName}Id` or related custom mapping (e.g., `ClassId` referencing the `ClassMaster` table).
*   **Indexes**:
    *   Clustered (Primary Keys): `PK_{TableName}`
    *   Non-Clustered Indexes: `IX_{TableName}_{ColumnName1}_{ColumnName2}`
    *   Filtered Indexes: `IX_{TableName}_{ColumnName}_Filtered` or `UX_{TableName}_{ColumnName}`
*   **Constraints**:
    *   Unique Constraints/Indexes: `UQ_{TableName}_{ColumnName}` or `UX_{TableName}_{ColumnName}` (if filtered)
    *   Check Constraints: `CK_{TableName}_{ColumnName}`
    *   Default Constraints: `DF_{TableName}_{ColumnName}`
*   **Views**: Prefixed with `vw_` (e.g., `vw_StudentDetails`).
*   **Functions**: Prefixed with `fn_` (e.g., `fn_GenerateGrNo`).
*   **Stored Procedures**: Prefixed with `usp_` (e.g., `usp_Student_Save`).

---

## 2. Global Column Standards

Every table (with the exception of `AuditLogs` which uses custom columns but still includes standard audit metadata) must contain the following fields for soft deletes and record tracking:

| Column Name | Data Type | Nullability | Default Value | Description |
| :--- | :--- | :--- | :--- | :--- |
| `CreatedDate` | `DATETIME2` | `NOT NULL` | `SYSUTCDATETIME()` | The UTC timestamp when the record was created. |
| `CreatedBy` | `INT` | `NOT NULL` | - | The `UserId` of the user who created the record. |
| `UpdatedDate` | `DATETIME2` | `NULL` | - | The UTC timestamp when the record was last updated. |
| `UpdatedBy` | `INT` | `NULL` | - | The `UserId` of the user who last updated the record. |
| `IsActive` | `BIT` | `NOT NULL` | `1` | Indicates if the record is active. |
| `IsDeleted` | `BIT` | `NOT NULL` | `0` | Indicates if the record has been soft-deleted (`1` = Deleted, `0` = Active). |

---

## 3. Table Schema & Constraints

### 3.1. FinancialYear
Tracks the academic/financial cycles of the school (e.g., "2025-2026").
*   **Primary Key**: `FinancialYearId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `FinancialYear` `VARCHAR(20) NOT NULL` (e.g., "2026-2027")
    *   `StartDate` `DATE NOT NULL`
    *   `EndDate` `DATE NOT NULL`
    *   `IsCurrent` `BIT NOT NULL DEFAULT 0`
*   **Constraints & Rules**:
    *   `CK_FinancialYears_Dates`: `StartDate < EndDate`
    *   `UX_FinancialYears_IsCurrent`: Filtered unique index to ensure that only a single active record has `IsCurrent = 1`.
        *   `CREATE UNIQUE INDEX UX_FinancialYears_IsCurrent ON FinancialYear(IsCurrent) WHERE IsCurrent = 1 AND IsDeleted = 0;`
    *   `UX_FinancialYears_FinancialYear`: Unique constraint on `FinancialYear` where `IsDeleted = 0`.

### 3.2. DivisionMaster
Tracks the classrooms divisions/sections (e.g., "A", "B", "C").
*   **Primary Key**: `DivisionId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `DivisionName` `VARCHAR(50) NOT NULL`
*   **Constraints**:
    *   `UX_Divisions_DivisionName`: Unique index on `DivisionName` where `IsDeleted = 0`.

### 3.3. ClassMaster
Tracks the standard grade levels (e.g., "Class 1", "Nursery").
*   **Primary Key**: `ClassId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `ClassName` `VARCHAR(50) NOT NULL`
*   **Constraints**:
    *   `UX_Classes_ClassName`: Unique index on `ClassName` where `IsDeleted = 0`.

### 3.4. ClassSchedules
Maps classes and divisions to a specific financial year (representing actual classrooms).
*   **Primary Key**: `ClassScheduleId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `ClassId` `INT NOT NULL` (FK to `ClassMaster`)
    *   `DivisionId` `INT NOT NULL` (FK to `DivisionMaster`)
    *   `FinancialYearId` `INT NOT NULL` (FK to `FinancialYear`)
    *   `MaxCapacity` `INT NOT NULL`
*   **Constraints**:
    *   `FK_ClassSchedules_Classes_ClassId`: FK to `ClassMaster(ClassId)`
    *   `FK_ClassSchedules_Divisions_DivisionId`: FK to `DivisionMaster(DivisionId)`
    *   `FK_ClassSchedules_FinancialYears_FinancialYearId`: FK to `FinancialYear(FinancialYearId)`
    *   `CK_ClassSchedules_MaxCapacity`: `MaxCapacity > 0`
    *   `UX_ClassSchedules_Year_Class_Div`: Unique index on `FinancialYearId + ClassId + DivisionId` where `IsDeleted = 0`.

### 3.5. StudentInfo
Stores detailed information about students.
*   **Primary Key**: `StudentId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `GrNo` `VARCHAR(20) NOT NULL` (Unique, auto-generated, format: `GR-YYyy-Sequence`)
    *   `AdmissionDate` `DATE NOT NULL`
    *   `FirstName` `VARCHAR(50) NOT NULL`
    *   `MiddleName` `VARCHAR(50) NULL`
    *   `LastName` `VARCHAR(50) NOT NULL`
    *   `DateOfBirth` `DATE NOT NULL`
    *   `Gender` `VARCHAR(10) NOT NULL` (Male, Female, Other)
    *   `StudentPhoto` `VARBINARY(MAX) NULL`
    *   `PlaceOfBirth` `VARCHAR(100) NULL`
    *   `Nationality` `VARCHAR(50) NOT NULL DEFAULT 'Indian'`
    *   `BloodGroup` `VARCHAR(5) NULL`
    *   `Category` `VARCHAR(30) NULL`
    *   `Religion` `VARCHAR(50) NULL`
    *   `AadhaarNumber` `VARCHAR(12) NULL`
    *   `AddressLine1` `VARCHAR(150) NOT NULL`
    *   `AddressLine2` `VARCHAR(150) NULL`
    *   `City` `VARCHAR(50) NOT NULL`
    *   `State` `VARCHAR(50) NOT NULL`
    *   `Country` `VARCHAR(50) NOT NULL DEFAULT 'India'`
    *   `PinCode` `VARCHAR(10) NOT NULL`
    *   `FatherName` `VARCHAR(100) NOT NULL`
    *   `FatherOccupation` `VARCHAR(100) NULL`
    *   `FatherMobileNumber` `VARCHAR(15) NOT NULL`
    *   `MotherName` `VARCHAR(100) NOT NULL`
    *   `MotherOccupation` `VARCHAR(100) NULL`
    *   `MotherMobileNumber` `VARCHAR(15) NULL`
    *   `GuardianName` `VARCHAR(100) NULL`
    *   `GuardianMobileNumber` `VARCHAR(15) NULL`
    *   `EmergencyContactNumber` `VARCHAR(15) NOT NULL`
    *   `PreviousSchoolName` `VARCHAR(150) NULL`
    *   `AdmissionFinancialYearId` `INT NOT NULL` (FK to `FinancialYear`)
    *   `EmailAddress` `VARCHAR(100) NULL`
*   **Constraints**:
    *   `UX_Students_GrNo`: Unique index on `GrNo` where `IsDeleted = 0`.
    *   `FK_Students_FinancialYears_AdmissionFinancialYearId`: FK to `FinancialYear(AdmissionFinancialYearId)`
    *   `CK_Students_Gender`: `Gender IN ('Male', 'Female', 'Other')`
    *   `CK_Students_DateOfBirth`: Checked via stored procedure and application logic (as SQL Server does not support non-deterministic functions in check constraints).

### 3.6. StudentMappings
Tracks student allocations to classes for each financial year.
*   **Primary Key**: `StudentMappingId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `StudentId` `INT NOT NULL` (FK to `StudentInfo`)
    *   `ClassScheduleId` `INT NOT NULL` (FK to `ClassSchedules`)
    *   `FinancialYearId` `INT NOT NULL` (FK to `FinancialYear`)
    *   `RollNo` `INT NOT NULL`
*   **Constraints**:
    *   `FK_StudentMappings_Students_StudentId`: FK to `StudentInfo(StudentId)`
    *   `FK_StudentMappings_ClassSchedules_ClassScheduleId`: FK to `ClassSchedules(ClassScheduleId)`
    *   `FK_StudentMappings_FinancialYears_FinancialYearId`: FK to `FinancialYear(FinancialYearId)`
    *   `UX_StudentMappings_Year_Student`: Unique index on `FinancialYearId + StudentId` where `IsDeleted = 0` (Student can only belong to one class per year).
    *   `UX_StudentMappings_Schedule_RollNo`: Unique index on `ClassScheduleId + RollNo` where `IsDeleted = 0` (Roll number must be unique in a class schedule).

### 3.7. Users
Stores user authentication details.
*   **Primary Key**: `UserId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `Username` `VARCHAR(50) NOT NULL`
    *   `PasswordHash` `VARCHAR(255) NOT NULL` (Argon2id or PBKDF2 representation)
    *   `FullName` `VARCHAR(100) NOT NULL`
    *   `EmailAddress` `VARCHAR(100) NULL`
    *   `LastLoginDate` `DATETIME2 NULL`
*   **Constraints**:
    *   `UX_Users_Username`: Unique index on `Username` where `IsDeleted = 0`.

### 3.8. Roles
Stores security roles.
*   **Primary Key**: `RoleId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `RoleName` `VARCHAR(50) NOT NULL`
*   **Constraints**:
    *   `UX_Roles_RoleName`: Unique index on `RoleName` where `IsDeleted = 0`.

### 3.9. UserRoles
Maps users to their security roles (many-to-many relationship).
*   **Primary Key**: `UserRoleId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `UserId` `INT NOT NULL` (FK to `Users`)
    *   `RoleId` `INT NOT NULL` (FK to `Roles`)
*   **Constraints**:
    *   `FK_UserRoles_Users_UserId`: FK to `Users(UserId)`
    *   `FK_UserRoles_Roles_RoleId`: FK to `Roles(RoleId)`
    *   `UX_UserRoles_User_Role`: Unique index on `UserId + RoleId` where `IsDeleted = 0`.

### 3.10. AuditLogs
Stores an audit trail of modifications.
*   **Primary Key**: `AuditLogId` `INT IDENTITY(1,1) PRIMARY KEY`
*   **Columns**:
    *   `TableName` `VARCHAR(100) NOT NULL`
    *   `RecordId` `INT NOT NULL`
    *   `OperationType` `VARCHAR(10) NOT NULL` (Check constraint: `IN ('INSERT', 'UPDATE', 'DELETE')`)
    *   `OldValuesJson` `NVARCHAR(MAX) NULL`
    *   `NewValuesJson` `NVARCHAR(MAX) NULL`
    *   `PerformedBy` `INT NOT NULL` (References `Users(UserId)` or `-1` for system/anonymous)
    *   `IPAddress` `VARCHAR(50) NULL`
    *   `CreatedDate` `DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()`
*   **Constraints**:
    *   `CK_AuditLogs_OperationType`: `OperationType IN ('INSERT', 'UPDATE', 'DELETE')`

---

## 4. Entity Relationship Diagram (Text Format)

```text
  [FinancialYear]
        |
        |-- (1:N) --> [ClassSchedules] <-- (1:N) -- [ClassMaster]
        |                    |
        |                    |-- (1:N) -- [StudentMappings]
        |                                       ^
        |-- (1:N) --> [StudentInfo] ------------| (1:N)
                             |
                      (Admitted In)
                             

  [DivisionMaster] -- (1:N) --> [ClassSchedules]


  [Users] -- (1:N) --> [UserRoles] <-- (1:N) -- [Roles]
     |
     |--- (1:N) --> [AuditLogs] (via PerformedBy)
```

### Table Relationships & Cardinality

1.  **`FinancialYear` to `ClassSchedules`**: One financial year can have many class schedules. (1:N)
2.  **`ClassMaster` to `ClassSchedules`**: One class can be scheduled across multiple financial years or divisions. (1:N)
3.  **`DivisionMaster` to `ClassSchedules`**: One division can belong to multiple classes and financial years. (1:N)
4.  **`ClassSchedules` to `StudentMappings`**: One class schedule can contain multiple student allocations. (1:N)
5.  **`StudentInfo` to `StudentMappings`**: One student can be mapped to different classes across different financial years, but only one class per financial year. (1:N)
6.  **`FinancialYear` to `StudentMappings`**: One financial year can have many student mappings. (1:N)
7.  **`FinancialYear` to `StudentInfo`**: Tracks the financial year of admission. (1:N)
8.  **`Users` to `UserRoles`**: One user can have many roles. (1:N)
9.  **`Roles` to `UserRoles`**: One role can be assigned to multiple users. (1:N)
10. **`Users` to `AuditLogs`**: One user can perform many operations recorded in the audit logs. (1:N, nullable target if performed by system)
