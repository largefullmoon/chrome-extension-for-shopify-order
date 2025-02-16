
{capture name="mainbox"}

{if $runtime.mode == "new"}
    <p>{__("text_admin_new_orders")}</p>
{/if}

{$order_status_descr = $smarty.const.STATUSES_ORDER|fn_get_simple_statuses:true:true}
{$order_statuses = $smarty.const.STATUSES_ORDER|fn_get_statuses:$statuses:true:true}
{$can_change_status = "orders.update_status"|fn_check_view_permissions:"POST"}

{capture name="sidebar"}
    {hook name="orders:manage_sidebar"}
{include file="common/saved_search.tpl" dispatch="orders.manage" view_type="orders"}
    {include file="views/orders/components/orders_search_form.tpl" dispatch="orders.manage"}
    {/hook}
{/capture}

<form action="{""|fn_url}" method="post" target="_self" name="orders_list_form" id="orders_list_form" data-ca-is-multiple-submit-allowed="true">

{include file="common/pagination.tpl" save_current_page=true save_current_url=true div_id=$smarty.request.content_id}

{$c_url=$config.current_url|fn_query_remove:"sort_by":"sort_order"}
{$rev=$smarty.request.content_id|default:"pagination_contents"}
{$page_title=__("orders")}
{$extra_status=$config.current_url|escape:"url"}
{$notify_vendor = fn_allowed_for("MULTIVENDOR")}
{$notify=true}
{$notify_department=true}

{if $orders}
    {capture name="orders_table"}
        <div class="table-responsive-wrapper longtap-selection">
            <table width="100%" class="table table-middle table--relative table-responsive table--overflow-hidden table--show-checkbox table-manage-orders">
            <thead data-ca-bulkedit-default-object="true" data-ca-bulkedit-component="defaultObject">
            <tr>
                <th width="3%" class="left mobile-hide table__check-items-column table__check-items-column--show-checkbox">
                    {include file="common/check_items.tpl"
                        show_checkbox=true
                        check_statuses=$order_status_descr
                        meta="table__check-items table__check-items--show-checkbox"
                        class="check-items--show-checkbox"
                    }
                    <input type="checkbox"
                        class="bulkedit-toggler hide"
                        data-ca-bulkedit-disable="[data-ca-bulkedit-default-object=true]"
                        data-ca-bulkedit-enable="[data-ca-bulkedit-expanded-object=true]"
                    />
                </th>
                <th width="15%">
                    {include file="common/table_col_head.tpl" type="order_id" text=__("id")}
                </th>
                <th width="15%">
                    {include file="common/table_col_head.tpl" type="status"}
                </th>
                <th width="15%">
                    {include file="common/table_col_head.tpl" type="date"}
                </th>
                <th width="28%">
                    {include file="common/table_col_head.tpl" type="customer"}
                </th>
                <th width="10%">
                    {include file="common/table_col_head.tpl" text=__("phone")}
                </th>
                <th width="4%">{("AdobeSign")}</th>

                {hook name="orders:manage_header"}{/hook}

                <th class="mobile-hide">&nbsp;</th>
                <th width="10%" class="right">
                    {include file="common/table_col_head.tpl" type="total"}
                </th>
            </tr>
            </thead>
            {foreach from=$orders item="o"}
            {hook name="orders:order_row"}
            <tr class="cm-longtap-target"
                data-ca-longtap-action="setCheckBox"
                data-ca-longtap-target="input.cm-item"
                data-ca-id="{$o.order_id}"
            >
                <td width="3%" class="left mobile-hide table__check-items-cell table__check-items-cell--show-checkbox">
                    <input type="checkbox" name="order_ids[]" value="{$o.order_id}" class="cm-item cm-item-status-{$o.status|lower}" /></td>
                <td width="15%" data-th="{__("id")}">
                    <a href="{"orders.details?order_id=`$o.order_id`"|fn_url}" class="underlined link--monochrome">{__("order")} <bdi>#{$o.order_id}</bdi></a>
                    {if $order_statuses[$o.status].params.appearance_type == "I" && $o.invoice_id}
                        <p class="muted">{__("invoice")} #{$o.invoice_id}</p>
                    {elseif $order_statuses[$o.status].params.appearance_type == "C" && $o.credit_memo_id}
                        <p class="muted">{__("credit_memo")} #{$o.credit_memo_id}</p>
                    {/if}
                    {include file="views/companies/components/company_name.tpl" object=$o}
                </td>
                <td width="15%" data-th="{__("status")}">
                    {include file="common/select_popup.tpl"
                            type="orders"
                            suffix="o"
                            order_info=$o
                            id=$o.order_id
                            status=$o.status
                            items_status=$order_status_descr
                            update_controller="orders"
                            notify=$notify
                            notify_department=$notify_department
                            notify_vendor=$notify_vendor
                            status_target_id="orders_total,`$rev`"
                            extra="&return_url=`$extra_status`"
                            statuses=$order_statuses
                            btn_meta="btn btn-info o-status-`$o.status` order-status"|lower
                            text_wrap=true
                    }
                    {if $o.issuer_id}
                        {if $o.issuer_name|trim}
                            <p class="muted shift-left manager-order">{$o.issuer_name}</p>
                        {else}
                            <p class="muted shift-left manager-order">{$o.issuer_email}</p>
                        {/if}
                    {/if}
                </td>
                <td width="15%" class="nowrap" data-th="{__("date")}">{$o.timestamp|date_format:"`$settings.Appearance.date_format`, `$settings.Appearance.time_format`"}</td>
                <td width="17%" data-th="{__("customer")}">
                    {if $o.email}<a href="mailto:{$o.email|escape:url}" class="link--monochrome">@</a> {/if}
                    {if $o.company}<p class="muted">{$o.company}</p>{/if}
                    {if $o.user_type !== "UserTypes::CUSTOMER"|enum
                        && $auth.user_type !== "UserTypes::ADMIN"|enum
                        && $o.user_id !== $auth.user_id
                        || !$o.user_id
                    }
                        {$o.lastname} {$o.firstname}
                    {elseif $o.user_id}
                        <a href="{"profiles.update?user_id=`$o.user_id`"|fn_url}" class="link--monochrome">{$o.lastname} {$o.firstname}</a>
                    {/if}
                </td>
                <td width="10%" {if $o.phone}data-th="{__("phone")}"{/if}>{if $o.phone}<bdi><a href="tel:{$o.phone}" class="link--monochrome">{$o.phone}</a></bdi>{/if}</td>

                <td width="4%">
                    {if $contracts[$o.order_id]}
                    <button class="btn btn-success" onclick="showCustomModal({$o.order_id},'signed'); return false;">
                    {$contracts[$o.order_id]}
                    {else}
                    <button class="btn btn-primary" id="signbutton{$o.order_id}" onclick="showCustomModal({$o.order_id},'sign'); return false;">
                    sign
                    {/if}
                    </button>
                </td>
                {hook name="orders:manage_data"}{/hook}
                <td class="center" data-th="{__("tools")}">
                    {capture name="tools_items"}
                        <li>{btn type="list" href="orders.details?order_id=`$o.order_id`" text={__("view")}}</li>
                        {hook name="orders:list_extra_links"}
                            <li>{btn type="list" href="order_management.edit?order_id=`$o.order_id`" text={__("edit")}}</li>
                            <li>{btn type="list" href="order_management.edit?order_id=`$o.order_id`&copy=1" text={__("copy")}}</li>
                            {$current_redirect_url=$config.current_url|escape:url}
                            <li>{btn type="list" href="orders.delete?order_id=`$o.order_id`&redirect_url=`$current_redirect_url`" class="cm-confirm" text={__("delete")} method="POST"}</li>
                        {/hook}
                    {/capture}
                    <div class="hidden-tools">
                        {dropdown content=$smarty.capture.tools_items}
                    </div>
                </td>
                <td width="10%" class="right" data-th="{__("total")}">
                    {include file="common/price.tpl" value=$o.total}
                </td>
            </tr>
            {/hook}
            {/foreach}
            </table>
        </div>
    {/capture}

    {include file="common/context_menu_wrapper.tpl"
        form="orders_list_form"
        object="orders"
        items=$smarty.capture.orders_table
    }
{else}
    <p class="no-items">{__("no_data")}</p>
{/if}

{if $orders}
    <div class="statistic clearfix" id="orders_total">
        {hook name="orders:statistic_list"}
        <div class="table-wrapper">
            <table class="pull-right ">
                {if $total_pages > 1 && $search.page != "full_list"}
                    <tr>
                        <td>&nbsp;</td>
                        <td width="100px">{__("for_this_page_orders")}:</td>
                    </tr>
                    <tr>
                        <td>{__("gross_total")}:</td>
                        <td>{include file="common/price.tpl" value=$display_totals.gross_total}</td>
                    </tr>
                    <tr>
                        <td>{__("totally_paid")}:</td>
                        <td>{include file="common/price.tpl" value=$display_totals.totally_paid}</td>
                    </tr>
                    <hr />
                    <tr>
                        <td>{__("for_all_found_orders")}:</td>
                    </tr>
                {/if}
                <tr>
                    <td class="shift-right">{__("gross_total")}:</td>
                    <td>{include file="common/price.tpl" value=$totals.gross_total}</td>
                </tr>
                {hook name="orders:totals_stats"}
                <tr>
                    <td class="shift-right"><h4>{__("totally_paid")}:</h4></td>
                    <td class="price">{include file="common/price.tpl" value=$totals.totally_paid}</td>
                </tr>
                {/hook}
            </table>
        </div>
        {/hook}
    <!--orders_total--></div>
{/if}

{include file="common/pagination.tpl" div_id=$smarty.request.content_id}


{capture name="adv_buttons"}
    {hook name="orders:manage_tools"}
        {include file="common/tools.tpl"
            tool_href="order_management.new"
            tool_override_meta="btn btn-primary"
            prefix="bottom"
            hide_tools="true"
            title=__("add_order")
            link_text=__("add_order")
            icon="icon-plus"
        }
    {/hook}
{/capture}

</form>
{/capture}

{capture name="buttons"}
    {capture name="tools_list"}
        {hook name="orders:list_tools"}
        {/hook}
    {/capture}
    {dropdown content=$smarty.capture.tools_list class="bulkedit-dropdown--legacy hide"}
{/capture}

{include file="common/mainbox.tpl"
    title=$page_title
    sidebar=$smarty.capture.sidebar
    content=$smarty.capture.mainbox
    buttons=$smarty.capture.buttons
    adv_buttons=$smarty.capture.adv_buttons
    content_id="manage_orders"
    select_storefront=true
    storefront_switcher_param_name="storefront_id"
    selected_storefront_id=$selected_storefront_id
}

<script>
    (function(_, $) {
        $.ceEvent('on', 'ce.commoninit', function(context) {
            window.showCustomModal = function(order_id,sign) {
                var modal = document.createElement('div');
                modal.style.position = 'fixed';
                modal.id = 'adobemodal';
                modal.style.width = '100vw';
                modal.style.height = '100vh';
                modal.style.display = 'block';
                modal.style.top = '0px';
                modal.style.zIndex = 1100;
                modal.style.left = '0px';
                modal.style.backgroundColor = 'black';
                var text = `<a target="blank" href="https://mail.google.com/mail/u/0/?tab=rm&ogbl#inbox"><div style="width:30px; height:30px; cursor:pointer;  fond-weight:bold; color: red; position: absolute; top: 20px; right: 60px; background-image: url('images/mail.png'); background-size: cover;"></div></a>`;
                modal.innerHTML = `<div style="width:80px; height:80px; cursor:pointer;" onclick="closeModal('`+order_id+`')"><span style="font-size: 40px; cursor:pointer;  fond-weight:bold; color: red; position: absolute; top: 20px; right: 30px;" >&times;</span></div><div style="width: 100%; height: 100%; display: flex; justify-content: center;"><iframe width="900px" height="600px" id="frame"></iframe></div>`;
                document.body.appendChild(modal);
                var url = fn_url('adobesign.get_customer_info');
                var frame = document.getElementById("frame");
                frame.src = url+"&order_id="+order_id+"&type=sign"+"&sign="+sign;
            };
            window.closeModal =  function(order_id){
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function() {
                    if (this.readyState == 4 && this.status == 200) {
                        var modal = document.getElementById('adobemodal');
                        modal.parentElement.removeChild(modal);
                        if(this.responseText=='success'){
                            var signbtn = document.getElementById('signbutton'+order_id);
                            signbtn.innerText = 'signed';
                            signbtn.className = 'btn btn-success';
                        }
                    }
                };
                var url = fn_url('adobesign.get_customer_info');
                xhttp.open("GET", url+"&order_id="+order_id+"&type=save", true);
                xhttp.send();
            };
        });
    })(Tygh, Tygh.$);
</script>

