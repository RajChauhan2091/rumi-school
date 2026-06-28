namespace SchoolManagement.Domain.Entities
{
    public class StudentPaymentsView
    {
        public int PaymentDetailID { get; set; }
        public int StudentID { get; set; }
        public string StudentFullName { get; set; } = string.Empty;
        public string GrNo { get; set; } = string.Empty;
        public int FinancialYearID { get; set; }
        public string FinancialYear { get; set; } = string.Empty;
        public int FeeID { get; set; }
        public decimal TotalFeeAmount { get; set; }
        public int SemesterID { get; set; }
        public string SemesterName { get; set; } = string.Empty;
        public string PaymentMode { get; set; } = string.Empty;
        public string? TransactionRef { get; set; }
        public string? Transactionphoto { get; set; } // stores base64 string
        public bool IsFullyPaid { get; set; }
        public decimal FeePaid { get; set; }
        public int TotalInstallment { get; set; }
        public string? Remarks { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public decimal FeeRemaining { get; set; }
    }
}
