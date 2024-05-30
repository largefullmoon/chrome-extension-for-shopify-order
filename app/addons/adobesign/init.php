<?php
    if (!defined('BOOTSTRAP')) { die('Access denied'); }

    // Define hooks
    fn_register_hooks(
        'get_orders_post',
        'get_orders',
        'dispatch_assign_template',
    );
?>
