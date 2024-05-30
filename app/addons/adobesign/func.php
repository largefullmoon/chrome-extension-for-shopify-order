<?php
    use Faker\Factory as Faker;
    use Illuminate\Support\Collection;
    use Tygh\BlockManager\Block;
    use Tygh\BlockManager\Location;
    use Tygh\Embedded;
    use Tygh\Enum\NotificationSeverity;
    use Tygh\Enum\ObjectStatuses;
    use Tygh\Enum\OrderDataTypes;
    use Tygh\Enum\OrderStatuses;
    use Tygh\Enum\OutOfStockActions;
    use Tygh\Enum\ProductOptionTypes;
    use Tygh\Enum\ProductTracking;
    use Tygh\Enum\ProductZeroPriceActions;
    use Tygh\Enum\ProfileDataTypes;
    use Tygh\Enum\ProfileFieldLocations;
    use Tygh\Enum\ProfileFieldSections;
    use Tygh\Enum\ShippingCalculationTypes;
    use Tygh\Enum\ShippingRateTypes;
    use Tygh\Enum\SiteArea;
    use Tygh\Enum\UserTypes;
    use Tygh\Enum\VendorStatuses;
    use Tygh\Enum\YesNo;
    use Tygh\Languages\Languages;
    use Tygh\Navigation\LastView;
    use Tygh\Notifications\EventIdProviders\OrderProvider;
    use Tygh\Providers\EventDispatcherProvider;
    use Tygh\Providers\StorefrontProvider;
    use Tygh\Registry;
    use Tygh\Settings;
    use Tygh\Shippings\Shippings;
    use Tygh\Storage;
    use Tygh\Themes\Themes;
    use Tygh\Tools\SecurityHelper;
    use Tygh\Tygh;
    // Get the database connection
    
    if (!defined('BOOTSTRAP')) { die('Access denied'); }
    
    function fn_adobesign_get_orders_post($params, $orders) {
        $signs = db_get_array("select * from cscart_order_contracts where state='signed'");
        $contracts = array();
        foreach ($signs as $key => $sign) {
            $contracts[$sign['order_id']] = $sign['state'];
        }
        Tygh::$app['view']->assign('contracts', $contracts);
    }
    function fn_adobesign_get_orders($params,$fields,$sortings,$condition,$join,$group) {
        $connection = Tygh::$app['db'];
        $connection->query("CREATE TABLE IF NOT EXISTS `cscart_order_contracts` (
            `order_id` mediumint(8) unsigned NOT NULL,
            `widgetId` varchar(255) NOT NULL,
            `state` varchar(255) NOT NULL,
            `date_time` varchar(30)
          ) ENGINE=MyISAM DEFAULT CHARSET=utf8
        ");
    }
    function fn_adobesign_dispatch_assign_template($controller, $mode, $area, $controllers_cascade) {
        if ($area=='C' && $controller=='orders' && $mode=='search') { // Check if we're in the admin area
            $view = Tygh::$app['view'];
            if ($view->templateExists('addons/adobesign/views/orders/search.tpl')) {
                $view->assign('content_tpl', 'addons/adobesign/views/orders/search.tpl');
            }else{

            }
        }
    }
    
?>
