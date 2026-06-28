using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;

namespace SchoolManagement.Application.Interfaces
{
    public interface IFeeRepository
    {
        // FeeMaster Configs
        Task<IEnumerable<FeeMaster>> GetFeeMasterAllAsync();
        Task<FeeMaster?> GetFeeMasterByIdAsync(int id);
        Task<DbOperationResult> SaveFeeMasterAsync(FeeMaster entity, int performedBy, string ipAddress);

        // FeeDetail Mappings
        Task<IEnumerable<FeeDetailsView>> GetFeeDetailAllAsync(int? financialYearId = null);
        Task<FeeDetailsView?> GetFeeDetailByIdAsync(int id);
        Task<DbOperationResult> SaveFeeDetailAsync(FeeDetail entity, int performedBy, string ipAddress);
        Task<DbOperationResult> DeleteFeeDetailAsync(int id, int performedBy, string ipAddress);

        // Semesters
        Task<IEnumerable<SemesterMaster>> GetSemestersAsync();
        Task<IEnumerable<SemesterMaster>> GetSemestersAllAsync();
        Task<SemesterMaster?> GetSemesterByIdAsync(int id);
        Task<DbOperationResult> SaveSemesterAsync(SemesterMaster entity, int performedBy, string ipAddress);
        Task<DbOperationResult> DeleteSemesterAsync(int id, int performedBy, string ipAddress);
    }
}
