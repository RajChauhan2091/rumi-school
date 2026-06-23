using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;
using SchoolManagement.Domain.Models;
using SchoolManagement.Web.Models;

namespace SchoolManagement.Web.Controllers
{
    [Authorize]
    public class StudentsController : Controller
    {
        private const long MaxPhotoBytes = 2 * 1024 * 1024;
        private static readonly HashSet<string> AllowedPhotoContentTypes = new(StringComparer.OrdinalIgnoreCase)
        {
            "image/jpeg",
            "image/png",
            "image/webp"
        };

        private readonly IStudentService _studentService;
        private readonly IClassScheduleService _classScheduleService;
        private readonly IFinancialYearService _financialYearService;

        public StudentsController(
            IStudentService studentService,
            IClassScheduleService classScheduleService,
            IFinancialYearService financialYearService)
        {
            _studentService = studentService;
            _classScheduleService = classScheduleService;
            _financialYearService = financialYearService;
        }

        public async Task<IActionResult> Index(string? searchText, int? classScheduleId, int? financialYearId, string? gender)
        {
            var students = await _studentService.SearchAsync(searchText, classScheduleId, financialYearId, gender);

            var schedules = await _classScheduleService.GetAllAsync();
            var financialYears = await _financialYearService.GetAllAsync();

            ViewBag.ClassSchedules = new SelectList(schedules, "ClassScheduleId", "ClassName", classScheduleId);
            ViewBag.FinancialYears = new SelectList(financialYears, "FinancialYearId", "FinancialYearName", financialYearId);
            ViewBag.Genders = new SelectList(new[] { "Male", "Female", "Other" }, gender);

            ViewBag.SearchText = searchText;
            ViewBag.SelectedScheduleId = classScheduleId;
            ViewBag.SelectedFinancialYearId = financialYearId;
            ViewBag.SelectedGender = gender;

            return View(students);
        }

        public async Task<IActionResult> Details(int id)
        {
            var list = await _studentService.GetByIdAsync(id);
            if (!list.Any())
            {
                return NotFound();
            }

            // The list contains one row per mapping. The basic student info is identical across rows.
            var student = list.First();
            ViewBag.History = list.Where(x => x.StudentMappingId.HasValue).ToList();

            return View(student);
        }

        [Authorize(Roles = "Administrator,Clerk")]
        public async Task<IActionResult> Create()
        {
            await PopulateDropdownsAsync();
            var model = new StudentInfo
            {
                AdmissionDate = DateTime.Today,
                DateOfBirth = DateTime.Today.AddYears(-5)
            };
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Administrator,Clerk")]
        public async Task<IActionResult> Create(StudentInfo model, int? classScheduleId, int? rollNo, IFormFile? studentPhoto)
        {
            if (!ModelState.IsValid)
            {
                await PopulateDropdownsAsync(classScheduleId);
                return View(model);
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            if (studentPhoto != null && studentPhoto.Length > 0)
            {
                var validationError = ValidatePhoto(studentPhoto);
                if (validationError != null)
                {
                    ModelState.AddModelError("studentPhoto", validationError);
                    await PopulateDropdownsAsync(classScheduleId);
                    return View(model);
                }

                model.StudentPhoto = await ReadPhotoAsync(studentPhoto);
            }

            var result = await _studentService.SaveAsync(model, classScheduleId, rollNo, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Student admitted successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateDropdownsAsync(classScheduleId);
            return View(model);
        }

        [Authorize(Roles = "Administrator,Clerk")]
        public async Task<IActionResult> Edit(int id)
        {
            var list = await _studentService.GetByIdAsync(id);
            if (!list.Any())
            {
                return NotFound();
            }

            var viewItem = list.First();
            
            // Map view back to StudentInfo entity
            var model = new StudentInfo
            {
                StudentId = viewItem.StudentId,
                GrNo = viewItem.GrNo,
                AdmissionDate = viewItem.AdmissionDate,
                FirstName = viewItem.FirstName,
                MiddleName = viewItem.MiddleName,
                LastName = viewItem.LastName,
                DateOfBirth = viewItem.DateOfBirth,
                Gender = viewItem.Gender,
                StudentPhoto = viewItem.StudentPhoto,
                PlaceOfBirth = viewItem.PlaceOfBirth,
                Nationality = viewItem.Nationality,
                BloodGroup = viewItem.BloodGroup,
                Category = viewItem.Category,
                Religion = viewItem.Religion,
                AadhaarNumber = viewItem.AadhaarNumber,
                AddressLine1 = viewItem.AddressLine1,
                AddressLine2 = viewItem.AddressLine2,
                City = viewItem.City,
                State = viewItem.State,
                Country = viewItem.Country,
                PinCode = viewItem.PinCode,
                FatherName = viewItem.FatherName,
                FatherOccupation = viewItem.FatherOccupation,
                FatherMobileNumber = viewItem.FatherMobileNumber,
                MotherName = viewItem.MotherName,
                MotherOccupation = viewItem.MotherOccupation,
                MotherMobileNumber = viewItem.MotherMobileNumber,
                GuardianName = viewItem.GuardianName,
                GuardianMobileNumber = viewItem.GuardianMobileNumber,
                EmergencyContactNumber = viewItem.EmergencyContactNumber,
                PreviousSchoolName = viewItem.PreviousSchoolName,
                AdmissionFinancialYearId = viewItem.AdmissionFinancialYearId,
                EmailAddress = viewItem.EmailAddress
            };

            await PopulateDropdownsAsync();
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Administrator,Clerk")]
        public async Task<IActionResult> Edit(int id, StudentInfo model, IFormFile? studentPhoto)
        {
            if (id != model.StudentId)
            {
                return BadRequest();
            }

            if (!ModelState.IsValid)
            {
                await PopulateDropdownsAsync();
                return View(model);
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            if (studentPhoto != null && studentPhoto.Length > 0)
            {
                var validationError = ValidatePhoto(studentPhoto);
                if (validationError != null)
                {
                    ModelState.AddModelError("studentPhoto", validationError);
                    await PopulateDropdownsAsync();
                    return View(model);
                }

                model.StudentPhoto = await ReadPhotoAsync(studentPhoto);
            }
            else
            {
                var list = await _studentService.GetByIdAsync(id);
                if (list.Any())
                {
                    model.StudentPhoto = list.First().StudentPhoto;
                }
            }

            // When editing basic student details, we pass null classScheduleId and rollNo because they are updated independently or mapped elsewhere
            var result = await _studentService.SaveAsync(model, null, null, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Student details updated successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateDropdownsAsync();
            return View(model);
        }

        [HttpGet]
        [Authorize(Roles = "Administrator")]
        public async Task<IActionResult> Allocate(int id)
        {
            var list = await _studentService.GetByIdAsync(id);
            if (!list.Any())
            {
                return NotFound();
            }

            var student = list.First();
            ViewBag.StudentName = $"{student.FirstName} {student.LastName} ({student.GrNo})";
            ViewBag.History = list.Where(x => x.StudentMappingId.HasValue).ToList();

            var schedules = await _classScheduleService.GetAllAsync();
            ViewBag.ClassSchedules = new SelectList(schedules, "ClassScheduleId", "ClassName");

            return View(new StudentAllocationModel { StudentId = id });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Administrator")]
        public async Task<IActionResult> Allocate(StudentAllocationModel model)
        {
            var list = await _studentService.GetByIdAsync(model.StudentId);
            if (!list.Any())
            {
                return NotFound();
            }

            var viewItem = list.First();
            ViewBag.StudentName = $"{viewItem.FirstName} {viewItem.LastName} ({viewItem.GrNo})";
            ViewBag.History = list.Where(x => x.StudentMappingId.HasValue).ToList();

            if (!ModelState.IsValid)
            {
                var schedules = await _classScheduleService.GetAllAsync();
                ViewBag.ClassSchedules = new SelectList(schedules, "ClassScheduleId", "ClassName", model.ClassScheduleId);
                return View(model);
            }

            // Reconstruct StudentInfo for SaveAsync
            var studentInfo = new StudentInfo
            {
                StudentId = viewItem.StudentId,
                GrNo = viewItem.GrNo,
                AdmissionDate = viewItem.AdmissionDate,
                FirstName = viewItem.FirstName,
                MiddleName = viewItem.MiddleName,
                LastName = viewItem.LastName,
                DateOfBirth = viewItem.DateOfBirth,
                Gender = viewItem.Gender,
                StudentPhoto = viewItem.StudentPhoto,
                PlaceOfBirth = viewItem.PlaceOfBirth,
                Nationality = viewItem.Nationality,
                BloodGroup = viewItem.BloodGroup,
                Category = viewItem.Category,
                Religion = viewItem.Religion,
                AadhaarNumber = viewItem.AadhaarNumber,
                AddressLine1 = viewItem.AddressLine1,
                AddressLine2 = viewItem.AddressLine2,
                City = viewItem.City,
                State = viewItem.State,
                Country = viewItem.Country,
                PinCode = viewItem.PinCode,
                FatherName = viewItem.FatherName,
                FatherOccupation = viewItem.FatherOccupation,
                FatherMobileNumber = viewItem.FatherMobileNumber,
                MotherName = viewItem.MotherName,
                MotherOccupation = viewItem.MotherOccupation,
                MotherMobileNumber = viewItem.MotherMobileNumber,
                GuardianName = viewItem.GuardianName,
                GuardianMobileNumber = viewItem.GuardianMobileNumber,
                EmergencyContactNumber = viewItem.EmergencyContactNumber,
                PreviousSchoolName = viewItem.PreviousSchoolName,
                AdmissionFinancialYearId = viewItem.AdmissionFinancialYearId,
                EmailAddress = viewItem.EmailAddress
            };

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _studentService.SaveAsync(studentInfo, model.ClassScheduleId, model.RollNo, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Student allocated successfully.";
                return RedirectToAction(nameof(Details), new { id = model.StudentId });
            }

            ModelState.AddModelError(string.Empty, result.Message);
            var schedulesList = await _classScheduleService.GetAllAsync();
            ViewBag.ClassSchedules = new SelectList(schedulesList, "ClassScheduleId", "ClassName", model.ClassScheduleId);
            return View(model);
        }

        [HttpGet]
        [Authorize(Roles = "Administrator")]
        public async Task<IActionResult> Delete(int id)
        {
            var list = await _studentService.GetByIdAsync(id);
            if (!list.Any())
            {
                return NotFound();
            }
            return View(list.First());
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = "Administrator")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _studentService.DeleteAsync(id, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Student deleted successfully.";
                return RedirectToAction(nameof(Index));
            }

            TempData["ErrorMessage"] = result.Message;
            return RedirectToAction(nameof(Index));
        }

        private async Task PopulateDropdownsAsync(int? selectedScheduleId = null)
        {
            var schedules = await _classScheduleService.GetAllAsync();
            var financialYears = await _financialYearService.GetAllAsync();

            ViewBag.ClassSchedules = new SelectList(schedules, "ClassScheduleId", "ClassName", selectedScheduleId);
            ViewBag.FinancialYears = new SelectList(financialYears, "FinancialYearId", "FinancialYearName");
            ViewBag.Genders = new SelectList(new[] { "Male", "Female", "Other" });
            ViewBag.BloodGroups = new SelectList(new[] { "A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-" });
            ViewBag.Categories = new SelectList(new[] { "General", "OBC", "SC", "ST", "EWS" });
        }

        private static string? ValidatePhoto(IFormFile file)
        {
            if (file.Length <= 0)
            {
                return "Student photo is empty.";
            }

            if (file.Length > MaxPhotoBytes)
            {
                return "Student photo must be 2 MB or smaller.";
            }

            if (!AllowedPhotoContentTypes.Contains(file.ContentType))
            {
                return "Only JPEG, PNG, or WebP photos are allowed.";
            }

            return null;
        }

        private static async Task<byte[]> ReadPhotoAsync(IFormFile file)
        {
            await using var memoryStream = new MemoryStream();
            await file.CopyToAsync(memoryStream);
            return memoryStream.ToArray();
        }

        private bool TryGetCurrentUserId(out int userId)
        {
            userId = 0;
            var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(value, out userId);
        }
    }
}
