using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;

namespace SchoolManagement.Web.Controllers
{
    [Authorize(Roles = "Administrator")]
    public class ClassSchedulesController : Controller
    {
        private readonly IClassScheduleService _service;
        private readonly IClassService _classService;
        private readonly IDivisionService _divisionService;
        private readonly IFinancialYearService _financialYearService;

        public ClassSchedulesController(
            IClassScheduleService service,
            IClassService classService,
            IDivisionService divisionService,
            IFinancialYearService financialYearService)
        {
            _service = service;
            _classService = classService;
            _divisionService = divisionService;
            _financialYearService = financialYearService;
        }

        public async Task<IActionResult> Index()
        {
            var list = await _service.GetAllAsync();
            return View(list);
        }

        public async Task<IActionResult> Details(int id)
        {
            var item = await _service.GetByIdAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return View(item);
        }

        public async Task<IActionResult> Create()
        {
            await PopulateDropdownsAsync();
            return View(new ClassSchedule { MaxCapacity = 40 });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(ClassSchedule model)
        {
            if (!ModelState.IsValid)
            {
                await PopulateDropdownsAsync(model);
                return View(model);
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _service.SaveAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Class Schedule created successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateDropdownsAsync(model);
            return View(model);
        }

        public async Task<IActionResult> Edit(int id)
        {
            var viewItem = await _service.GetByIdAsync(id);
            if (viewItem == null)
            {
                return NotFound();
            }

            // Map view back to entity model for editing
            var model = new ClassSchedule
            {
                ClassScheduleId = viewItem.ClassScheduleId,
                ClassId = viewItem.ClassId,
                DivisionId = viewItem.DivisionId,
                FinancialYearId = viewItem.FinancialYearId,
                MaxCapacity = viewItem.MaxCapacity
            };

            await PopulateDropdownsAsync(model);
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, ClassSchedule model)
        {
            if (id != model.ClassScheduleId)
            {
                return BadRequest();
            }

            if (!ModelState.IsValid)
            {
                await PopulateDropdownsAsync(model);
                return View(model);
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _service.SaveAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Class Schedule updated successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateDropdownsAsync(model);
            return View(model);
        }

        [HttpGet]
        public async Task<IActionResult> Delete(int id)
        {
            var item = await _service.GetByIdAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return View(item);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _service.DeleteAsync(id, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Class Schedule deleted successfully.";
                return RedirectToAction(nameof(Index));
            }

            TempData["ErrorMessage"] = result.Message;
            return RedirectToAction(nameof(Index));
        }

        private async Task PopulateDropdownsAsync(ClassSchedule? model = null)
        {
            var classes = await _classService.GetAllAsync();
            var divisions = await _divisionService.GetAllAsync();
            var financialYears = await _financialYearService.GetAllAsync();

            ViewBag.Classes = new SelectList(classes, "ClassId", "ClassName", model?.ClassId);
            ViewBag.Divisions = new SelectList(divisions, "DivisionId", "DivisionName", model?.DivisionId);
            ViewBag.FinancialYears = new SelectList(financialYears, "FinancialYearId", "FinancialYearName", model?.FinancialYearId);
        }

        private bool TryGetCurrentUserId(out int userId)
        {
            userId = 0;
            var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(value, out userId);
        }
    }
}
