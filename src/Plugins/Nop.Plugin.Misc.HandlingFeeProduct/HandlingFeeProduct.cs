using Nop.Core;
using Nop.Services.Catalog;
using Nop.Services.Common;
using Nop.Services.Configuration;
using Nop.Services.Localization;
using Nop.Services.Orders;
using Nop.Services.Plugins;

namespace Nop.Plugin.Misc.HandlingFeeProduct;

public class HandlingFeeProduct : BasePlugin, IMiscPlugin
{
    private readonly ISettingService _settingService;
    private readonly IShoppingCartService _shoppingCartService;
    private readonly IOrderTotalCalculationService _orderTotalCalculationService;
    private readonly IWorkContext _workContext;
    private readonly IStoreContext _storeContext;
    private readonly IProductService _productService;
    private readonly ILocalizationService _localizationService;
    private readonly IWebHelper _webHelper;

    public HandlingFeeProduct(ISettingService settingService
           , IShoppingCartService shoppingCartService
           , IOrderTotalCalculationService orderTotalCalculationService
           , IWorkContext workContext
           , IStoreContext storeContext
           , IProductService productService,
           ILocalizationService localizationService,
           IWebHelper webHelper
           )
    {
        _settingService = settingService;
        _shoppingCartService = shoppingCartService;
        _orderTotalCalculationService = orderTotalCalculationService;
        _workContext = workContext;
        _storeContext = storeContext;
        _productService = productService;
        _localizationService = localizationService;
        _webHelper = webHelper;
    }

    public override string GetConfigurationPageUrl()
    {
        return $"{_webHelper.GetStoreLocation()}Admin/HandlingFeeProduct/Configure";
    }

    public override async Task InstallAsync()
    {
        HandlingFeeProductSettings settings = new HandlingFeeProductSettings
        {
            SubTotalAmountTreshold = 0,
            ProductIdtoAdd = 0,
            IgnoreGiftCards = false
        };

      await  _settingService.SaveSettingAsync(settings);

        //locales
      await  _localizationService.AddOrUpdateLocaleResourceAsync(new Dictionary<string, string>
        {
            ["Plugins.Misc.HandlingFeeProduct.Admin.SubTotalAmountTreshold"] = "Sub Total Amount Threshold",
            ["Plugins.Misc.HandlingFeeProduct.Admin.SubTotalAmountTreshold.Hint"] = "If the cart subtotal amount is less than or equal to this then the Additional Fee Product is applied. Setting it to 0 will inactivate the plugin.",
            ["Plugins.Misc.HandlingFeeProduct.Admin.ProductIdtoAdd"] = "Additional Fee Product ID",
            ["Plugins.Misc.HandlingFeeProduct.Admin.ProductIdtoAdd.Hint"] = "The ID of the Additional Fee Product that has to be added to the cart if the subtotal amount is less than or equal the treshold amount. Setting it to 0 will inactivate the plugin",
            ["Plugins.Misc.HandlingFeeProduct.Admin.IgnoreGiftCards"] = "Ignore GiftCards",
            ["Plugins.Misc.HandlingFeeProduct.Admin.IgnoreGiftCards.Hint"] = "Check this if you don't want to apply the threshold on Gift Cards",
            ["Plugins.Misc.HandlingFeeProduct.Admin.SubTotalAmountTreshold.Validation"] = "Value has to be greater or equal than 0",
            ["Plugins.Misc.HandlingFeeProduct.Admin.ProductIdtoAdd.Validation"] = "Please insert an existing Product ID"
        });

        await base.InstallAsync();
    }
    public override async Task UninstallAsync()
    {
       await _settingService.DeleteSettingAsync<HandlingFeeProductSettings>();

        //locales
        await _localizationService.DeleteLocaleResourcesAsync("Plugins.Misc.HandlingFeeProduct.Admin");

        await base.UninstallAsync();
    }

}
