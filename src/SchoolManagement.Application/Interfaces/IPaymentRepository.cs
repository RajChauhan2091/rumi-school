using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IPaymentRepository
    {
        Task<IEnumerable<StudentPaymentsView>> GetAllAsync();
        Task<StudentPaymentsView?> GetPaymentByIdAsync(int paymentDetailId);
        Task<IEnumerable<StudentPaymentsView>> GetByStudentAsync(int studentId, int? financialYearId = null);
        Task<DbOperationResult> SavePaymentAsync(PaymentDetail entity, int performedBy, string ipAddress);
        Task<DbOperationResult> DeletePaymentAsync(int paymentDetailId, int performedBy, string ipAddress);
        Task<IEnumerable<FeeDetailsView>> GetAvailableFeesForClassAsync(int classId, int financialYearId);
        Task<IEnumerable<PendingFeeReportView>> GetPendingFeesReportAsync(int? classId, int? semesterId, int financialYearId);
    }
}
