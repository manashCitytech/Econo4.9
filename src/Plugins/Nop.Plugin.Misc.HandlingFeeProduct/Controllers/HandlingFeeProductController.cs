using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Nop.Core;
using Nop.Plugin.Misc.HandlingFeeProduct.Models;
using Nop.Services.Configuration;
using Nop.Services.Localization;
using Nop.Services.Logging;
using Nop.Services.Messages;
using Nop.Services.Orders;
using Nop.Services.Payments;
using Nop.Services.Stores;
using Nop.Web.Framework;
using Nop.Web.Framework.Controllers;
using Nop.Web.Framework.Mvc.Filters;

namespace Nop.Plugin.Misc.HandlingFeeProduct.Controllers;
public class HandlingFeeProductController:BasePluginController
{
    private readonly ISettingService _settingService;
    private readonly IPaymentService _paymentService;
    private readonly IStoreService _storeService;
    private readonly IOrderService _orderService;
    private readonly IWorkContext _workContext;
    private readonly IStoreContext _storeContext;
    private readonly ILogger _logger;
    private readonly INotificationService _notificationService;
    private readonly ILocalizationService _localizationService;

    public HandlingFeeProductController(
           ISettingService settingService,
           IPaymentService paymentService,
           IStoreService storeService,
           IOrderService orderService,
           IWorkContext workContext,
           IStoreContext storeContext,
           ILogger logger,
           INotificationService notificationService,
           ILocalizationService localizationService)
    {
        _settingService = settingService;
        _paymentService = paymentService;
        _storeService = storeService;
        _orderService = orderService;
        _workContext = workContext;
        _storeContext = storeContext;
        _logger = logger;
        _notificationService = notificationService;
        _localizationService = localizationService;

    }

    [AuthorizeAdmin]
    [Area(AreaNames.ADMIN)]
    public async Task<IActionResult> Configure()
    {

        int storeScope =await _storeContext.GetActiveStoreScopeConfigurationAsync();
        var settings =await _settingService.LoadSettingAsync<HandlingFeeProductSettings>(storeScope);
        var model = new ConfigurationModel()
        {
            ActiveStoreScopeConfiguration = storeScope,
            SubTotalAmountTreshold = settings.SubTotalAmountTreshold,
            ProductIdtoAdd = settings.ProductIdtoAdd,
            IgnoreGiftCards = settings.IgnoreGiftCards
        };

        if (storeScope > 0)
        {
            model.SubTotalAmountTreshold_OverrideForStore = _settingService.SettingExists(settings, x => x.SubTotalAmountTreshold, storeScope);
            model.ProductIdtoAdd_OverrideForStore = _settingService.SettingExists(settings, x => x.ProductIdtoAdd, storeScope);
            model.IgnoreGiftCards_OverrideForStore = _settingService.SettingExists(settings, x => x.IgnoreGiftCards, storeScope);
        }

        return View("~/Plugins/Misc.HandlingFeeProduct/Views/HandlingFeeProduct/Configure.cshtml", model);

    }

    [HttpPost]
    [AuthorizeAdmin]
    [Area(AreaNames.ADMIN)]
    public async Task< IActionResult> Configure(ConfigurationModel model)
    {
        if (!ModelState.IsValid)
            return await Configure();

        var storeScope =await _storeContext.GetActiveStoreScopeConfigurationAsync();
        var settings =await _settingService.LoadSettingAsync<HandlingFeeProductSettings>(storeScope);

        settings.SubTotalAmountTreshold = model.SubTotalAmountTreshold;
        settings.ProductIdtoAdd = model.ProductIdtoAdd;
        settings.IgnoreGiftCards = model.IgnoreGiftCards;

        //save settings
        if (model.ProductIdtoAdd_OverrideForStore || storeScope == 0)
            _settingService.SaveSetting(settings, x => x.ProductIdtoAdd, storeScope, false);
        else if (storeScope > 0)
           await _settingService.DeleteSettingAsync(settings, x => x.ProductIdtoAdd, storeScope);

        if (model.SubTotalAmountTreshold_OverrideForStore || storeScope == 0)
            _settingService.SaveSetting(settings, x => x.SubTotalAmountTreshold, storeScope, false);
        else if (storeScope > 0)
          await  _settingService.DeleteSettingAsync(settings, x => x.SubTotalAmountTreshold, storeScope);

        if (model.IgnoreGiftCards_OverrideForStore || storeScope == 0)
            _settingService.SaveSetting(settings, x => x.IgnoreGiftCards, storeScope, false);
        else if (storeScope > 0)
          await  _settingService.DeleteSettingAsync(settings, x => x.IgnoreGiftCards, storeScope);

        //now clear settings cache
        _settingService.ClearCache();

        _notificationService.SuccessNotification(await _localizationService.GetResourceAsync("Admin.Plugins.Saved"));

        return await Configure();
    }
}
