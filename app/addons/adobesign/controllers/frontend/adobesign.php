<?php
/***************************************************************************
 *                                                                          *
 *   (c) 2004 Vladimir V. Kalynyak, Alexey V. Vinokurov, Ilya M. Shalnev    *
 *                                                                          *
 * This  is  commercial  software,  only  users  who have purchased a valid *
 * license  and  accept  to the terms of the  License Agreement can install *
 * and use this program.                                                    *
 *                                                                          *
 ****************************************************************************
 * PLEASE READ THE FULL TEXT  OF THE SOFTWARE  LICENSE   AGREEMENT  IN  THE *
 * "copyright.txt" FILE PROVIDED WITH THIS DISTRIBUTION PACKAGE.            *
 ****************************************************************************/
    use Tygh\Addons\AdvancedImport\Exceptions\DownloadException;
    use Tygh\Addons\AdvancedImport\Exceptions\FileNotFoundException;
    use Tygh\Addons\AdvancedImport\Exceptions\ReaderNotFoundException;
    use Tygh\Enum\Addons\AdvancedImport\ImportStatuses;
    use Tygh\Addons\AdvancedImport\ServiceProvider;
    use Tygh\Enum\Addons\AdvancedImport\RelatedObjectTypes;
    use Tygh\Enum\NotificationSeverity;
    use Tygh\Exceptions\PermissionsException;
    use Tygh\Registry;
    use Tygh\Http;
    use Tygh;
    defined('BOOTSTRAP') or die('Access denied');
    if($_REQUEST['order_id']&&$_REQUEST['type']=='sign'){
        fn_your_addon_get_customer_info();
    }
    if($_REQUEST['type']=='save'){
        checkSign();
    }
    function fn_your_addon_get_customer_info()
    {
        $order_id = $_REQUEST['order_id'];
        // Retrieve the order details based on the order ID
        $order = fn_get_order_info($order_id);
        exportPDF($order);
    }
    function checkSign(){
        $widgetRow = db_get_row('select * from cscart_order_contracts where order_id='.$_REQUEST['order_id']);
        $widgetId = $widgetRow['widgetId'];
        $target_server = 'https://api.au1.adobesign.com/api/rest/v6/widgets/'.$widgetId.'/formData';
        $ch = curl_init();
        $headers = array(
            'Authorization:Bearer 3AAABLblqZhCg9mzG-PNtjwRdqG6fK6YECiei7N8hrGdjiJif1BPZVhZHKpUPUyMXWuYWmp0e3v2Wudc2doWiXCr_X8w4LzmS',
            'Accept:application/json',
        );
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        // Set the URL of the server you want to fetch data from
        curl_setopt($ch, CURLOPT_URL, $target_server);
        // Set the cURL option to return the response as a string
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        
        // Execute the cURL request
        $response = curl_exec($ch);
        curl_close($ch);
        $result = json_decode($response);
        if($result->formDataList){
            $formDataList = $result->formDataList;
            // $agreementId = $formDataList->agreementId;
            $completed = $formDataList->completed;
            $order_id = $_REQUEST['order_id'];
            if($completed != ''){
                // $target_server = "https://api.au1.adobesign.com/api/rest/v6/agreements/".$agreementId."/documents";
                // $ch = curl_init();
                // $headers = array(
                //     'Authorization:Bearer 3AAABLblqZhCg9mzG-PNtjwRdqG6fK6YECiei7N8hrGdjiJif1BPZVhZHKpUPUyMXWuYWmp0e3v2Wudc2doWiXCr_X8w4LzmS',
                //     'Content-Type:application/json',
                // );
                // curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
                // // Set the URL of the server you want to fetch data from
                // curl_setopt($ch, CURLOPT_URL, $target_server);
                // // Set the cURL option to return the response as a string
                // curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                
                // // Execute the cURL request
                // $response = curl_exec($ch);
                // curl_close($ch);
                // $result = json_decode($response);
                // $documents = $result->documents;
                // $documentID = $documents[0]->id;
                // $target_server = "https://api.au1.adobesign.com/api/rest/v6/agreements/".$agreementId."/documents/".$documentID;
                // $ch = curl_init();
                // $headers = array(
                //     'Authorization:Bearer 3AAABLblqZhCg9mzG-PNtjwRdqG6fK6YECiei7N8hrGdjiJif1BPZVhZHKpUPUyMXWuYWmp0e3v2Wudc2doWiXCr_X8w4LzmS',
                //     'Content-Type:application/json',
                // );
                // curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
                // // Set the URL of the server you want to fetch data from
                // curl_setopt($ch, CURLOPT_URL, $target_server);
                // // Set the cURL option to return the response as a string
                // curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                // // Execute the cURL request
                // $response = curl_exec($ch);
                // curl_close($ch);
                // $filename = '/signed.pdf';
                // file_put_contents($filename, $response);
                $connection = Tygh::$app['db'];
                $connection->query("UPDATE `cscart_order_contracts` SET state = 'signed', date_time = '".$completed."' where order_id=".$order_id);
                echo "success";
                exit;
            }
        }
        echo "failed";
        exit;
    }
    function exportPDF($customer_info){
        require_once('TCPDF/examples/tcpdf_include.php');

        // create new PDF document
        $pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);
        // set document information
        $pdf->setCreator(PDF_CREATOR);
        $pdf->setTitle('Order Contract');
        // set default monospaced font
        $pdf->setDefaultMonospacedFont(PDF_FONT_MONOSPACED);
        // set margins
        $pdf->setMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);
        $pdf->setHeaderMargin(PDF_MARGIN_HEADER);
        $pdf->setFooterMargin(PDF_MARGIN_FOOTER);
        // set auto page breaks
        // $pdf->setAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);
        // set image scale factor
        $pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);
        // set some language-dependent strings (optional)
        if (@file_exists(dirname(__FILE__).'/lang/eng.php')) {
            require_once(dirname(__FILE__).'/lang/eng.php');
            $pdf->setLanguageArray($l);
        }
        // set default font subsetting mode
        $pdf->setFontSubsetting(true);
        // Set font
        // dejavusans is a UTF-8 Unicode font, if you only need to
        // print standard ASCII chars, you can use core fonts like
        // helvetica or times to reduce file size.
        $pdf->setFont('dejavusans', '', 14, '', true);
        // Add a page
        // This method has several options, check the source code documentation for more information.
        $pdf->AddPage();

        // set text shadow effect
        $pdf->setTextShadow(array('enabled'=>true, 'depth_w'=>0.2, 'depth_h'=>0.2, 'color'=>array(196,196,196), 'opacity'=>1, 'blend_mode'=>'Normal'));

        // Set some content to print
        $html = <<<EOD
        <div style="font-size: 20px;">
        <div id="title" style="text-align: center;font-size: 40px;font-weight: bold;">Order Contract</div>
        <div style="padding: 5px; display: flex; justify-content:space-around;">
            <div>
            <span>First Name:</span><span>{$customer_info['firstname']}</span>
            </div>
            <div>
            <span>Last Name:</span><span>{$customer_info['lastname']}</span>
            </div>
        </div>
        <div style="padding: 5px; display: flex; justify-content:space-around;">
            <div>
            <span>Email:</span><span>{$customer_info['email']}</span>
            </div>
            <div>
            <span>Phone:</span><span>{$customer_info['phone']}</span>
            </div>
        </div>
        <div style="padding: 5px; display: flex; justify-content:space-around;">
            <div>
            <span>Country:</span><span>{$customer_info['b_country_descr']}</span>
            </div>
            <div>
            <span>City:</span><span>{$customer_info['b_city']}</span>
            </div>
        </div>
        <div style="padding: 5px; display: flex; justify-content:space-around;">
            <div>
            <span>Address:</span><span>{$customer_info['b_country_descr']}</span>
            </div>
            <div>
            <span>Zipcode:</span><span>{$customer_info['b_zipcode']}</span>
            </div>
        </div>
        <div style="height:40px; width:100%">
        </div>
        </div>
        EOD;
        // Print text using writeHTMLCell()
        $pdf->writeHTMLCell(0, 0, '', '', $html, 0, 1, 0, true, '', true);

        // ---------------------------------------------------------
        // Close and output PDF document
        // This method has several options, check the source code documentation for more information.
        // $pdf->Output('order_contract.pdf', 'I');
        $indexDir = dirname(__FILE__);
        $output_file = $indexDir.'/order_contract.pdf';
        // Output the PDF to a file
        $widgetRow = db_get_row('select * from cscart_order_contracts where order_id='.$_REQUEST['order_id']);
        if($widgetRow){
            $widgetId = $widgetRow['widgetId'];
            $target_server = 'https://api.au1.adobesign.com/api/rest/v6/widgets/'.$widgetId.'/formData';
            $ch = curl_init();
            $headers = array(
                'Authorization:Bearer 3AAABLblqZhCg9mzG-PNtjwRdqG6fK6YECiei7N8hrGdjiJif1BPZVhZHKpUPUyMXWuYWmp0e3v2Wudc2doWiXCr_X8w4LzmS',
                'Accept:application/json',
            );
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
            // Set the URL of the server you want to fetch data from
            curl_setopt($ch, CURLOPT_URL, $target_server);
            // Set the cURL option to return the response as a string
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            // Execute the cURL request
            $response = curl_exec($ch);
            curl_close($ch);
            $result = json_decode($response);
            if($result->formDataList){
                $completed = $result->formDataList->completed;
                if($completed != ''){
                    $pdf->Output('order_contract.pdf', 'I');
                    exit;
                }
            }
        }
        $pdf->Output($output_file, 'F');
        $target_server = "https://api.au1.adobesign.com/api/rest/v6/transientDocuments";

        if (file_exists($output_file)) {
            // Prepare the file data for upload
            $file_data = array(
                'File' => new CURLFile($output_file, 'application/pdf', 'order_contract.pdf'),
                'File-Name' => 'order_contract.pdf'
            );
            // Initialize cURL
            $ch = curl_init();

            // Set cURL options
            curl_setopt($ch, CURLOPT_URL, $target_server);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $file_data);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

            // Set the content-type in the request header
            $headers = array(
                'Authorization:Bearer 3AAABLblqZhCg9mzG-PNtjwRdqG6fK6YECiei7N8hrGdjiJif1BPZVhZHKpUPUyMXWuYWmp0e3v2Wudc2doWiXCr_X8w4LzmS',
                'x-api-user:email:sam@fight-club.com.au',
                'Content-Type:multipart/form-data',
                'Accept:application/json'
            );
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
            // Execute the cURL request
            $response = curl_exec($ch);

            //----------------------------------------------------------------

            // var_dump(json_decode($response));exit;
            $result = json_decode($response);
            $transientDocumentId = $result->transientDocumentId;
            curl_close($ch);
            $json_data = '{
            "fileInfos": [
                {
                "transientDocumentId": "'.$transientDocumentId.'"
                }
                ],
            "name": "Adobe Sign",
                "widgetParticipantSetInfo": {
                    "memberInfos": [{
                        "email": ""
                    }],
                "role": "SIGNER"
                },
                "state": "ACTIVE"
            }';
            $target_server = "https://api.au1.adobesign.com/api/rest/v6/widgets";
            $ch = curl_init();
        // Set cURL options
            curl_setopt($ch, CURLOPT_URL, $target_server);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $json_data);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

            // Set the content-type in the request header
            $headers = array(
                'Authorization:Bearer 3AAABLblqZhCg9mzG-PNtjwRdqG6fK6YECiei7N8hrGdjiJif1BPZVhZHKpUPUyMXWuYWmp0e3v2Wudc2doWiXCr_X8w4LzmS',
                'x-api-user:email:sam@fight-club.com.au',
                'Content-Type:application/json',
            );
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
            // Execute the cURL request
            $response = curl_exec($ch);
            $result = json_decode($response);
            curl_close($ch);
            // Close the cURL session
            //----------------------------------------------------------------
            $ch = curl_init();
            $target_server = "https://api.au1.adobesign.com/api/rest/v6/widgets";
            $headers = array(
                'Authorization:Bearer 3AAABLblqZhCg9mzG-PNtjwRdqG6fK6YECiei7N8hrGdjiJif1BPZVhZHKpUPUyMXWuYWmp0e3v2Wudc2doWiXCr_X8w4LzmS',
                'Accept:application/json',
            );
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
            // Set the URL of the server you want to fetch data from
            curl_setopt($ch, CURLOPT_URL, $target_server);
            // Set the cURL option to return the response as a string
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

            // Execute the cURL request
            $response = curl_exec($ch);
            $result = json_decode($response);
            curl_close($ch);
            $widgetList = $result->userWidgetList;
            $script = $widgetList[0]->javascript;
            $widgetId = $widgetList[0]->id;
            $connection = Tygh::$app['db'];
            $connection->query("delete from `cscart_order_contracts` where order_id=".$_REQUEST['order_id']);
            $connection->query("INSERT INTO `cscart_order_contracts` (
                `order_id`,
                `widgetId`,
                `state`
                )
                VALUES
                (
                    '".$_REQUEST['order_id']."',
                    '".$widgetId."',
                    'sign'
                );
            ");
            echo $script; exit;
        } else {
            echo "PDF file not found in the local server.";
        }
    }

