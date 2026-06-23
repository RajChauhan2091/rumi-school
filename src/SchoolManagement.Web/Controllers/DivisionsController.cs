using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SchoolManagement.Application.Interfaces;
using SchoolManagement.Domain.Entities;

namespace SchoolManagement.Web.Controllers
{
    [Authorize(Roles = "Administrator")]
    public class DivisionsController : Controller
    {
        private readonly IDivisionService _service;

        public DivisionsController(IDivisionService service)
        {
            _service = service;
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

        public IActionResult Create()
        {
            return View(new DivisionMaster());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(DivisionMaster model)
        {
            if (!ModelState.IsValid)
            {
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
                TempData["SuccessMessage"] = "Division created successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            return View(model);
        }

        public async Task<IActionResult> Edit(int id)
        {
            var item = await _service.GetByIdAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return View(item);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, DivisionMaster model)
        {
            if (id != model.DivisionId)
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

            var result = await _service.SaveAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Division updated successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
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
                TempData["SuccessMessage"] = "Division deleted successfully.";
                return RedirectToAction(nameof(Index));
            }

            TempData["ErrorMessage"] = result.Message;
            return RedirectToAction(nameof(Index));
        }

        private bool TryGetCurrentUserId(out int userId)
        {
            userId = 0;
            var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(value, out userId);
        }
    }
}
