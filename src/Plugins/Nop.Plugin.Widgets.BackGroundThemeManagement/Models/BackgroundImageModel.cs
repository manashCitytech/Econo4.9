using System.ComponentModel.DataAnnotations;
using Nop.Web.Framework.Models;
using Nop.Web.Framework.Mvc.ModelBinding;

namespace Nop.Plugin.Widgets.BackGroundManagement.Models
{
    public record BackgroundImageModel : BaseNopModel
    {
        [NopResourceDisplayName("Plugins.Widgets.BackgroundManagement.Header.Picture")]
        [UIHint("Picture")]
        public int PictureId { get; set; }
    }

}

