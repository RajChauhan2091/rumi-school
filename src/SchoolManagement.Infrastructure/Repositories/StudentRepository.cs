using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;
using SchoolManagement.Infrastructure.Data;

namespace SchoolManagement.Infrastructure.Repositories
{
    public class StudentRepository : IStudentRepository
    {
        private readonly SchoolDbContext _context;

        public StudentRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<StudentDetailsView>> GetAllAsync()
        {
            return await _context.StudentDetailsView
                .FromSqlRaw("EXEC usp_Student_GetAll")
                .ToListAsync();
        }

        public async Task<IEnumerable<StudentDetailsView>> GetByIdAsync(int id)
        {
            return await _context.StudentDetailsView
                .FromSqlRaw("EXEC usp_Student_GetById @StudentId", new SqlParameter("@StudentId", id))
                .ToListAsync();
        }

        public async Task<IEnumerable<StudentDetailsView>> SearchAsync(string searchText, int? classScheduleId, int? financialYearId, string gender)
        {
            return await _context.StudentDetailsView
                .FromSqlRaw(
                    "EXEC usp_Student_Search @SearchText, @ClassScheduleId, @FinancialYearId, @Gender",
                    new SqlParameter("@SearchText", searchText ?? (object)DBNull.Value),
                    new SqlParameter("@ClassScheduleId", classScheduleId ?? (object)DBNull.Value),
                    new SqlParameter("@FinancialYearId", financialYearId ?? (object)DBNull.Value),
                    new SqlParameter("@Gender", gender ?? (object)DBNull.Value)
                )
                .ToListAsync();
        }

        public async Task<DbOperationResult> SaveAsync(StudentInfo entity, int? classScheduleId, int? rollNo, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_Student_Save " +
                    "@StudentId, @GrNo, @AdmissionDate, @FirstName, @MiddleName, @LastName, @DateOfBirth, @Gender, @StudentPhoto, " +
                    "@PlaceOfBirth, @Nationality, @BloodGroup, @Category, @Religion, @AadhaarNumber, " +
                    "@AddressLine1, @AddressLine2, @City, @State, @Country, @PinCode, " +
                    "@FatherName, @FatherOccupation, @FatherMobileNumber, @MotherName, @MotherOccupation, @MotherMobileNumber, " +
                    "@GuardianName, @GuardianMobileNumber, @Guardian2Name, @Guardian2MobileNumber, @EmergencyContactNumber, " +
                    "@PreviousSchoolName, @AdmissionFinancialYearId, @EmailAddress, " +
                    "@ClassScheduleId, @RollNo, @PerformedBy, @IPAddress",
                    new SqlParameter("@StudentId", entity.StudentId),
                    new SqlParameter("@GrNo", entity.GrNo ?? (object)DBNull.Value),
                    new SqlParameter("@AdmissionDate", entity.AdmissionDate),
                    new SqlParameter("@FirstName", entity.FirstName ?? (object)DBNull.Value),
                    new SqlParameter("@MiddleName", entity.MiddleName ?? (object)DBNull.Value),
                    new SqlParameter("@LastName", entity.LastName ?? (object)DBNull.Value),
                    new SqlParameter("@DateOfBirth", entity.DateOfBirth),
                    new SqlParameter("@Gender", entity.Gender ?? (object)DBNull.Value),
                    new SqlParameter("@StudentPhoto", System.Data.SqlDbType.VarBinary) { Value = (object?)entity.StudentPhoto ?? DBNull.Value },
                    new SqlParameter("@PlaceOfBirth", entity.PlaceOfBirth ?? (object)DBNull.Value),
                    new SqlParameter("@Nationality", entity.Nationality ?? (object)DBNull.Value),
                    new SqlParameter("@BloodGroup", entity.BloodGroup ?? (object)DBNull.Value),
                    new SqlParameter("@Category", entity.Category ?? (object)DBNull.Value),
                    new SqlParameter("@Religion", entity.Religion ?? (object)DBNull.Value),
                    new SqlParameter("@AadhaarNumber", entity.AadhaarNumber ?? (object)DBNull.Value),
                    new SqlParameter("@AddressLine1", entity.AddressLine1 ?? (object)DBNull.Value),
                    new SqlParameter("@AddressLine2", entity.AddressLine2 ?? (object)DBNull.Value),
                    new SqlParameter("@City", entity.City ?? (object)DBNull.Value),
                    new SqlParameter("@State", entity.State ?? (object)DBNull.Value),
                    new SqlParameter("@Country", entity.Country ?? (object)DBNull.Value),
                    new SqlParameter("@PinCode", entity.PinCode ?? (object)DBNull.Value),
                    new SqlParameter("@FatherName", entity.FatherName ?? (object)DBNull.Value),
                    new SqlParameter("@FatherOccupation", entity.FatherOccupation ?? (object)DBNull.Value),
                    new SqlParameter("@FatherMobileNumber", entity.FatherMobileNumber ?? (object)DBNull.Value),
                    new SqlParameter("@MotherName", entity.MotherName ?? (object)DBNull.Value),
                    new SqlParameter("@MotherOccupation", entity.MotherOccupation ?? (object)DBNull.Value),
                    new SqlParameter("@MotherMobileNumber", entity.MotherMobileNumber ?? (object)DBNull.Value),
                    new SqlParameter("@GuardianName", entity.GuardianName ?? (object)DBNull.Value),
                    new SqlParameter("@GuardianMobileNumber", entity.GuardianMobileNumber ?? (object)DBNull.Value),
                    new SqlParameter("@Guardian2Name", entity.Guardian2Name ?? (object)DBNull.Value),
                    new SqlParameter("@Guardian2MobileNumber", entity.Guardian2MobileNumber ?? (object)DBNull.Value),
                    new SqlParameter("@EmergencyContactNumber", entity.EmergencyContactNumber ?? (object)DBNull.Value),
                    new SqlParameter("@PreviousSchoolName", entity.PreviousSchoolName ?? (object)DBNull.Value),
                    new SqlParameter("@AdmissionFinancialYearId", entity.AdmissionFinancialYearId),
                    new SqlParameter("@EmailAddress", entity.EmailAddress ?? (object)DBNull.Value),
                    new SqlParameter("@ClassScheduleId", classScheduleId ?? (object)DBNull.Value),
                    new SqlParameter("@RollNo", rollNo ?? (object)DBNull.Value),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }

        public async Task<DbOperationResult> DeleteAsync(int id, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_Student_Delete @StudentId, @PerformedBy, @IPAddress",
                    new SqlParameter("@StudentId", id),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }
    }
}
