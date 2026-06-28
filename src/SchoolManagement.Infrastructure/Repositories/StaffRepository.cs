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
    public class StaffRepository : IStaffRepository
    {
        private readonly SchoolDbContext _context;

        public StaffRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<StaffDetailsView>> GetAllAsync()
        {
            return await _context.StaffDetailsView
                .FromSqlRaw("EXEC usp_StaffDetail_GetAll")
                .ToListAsync();
        }

        public async Task<StaffDetailsView?> GetByIdAsync(int id)
        {
            var result = await _context.StaffDetailsView
                .FromSqlRaw("EXEC usp_StaffDetail_GetById @StaffId", new SqlParameter("@StaffId", id))
                .ToListAsync();
            return result.FirstOrDefault();
        }

        public async Task<DbOperationResult> SaveAsync(StaffDetail entity, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_StaffDetail_Save @StaffId, @StaffFirstName, @StaffMiddleName, @StaffLastName, @StaffType, @Mobileno, @EmergencyContact, @AddressLine1, @AddressLine2, @AadhaarNo, @BankName, @IFSCCode, @AccountNo, @PanNo, @StaffPic, @DOB, @IsActive, @PerformedBy, @IPAddress",
                    new SqlParameter("@StaffId", entity.StaffID),
                    new SqlParameter("@StaffFirstName", entity.StaffFirstName),
                    new SqlParameter("@StaffMiddleName", entity.StaffMiddleName ?? (object)DBNull.Value),
                    new SqlParameter("@StaffLastName", entity.StaffLastName),
                    new SqlParameter("@StaffType", entity.StaffType),
                    new SqlParameter("@Mobileno", entity.Mobileno),
                    new SqlParameter("@EmergencyContact", entity.EmergencyContact),
                    new SqlParameter("@AddressLine1", entity.AddressLine1),
                    new SqlParameter("@AddressLine2", entity.AddressLine2 ?? (object)DBNull.Value),
                    new SqlParameter("@AadhaarNo", entity.AadhaarNo ?? (object)DBNull.Value),
                    new SqlParameter("@BankName", entity.BankName ?? (object)DBNull.Value),
                    new SqlParameter("@IFSCCode", entity.IFSCCode ?? (object)DBNull.Value),
                    new SqlParameter("@AccountNo", entity.AccountNo ?? (object)DBNull.Value),
                    new SqlParameter("@PanNo", entity.PanNo ?? (object)DBNull.Value),
                    new SqlParameter("@StaffPic", entity.StaffPic ?? (object)DBNull.Value),
                    new SqlParameter("@DOB", entity.DOB),
                    new SqlParameter("@IsActive", entity.IsActive),
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
                    "EXEC usp_StaffDetail_Delete @StaffId, @PerformedBy, @IPAddress",
                    new SqlParameter("@StaffId", id),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }

        public async Task<IEnumerable<StaffTypeMaster>> GetStaffTypesAsync()
        {
            return await _context.StaffTypes
                .FromSqlRaw("EXEC usp_Dropdown_GetStaffTypes")
                .ToListAsync();
        }

        public async Task<IEnumerable<StaffDetail>> GetStaffDropdownAsync(int? staffTypeId = null)
        {
            // Executing the helper dropdown stored procedure
            var rawList = await _context.StaffDetailsView
                .FromSqlRaw("EXEC usp_Dropdown_GetStaff @StaffTypeId", 
                    new SqlParameter("@StaffTypeId", staffTypeId ?? (object)DBNull.Value))
                .ToListAsync();

            return rawList.Select(x => new StaffDetail
            {
                StaffID = x.StaffID,
                StaffFirstName = x.StaffFullName // map fullName helper to firstName for SelectList convenience
            });
        }
    }
}
