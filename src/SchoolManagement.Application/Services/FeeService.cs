using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Services
{
    public class FeeService : IFeeService
    {
        private readonly IFeeRepository _repository;

        public FeeService(IFeeRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<FeeMaster>> GetFeeMasterAllAsync()
        {
            return await _repository.GetFeeMasterAllAsync();
        }

        public async Task<FeeMaster?> GetFeeMasterByIdAsync(int id)
        {
            return await _repository.GetFeeMasterByIdAsync(id);
        }

        public async Task<DbOperationResult> SaveFeeMasterAsync(FeeMaster entity, int performedBy, string ipAddress)
        {
            return await _repository.SaveFeeMasterAsync(entity, performedBy, ipAddress);
        }

        public async Task<IEnumerable<FeeDetailsView>> GetFeeDetailAllAsync(int? financialYearId = null)
        {
            return await _repository.GetFeeDetailAllAsync(financialYearId);
        }

        public async Task<FeeDetailsView?> GetFeeDetailByIdAsync(int id)
        {
            return await _repository.GetFeeDetailByIdAsync(id);
        }

        public async Task<DbOperationResult> SaveFeeDetailAsync(FeeDetail entity, int performedBy, string ipAddress)
        {
            return await _repository.SaveFeeDetailAsync(entity, performedBy, ipAddress);
        }

        public async Task<DbOperationResult> DeleteFeeDetailAsync(int id, int performedBy, string ipAddress)
        {
            return await _repository.DeleteFeeDetailAsync(id, performedBy, ipAddress);
        }

        public async Task<IEnumerable<SemesterMaster>> GetSemestersAsync()
        {
            return await _repository.GetSemestersAsync();
        }

        public async Task<IEnumerable<SemesterMaster>> GetSemestersAllAsync()
        {
            return await _repository.GetSemestersAllAsync();
        }

        public async Task<SemesterMaster?> GetSemesterByIdAsync(int id)
        {
            return await _repository.GetSemesterByIdAsync(id);
        }

        public async Task<DbOperationResult> SaveSemesterAsync(SemesterMaster entity, int performedBy, string ipAddress)
        {
            return await _repository.SaveSemesterAsync(entity, performedBy, ipAddress);
        }

        public async Task<DbOperationResult> DeleteSemesterAsync(int id, int performedBy, string ipAddress)
        {
            return await _repository.DeleteSemesterAsync(id, performedBy, ipAddress);
        }
    }
}
