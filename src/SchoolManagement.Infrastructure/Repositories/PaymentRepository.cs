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
    public class PaymentRepository : IPaymentRepository
    {
        private readonly SchoolDbContext _context;

        public PaymentRepository(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<StudentPaymentsView>> GetAllAsync()
        {
            return await _context.StudentPaymentsView
                .FromSqlRaw("EXEC usp_PaymentDetail_GetAll")
                .ToListAsync();
        }

        public async Task<IEnumerable<StudentPaymentsView>> GetByStudentAsync(int studentId, int? financialYearId = null)
        {
            return await _context.StudentPaymentsView
                .FromSqlRaw("EXEC usp_PaymentDetail_GetByStudent @StudentId, @FinancialYearId",
                    new SqlParameter("@StudentId", studentId),
                    new SqlParameter("@FinancialYearId", financialYearId ?? (object)DBNull.Value))
                .ToListAsync();
        }

        public async Task<StudentPaymentsView?> GetPaymentByIdAsync(int paymentDetailId)
        {
            var result = await _context.StudentPaymentsView
                .FromSqlRaw("SELECT * FROM vw_StudentPayments WHERE PaymentDetailID = @PaymentDetailId",
                    new SqlParameter("@PaymentDetailId", paymentDetailId))
                .ToListAsync();
            return result.FirstOrDefault();
        }

        public async Task<DbOperationResult> SavePaymentAsync(PaymentDetail entity, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_PaymentDetail_Save @PaymentDetailId, @StudentId, @FinancialYearId, @FeeId, @PaymentMode, @TransactionRef, @Transactionphoto, @IsFullyPaid, @SemesterId, @FeePaid, @TotalInstallment, @Remarks, @PerformedBy, @IPAddress",
                    new SqlParameter("@PaymentDetailId", entity.PaymentDetailID),
                    new SqlParameter("@StudentId", entity.StudentID),
                    new SqlParameter("@FinancialYearId", entity.FinancialYearID),
                    new SqlParameter("@FeeId", entity.FeeID),
                    new SqlParameter("@PaymentMode", entity.PaymentMode),
                    new SqlParameter("@TransactionRef", entity.TransactionRef ?? (object)DBNull.Value),
                    new SqlParameter("@Transactionphoto", entity.Transactionphoto ?? (object)DBNull.Value),
                    new SqlParameter("@IsFullyPaid", entity.IsFullyPaid),
                    new SqlParameter("@SemesterId", entity.SemesterID),
                    new SqlParameter("@FeePaid", entity.FeePaid),
                    new SqlParameter("@TotalInstallment", entity.TotalInstallment),
                    new SqlParameter("@Remarks", entity.Remarks ?? (object)DBNull.Value),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }

        public async Task<DbOperationResult> DeletePaymentAsync(int paymentDetailId, int performedBy, string ipAddress)
        {
            var result = await _context.DbOperationResults
                .FromSqlRaw(
                    "EXEC usp_PaymentDetail_Delete @PaymentDetailId, @PerformedBy, @IPAddress",
                    new SqlParameter("@PaymentDetailId", paymentDetailId),
                    new SqlParameter("@PerformedBy", performedBy),
                    new SqlParameter("@IPAddress", ipAddress ?? (object)DBNull.Value)
                )
                .ToListAsync();

            return result.FirstOrDefault() ?? new DbOperationResult { StatusCode = 500, Message = "Internal server error." };
        }

        public async Task<IEnumerable<FeeDetailsView>> GetAvailableFeesForClassAsync(int classId, int financialYearId)
        {
            return await _context.FeeDetailsView
                .FromSqlRaw("EXEC usp_Dropdown_GetAvailableFeesForClass @ClassId, @FinancialYearId",
                    new SqlParameter("@ClassId", classId),
                    new SqlParameter("@FinancialYearId", financialYearId))
                .ToListAsync();
        }

        public async Task<IEnumerable<PendingFeeReportView>> GetPendingFeesReportAsync(int? classId, int? semesterId, int financialYearId)
        {
            return await _context.PendingFeeReportView
                .FromSqlRaw("EXEC usp_Report_GetPendingFees @ClassId, @SemesterId, @FinancialYearId",
                    new SqlParameter("@ClassId", classId ?? (object)DBNull.Value),
                    new SqlParameter("@SemesterId", semesterId ?? (object)DBNull.Value),
                    new SqlParameter("@FinancialYearId", financialYearId))
                .ToListAsync();
        }
    }
}
