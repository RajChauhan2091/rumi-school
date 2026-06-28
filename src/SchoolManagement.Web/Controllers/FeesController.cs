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
    public class FeesController : Controller
    {
        private readonly IFeeService _feeService;
        private readonly IClassService _classService;
        private readonly IFinancialYearService _financialYearService;

        public FeesController(
            IFeeService feeService,
            IClassService classService,
            IFinancialYearService financialYearService)
        {
            _feeService = feeService;
            _classService = classService;
            _financialYearService = financialYearService;
        }

        public async Task<IActionResult> Index()
        {
            var fees = await _feeService.GetFeeMasterAllAsync();
            return View(fees);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateFeeMaster(FeeMaster model)
        {
            if (!ModelState.IsValid)
            {
                TempData["ErrorMessage"] = "Invalid fee details.";
                return RedirectToAction(nameof(Index));
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _feeService.SaveFeeMasterAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Fee amount configured successfully.";
            }
            else
            {
                TempData["ErrorMessage"] = result.Message;
            }

            return RedirectToAction(nameof(Index));
        }

        public async Task<IActionResult> Mappings()
        {
            var currentFY = await _financialYearService.GetAllAsync();
            var activeFY = currentFY.OverloadsOrActiveCurrent();
            ViewBag.ActiveFYId = activeFY?.FinancialYearId;

            var list = await _feeService.GetFeeDetailAllAsync(activeFY?.FinancialYearId);
            return View(list);
        }

        public async Task<IActionResult> CreateMapping()
        {
            await PopulateMappingDropdownsAsync();
            return View(new FeeDetail { IsActive = true });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateMapping(FeeDetail model)
        {
            if (!ModelState.IsValid)
            {
                await PopulateMappingDropdownsAsync(model);
                return View(model);
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _feeService.SaveFeeDetailAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Class Fee structured mapped successfully.";
                return RedirectToAction(nameof(Mappings));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateMappingDropdownsAsync(model);
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteMapping(int id)
        {
            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _feeService.DeleteFeeDetailAsync(id, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Fee mapping deleted successfully.";
            }
            else
            {
                TempData["ErrorMessage"] = result.Message;
            }

            return RedirectToAction(nameof(Mappings));
        }

        [HttpGet]
        public async Task<IActionResult> EditFeeMaster(int id)
        {
            var item = await _feeService.GetFeeMasterByIdAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return View(item);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditFeeMaster(int id, FeeMaster model)
        {
            if (id != model.FeeID)
            {
                return BadRequest();
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _feeService.SaveFeeMasterAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Fee configuration updated successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            return View(model);
        }

        [HttpGet]
        public async Task<IActionResult> EditMapping(int id)
        {
            var viewItem = await _feeService.GetFeeDetailByIdAsync(id);
            if (viewItem == null)
            {
                return NotFound();
            }

            var model = new FeeDetail
            {
                FeeDetailID = viewItem.FeeDetailID,
                FeeID = viewItem.FeeID,
                ClassID = viewItem.ClassID,
                FinancialYearID = viewItem.FinancialYearID,
                SemesterID = viewItem.SemesterID,
                IsActive = viewItem.IsActive
            };

            await PopulateMappingDropdownsAsync(model);
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditMapping(int id, FeeDetail model)
        {
            if (id != model.FeeDetailID)
            {
                return BadRequest();
            }

            if (!ModelState.IsValid)
            {
                await PopulateMappingDropdownsAsync(model);
                return View(model);
            }

            if (!TryGetCurrentUserId(out var performedBy))
            {
                return Challenge();
            }
            string ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown";

            var result = await _feeService.SaveFeeDetailAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Fee mapping updated successfully.";
                return RedirectToAction(nameof(Mappings));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateMappingDropdownsAsync(model);
            return View(model);
        }

        private async Task PopulateMappingDropdownsAsync(FeeDetail? model = null)
        {
            var fees = await _feeService.GetFeeMasterAllAsync();
            var classes = await _classService.GetAllAsync();
            var semesters = await _feeService.GetSemestersAsync();
            var financialYears = await _financialYearService.GetAllAsync();

            ViewBag.Fees = new SelectList(fees, "FeeID", "Fee", model?.FeeID);
            ViewBag.Classes = new SelectList(classes, "ClassId", "ClassName", model?.ClassID);
            ViewBag.Semesters = new SelectList(semesters, "SemesterID", "SemesterName", model?.SemesterID);
            ViewBag.FinancialYears = new SelectList(financialYears, "FinancialYearId", "FinancialYearName", model?.FinancialYearID);
        }

        private bool TryGetCurrentUserId(out int userId)
        {
            userId = 0;
            var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(value, out userId);
        }
    }

    public static class FinancialYearExtensions
    {
        public static FinancialYear? OverloadsOrActiveCurrent(this System.Collections.Generic.IEnumerable<FinancialYear> list)
        {
            foreach (var fy in list)
            {
                if (fy.IsCurrent) return fy;
            }
            return null;
        }
    }
}
