<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet SYSTEM	"ulang://i18n/constants.dtd:file">

<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'bonus']">
		<xsl:apply-templates select="//steps" />
		<form id="bonus_payment" method="post" action="do/">
			<h4>
				<xsl:text>&pay-by-bonuses;</xsl:text>
			</h4>
			<div style="margin:0 15px;">
				<p>&can-use-bonuses;</p>
				<xsl:text>&order-summ; </xsl:text>
				<xsl:value-of select="$currency-prefix" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="bonus/actual_total_price" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="$currency-suffix" />
				<xsl:text>.</xsl:text><br />
				<xsl:text> &available-bonuses; </xsl:text>
				<xsl:value-of select="$currency-prefix" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="bonus/available_bonus" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="$currency-suffix" />
				<xsl:text>.</xsl:text>
			</div>
			<div><label>&spend-bonuses; <xsl:value-of select="$currency-prefix" /><input type="text" name="bonus" /><xsl:value-of select="$currency-suffix" /></label></div>
			<div><input type="submit" value="&continue;" class="button big" /></div>
		</form>
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment']/bonus/@prefix">
		<xsl:value-of select="." />
		<xsl:text>&#160;</xsl:text>
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment']/bonus/@suffix">
		<xsl:text>&#160;</xsl:text>
		<xsl:value-of select="." />
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'choose']">
		<xsl:apply-templates select="//steps" />
		<form id="payment_choose" method="post">
			<xsl:attribute name="action"><xsl:value-of select="submit_url" /></xsl:attribute>
			<h4>
				<xsl:text>&payment-type;:</xsl:text>
			</h4>
			<script>
				<![CDATA[
					window.paymentId = null;
					jQuery('#payment_choose').submit(function(){
						if (window.paymentId) {
							var checkPaymentReceipt = function(id) {
								if (jQuery(':radio:checked','#payment_choose').attr('class') == 'receipt') {
									var url = "]]><xsl:value-of select="submit_url" /><![CDATA[";
									var win = window.open("", "_blank", "width=710,height=620,titlebar=no,toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=no");
									win.document.write("<html><head><" + "script" + ">location.href = '" + url + "?payment-id=" + id + "'</" + "script" + "></head><body></body></html>");
									win.focus();
									return false;
								}
							}
							return checkPaymentReceipt(window.paymentId);
						}
						else return true;
					});
				]]>
			</script>

			<xsl:apply-templates select="items/item" mode="payment" />

			<div>
				<input type="submit" value="&continue;" class="button big" />
			</div>
		</form>
	</xsl:template>

	<xsl:template match="item" mode="payment">
		<div>
			<label>
				<xsl:if test="(position() = 1) and (@type-name = 'receipt')">
					<script>
						window.paymentId = <xsl:value-of select="@id" />;
					</script>
				</xsl:if>
				<input type="radio" name="payment-id" class="{@type-name}" value="{@id}">
					<xsl:attribute name="onclick">
						<xsl:text>this.form.action = </xsl:text>
						<xsl:choose>
							<xsl:when test="@type-name != 'receipt'">
								<xsl:text>'</xsl:text>
								<xsl:value-of select="//submit_url" />
								<xsl:text>';</xsl:text>
							</xsl:when>
							<xsl:otherwise><xsl:text>'/emarket/ordersList/'; window.paymentId = '</xsl:text><xsl:value-of select="@id" /><xsl:text>';</xsl:text></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:if test="@active = 'active'">
						<xsl:attribute name="checked">
							<xsl:text>checked</xsl:text>
						</xsl:attribute>
					</xsl:if>
				</input>
				<xsl:value-of select="@name" />
			</label>
		</div>
	</xsl:template>

	<xsl:template match="item" mode="payment_one_step">
		<div>
			<label>
				<input type="radio" name="payment-id" class="{@type-name}" value="{@id}">
					<xsl:if test="@active = 'active'">
						<xsl:attribute name="checked">
							<xsl:text>checked</xsl:text>
						</xsl:attribute>
					</xsl:if>
				</input>
				<xsl:value-of select="@name" />
			</label>
		</div>
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'yandex30']">
		<form id="form_yandex30" action="{formAction}" method="post">
			<input type="hidden" name="shopId" value="{shopId}" />
			<input type="hidden" name="Sum" value="{Sum}" />
			<input type="hidden" name="BankId" value="{BankId}" />
			<input type="hidden" name="scid" value="{scid}" />
			<input type="hidden" name="CustomerNumber" value="{CustomerNumber}" />
			<input type="hidden" name="order-id" value="{orderId}" />
			<input type="hidden" name="PaymentType" value="" />
			<input type="hidden" name="PaymentTypeProvider" value="" />
			<input type="hidden" name="cms_name" value="umistand"/>
			<div class="inline">
				<xsl:apply-templates select="items/item" mode="payment-modes-yandex30" />
			</div>
			<div>
				<xsl:text>&payment-redirect-text; Yandex.</xsl:text>
			</div>
			<div>
				<input type="submit" value="Оплатить" class="button big" />
			</div>
		</form>
		<script>
			var elements = document.getElementById('form_yandex30').elements;
			elements.mode_type.value = '';
			function change(type, subtype) {
				elements.PaymentType.value = type;
				elements.PaymentTypeProvider.value = subtype;
			}
		</script>
	</xsl:template>

	<xsl:template match="item" mode="payment-modes-yandex30">
		<label><input type="radio" name="mode_type" value="{id}" onChange="javascript:change('{type}', '{subtype}');"/><xsl:value-of select="label"/></label>
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'acquiropay']">
		<form method="post" action="{formAction}">
			<input type="hidden" name="product_id" value="{product_id}" />
			<input type="hidden" name="amount" value="{amount}" />
			<input type="hidden" name="language" value="{language}" />
			<input type="hidden" name="cf" value="{order_id}" />
			<input type="hidden" name="ok_url" value="{ok_url}" />
			<input type="hidden" name="cb_url" value="{cb_url}" />
			<input type="hidden" name="ko_url" value="{ko_url}" />
			<input type="hidden" name="token" value="{token}" />
			<div>
				<xsl:text>&payment-redirect-text; AcquiroPay.</xsl:text>
			</div>
			<div>
				<input type="submit" value="&pay;" class="button big" />
			</div>
		</form>
		<xsl:call-template name="form-send" />
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'chronopay']">
		<form method="post" action="{formAction}">
			<input type="hidden" name="product_id" value="{product_id}" />
			<input type="hidden" name="product_name" value="{product_name}" />
			<input type="hidden" name="product_price" value="{product_price}" />
			<input type="hidden" name="language" value="{language}" />
			<input type="hidden" name="cs1" value="{cs1}" />
			<input type="hidden" name="cs2" value="{cs2}" />
			<input type="hidden" name="cs3" value="{cs3}" />
			<input type="hidden" name="cb_type" value="{cb_type}" />
			<input type="hidden" name="cb_url" value="{cb_url}" />
			<input type="hidden" name="decline_url" value="{decline_url}" />
			<input type="hidden" name="sign" value="{sign}" />

			<div>
				<xsl:text>&payment-redirect-text; Chronopay.</xsl:text>
			</div>

			<div>
				<input type="submit" value="&pay;" class="button big" />
			</div>
		</form>
		<xsl:call-template name="form-send" />
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'yandex']">
		<form action="{formAction}" method="post">
			<input type="hidden" name="shopId"	value="{shopId}" />
			<input type="hidden" name="Sum"		value="{Sum}" />
			<input type="hidden" name="BankId"	value="{BankId}" />
			<input type="hidden" name="scid"	value="{scid}" />
			<input type="hidden" name="CustomerNumber" value="{CustomerNumber}" />
			<input type="hidden" name="order-id" value="{orderId}" />

			<div>
				<xsl:text>&payment-redirect-text; Yandex.</xsl:text>
			</div>

			<div>
				<input type="submit" value="&pay;" class="button big" />
			</div>
		</form>
		<xsl:call-template name="form-send" />
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'payonline']">
		<form action="{formAction}" method="post">

			<input type="hidden" name="MerchantId" 	value="{MerchantId}" />
			<input type="hidden" name="OrderId" 	value="{OrderId}" />
			<input type="hidden" name="Currency" 	value="{Currency}" />
			<input type="hidden" name="SecurityKey" value="{SecurityKey}" />
			<input type="hidden" name="ReturnUrl" 	value="{ReturnUrl}" />
			<!-- NB! This field should exist for proper system working -->
			<input type="hidden" name="order-id"    value="{orderId}" />
			<input type="hidden" name="Amount" value="{Amount}" />

			<div>
				<xsl:text>&payment-redirect-text; PayOnline.</xsl:text>
			</div>

			<div>
				<input type="submit" value="&pay;" class="button big" />
			</div>
		</form>
		<xsl:call-template name="form-send" />
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'robox']">
		<form action="{formAction}" method="post">
			<input type="hidden" name="MrchLogin" value="{MrchLogin}" />
			<input type="hidden" name="OutSum"	  value="{OutSum}" />
			<input type="hidden" name="InvId"	  value="{InvId}" />
			<input type="hidden" name="Desc"	  value="{Desc}" />
			<input type="hidden" name="SignatureValue" value="{SignatureValue}" />
			<input type="hidden" name="IncCurrLabel"   value="{IncCurrLabel}" />
			<input type="hidden" name="Culture"   value="{Culture}" />
			<input type="hidden" name="shp_orderId" value="{shp_orderId}" />

			<div>
				<xsl:text>&payment-redirect-text; Robox.</xsl:text>
			</div>

			<div>
				<input type="submit" value="&pay;" class="button big" />
			</div>
		</form>
		<xsl:call-template name="form-send" />
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'liqpay']">
		<xsl:value-of select="form_html" disable-output-escaping="yes" />

		<xsl:call-template name="form-send" />
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'rbk']">
		<form action="{formAction}" method="post">
			<input type="hidden" name="eshopId" value="{eshopId}" />
			<input type="hidden" name="orderId"	value="{orderId}" />
			<input type="hidden" name="recipientAmount"	value="{recipientAmount}" />
			<input type="hidden" name="recipientCurrency" value="{recipientCurrency}" />
			<input type="hidden" name="version" value="{version}" />

			<div>
				<xsl:text>&payment-redirect-text; RBK Money.</xsl:text>
			</div>

			<div>
				<input type="submit" value="&pay;" class="button big" />
			</div>
		</form>
		<xsl:call-template name="form-send" />
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'kupivkredit'][@action = 'widget']">
		<xsl:choose>
			<xsl:when test="./@test-mode">
				<script src="https://kupivkredit-test-fe.tcsbank.ru/widget/vkredit.js"></script>
			</xsl:when>
			<xsl:otherwise>
				<script src="https://www.kupivkredit.ru/widget/vkredit.js"></script>
			</xsl:otherwise>
		</xsl:choose>
		<script>
			jQuery(document).ready(function() {
			<![CDATA[
			function widgetOpen(order, sig, price) {
				vKredit = new VkreditWidget(1, price, {
					order: order,
					sig: sig,
					onClose: function() {
						window.location.assign("/emarket/purchase/payment/choose/");
					},
					onAccept: function(accepted) {
						if(accepted == 1) {
							window.location.assign("/emarket/purchase/payment/kupivkredit/?accepted=accepted");
						} else {
							window.location.assign("/emarket/purchase/payment/choose/");
					}

					}
				});

				vKredit.openWidget();
			}
		]]>
			widgetOpen("<xsl:value-of select="order" />", "<xsl:value-of select="sig" />", <xsl:value-of select="totalPrice" />);
		});
		</script>
		<xsl:apply-templates select="//steps" />
		<h4>&in-progress;</h4>
		<p>&credit-request;</p>
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'kupivkredit'][@action = 'declined']">
		<xsl:apply-templates select="//steps" />
		<h4>&error;</h4>
		<p>&credit-canceled;</p>
		<p><a href="/emarket/purchase/payment">&select-payment;</a></p>
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'kupivkredit'][@action = 'error']">
		<xsl:apply-templates select="//steps" />
		<h4>&error;</h4>
		<p>&order-error;</p>
		<p><a href="/emarket/purchase/payment">&select-payment;</a></p>
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'payanyway']">
		<form action="{formAction}" method="post">
            <input type="hidden" name="MNT_ID" value="{mntId}" />
            <input type="hidden" name="MNT_TRANSACTION_ID" value="{mnTransactionId}" />
            <input type="hidden" name="MNT_CURRENCY_CODE" value="{mntCurrencyCode}" />
            <input type="hidden" name="MNT_AMOUNT" value="{mntAmount}" />
            <input type="hidden" name="MNT_TEST_MODE" value="{mntTestMode}" />
            <input type="hidden" name="MNT_SIGNATURE" value="{mntSignature}" />
            <input type="hidden" name="MNT_SUCCESS_URL" value="{mntSuccessUrl}" />
            <input type="hidden" name="MNT_FAIL_URL" value="{mntFailUrl}" />

			<div>
				<xsl:text>&payment-redirect-text; PayAnyWay.</xsl:text>
			</div>

			<div>
				<input type="submit" value="&pay;" class="button big" />
			</div>
		</form>
		<xsl:call-template name="form-send" />
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'dengionline']">
		<xsl:apply-templates select="//steps" />
		<form class="width_100" action="{formAction}" method="post">
			<h4>
				<xsl:text>&payment-type;:</xsl:text>
			</h4>
			<input type="hidden" name="project" value="{project}" />
			<input type="hidden" name="amount" value="{amount}" />
			<input type="hidden" name="nickname" value="{order_id}" />
			<input type="hidden" name="source" value="{source}" />
			<input type="hidden" name="order_id" value="{order_id}" />
			<input type="hidden" name="comment" value="{comment}" />
			<input type="hidden" name="paymentCurrency" value="{paymentCurrency}" />
			<div class="inline">
				<xsl:apply-templates select="items/item[position() mod 3 = 1]" mode="payment-modes" />
			</div>
			<div class="inline">
				<xsl:apply-templates select="items/item[position() mod 3 = 2]" mode="payment-modes" />
			</div>
			<div class="inline">
				<xsl:apply-templates select="items/item[position() mod 3 = 0]" mode="payment-modes" />
			</div>
			<div>
				<input type="submit" value="&pay;" class="button big" />
			</div>
		</form>
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'paypal']">
		<xsl:apply-templates select="//steps" />
		<form class="width_100" action="{formAction}" method="post">
			<input type="hidden" name="cmd" value="_xclick" />
			<input type="hidden" name="business" value="{paypalemail}" />
			<input type="hidden" name="item_name" value="Payment for order #{order_id}" />
			<input type="hidden" name="item_number" value="{order_id}" />
			<input type="hidden" name="amount" value="{total}" />
			<input type="hidden" name="no_shipping" value="1" />
			<input type="hidden" name="return" value="{return_success}" />
			<input type="hidden" name="rm" value="2" />
			<input type="hidden" name="cancel_return" value="{cancel_return}" />
			<input type="hidden" name="notify_url" value="{notify_url}" />
			<input type="hidden" name="currency_code" value="{currency}" />

			<div>
				<xsl:text>&payment-redirect-text; PayPal.</xsl:text>
			</div>

			<div>
				<input type="submit" value="&pay;" class="button big" />
			</div>
		</form>
	</xsl:template>

	<xsl:template match="item" mode="payment-modes">
		<label><input type="radio" name="mode_type" value="{id}"/><xsl:value-of select="label"/></label>
	</xsl:template>

	<xsl:template match="purchasing[@stage = 'payment'][@step = 'invoice']" xmlns:xlink="http://www.w3.org/TR/xlink">
		<xsl:apply-templates select="//steps" />
		<form id="invoice" method="post" action="do">
			<xsl:apply-templates select="items" mode="legal-person" />
			<div>
				<input type="submit" value="&make-bill;" class="button big" />
			</div>
		</form>
		<script>
			jQuery('#invoice').submit(function(){
				var input = jQuery('input:radio:checked', this);
				if (typeof input.val() == 'undefined' || input.val() == 'new') {
					if (typeof input.val() == 'undefined') {
						jQuery('input:radio[value=new]', this).attr('checked','checked');
					}
					return site.forms.data.check(this);
				}
			});
		</script>
	</xsl:template>

	<xsl:template match="items" mode="legal-person" xmlns:xlink="http://www.w3.org/TR/xlink">
		<input type="hidden" name="legal-person" value="new" />
		<xsl:apply-templates select="document(../@xlink:href)//field" mode="form" />
	</xsl:template>

	<xsl:template match="items[count(item) &gt; 0]" mode="legal-person" xmlns:xlink="http://www.w3.org/TR/xlink">
		<h4>
			<xsl:text>&choose-legal_person;:</xsl:text>
		</h4>
		<xsl:apply-templates select="item" mode="legal-person" />

		<div>
			<label>
				<input type="radio" name="legal-person" value="new" />
				<xsl:text>&new-legal-person;</xsl:text>
			</label>
		</div>

		<div id="new-legal-person">
			<xsl:apply-templates select="document(../@xlink:href)//field" mode="form" />
		</div>

	</xsl:template>

	<xsl:template match="item" mode="legal-person"  xmlns:xlink="http://www.w3.org/TR/xlink">
		<div class="form_element">
			<label>
				<input type="radio" name="legal-person" value="{@id}">
					<xsl:if test="position() = 1">
						<xsl:attribute name="checked">
							<xsl:text>checked</xsl:text>
						</xsl:attribute>
					</xsl:if>
				</input>
				<xsl:value-of select="@name" />
			</label>
		</div>
	</xsl:template>
	
	<xsl:template name="form-send">
		<script>
			jQuery('body').hide(0, function() {
				jQuery(document).ready(function(){
					jQuery('.center form').get(0).submit();
				});
			});
		</script>
	</xsl:template>

</xsl:stylesheet>
