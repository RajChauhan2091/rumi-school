using System;

namespace SchoolManagement.Domain.Entities
{
    public class StudentDetailsView
    {
        public int StudentId { get; set; }
        public string? GrNo { get; set; }
        public DateTime AdmissionDate { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string? MiddleName { get; set; }
        public string LastName { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        public string Gender { get; set; } = string.Empty;
        public byte[]? StudentPhoto { get; set; }
        public string? PlaceOfBirth { get; set; }
        public string? Nationality { get; set; }
        public string? BloodGroup { get; set; }
        public string? Category { get; set; }
        public string? Religion { get; set; }
        public string? AadhaarNumber { get; set; }
        public string AddressLine1 { get; set; } = string.Empty;
        public string? AddressLine2 { get; set; }
        public string City { get; set; } = string.Empty;
        public string? State { get; set; }
        public string? Country { get; set; }
        public string PinCode { get; set; } = string.Empty;
        public string FatherName { get; set; } = string.Empty;
        public string? FatherOccupation { get; set; }
        public string FatherMobileNumber { get; set; } = string.Empty;
        public string MotherName { get; set; } = string.Empty;
        public string? MotherOccupation { get; set; }
        public string? MotherMobileNumber { get; set; }
        public string? GuardianName { get; set; }
        public string? GuardianMobileNumber { get; set; }
        public string? Guardian2Name { get; set; }
        public string? Guardian2MobileNumber { get; set; }
        public string EmergencyContactNumber { get; set; } = string.Empty;
        public string? PreviousSchoolName { get; set; }
        public int AdmissionFinancialYearId { get; set; }
        public string AdmissionFinancialYear { get; set; } = string.Empty;
        public string? EmailAddress { get; set; }
        public bool IsStudentActive { get; set; }
        
        // Mapping info (from vw_StudentDetails LEFT JOIN)
        public int? StudentMappingId { get; set; }
        public int? RollNo { get; set; }
        public int? ClassScheduleId { get; set; }
        public int? ClassId { get; set; }
        public string? ClassName { get; set; }
        public int? DivisionId { get; set; }
        public string? DivisionName { get; set; }
        public int? MappingFinancialYearId { get; set; }
        public string? MappingFinancialYear { get; set; }
        public bool? IsCurrentMappingYear { get; set; }
    }
}
