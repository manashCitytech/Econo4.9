using Nop.Core;
using Nop.Plugin.Widgets.BackGroundThemeManagement.Components;
using Nop.Services.Cms;
using Nop.Services.Plugins;
using Nop.Web.Framework.Infrastructure;

namespace Nop.Plugin.Widgets.BackGroundThemeManagement;

public class BackgroundManagementPlugin : BasePlugin, IWidgetPlugin, IPlugin
{

    private readonly IWebHelper _webHelper;

    public BackgroundManagementPlugin(IWebHelper webHelper)
    {
        this._webHelper = webHelper; 
    }

    public bool HideInWidgetList => false;

    public Type GetWidgetViewComponent(string widgetZone)
    {
        return typeof(WidgetsBackgroundManagementViewComponent);
    }

    public async Task<IList<string>> GetWidgetZonesAsync()
    {
        return await Task.FromResult(new List<string> { PublicWidgetZones.HeaderAfter });
    }


    public override string GetConfigurationPageUrl()
    {
      return   _webHelper.GetStoreLocation() + "Admin/WidgetsBackgroundManagement/Configure";
    }

}
