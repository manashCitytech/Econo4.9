using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Nop.Core.Configuration;

namespace Nop.Plugin.Misc.HandlingFeeProduct;
public class HandlingFeeProductSettings : ISettings
{
    public decimal SubTotalAmountTreshold { get; set; }
    public int ProductIdtoAdd { get; set; }
    public bool IgnoreGiftCards { get; set; }
}
