using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class PaymentDetail : BaseEntity
    {
        public int PaymentDetailID { get; set; }
        public int StudentID { get; set; }
        public int FinancialYearID { get; set; }
        public int FeeID { get; set; }
        public string PaymentMode { get; set; } = string.Empty;
        public string? TransactionRef { get; set; }
        public string? Transactionphoto { get; set; } // stores base64 string
        public bool IsFullyPaid { get; set; }
        public int SemesterID { get; set; }
        public decimal FeePaid { get; set; }
        public int TotalInstallment { get; set; }
        public string? Remarks { get; set; }

        public virtual StudentInfo? StudentInfo { get; set; }
        public virtual FinancialYear? FinancialYear { get; set; }
        public virtual FeeMaster? FeeMaster { get; set; }
        public virtual SemesterMaster? SemesterMaster { get; set; }
    }
}
