using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly IPaymentRepository _repository;

        public PaymentService(IPaymentRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<StudentPaymentsView>> GetAllAsync()
        {
            return await _repository.GetAllAsync();
        }

        public async Task<StudentPaymentsView?> GetPaymentByIdAsync(int paymentDetailId)
        {
            return await _repository.GetPaymentByIdAsync(paymentDetailId);
        }

        public async Task<IEnumerable<StudentPaymentsView>> GetByStudentAsync(int studentId, int? financialYearId = null)
        {
            return await _repository.GetByStudentAsync(studentId, financialYearId);
        }

        public async Task<DbOperationResult> SavePaymentAsync(PaymentDetail entity, int performedBy, string ipAddress)
        {
            return await _repository.SavePaymentAsync(entity, performedBy, ipAddress);
        }

        public async Task<DbOperationResult> DeletePaymentAsync(int paymentDetailId, int performedBy, string ipAddress)
        {
            return await _repository.DeletePaymentAsync(paymentDetailId, performedBy, ipAddress);
        }

        public async Task<IEnumerable<FeeDetailsView>> GetAvailableFeesForClassAsync(int classId, int financialYearId)
        {
            return await _repository.GetAvailableFeesForClassAsync(classId, financialYearId);
        }

        public async Task<IEnumerable<PendingFeeReportView>> GetPendingFeesReportAsync(int? classId, int? semesterId, int financialYearId)
        {
            return await _repository.GetPendingFeesReportAsync(classId, semesterId, financialYearId);
        }
    }
}
