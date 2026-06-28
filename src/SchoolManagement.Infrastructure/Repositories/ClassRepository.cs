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
    public class ClassRepository : IClassRepository
    {
        private readonly SchoolDbContext _context;

        public ClassRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<ClassMaster>> GetAllAsync()
        {
            return await _context.Classes
                .FromSqlRaw("EXEC usp_Class_GetAll")
                .ToListAsync();
        }

        public async Task<ClassMaster> GetByIdAsync(int id)
        {
            var result = await _context.Classes
                .FromSqlRaw("EXEC usp_Class_GetById @ClassId", new SqlParameter("@ClassId", id))
                .ToListAsync();

            return result.FirstOrDefault();
        }

        public async Task<DbOperationResult> SaveAsync(ClassMaster entity, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_Class_Save @ClassId, @ClassName, @IsActive, @PerformedBy, @IPAddress",
                    new SqlParameter("@ClassId", entity.ClassId),
                    new SqlParameter("@ClassName", entity.ClassName ?? (object)DBNull.Value),
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
                    "EXEC usp_Class_Delete @ClassId, @PerformedBy, @IPAddress",
                    new SqlParameter("@ClassId", id),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }
    }
}
