using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Nop.Core.Infrastructure;

namespace Nop.Plugin.Misc.HandlingFeeProduct.Infrastructure;
public class NopStartup : INopStartup
{
    public int Order => 101;

    public void Configure(IApplicationBuilder application)
    {
        //throw new NotImplementedException();
    }

    public void ConfigureServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<Events.ICitytechHandlingProductEventHandler, Events.CitytechHandlingProductEventHandler>();
    }
}
