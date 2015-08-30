<?php
class liqpayPayment extends payment {

	public function validate() {
		// Запрещаем оплату с помощью ,
		// если сумма заказа меньше 1 грн.
		$sum = (float) $this->order->getActualPrice();
		if($sum < 1) {
			return false;
		}

		return true;
	}

	public function process($template = null) {
		$order = $this->order;
		$order->order();
		$order->setPaymentStatus('initialized'); // Ставим заказу статус "инициализирована оплата"

		// Загружаем API класс LiqPay
		objectProxyHelper::includeClass('emarket/classes/payment/api/', 'LiqPay');

		$liqpay = new LiqPay($this->getValue('public_key'), $this->getValue('private_key'));

		$sandbox_status = 0;
		if($this->getValue('sandbox_status')) $sandbox_status = 1;

		$domain = $_SERVER['HTTP_HOST'];

		$html = $liqpay->cnb_form(array(
			'version'        => '3',
			'sandbox'        => $sandbox_status,
			'amount'         => $order->getActualPrice(),
			'currency'       => $this->getValue('currency'),
			'description'    => $this->getValue('desc'),
			'pay_way'        => $this->getValue('pay_way'),
			'order_id'       => $order->getId(),
			'type'           => 'buy',
			'result_url'     => $domain . '/emarket/purchase/result/successful/?order_id='.$order->getId().'&amp;order_type=liq_pay',
		));

		$param = array();
		$param['form_html'] = $html;

		list($templateString) = def_module::loadTemplates("emarket/payment/liqpay/".$template, "form_block");

		return def_module::parseTemplate($templateString, $param);
	}

	public function poll() {
		$buffer = outputBuffer::current();
		$buffer->clear();
		$buffer->contentType('text/plain');
		$buffer->push('Sorry, but this payment system doesn\'t support server polling.' . getRequest('param0'));
		$buffer->end();
	}

};
?>
