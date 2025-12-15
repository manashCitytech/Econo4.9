using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Nop.Core;
using Nop.Core.Domain.Discounts;
using Nop.Core.Domain.Orders;
using Nop.Core.Events;
using Nop.Services.Catalog;
using Nop.Services.Configuration;
using Nop.Services.Events;
using Nop.Services.Orders;

namespace Nop.Plugin.Misc.HandlingFeeProduct.Events;
public class CitytechHandlingProductEventHandler : ICitytechHandlingProductEventHandler, IConsumer<EntityInsertedEvent<ShoppingCartItem>>, IConsumer<EntityUpdatedEvent<ShoppingCartItem>>, IConsumer<EntityDeletedEvent<ShoppingCartItem>>
{
    private readonly IStoreContext _storeContext;
    private readonly ISettingService _settingService;
    private readonly IOrderTotalCalculationService _orderTotalCalculationService;
    private readonly IShoppingCartService _shoppingCartService;
    private readonly IWorkContext _workContext;
    private readonly IProductService _productService;
    public CitytechHandlingProductEventHandler(IStoreContext storeContext, ISettingService settingService, IOrderTotalCalculationService orderTotalCalculationService,
        IShoppingCartService shoppingCartService, IWorkContext workContext, IProductService productService
       )
    {
        _storeContext = storeContext;
        _settingService = settingService;
        _orderTotalCalculationService = orderTotalCalculationService;
        _shoppingCartService = shoppingCartService;
        _workContext = workContext;
        _productService = productService;
    }


    public async Task HandleEventAsync(EntityInsertedEvent<ShoppingCartItem> eventMessage)
    {
       await CommonMethod();

    }

    public async Task CommonMethod()
    {
        var storeScope = (await _storeContext.GetCurrentStoreAsync()).Id;
        var settings = await _settingService.LoadSettingAsync<HandlingFeeProductSettings>(storeScope);

        //If the treshold value or productid is set to 0 we don't do anything
        if (settings.SubTotalAmountTreshold == 0 || settings.ProductIdtoAdd == 0)
        {
            return;
        }

        var cart = await _shoppingCartService.GetShoppingCartAsync((await _workContext.GetCurrentCustomerAsync()), ShoppingCartType.ShoppingCart, (await _storeContext.GetCurrentStoreAsync()).Id);

        if (cart.Any())
        {
            var cartFiltered = await PrepareFilteredShoppingCart(await cart.ToListAsync(), settings);

            var productHandlingFeeProduct = await _productService.GetProductByIdAsync(settings.ProductIdtoAdd);
            var cartItemHandlingFeeProduct = await _shoppingCartService.FindShoppingCartItemInTheCartAsync(cart,
                ShoppingCartType.ShoppingCart, productHandlingFeeProduct);

            if (!cartFiltered.Any())
            {
                return;
            }

            ////sub total (incl tax)
            //decimal orderSubTotalDiscountAmount;
            ////Discount orderSubTotalAppliedDiscount;
            //List<Discount> orderSubTotalAppliedDiscount;
            //decimal subTotalWithoutDiscountBase;
            //decimal subTotalWithDiscountBase;

            var (orderSubTotalDiscountAmount, orderSubTotalAppliedDiscount, subTotalWithoutDiscountBase, subTotalWithDiscountBase, _) = await _orderTotalCalculationService.GetShoppingCartSubTotalAsync(cartFiltered, true);

            if (subTotalWithDiscountBase <= settings.SubTotalAmountTreshold)
            {
                if (cartItemHandlingFeeProduct == null)
                {
                    //_shoppingCartService.AddToCart(_workContext.CurrentCustomer, productHandlingFeeProduct,
                    //    ShoppingCartType.ShoppingCart,
                    //    storeScope, string.Empty, decimal.Zero, 1, false);

                    await _shoppingCartService.AddToCartAsync(await _workContext.GetCurrentCustomerAsync(), productHandlingFeeProduct, ShoppingCartType.ShoppingCart,
                                                      storeScope, null, decimal.Zero, null, null, 1, false);
                }
            }
            else
            {
                if (cartItemHandlingFeeProduct != null)
                {
                    await _shoppingCartService.DeleteShoppingCartItemAsync(cartItemHandlingFeeProduct);
                }
            }
        }
    }

    public async Task HandleEventAsync(EntityUpdatedEvent<ShoppingCartItem> eventMessage)
    {
        await CommonMethod();
    }

    public async Task HandleEventAsync(EntityDeletedEvent<ShoppingCartItem> eventMessage)
    {
        await CommonMethod();
    }



    public async Task<List<ShoppingCartItem>> PrepareFilteredShoppingCart(List<ShoppingCartItem> cart, HandlingFeeProductSettings settings)
    {
       var enumerable = cart;
        HandlingFeeProductSettings handlingFeeProductSettings = settings;
        enumerable = cart.Where(a => (a.ProductId != handlingFeeProductSettings.ProductIdtoAdd)).ToList();
        if (settings.IgnoreGiftCards)
        {
            enumerable = await enumerable.WhereAwait(async x => !(await _productService.GetProductByIdAsync(x.ProductId)).IsGiftCard).ToListAsync();
        }
        return enumerable;
    }
}
