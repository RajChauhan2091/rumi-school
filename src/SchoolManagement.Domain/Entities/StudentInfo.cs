using System;
using SchoolManagement.Domain.Common;

namespace SchoolManagement.Domain.Entities
{
    public class StudentInfo : BaseEntity
    {
        public int StudentId { get; set; }
        
        // Basic Information
        public string? GrNo { get; set; }
        public DateTime AdmissionDate { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string? MiddleName { get; set; }
        public string LastName { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        public string Gender { get; set; } = string.Empty;
        public byte[]? StudentPhoto { get; set; }

        // Personal Information
        public string? PlaceOfBirth { get; set; }
        public string? Nationality { get; set; }
        public string? BloodGroup { get; set; }
        public string? Category { get; set; }
        public string? Religion { get; set; }
        public string? AadhaarNumber { get; set; }

        // Address Information
        public string? AddressLine1 { get; set; }
        public string? AddressLine2 { get; set; }
        public string? City { get; set; }
        public string? State { get; set; }
        public string? Country { get; set; }
        public string? PinCode { get; set; }

        // Parent Information
        public string? FatherName { get; set; }
        public string? FatherOccupation { get; set; }
        public string? FatherMobileNumber { get; set; }
        public string? MotherName { get; set; }
        public string? MotherOccupation { get; set; }
        public string? MotherMobileNumber { get; set; }

        // Guardian Information
        public string? GuardianName { get; set; }
        public string? GuardianMobileNumber { get; set; }
        public string? Guardian2Name { get; set; }
        public string? Guardian2MobileNumber { get; set; }
        public string? EmergencyContactNumber { get; set; }

        // Academic Information
        public string? PreviousSchoolName { get; set; }
        public int AdmissionFinancialYearId { get; set; }

        // Communication Information
        public string? EmailAddress { get; set; }

        // Navigation
        public virtual FinancialYear? AdmissionFinancialYear { get; set; }
    }
}
