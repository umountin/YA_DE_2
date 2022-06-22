INSERT INTO public.shipping_country_rates (shipping_country, shipping_country_base_rate)
SELECT 
	DISTINCT shipping_country,
	shipping_country_base_rate
FROM public.shipping;
INSERT INTO public.shipping_agreement
SELECT 
	DISTINCT vdesc[1]::int8 AS agreementid,
	vdesc[2]::varchar(16) AS agreement_number,
	vdesc[3]::numeric(14,3) AS agreement_rate,
	vdesc[4]::numeric(14,3) AS agreement_commission
FROM 
(
	SELECT
		regexp_split_to_array(vendor_agreement_description, E'\\:+') AS vdesc
	FROM public.shipping
) q
ORDER BY agreementid;
INSERT INTO public.shipping_transfer (transfer_type, transfer_model, shipping_transfer_rate)
SELECT 
	sdesc[1]::varchar(2) AS transfer_type,
	sdesc[2]::varchar(9) AS transfer_model,
	shipping_transfer_rate
FROM 
(
	SELECT
		DISTINCT shipping_transfer_rate,
		regexp_split_to_array(shipping_transfer_description, E'\\:+') AS sdesc
	FROM public.shipping
) q;
INSERT INTO public.shipping_info
SELECT 
	q.shippingid,
	q.vendorid,
	q.payment_amount,
	q.shipping_plan_datetime,
	qt.transfer_type_id,
	qc.shipping_contry_id,
	qa.agreementid
FROM 
(
	SELECT
		DISTINCT shippingid,
		vendorid,
		payment_amount,
		shipping_plan_datetime,
		regexp_split_to_array(shipping_transfer_description, E'\\:+') AS sdesc,
		shipping_country,
		regexp_split_to_array(vendor_agreement_description, E'\\:+') AS vdesc
	FROM public.shipping
) q
LEFT JOIN public.shipping_transfer qt ON qt.transfer_type = q.sdesc[1]::varchar(2) AND qt.transfer_model = q.sdesc[2]::varchar(9)
LEFT JOIN public.shipping_country_rates qc ON qc.shipping_country = q.shipping_country
LEFT JOIN public.shipping_agreement qa ON qa.agreementid = q.vdesc[1]::int8;
INSERT INTO public.shipping_status
WITH q AS (
	SELECT
		shippingid,
		status,
		state,
		ROW_NUMBER() OVER (PARTITION BY shippingid ORDER BY state_datetime DESC) AS row_num
	FROM public.shipping
),
qs AS (
	SELECT
		shippingid,
		state_datetime AS shipping_start_fact_datetime
	FROM public.shipping
	WHERE state = 'booked'
),
qe AS (
	SELECT
		shippingid,
		state_datetime AS shipping_end_fact_datetime
	FROM public.shipping
	WHERE state = 'recieved'
)
SELECT
	q.shippingid,
	q.status,
	q.state,
	qs.shipping_start_fact_datetime,
	qe.shipping_end_fact_datetime
FROM q
LEFT JOIN qs ON qs.shippingid = q.shippingid
LEFT JOIN qe ON qe.shippingid = q.shippingid
WHERE q.row_num = 1;
