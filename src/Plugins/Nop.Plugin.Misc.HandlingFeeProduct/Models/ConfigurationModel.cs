using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Nop.Web.Framework.Models;
using Nop.Web.Framework.Mvc.ModelBinding;

namespace Nop.Plugin.Misc.HandlingFeeProduct.Models;
public record ConfigurationModel : BaseNopModel
{
    public int ActiveStoreScopeConfiguration { get; set; }

    [NopResourceDisplayName("Plugins.Misc.HandlingFeeProduct.Admin.SubTotalAmountTreshold")]
    public decimal SubTotalAmountTreshold { get; set; }

    public bool SubTotalAmountTreshold_OverrideForStore { get; set; }

    [NopResourceDisplayName("Plugins.Misc.HandlingFeeProduct.Admin.ProductIdtoAdd")]
    public int ProductIdtoAdd { get; set; }
    public bool ProductIdtoAdd_OverrideForStore { get; set; }

    [NopResourceDisplayName("Plugins.Misc.HandlingFeeProduct.Admin.IgnoreGiftCards")]
    public bool IgnoreGiftCards { get; set; }
    public bool IgnoreGiftCards_OverrideForStore { get; set; }
}
