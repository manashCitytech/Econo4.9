using System.Linq.Expressions;
using Microsoft.AspNetCore.Mvc;
using Nop.Core;
using Nop.Plugin.Widgets.BackGroundManagement.Models;
using Nop.Services.Configuration;
using Nop.Services.Localization;
using Nop.Services.Media;
using Nop.Services.Messages;
using Nop.Services.Security;
using Nop.Web.Framework;
using Nop.Web.Framework.Controllers;
using Nop.Web.Framework.Mvc.Filters;

namespace Nop.Plugin.Widgets.BackGroundThemeManagement.Controllers;

[AuthorizeAdmin]
[Area(AreaNames.ADMIN)]
[AutoValidateAntiforgeryToken]
public class WidgetsBackgroundManagementController:BasePluginController
{

    private readonly ISettingService _settingService;
    private readonly IStoreContext _storeContext;
    private readonly IPermissionService _permissionService;
    private readonly IPictureService _pictureService;
    private readonly ILocalizationService _localizationService;
    private readonly INotificationService _notificationService;

    public WidgetsBackgroundManagementController(
      ISettingService settingService,
      IStoreContext storeContext,
      IPermissionService permissionService,
      IPictureService pictureService,
      INotificationService notificationService,
      ILocalizationService localizationService)
    {
        this._settingService = settingService;
        this._storeContext = storeContext;
        this._permissionService = permissionService;
        this._pictureService = pictureService;
        this._notificationService = notificationService;
        this._localizationService = localizationService;
    }

    [CheckPermission(StandardPermission.Configuration.MANAGE_WIDGETS)]
    public async Task< IActionResult> Configure()
    {
        var storescope = await _storeContext.GetActiveStoreScopeConfigurationAsync();
        BackgroundManagementSettings managementSettings = await _settingService.LoadSettingAsync<BackgroundManagementSettings>(storescope);
        return View("~/Plugins/Widgets.BackgroundTheme/Views/Configure.cshtml", (object)new BackgroundImageModel()
        {
            PictureId = managementSettings.PictureId
        });
    }

    [HttpPost]
    [CheckPermission(StandardPermission.Configuration.MANAGE_WIDGETS)]
    public async Task<IActionResult> Configure(BackgroundImageModel model)
    {
        
        int scopeConfiguration = await _storeContext.GetActiveStoreScopeConfigurationAsync();
        BackgroundManagementSettings managementSettings = this._settingService.LoadSetting<BackgroundManagementSettings>(scopeConfiguration);
        int pictureId = managementSettings.PictureId;
        managementSettings.PictureId = model.PictureId;
        await _settingService.SaveSettingOverridablePerStoreAsync<BackgroundManagementSettings, int>(managementSettings, (x => x.PictureId), false, scopeConfiguration, false);
        await _settingService.ClearCacheAsync();
        var pictureById = await _pictureService.GetPictureByIdAsync(pictureId);
        if (pictureById != null)
            await _pictureService.DeletePictureAsync(pictureById);
         _notificationService.SuccessNotification(await _localizationService.GetResourceAsync("Admin.Plugins.Saved"));
        return await Configure();
    }
}
