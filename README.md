# Проект 2

1. Анализ требований (цели, ключевые вопросы).
2. Анализ данных.

Структура проекта:
src/SE2_project_01 DDL.sql - DDL для новых таблиц
srce/SE2_project_02 Data Migration.sql - скрипт миграции данных
src/SE2_project_03 DataMart.sql - скрипт формирования представления

Что сделать: сделать миграцию в отдельные логические таблицы, а затем собрать на них витрину данных.

За какой период: ограничений по глубине данных нет. Обновление данных: не требуется. Дополнительные ограничения: нет.

Зачем:
1. оптимизация нагрузки на хранилище,
2. создание возможности строить анализ эффективности и прибыльности бизнеса.

Вопросы аналитиков:
- тарифы вендоров, 
- стоимость доставки в разные страны, 
- количестве доставленных заказов за последнюю неделю. 

Источник данных: таблица public.shipping.

Созданы таблицы с справочниками:
- public.shipping_country_rates - справочник стран и стоимости доставки в них (на основе данных из колонок shipping_country и shipping_country_base_rate в таблице public.shipping).
- public.shipping_agreement - справочник договоров с поставщиками и коммерческих условий (на основе данных из колонки vendor_agreement_description в таблице public.shipping).
- public.shipping_transfer - справочник форматов и стоимости доставок (на основе данных из колонок shipping_transfer_description и shipping_transfer_rate в таблице public.shipping).

Созданы таблицы с оперативными данными:
- public.shipping_info - таблица с информацией о заказах.
- public.shipping_status - таблица с информацией по текущим статусу и промежуточной точке заказа, а также фактические даты начала и завершения заказа
-- shipping_start_fact_datetime - фактическая дата начала заказа (когда state заказа в таблице public.shipping перешёл в состояние booked)
-- shipping_end_fact_datetime - фактическая дата завершения заказа (когда state заказа в таблице public.shipping перешёл в состояние recieved).

Создано представление public.shipping_datamart, в котором расчитаны следующие показатели:
- full_day_at_shipping — количество полных дней, в течение которых длилась доставка. Высчитывается как:shipping_end_fact_datetime-shipping_start_fact_datetime.
- is_delay — статус, показывающий просрочена ли доставка. Высчитывается как: shipping_end_fact_datetime > shipping_plan_datetime → 1 ; 0.
- is_shipping_finish — статус, показывающий, что доставка завершена. Если финальный status = finished → 1; 0.
- delay_day_at_shipping — количество дней, на которые была просрочена доставка. Высчитыается как: shipping_end_fact_datetime > shipping_end_plan_datetime → shipping_end_fact_datetime - shipping_plan_datetime ; 0.
- vat — итоговый налог на доставку. Высчитывается как: payment_amount * ( shipping_country_base_rate + agreement_rate + shipping_transfer_rate).
- profit — итоговый доход компании с доставки. Высчитывается как: payment_amount * agreement_commission.
