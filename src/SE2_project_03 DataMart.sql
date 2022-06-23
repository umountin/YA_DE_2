CREATE OR REPLACE VIEW public.shipping_datamart AS
SELECT
	i.shippingid,
	i.vendorid,
	t.transfer_type,
	DATE_PART('day', AGE(s.shipping_start_fact_datetime, s.shipping_end_fact_datetime)) AS full_day_at_shipping,
	CASE 
		WHEN shipping_end_fact_datetime > shipping_plan_datetime THEN 1
		ELSE NULL
	END AS is_delay,
	CASE
		WHEN s.status = 'finished' THEN 1
		ELSE 0
	END AS is_shipping_finish,
	CASE 
		WHEN s.shipping_end_fact_datetime > i.shipping_plan_datetime THEN EXTRACT (DAY FROM (s.shipping_end_fact_datetime - s.shipping_start_fact_datetime))
		ELSE 0
	END AS delay_day_at_shipping,
	i.payment_amount,
	i.payment_amount*(c.shipping_country_base_rate+a.agreement_rate+t.shipping_transfer_rate) AS vat,
	i.payment_amount*a.agreement_commission AS profit
FROM public.shipping_info i
LEFT JOIN public.shipping_transfer t ON t.transfer_type_id = i.transfer_type_id
LEFT JOIN public.shipping_status s ON s.shippingid = i.shippingid
LEFT JOIN public.shipping_country_rates c ON c.shipping_contry_id = i.shipping_contry_id
LEFT JOIN public.shipping_agreement a ON a.agreementid = i.agreementid;
