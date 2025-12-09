using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Nop.Core;
using Nop.Core.Domain.Media;
using Nop.Plugin.Widgets.BackGroundManagement.Models;
using Nop.Services.Configuration;
using Nop.Services.Media;
using Nop.Web.Framework.Components;

namespace Nop.Plugin.Widgets.BackGroundThemeManagement.Components;
public class WidgetsBackgroundManagementViewComponent : NopViewComponent
{
    private readonly ISettingService _settingService;
    private readonly IStoreContext _storeContext;
    private readonly IPictureService _pictureService;

    public WidgetsBackgroundManagementViewComponent(
      ISettingService settingService,
      IStoreContext storeContext,
      IPictureService pictureService)
    {
        this._settingService = settingService;
        this._storeContext = storeContext;
        this._pictureService = pictureService;
    }

    public async Task<IViewComponentResult> InvokeAsync(string widgetZone, object additionalData)
    {
        BackgroundManagementSettings managementSettings = await _settingService.LoadSettingAsync<BackgroundManagementSettings>( _storeContext.GetCurrentStore().Id);
        if (managementSettings == null || managementSettings.PictureId <= 0)
            return (IViewComponentResult)((ViewComponent)this).Content("");
        new BackgroundImageModel().PictureId = managementSettings.PictureId;
        return View("~/Plugins/Widgets.BackgroundTheme/Views/PublicInfo.cshtml", await _pictureService.GetPictureUrlAsync(managementSettings.PictureId, 0, true));
    }
}
