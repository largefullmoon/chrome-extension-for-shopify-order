{capture name="section"}
    {include file="views/orders/components/orders_search_form.tpl"}
{/capture}
{include file="common/section.tpl" section_title=__("search_options") section_content=$smarty.capture.section class="ty-search-form" collapse=true}

{assign var="c_url" value=$config.current_url|fn_query_remove:"sort_by":"sort_order"}
{if $search.sort_order == "asc"}
    {include_ext file="common/icon.tpl" class="ty-icon-down-dir" assign=sort_sign}
{else}
    {include_ext file="common/icon.tpl" class="ty-icon-up-dir" assign=sort_sign}
{/if}
{if !$config.tweaks.disable_dhtml}
    {assign var="ajax_class" value="cm-ajax"}

{/if}

{include file="common/pagination.tpl"}

<table class="ty-table ty-orders-search">
    <thead>
        <tr>
            <th><a class="{$ajax_class}" href="{"`$c_url`&sort_by=order_id&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id="pagination_contents">{__("id")}</a>{if $search.sort_by === "order_id"}{$sort_sign nofilter}{/if}</th>
            <th><a class="{$ajax_class}" href="{"`$c_url`&sort_by=status&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id="pagination_contents">{__("status")}</a>{if $search.sort_by === "status"}{$sort_sign nofilter}{/if}</th>
            <th><a class="{$ajax_class}" href="{"`$c_url`&sort_by=customer&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id="pagination_contents">{__("customer")}</a>{if $search.sort_by === "customer"}{$sort_sign nofilter}{/if}</th>
            <th><a class="{$ajax_class}" href="{"`$c_url`&sort_by=date&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id="pagination_contents">{__("date")}</a>{if $search.sort_by === "date"}{$sort_sign nofilter}{/if}</th>
            <th>{("AdobeSign")}</th>
            {hook name="orders:manage_header"}{/hook}

            <th><a class="{$ajax_class}" href="{"`$c_url`&sort_by=total&sort_order=`$search.sort_order_rev`"|fn_url}" data-ca-target-id="pagination_contents">{__("total")}</a>{if $search.sort_by === "total"}{$sort_sign nofilter}{/if}</th>
            <th class="ty-orders-search__header ty-orders-search__header--actions">{__("actions")}</th>
        </tr>
    </thead>
    {foreach from=$orders item="o"}
        <tr>
            <td class="ty-orders-search__item"><a href="{"orders.details?order_id=`$o.order_id`"|fn_url}"><strong>#{$o.order_id}</strong></a></td>
            <td class="ty-orders-search__item">{include file="common/status.tpl" status=$o.status display="view"}</td>
            <td class="ty-orders-search__item">
                <ul class="ty-orders-search__user-info">
                    <li class="ty-orders-search__user-name">{$o.firstname} {$o.lastname}</li>
                    <li  class="ty-orders-search__user-mail"><a href="mailto:{$o.email|escape:url}">{$o.email}</a></li>
                </ul>
            </td>
            <td class="ty-orders-search__item"><a href="{"orders.details?order_id=`$o.order_id`"|fn_url}">{$o.timestamp|date_format:"`$settings.Appearance.date_format`, `$settings.Appearance.time_format`"}</a></td>
            <td>
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

            <td class="ty-orders-search__item">{include file="common/price.tpl" value=$o.total}</td>
            <td class="ty-orders-search__item ty-orders-search__item--actions">
                {include file="buttons/button.tpl"
                        but_meta="cm-new-window ty-btn-icon"
                        but_role="text"
                        but_title=__("print_invoice")
                        but_href="orders.print_invoice?order_id=`$o.order_id`"
                        but_icon="ty-orders__actions-icon ty-icon-print"}

                {include file="buttons/button.tpl"
                        but_meta="ty-btn-icon"
                        but_role="text"
                        but_title=__("re_order")
                        but_href="orders.reorder?order_id=`$o.order_id`"
                        but_icon="ty-orders__actions-icon ty-icon-cw"}

                {include file="buttons/button.tpl"
                        but_meta="ty-btn-icon"
                        but_role="text"
                        but_title=__("search_products")
                        but_href="products.search?search_performed=Y&order_ids=`$o.order_id`"
                        but_icon="ty-orders__actions-icon ty-icon-search"}
            </td>
        </tr>
    {foreachelse}
        <tr class="ty-table__no-items">
            <td colspan="7">
                <p class="ty-no-items">{__("text_no_orders")}</p>
            </td>
        </tr>
    {/foreach}
</table>

{include file="common/pagination.tpl"}

{capture name="mainbox_title"}{__("orders")}{/capture}


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