<?php
include 'standalone.php';

if(isset($_POST['signature']) && isset($_POST['data'])) {
    // Указать сюда id способа оплаты модуля ИМ,
    // чтобы вытянуть $public_key и $private_key
    $pay = umiObjectsCollection::getInstance()->getObject(1272);

    $public_key = $pay->getValue('public_key');
    $private_key = $pay->getValue('private_key');

    $liq_pay_data = json_decode(base64_decode($_POST['data']), TRUE);
    $sign = base64_encode(sha1( $private_key . $_POST['data'] . $private_key, 1));

    if($liq_pay_data['status'] == 'sandbox' or $liq_pay_data['status'] == 'success') {
        // Обязательно, иначе класс order не подключится!!!
        cmsController::getInstance()->getModule("emarket");

        $order = order::get($liq_pay_data['order_id']);

        $order->setOrderStatus('ready');
        $order->setPaymentStatus('accepted');
    }
}
?>