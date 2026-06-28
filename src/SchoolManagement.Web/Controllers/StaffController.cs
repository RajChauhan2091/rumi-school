using System;
using System.IO;
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
    [Authorize(Roles = "Administrator")]
    public class StaffController : Controller
    {
        private readonly IStaffService _staffService;

        public StaffController(IStaffService staffService)
        {
            _staffService = staffService;
        }

        public async Task<IActionResult> Index()
        {
            var list = await _staffService.GetAllAsync();
            return View(list);
        }

        public async Task<IActionResult> Details(int id)
        {
            var item = await _staffService.GetByIdAsync(id);
            if (item == null)
            {
                return NotFound();
            }
            return View(item);
        }

        public async Task<IActionResult> Create()
        {
            await PopulateDropdownsAsync();
            return View(new StaffDetail { DOB = DateTime.Today.AddYears(-25), IsActive = true });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(StaffDetail model, IFormFile? staffPicFile)
        {
            if (staffPicFile != null && staffPicFile.Length > 0)
            {
                using (var ms = new MemoryStream())
                {
                    await staffPicFile.CopyToAsync(ms);
                    var fileBytes = ms.ToArray();
                    model.StaffPic = Convert.ToBase64String(fileBytes);
                }
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

            var result = await _staffService.SaveAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Staff profile created successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateDropdownsAsync(model);
            return View(model);
        }

        public async Task<IActionResult> Edit(int id)
        {
            var viewItem = await _staffService.GetByIdAsync(id);
            if (viewItem == null)
            {
                return NotFound();
            }

            var model = new StaffDetail
            {
                StaffID = viewItem.StaffID,
                StaffFirstName = viewItem.StaffFirstName,
                StaffMiddleName = viewItem.StaffMiddleName,
                StaffLastName = viewItem.StaffLastName,
                StaffType = viewItem.StaffTypeID,
                Mobileno = viewItem.Mobileno,
                EmergencyContact = viewItem.EmergencyContact,
                AddressLine1 = viewItem.AddressLine1,
                AddressLine2 = viewItem.AddressLine2,
                AadhaarNo = viewItem.AadhaarNo,
                BankName = viewItem.BankName,
                IFSCCode = viewItem.IFSCCode,
                AccountNo = viewItem.AccountNo,
                PanNo = viewItem.PanNo,
                StaffPic = viewItem.StaffPic,
                DOB = viewItem.DOB,
                IsActive = viewItem.IsActive
            };

            await PopulateDropdownsAsync(model);
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, StaffDetail model, IFormFile? staffPicFile)
        {
            if (id != model.StaffID)
            {
                return BadRequest();
            }

            if (staffPicFile != null && staffPicFile.Length > 0)
            {
                using (var ms = new MemoryStream())
                {
                    await staffPicFile.CopyToAsync(ms);
                    var fileBytes = ms.ToArray();
                    model.StaffPic = Convert.ToBase64String(fileBytes);
                }
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

            var result = await _staffService.SaveAsync(model, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Staff profile updated successfully.";
                return RedirectToAction(nameof(Index));
            }

            ModelState.AddModelError(string.Empty, result.Message);
            await PopulateDropdownsAsync(model);
            return View(model);
        }

        [HttpGet]
        public async Task<IActionResult> Delete(int id)
        {
            var item = await _staffService.GetByIdAsync(id);
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

            var result = await _staffService.DeleteAsync(id, performedBy, ipAddress);
            if (result.StatusCode == 200)
            {
                TempData["SuccessMessage"] = "Staff profile deleted successfully.";
                return RedirectToAction(nameof(Index));
            }

            TempData["ErrorMessage"] = result.Message;
            return RedirectToAction(nameof(Index));
        }

        private async Task PopulateDropdownsAsync(StaffDetail? model = null)
        {
            var staffTypes = await _staffService.GetStaffTypesAsync();
            ViewBag.StaffTypes = new SelectList(staffTypes, "StaffTypeID", "StaffType", model?.StaffType);
        }

        private bool TryGetCurrentUserId(out int userId)
        {
            userId = 0;
            var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(value, out userId);
        }
    }
}
