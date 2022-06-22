DROP TABLE IF EXISTS public.shipping_info;
DROP TABLE IF EXISTS public.shipping_status;
DROP TABLE IF EXISTS public.shipping_country_rates;
DROP TABLE IF EXISTS public.shipping_agreement;
DROP TABLE IF EXISTS public.shipping_transfer;

CREATE TABLE public.shipping_country_rates (
	shipping_contry_id serial4 NOT NULL,
	shipping_country varchar(16) NULL,
	shipping_country_base_rate numeric(14, 3) NULL,
	CONSTRAINT shipping_country_rates_pkey PRIMARY KEY (shipping_contry_id)
);
CREATE TABLE public.shipping_agreement (
	agreementid int8 NOT NULL,
	agreement_number varchar(16) NULL,
	agreement_rate numeric(14, 3) NULL,
	agreement_commission numeric(14, 3) NULL,
	CONSTRAINT shipping_agreement_pkey PRIMARY KEY (agreementid)
);
CREATE INDEX shipping_agreement_index ON public.shipping_agreement(agreementid);
CREATE TABLE public.shipping_transfer (
	transfer_type_id serial4 NOT NULL,
	transfer_type varchar(2) NULL,
	transfer_model varchar(9) NULL,
	shipping_transfer_rate numeric(14, 3) NULL,
	CONSTRAINT shipping_transfer_pkey PRIMARY KEY (transfer_type_id)
);
CREATE TABLE public.shipping_info (
	shippingid int8 NOT NULL,
	vendorid int8 NULL,
	payment_amount numeric(14, 2) NULL,
	shipping_plan_datetime timestamp NULL,
	transfer_type_id bigint NULL,
	shipping_contry_id bigint NULL,
	agreementid bigint NULL,
	CONSTRAINT shipping_info_pkey PRIMARY KEY (shippingid),
	CONSTRAINT shipping_info_transfer_type FOREIGN KEY (transfer_type_id) REFERENCES public.shipping_transfer(transfer_type_id) ON UPDATE CASCADE,
	CONSTRAINT shipping_info_shipping_contry FOREIGN KEY (shipping_contry_id) REFERENCES public.shipping_country_rates(shipping_contry_id) ON UPDATE CASCADE,
	CONSTRAINT shipping_info_agreement FOREIGN KEY (agreementid) REFERENCES public.shipping_agreement (agreementid) ON UPDATE CASCADE
);
CREATE INDEX shipping_info_index ON public.shipping_info(shippingid);
CREATE TABLE public.shipping_status (
	shippingid int8 NOT NULL,
	status varchar(11) NULL,
	state varchar(11) NULL,
	shipping_start_fact_datetime timestamp NULL,
	shipping_end_fact_datetime timestamp NULL,
	CONSTRAINT shipping_status_pkey PRIMARY KEY (shippingid)
);
CREATE INDEX shipping_status_index ON public.shipping_status(shippingid);