using System;
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

namespace SchoolManagement.Web.Controllers
{
    [Authorize]
    public class PaymentsController : Controller
    {
        private readonly IPaymentService _paymentService;
        private readonly IStudentService _studentService;
        private readonly IFinancialYearService _financialYearService;
        private readonly IClassService _classService;
        private readonly IFeeService _feeService;

        public PaymentsController(
            IPaymentService paymentService,
            IStudentService studentService,
            IFinancialYearService financialYearService,
            IClassService classService,
            IFeeService feeService)
        {
            _paymentService = paymentService;
            _studentService = studentService;
            _financialYearService = financialYearService;
            _classService = classService;
            _feeService = feeService;
        }

        // GET: /Payments — Shows all payment receipts across all students
        public async Task<IActionResult> Index()
        {
            var allPayments = await _paymentService.GetAllAsync();
            return View(allPayments);
        }

        // GET: /Payments/StudentLedger/5 — Shows payments for a specific student
        public async Task<IActionResult> StudentLedger(int? studentId)
        {
            if (!studentId.HasValue || studentId.Value == 0)
            {
                TempData["Message"] = "Please select a student from the directory to view their payments.";
                return RedirectToAction("Index", "Students");
            }

            var studentList = await _studentService.GetByIdAsync(studentId.Value);
            var student = studentList.FirstOrDefault();
            if (student == null)
            {
                return NotFound();
            }

            ViewBag.Student = student;
            var allFY = await _financialYearService.GetAllAsync();
            var activeFY = allFY.FirstOrDefault(f => f.IsCurrent);
            ViewBag.ActiveFYId = activeFY?.FinancialYearId;

            var history = await _paymentService.GetByStudentAsync(studentId.Value, activeFY?.FinancialYearId);
            return View(history);
        }

        // GET: /Payments/Collect?studentId=5
        // GET: /Payments/Collect?studentId=5
        public async Task<IActionResult> Collect(int? studentId)
        {
            var allFY = await _financialYearService.GetAllAsync();
            var activeFY = allFY.FirstOrDefault(f => f.IsCurrent);

            if (activeFY == null)
            {
                TempData["ErrorMessage"] = "No active Financial Year set. Please configure one first.";
                return RedirectToAction(nameof(Index));
            }

            // Get all active students for dropdown selection
            var students = await _studentService.GetAllAsync();
            var activeStudents = students.Where(s => s.IsStudentActive).OrderBy(s => s.FullName).ToList();
            
            ViewBag.Students = new SelectList(activeStudents.Select(s => new {
                StudentId = s.StudentId,
                DisplayText = $"{s.FullName} ({s.GrNo}) - Class: {s.ClassName} ({s.DivisionName}) - Roll: {s.RollNo}"
            }), "StudentId", "DisplayText", studentId);

            ViewBag.ActiveFY = activeFY;

            var model = new PaymentDetail
            {
                StudentID = studentId ?? 0,
                FinancialYearID = activeFY.FinancialYearId,
                TotalInstallment = 1
            };

            if (studentId.HasValue && studentId.Value > 0)
            {
                var student = activeStudents.FirstOrDefault(s => s.StudentId == studentId.Value);
                if (student != null)
                {
                    ViewBag.Student = student;
                    var feeStructures = await _paymentService.GetAvailableFeesForClassAsync(student.ClassId ?? 0, activeFY.FinancialYearId);
                    ViewBag.FeeStructures = new SelectList(feeStructures, "FeeID", "SemesterName", null);
                }
            }

            return View(model);
        }

        // GET: /Payments/GetStudentFeeStatusJson?studentId=5
        [HttpGet]
        public async Task<JsonResult> GetStudentFeeStatusJson(int studentId)
        {
            var studentList = await _studentService.GetByIdAsync(studentId);
            var student = studentList.FirstOrDefault();
            if (student == null)
            {
                return Json(new { success = false, message = "Student not found." });
            }

            var allFY = await _financialYearService.GetAllAsync();
            var activeFY = allFY.FirstOrDefault(f => f.IsCurrent);
            if (activeFY == null)
            {
                return Json(new { success = false, message = "No active Financial Year configured." });
            }

            // Load fee structures for student's class and active FY
            var feeStructures = await _paymentService.GetAvailableFeesForClassAsync(student.ClassId ?? 0, activeFY.FinancialYearId);

            // Load payments made by this student for this class in this FY
            var studentPayments = await _paymentService.GetByStudentAsync(studentId, activeFY.FinancialYearId);

            var result = feeStructures.Select(f => {
                // Calculate how much has been paid for this semester fee
                var totalPaid = studentPayments
                    .Where(p => p.FeeID == f.FeeID && p.SemesterID == f.SemesterID)
                    .Sum(p => p.FeePaid);

                var remainingBalance = f.FeeAmount - totalPaid;

                return new {
                    feeDetailId = f.FeeDetailID,
                    feeId = f.FeeID,
                    feeAmount = f.FeeAmount,
                    semesterId = f.SemesterID,
                    semesterName = f.SemesterName,
                    totalPaid = totalPaid,
                    remainingBalance = remainingBalance
                };
            }).ToList();

            return Json(new {
                success = true,
                student = new {
                    studentId = student.StudentId,
                    fullName = student.FullName,
                    grNo = student.GrNo,
                    className = student.ClassName,
                    divisionName = student.DivisionName,
                    rollNo = student.RollNo,
                    classId = student.ClassId,
                    financialYearId = activeFY.FinancialYearId
                },
                fees = result
            });
        }

        // POST: /Payments/Collect
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Collect(PaymentDetail model, IFormFile? transactionPhotoFile)
        {
            if (transactionPhotoFile == null || transactionPhotoFile.Length == 0)
            {
                TempData["ErrorMessage"] = "Receipt or Screenshot photo upload is required for all modes of payment.";
                return RedirectToAction(nameof(Collect), new { studentId = model.StudentID });
            }

            using (var ms = new MemoryStream())
            {
                await transactionPhotoFile.CopyToAsync(ms);
                model.Transactionphoto = Convert.ToBase64String(ms.ToArray());
            }

            // Server-side balance calculation & IsFullyPaid check
            var studentList = await _studentService.GetByIdAsync(model.StudentID);
            var student = studentList.FirstOrDefault();
            if (student != null)
            {
                var feeStructures = await _paymentService.GetAvailableFeesForClassAsync(student.ClassId ?? 0, model.FinancialYearID);
                var targetedFee = feeStructures.FirstOrDefault(f => f.FeeID == model.FeeID && f.SemesterID == model.SemesterID);
                if (targetedFee != null)
                {
                    var studentPayments = await _paymentService.GetByStudentAsync(model.StudentID, model.FinancialYearID);
                    var totalPaidBefore = studentPayments
                        .Where(p => p.FeeID == model.FeeID && p.SemesterID == model.SemesterID && p.PaymentDetailID != model.PaymentDetailID)
                        .Sum(p => p.FeePaid);

                    var totalPaidWithCurrent = totalPaidBefore + model.FeePaid;
                    model.IsFullyPaid = totalPaidWithCurrent >= targetedFee.FeeAmount;
                }
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _paymentService.SavePaymentAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Payment collected successfully.";
                return RedirectToAction(nameof(StudentLedger), new { studentId = model.StudentID });
            }

            TempData["ErrorMessage"] = result.Message;
            return RedirectToAction(nameof(Collect), new { studentId = model.StudentID });
        }

        [HttpGet]
        public async Task<IActionResult> Details(int id)
        {
            var item = await _paymentService.GetPaymentByIdAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return View(item);
        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var viewItem = await _paymentService.GetPaymentByIdAsync(id);
            if (viewItem == null)
            {
                return NotFound();
            }

            var model = new PaymentDetail
            {
                PaymentDetailID = viewItem.PaymentDetailID,
                StudentID = viewItem.StudentID,
                FinancialYearID = viewItem.FinancialYearID,
                FeeID = viewItem.FeeID,
                PaymentMode = viewItem.PaymentMode,
                TransactionRef = viewItem.TransactionRef,
                Transactionphoto = viewItem.Transactionphoto,
                IsFullyPaid = viewItem.IsFullyPaid,
                SemesterID = viewItem.SemesterID,
                FeePaid = viewItem.FeePaid,
                TotalInstallment = viewItem.TotalInstallment,
                Remarks = viewItem.Remarks
            };

            var studentList = await _studentService.GetByIdAsync(model.StudentID);
            ViewBag.Student = studentList.FirstOrDefault();
            
            var feeStructures = await _paymentService.GetAvailableFeesForClassAsync(ViewBag.Student?.ClassId ?? 0, model.FinancialYearID);
            ViewBag.FeeStructures = new SelectList(feeStructures, "FeeID", "SemesterName", model.FeeID);

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, PaymentDetail model, IFormFile? transactionPhotoFile)
        {
            if (id != model.PaymentDetailID)
            {
                return BadRequest();
            }

            if (transactionPhotoFile != null && transactionPhotoFile.Length > 0)
            {
                using (var ms = new MemoryStream())
                {
                    await transactionPhotoFile.CopyToAsync(ms);
                    model.Transactionphoto = Convert.ToBase64String(ms.ToArray());
                }
            }
            else
            {
                var existing = await _paymentService.GetPaymentByIdAsync(id);
                if (existing != null)
                {
                    model.Transactionphoto = existing.Transactionphoto;
                }
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _paymentService.SavePaymentAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Payment record updated successfully.";
                return RedirectToAction(nameof(StudentLedger), new { studentId = model.StudentID });
            }

            TempData["ErrorMessage"] = result.Message;
            return RedirectToAction(nameof(Edit), new { id = model.PaymentDetailID });
        }

        // POST: /Payments/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id, int? returnStudentId)
        {
            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _paymentService.DeletePaymentAsync(id, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Payment record deleted successfully.";
            }
            else
            {
                TempData["ErrorMessage"] = result.Message;
            }

            if (returnStudentId.HasValue && returnStudentId.Value > 0)
            {
                return RedirectToAction(nameof(StudentLedger), new { studentId = returnStudentId.Value });
            }
            return RedirectToAction(nameof(Index));
        }

        // GET: /Payments/GetClassFeesJson?classId=1&fyId=1
        [HttpGet]
        public async Task<JsonResult> GetClassFeesJson(int classId, int fyId)
        {
            var list = await _paymentService.GetAvailableFeesForClassAsync(classId, fyId);
            return Json(list);
        }

        // GET: /Payments/PendingReport
        public async Task<IActionResult> PendingReport(int? classId = null, int? semesterId = null)
        {
            var allFY = await _financialYearService.GetAllAsync();
            var activeFY = allFY.FirstOrDefault(f => f.IsCurrent);
            if (activeFY == null)
            {
                TempData["ErrorMessage"] = "No active Financial Year set. Please configure one first.";
                return RedirectToAction(nameof(Index));
            }

            // Get filtered reports
            var pendingReportList = await _paymentService.GetPendingFeesReportAsync(classId, semesterId, activeFY.FinancialYearId);

            // Populate Filter Select Lists
            var classes = await _classService.GetAllAsync();
            var semesters = await _feeService.GetSemestersAsync();

            ViewBag.Classes = new SelectList(classes.OrderBy(c => c.ClassName), "ClassId", "ClassName", classId);
            ViewBag.Semesters = new SelectList(semesters.OrderBy(s => s.SemesterName), "SemesterID", "SemesterName", semesterId);
            ViewBag.ActiveFYName = activeFY.FinancialYearName;
            ViewBag.SelectedClassId = classId;
            ViewBag.SelectedSemesterId = semesterId;

            return View(pendingReportList);
        }

        private bool TryGetCurrentUserId(out int userId)
        {
            userId = 0;
            var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(value, out userId);
        }
    }
}
