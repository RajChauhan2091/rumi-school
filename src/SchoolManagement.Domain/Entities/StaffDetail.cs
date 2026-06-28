using System;
using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class StaffDetail : BaseEntity
    {
        public int StaffID { get; set; }
        public string StaffFirstName { get; set; } = string.Empty;
        public string? StaffMiddleName { get; set; }
        public string StaffLastName { get; set; } = string.Empty;
        public int StaffType { get; set; }
        public string Mobileno { get; set; } = string.Empty;
        public string EmergencyContact { get; set; } = string.Empty;
        public string AddressLine1 { get; set; } = string.Empty;
        public string? AddressLine2 { get; set; }
        public string? AadhaarNo { get; set; }
        public string? BankName { get; set; }
        public string? IFSCCode { get; set; }
        public string? AccountNo { get; set; }
        public string? PanNo { get; set; }
        public string? StaffPic { get; set; } // stores base64 string
        public DateTime DOB { get; set; }

        public virtual StaffTypeMaster? StaffTypeMaster { get; set; }
    }
}
