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
    public class FeeRepository : IFeeRepository
    {
        private readonly SchoolDbContext _context;

        public FeeRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<FeeMaster>> GetFeeMasterAllAsync()
        {
            return await _context.Fees
                .FromSqlRaw("EXEC usp_FeeMaster_GetAll")
                .ToListAsync();
        }

        public async Task<FeeMaster?> GetFeeMasterByIdAsync(int id)
        {
            return await _context.Fees.FindAsync(id);
        }

        public async Task<DbOperationResult> SaveFeeMasterAsync(FeeMaster entity, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_FeeMaster_Save @FeeId, @Fee, @IsActive, @PerformedBy, @IPAddress",
                    new SqlParameter("@FeeId", entity.FeeID),
                    new SqlParameter("@Fee", entity.Fee),
                    new SqlParameter("@IsActive", entity.IsActive),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }

        public async Task<IEnumerable<FeeDetailsView>> GetFeeDetailAllAsync(int? financialYearId = null)
        {
            return await _context.FeeDetailsView
                .FromSqlRaw("EXEC usp_FeeDetail_GetAll @FinancialYearId", 
                    new SqlParameter("@FinancialYearId", financialYearId ?? (object)DBNull.Value))
                .ToListAsync();
        }

        public async Task<FeeDetailsView?> GetFeeDetailByIdAsync(int id)
        {
            var result = await _context.FeeDetailsView
                .FromSqlRaw("EXEC usp_FeeDetail_GetById @FeeDetailId", new SqlParameter("@FeeDetailId", id))
                .ToListAsync();
            return result.FirstOrDefault();
        }

        public async Task<DbOperationResult> SaveFeeDetailAsync(FeeDetail entity, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_FeeDetail_Save @FeeDetailId, @FeeId, @ClassId, @FinancialYearId, @SemesterId, @IsActive, @PerformedBy, @IPAddress",
                    new SqlParameter("@FeeDetailId", entity.FeeDetailID),
                    new SqlParameter("@FeeId", entity.FeeID),
                    new SqlParameter("@ClassId", entity.ClassID),
                    new SqlParameter("@FinancialYearId", entity.FinancialYearID),
                    new SqlParameter("@SemesterId", entity.SemesterID),
                    new SqlParameter("@IsActive", entity.IsActive),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }

        public async Task<DbOperationResult> DeleteFeeDetailAsync(int id, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_FeeDetail_Delete @FeeDetailId, @PerformedBy, @IPAddress",
                    new SqlParameter("@FeeDetailId", id),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }

        public async Task<IEnumerable<SemesterMaster>> GetSemestersAsync()
        {
            return await _context.Semesters
                .FromSqlRaw("EXEC usp_Dropdown_GetSemesters")
                .ToListAsync();
        }

        public async Task<IEnumerable<SemesterMaster>> GetSemestersAllAsync()
        {
            return await _context.Semesters
                .Where(s => !s.IsDeleted)
                .OrderBy(s => s.SemesterName)
                .ToListAsync();
        }

        public async Task<SemesterMaster?> GetSemesterByIdAsync(int id)
        {
            return await _context.Semesters
                .FirstOrDefaultAsync(s => s.SemesterID == id && !s.IsDeleted);
        }

        public async Task<DbOperationResult> SaveSemesterAsync(SemesterMaster entity, int performedBy, string ipAddress)
        {
            try
            {
                if (entity.SemesterID == 0)
                {
                    entity.CreatedBy = performedBy;
                    entity.CreatedDate = DateTime.UtcNow;
                    entity.IsDeleted = false;
                    _context.Semesters.Add(entity);
                }
                else
                {
                    var existing = await _context.Semesters.FindAsync(entity.SemesterID);
                    if (existing == null || existing.IsDeleted)
                    {
                        return new DbOperationResult { StatusCode = 404, Message = "Semester not found." };
                    }
                    existing.SemesterName = entity.SemesterName;
                    existing.IsActive = entity.IsActive;
                    existing.UpdatedBy = performedBy;
                    existing.UpdatedDate = DateTime.UtcNow;
                    _context.Semesters.Update(existing);
                }
                await _context.SaveChangesAsync();
                return new DbOperationResult { StatusCode = 200, Message = "Success" };
            }
            catch (Exception ex)
            {
                return new DbOperationResult { StatusCode = 500, Message = ex.Message };
            }
        }

        public async Task<DbOperationResult> DeleteSemesterAsync(int id, int performedBy, string ipAddress)
        {
            try
            {
                var existing = await _context.Semesters.FindAsync(id);
                if (existing == null || existing.IsDeleted)
                {
                    return new DbOperationResult { StatusCode = 404, Message = "Semester not found." };
                }
                existing.IsDeleted = true;
                existing.UpdatedBy = performedBy;
                existing.UpdatedDate = DateTime.UtcNow;
                _context.Semesters.Update(existing);
                await _context.SaveChangesAsync();
                return new DbOperationResult { StatusCode = 200, Message = "Success" };
            }
            catch (Exception ex)
            {
                return new DbOperationResult { StatusCode = 500, Message = ex.Message };
            }
        }
    }
}
