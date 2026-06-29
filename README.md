# School Management System (SMS) - MVC

A secure, high-performance, and beautifully styled web-based **School Management System (SMS)** built with **ASP.NET Core MVC (.NET 7)**, **Entity Framework Core**, and **SQL Server**. It adheres strictly to **Clean Architecture** patterns, leveraging an SP-first (Stored Procedure first) mutation model with comprehensive view reporting.

---

## 1. Project Directory Structure

```text
├── database/                   # Database schema, business objects, and seed data
│   ├── 01_create_tables.sql    # Database creation, tables, constraints, and indexes
│   ├── 02_sp_functions_views.sql # Functions, views, and stored procedures
│   └── 03_seed_data.sql        # Demo data and initial records
├── docs/                       # System design and architecture docs
├── src/                        # C# source code solution (.NET 7)
│   ├── SchoolManagement.Domain # Keyless query entities and data models
│   ├── SchoolManagement.Application # Service orchestration and business rules
│   ├── SchoolManagement.Infrastructure # EF Core context and SQL procedure call maps
│   └── SchoolManagement.Web    # Razor templates, controllers, and custom CSS theme
└── scratch/                    # Deployment helpers and utility patches
```

---

## 2. Quick-Start Database Setup Guide

To deploy the database to a clean local or remote SQL Server instance, choose **one** of the two methods below:

### Database Deployment
1. Open your SQL Server Management Studio (SSMS) or command-line client.
2. Run the SQL files in the `database/` folder in this order:
   1. `01_create_tables.sql`
   2. `02_sp_functions_views.sql`
   3. `03_seed_data.sql`

These three files contain the complete database setup for tables, objects, and seed data.

---

## 3. Running the Web Application

1. Open **`src/SchoolManagement.Web/appsettings.json`** and configure your connection string:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=YOUR_SERVER_NAME;Database=SMS;Trusted_Connection=True;TrustServerCertificate=True;"
   }
   ```
2. Open a terminal in the solution source directory:
   ```bash
   cd src/SchoolManagement.Web
   ```
3. Run the development server:
   ```bash
   dotnet run --launch-profile "http"
   ```
4. Access the web app in your browser at: **`http://localhost:5076`**

---

## 4. Default Seed Credentials

Use the following credentials to access the system:

*   **Role**: System Administrator
*   **Username**: `admin`
*   **Password**: `Admin@123`

---

## 5. Phase 2 Features Implemented

*   **Manual GR Entries**: The auto-generated GR function was removed from `usp_Student_Save` in favor of user-inputted GR numbers with server-side validation to block duplicates.
*   **Fee Mapping**: Link specific semesters (e.g. Sem-1, Sem-2) and fee values to classes. Accessible directly in the sidebar.
*   **Dynamic Payments**: Redesigned collection slip with searchable student filters, live fee structure populator, and automatic balance calculations.
*   **Audit Trail**: Every modification (insert, edit, delete) writes to `SMS_AuditLogs` using native JSON tracking.

