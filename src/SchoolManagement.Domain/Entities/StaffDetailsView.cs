namespace SchoolManagement.Domain.Entities
{
    public class StaffDetailsView
    {
        public int StaffID { get; set; }
        public string StaffFirstName { get; set; } = string.Empty;
        public string? StaffMiddleName { get; set; }
        public string StaffLastName { get; set; } = string.Empty;
        public string StaffFullName { get; set; } = string.Empty;
        public int StaffTypeID { get; set; }
        public string StaffTypeName { get; set; } = string.Empty;
        public string Mobileno { get; set; } = string.Empty;
        public string EmergencyContact { get; set; } = string.Empty;
        public string AddressLine1 { get; set; } = string.Empty;
        public string? AddressLine2 { get; set; }
        public string Address { get; set; } = string.Empty;
        public string? AadhaarNo { get; set; }
        public string? BankName { get; set; }
        public string? IFSCCode { get; set; }
        public string? AccountNo { get; set; }
        public string? PanNo { get; set; }
        public string? StaffPic { get; set; } // stores base64 string
        public System.DateTime DOB { get; set; }
        public bool IsActive { get; set; }
    }
}
