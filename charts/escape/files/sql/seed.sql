-- Locksmith industry seed data for local Docker testing.
--
-- Load from the backend repo root with:
-- docker compose exec -T db psql -U postgres -d escape < sql/locksmith_seed_data.sql
--
-- The seed is intentionally idempotent: it deletes only the demo keys below,
-- then recreates a connected customer, dispatch, invoice, inventory, vendor,
-- employee, purchase order, and permission dataset.
--
-- EXPANDED VERSION: 5x the records for more realistic testing.

BEGIN;

SET search_path TO exp_tables, public;

CREATE TABLE IF NOT EXISTS exp_tables.color (
 id integer PRIMARY KEY,
 name character varying(30) NOT NULL UNIQUE,
 foreground character varying(7) NOT NULL,
 background character varying(7) NOT NULL,
 UNIQUE (name, foreground, background)
);

DO $$
BEGIN
 IF to_regclass('public.permission_urlpermission') IS NOT NULL THEN
 DELETE FROM public.permission_urlpermission
 WHERE group_name = 'admin' AND database = 'cls' AND url IN ('*', '/api/cls/*');

 INSERT INTO public.permission_urlpermission (group_name, url, allowed, database)
 VALUES ('admin', '/api/cls*', true, 'cls')
 ON CONFLICT (group_name, url, database)
 DO UPDATE SET allowed = EXCLUDED.allowed;
 END IF;

 IF to_regclass('public.permission_modelpermission') IS NOT NULL THEN
 INSERT INTO public.permission_modelpermission (group_name, model_name, allowed, database)
 VALUES ('admin', '*', true, 'cls')
 ON CONFLICT (group_name, model_name, database)
 DO UPDATE SET allowed = EXCLUDED.allowed;
 END IF;
END $$;

DELETE FROM exp_tables.invrec WHERE ponum IN ('000000000000101', '000000000000102', '000000000000103', '000000000000104', '000000000000105');
DELETE FROM exp_tables.poled WHERE po IN ('000000000000101', '000000000000102', '000000000000103', '000000000000104', '000000000000105');
DELETE FROM exp_tables.po WHERE po IN ('000000000000101', '000000000000102', '000000000000103', '000000000000104', '000000000000105');
DELETE FROM exp_tables.salesled WHERE invoice IN ('0000002001', '0000002002', '0000002003', '0000002004', '0000002005', '0000002006', '0000002007', '0000002008', '0000002009', '0000002010', '0000002011', '0000002012', '0000002013', '0000002014', '0000002015');
DELETE FROM exp_tables.salesemp WHERE invoice IN ('0000002001', '0000002002', '0000002003', '0000002004', '0000002005', '0000002006', '0000002007', '0000002008', '0000002009', '0000002010', '0000002011', '0000002012', '0000002013', '0000002014', '0000002015');
DELETE FROM exp_tables.sales WHERE invoice IN ('0000002001', '0000002002', '0000002003', '0000002004', '0000002005', '0000002006', '0000002007', '0000002008', '0000002009', '0000002010', '0000002011', '0000002012', '0000002013', '0000002014', '0000002015');
DELETE FROM exp_tables.disptech WHERE dispatch IN ('000101', '000102', '000103', '000104', '000105', '000106', '000107', '000108', '000109', '000110', '000111', '000112', '000113', '000114', '000115');
DELETE FROM exp_tables.dispparts WHERE dispatch IN ('000101', '000102', '000103', '000104', '000105', '000106', '000107', '000108', '000109', '000110', '000111', '000112', '000113', '000114', '000115');
DELETE FROM exp_tables.dispatch WHERE dispatch IN ('000101', '000102', '000103', '000104', '000105', '000106', '000107', '000108', '000109', '000110', '000111', '000112', '000113', '000114', '000115');
DELETE FROM exp_tables.jobs WHERE jobid IN ('job-demo-clinic-rekey', 'job-demo-cafe-safe', 'job-demo-property-access', 'job-demo-office-master', 'job-demo-retail-rekey', 'job-demo-warehouse-audit', 'job-demo-school-master', 'job-demo-condo-fob', 'job-demo-bank-vault', 'job-demo-gym-lockers', 'job-demo-pharmacy-safe', 'job-demo-mall-access', 'job-demo-airport-tsa', 'job-demo-hotel-rekey', 'job-demo-mfg-access');
DELETE FROM exp_tables.customercontacts WHERE custno IN ('0001001', '0001002', '0001003', '0001004', '0001005', '0001006', '0001007', '0001008', '0001009', '0001010', '0001011', '0001012', '0001013', '0001014', '0001015');
DELETE FROM exp_tables.location WHERE custno IN ('0001001', '0001002', '0001003', '0001004', '0001005', '0001006', '0001007', '0001008', '0001009', '0001010', '0001011', '0001012', '0001013', '0001014', '0001015');
DELETE FROM exp_tables.customer WHERE custno IN ('0001001', '0001002', '0001003', '0001004', '0001005', '0001006', '0001007', '0001008', '0001009', '0001010', '0001011', '0001012', '0001013', '0001014', '0001015');
DELETE FROM exp_tables.invrec WHERE part IN ('LABOR-COMM', 'TRIP-LOCAL', 'TRIP-AFTERHRS', 'TRIP-REMOTE', 'TRIP-EMERGENCY', 'PART-DEADBOLT-GRADE1', 'PART-DEADBOLT-GRADE2', 'PART-SFIC-CORE', 'PART-IC-CORE', 'PART-KEY-SCHLAGE', 'PART-KEY-KWIKSET', 'PART-KEYPAD-LOCK', 'PART-KEYPAD-MORTISE', 'PART-SAFE-DIAL', 'PART-SAFE-ELECTRONIC', 'PART-MAGLOCK', 'PART-STRIKE-EL', 'PART-READER-PROX', 'PART-READER-BIO', 'PART-CAMERA-DOME', 'PART-CAMERA-BULLET', 'PART-PANIC-BAR', 'PART-CLOSER-GRADE1', 'PART-HINGE-BB', 'PART-THRESHOLD', 'PART-WEATHERSTRIP', 'PART-KEY-BLANK-ASSORTED', 'PART-KEY-BLANK-HIGHSEC', 'PART-TOOL-PICK-SET', 'PART-TOOL-DRILL-KIT', 'PART-TOOL-INSTALL-KIT', 'PART-TOOL-DIAGNOSTIC', 'PART-TOOL-KEY-MACHINE', 'PART-TOOL-SAFE-DRILL', 'PART-BATTERY-CR123', 'PART-BATTERY-AA-LITHIUM');
DELETE FROM exp_tables.invquan WHERE part IN ('LABOR-COMM', 'TRIP-LOCAL', 'TRIP-AFTERHRS', 'TRIP-REMOTE', 'TRIP-EMERGENCY', 'PART-DEADBOLT-GRADE1', 'PART-DEADBOLT-GRADE2', 'PART-SFIC-CORE', 'PART-IC-CORE', 'PART-KEY-SCHLAGE', 'PART-KEY-KWIKSET', 'PART-KEYPAD-LOCK', 'PART-KEYPAD-MORTISE', 'PART-SAFE-DIAL', 'PART-SAFE-ELECTRONIC', 'PART-MAGLOCK', 'PART-STRIKE-EL', 'PART-READER-PROX', 'PART-READER-BIO', 'PART-CAMERA-DOME', 'PART-CAMERA-BULLET', 'PART-PANIC-BAR', 'PART-CLOSER-GRADE1', 'PART-HINGE-BB', 'PART-THRESHOLD', 'PART-WEATHERSTRIP', 'PART-KEY-BLANK-ASSORTED', 'PART-KEY-BLANK-HIGHSEC', 'PART-TOOL-PICK-SET', 'PART-TOOL-DRILL-KIT', 'PART-TOOL-INSTALL-KIT', 'PART-TOOL-DIAGNOSTIC', 'PART-TOOL-KEY-MACHINE', 'PART-TOOL-SAFE-DRILL', 'PART-BATTERY-CR123', 'PART-BATTERY-AA-LITHIUM');
DELETE FROM exp_tables.venparts WHERE part IN ('PART-DEADBOLT-GRADE1', 'PART-DEADBOLT-GRADE2', 'PART-SFIC-CORE', 'PART-IC-CORE', 'PART-KEY-SCHLAGE', 'PART-KEY-KWIKSET', 'PART-KEYPAD-LOCK', 'PART-KEYPAD-MORTISE', 'PART-SAFE-DIAL', 'PART-SAFE-ELECTRONIC', 'PART-MAGLOCK', 'PART-STRIKE-EL', 'PART-READER-PROX', 'PART-READER-BIO', 'PART-CAMERA-DOME', 'PART-CAMERA-BULLET', 'PART-PANIC-BAR', 'PART-CLOSER-GRADE1', 'PART-HINGE-BB', 'PART-THRESHOLD', 'PART-WEATHERSTRIP', 'PART-KEY-BLANK-ASSORTED', 'PART-KEY-BLANK-HIGHSEC', 'PART-TOOL-PICK-SET', 'PART-TOOL-DRILL-KIT', 'PART-TOOL-INSTALL-KIT', 'PART-TOOL-DIAGNOSTIC', 'PART-TOOL-KEY-MACHINE', 'PART-TOOL-SAFE-DRILL', 'PART-BATTERY-CR123', 'PART-BATTERY-AA-LITHIUM');
DELETE FROM exp_tables.inven WHERE part IN ('LABOR-COMM', 'TRIP-LOCAL', 'TRIP-AFTERHRS', 'TRIP-REMOTE', 'TRIP-EMERGENCY', 'PART-DEADBOLT-GRADE1', 'PART-DEADBOLT-GRADE2', 'PART-SFIC-CORE', 'PART-IC-CORE', 'PART-KEY-SCHLAGE', 'PART-KEY-KWIKSET', 'PART-KEYPAD-LOCK', 'PART-KEYPAD-MORTISE', 'PART-SAFE-DIAL', 'PART-SAFE-ELECTRONIC', 'PART-MAGLOCK', 'PART-STRIKE-EL', 'PART-READER-PROX', 'PART-READER-BIO', 'PART-CAMERA-DOME', 'PART-CAMERA-BULLET', 'PART-PANIC-BAR', 'PART-CLOSER-GRADE1', 'PART-HINGE-BB', 'PART-THRESHOLD', 'PART-WEATHERSTRIP', 'PART-KEY-BLANK-ASSORTED', 'PART-KEY-BLANK-HIGHSEC', 'PART-TOOL-PICK-SET', 'PART-TOOL-DRILL-KIT', 'PART-TOOL-INSTALL-KIT', 'PART-TOOL-DIAGNOSTIC', 'PART-TOOL-KEY-MACHINE', 'PART-TOOL-SAFE-DRILL', 'PART-BATTERY-CR123', 'PART-BATTERY-AA-LITHIUM');
DELETE FROM exp_tables.invscat WHERE cat IN ('LOCKS', 'KEYS', 'SAFE', 'ACCESS', 'HARDWARE', 'TOOLS', 'ELECTRONIC', 'BATTERIES');
DELETE FROM exp_tables.invcat WHERE cat IN ('LOCKS', 'KEYS', 'SAFE', 'ACCESS', 'HARDWARE', 'TOOLS', 'ELECTRONIC', 'BATTERIES');
DELETE FROM exp_tables.vendorlocations WHERE vendor IN ('ALGO', 'MULK', 'AMSE', 'KABA', 'HIDG', 'ASSA', 'YALE', 'DETE', 'STAN', 'HES', 'SARG', 'CORB', 'FALC', 'MED', 'SECU');
DELETE FROM exp_tables.vendor WHERE vendor IN ('ALGO', 'MULK', 'AMSE', 'KABA', 'HIDG', 'ASSA', 'YALE', 'DETE', 'STAN', 'HES', 'SARG', 'CORB', 'FALC', 'MED', 'SECU');
DELETE FROM exp_tables.employee WHERE empno IN ('0001', '0002', '0003', '0004', '0005', '0006', '0007', '0008', '0009', '0010', '0011', '0012', '0013', '0014', '0015');
DELETE FROM exp_tables.users WHERE "user" IN ('ADMIN', 'AVA', 'MASON', 'LENA', 'JORDAN', 'RILEY', 'CASEY', 'QUINN', 'SKYLER', 'DREW', 'REMI', 'TAYLOR', 'ALEX', 'JAMIE', 'MORGAN');
DELETE FROM exp_tables.counter WHERE name IN ('Customer', 'Dispatch', 'Employee', 'Invoice', 'PO', 'GJ');
DELETE FROM exp_tables.dispatchpriority WHERE name IN ('HIGH', 'STD', 'LOW', 'EMRG', 'RUSH');
DELETE FROM exp_tables.dispatchtype WHERE name IN ('SERV', 'SAFE', 'INST', 'ACCS', 'EMRG', 'CONS');
DELETE FROM exp_tables.taxcodes WHERE code IN ('GST5', 'NONE', 'GSTHST', 'PST7', 'GSTPST');
DELETE FROM exp_tables.creditratings WHERE name IN ('A', 'B', 'C', 'COD');
DELETE FROM exp_tables.terms WHERE term IN ('Due on Receipt', 'Net 15', 'Net 30', 'Net 45', 'Net 60', '2/10 Net 30');
DELETE FROM exp_tables.warehous WHERE wh IN ('0001', '0002', '0003', '0004', '0005', '0006', '0007', '0008', '0009', '0010');
DELETE FROM exp_tables.sldept WHERE dept IN ('SV', 'SA', 'IN', '10', '20', '30', '40', '50', '60');
DELETE FROM exp_tables.findept WHERE dept IN ('SV', 'SA', 'IN', '10', '20', '30', '40', '50', '60');
DELETE FROM exp_tables.findiv WHERE div = '01';
DELETE FROM exp_tables.fingroup WHERE "group" IN ('AR', 'SALE', 'COGS', 'INV');
DELETE FROM exp_tables.finperiod WHERE periodid = '202605';
DELETE FROM exp_tables.finfiscal WHERE fiscalid = 'fiscal-2026-demo';
DELETE FROM exp_tables.coa WHERE accountid IN ('acct-ar-demo', 'acct-sales-demo', 'acct-cogs-demo', 'acct-inventory-demo', 'acct-tax-demo');
DELETE FROM exp_tables.setup WHERE key = '1';
DELETE FROM exp_tables.company WHERE name = 'Calgary Lock & Safe Demo';
DELETE FROM exp_tables.color WHERE id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
DELETE FROM exp_tables.reportviewfilter
WHERE viewid IN (
 '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1',
 '86c3e36d-102c-44f4-9b42-f0f57d3c9dc2',
 '4b011415-5e18-4a27-b8ff-253a7ea16a10',
 '60790320-c434-4425-a1e5-9f7f4d5c2a8f',
 '6c7fbe33-d0fd-4f95-af9c-40862265b9e4',
 '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2',
 'd901fe5f-9249-49c4-8a3f-5e176626aef1'
);
DELETE FROM exp_tables.reportviewcustomfield
WHERE viewid IN (
 '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1',
 '86c3e36d-102c-44f4-9b42-f0f57d3c9dc2',
 '4b011415-5e18-4a27-b8ff-253a7ea16a10',
 '60790320-c434-4425-a1e5-9f7f4d5c2a8f',
 '6c7fbe33-d0fd-4f95-af9c-40862265b9e4',
 '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2',
 'd901fe5f-9249-49c4-8a3f-5e176626aef1'
);
DELETE FROM exp_tables.reportview
WHERE viewid IN (
 '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1',
 '86c3e36d-102c-44f4-9b42-f0f57d3c9dc2',
 '4b011415-5e18-4a27-b8ff-253a7ea16a10',
 '60790320-c434-4425-a1e5-9f7f4d5c2a8f',
 '6c7fbe33-d0fd-4f95-af9c-40862265b9e4',
 '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2',
 'd901fe5f-9249-49c4-8a3f-5e176626aef1'
);

INSERT INTO exp_tables.company (name, address, address2, city, state, zip, phone, fax, fiscalbeg, fedidnum)
VALUES ('Calgary Lock & Safe Demo', '410 10 Ave SW', 'Suite 210', 'Calgary', 'AB', 'T2R 0A8', '4035550199', '4035550198', '01', '123456789');

DO $$
DECLARE
 columns_sql text;
 values_sql text;
BEGIN
 SELECT
 string_agg(format('%I', column_name), ', ' ORDER BY ordinal_position),
 string_agg(
 CASE
 WHEN column_name = 'key' THEN quote_literal('1')
 WHEN column_name = 'taxcode' THEN quote_literal('GST5')
 WHEN column_name = 'terms' THEN quote_literal('Net 30')
 WHEN column_name = 'defaulttyp' THEN quote_literal('SERV')
 WHEN column_name = 'defdept' THEN quote_literal('10')
 WHEN column_name = 'defnordept' THEN quote_literal('10')
 WHEN column_name = 'priority' THEN quote_literal('STD')
 WHEN column_name = 'deftechsa' THEN quote_literal('0001')
 WHEN column_name = 'deftechdi' THEN quote_literal('0001')
 WHEN column_name = 'recacct' THEN quote_literal('1100')
 WHEN column_name = 'recdeposit' THEN quote_literal('1100')
 WHEN column_name = 'rectrade' THEN quote_literal('1100')
 WHEN column_name = 'latecredit' THEN quote_literal('4100')
 WHEN column_name = 'tripcharge' THEN '49'
 WHEN column_name = 'leadtime' THEN '30'
 WHEN column_name = 'lblphone1' THEN quote_literal('Main')
 WHEN column_name = 'lblphone2' THEN quote_literal('Mobile')
 WHEN column_name = 'lblphone3' THEN quote_literal('After Hours')
 WHEN column_name = 'lblphone4' THEN quote_literal('Fax')
 WHEN column_name = 'phonelst1' THEN quote_literal('Main')
 WHEN column_name = 'phonelst2' THEN quote_literal('Mobile')
 WHEN column_name = 'phonelst3' THEN quote_literal('After Hours')
 WHEN column_name = 'phonelst4' THEN quote_literal('Fax')
 WHEN column_name = 'phonelst5' THEN quote_literal('Office')
 WHEN column_name = 'phonelst6' THEN quote_literal('Dispatch')
 WHEN column_name = 'phonelst7' THEN quote_literal('Billing')
 WHEN column_name = 'phonelst8' THEN quote_literal('Emergency')
 WHEN column_name LIKE 'dispeq_' THEN quote_literal('')
 WHEN column_name IN ('dispeq1', 'dispeq2', 'dispeq3', 'dispeq4', 'dispeq5', 'dispeq6') THEN quote_literal('')
 WHEN column_name LIKE 'ampreftime%' THEN quote_literal('')
 WHEN column_name LIKE 'amacttime%' THEN quote_literal('')
 WHEN data_type IN ('integer', 'smallint', 'double precision', 'real', 'numeric', 'bigint') THEN '0'
 WHEN data_type = 'timestamp without time zone' THEN 'NULL'
 ELSE quote_literal('')
 END,
 ', ' ORDER BY ordinal_position
 )
 INTO columns_sql, values_sql
 FROM information_schema.columns
 WHERE table_schema = 'exp_tables'
 AND table_name = 'setup';

 EXECUTE format('INSERT INTO exp_tables.setup (%s) VALUES (%s)', columns_sql, values_sql);
END $$;

INSERT INTO exp_tables.color (id, name, foreground, background) VALUES
 (1, 'High Priority', '#FFFFFF', '#B42318'),
 (2, 'Standard', '#111827', '#FACC15'),
 (3, 'Low Priority', '#111827', '#D1D5DB'),
 (4, 'Completed', '#FFFFFF', '#15803D'),
 (5, 'Emergency', '#FFFFFF', '#7C3AED'),
 (6, 'Rush', '#FFFFFF', '#EA580C'),
 (7, 'Quote Pending', '#111827', '#38BDF8'),
 (8, 'On Hold', '#111827', '#A78BFA'),
 (9, 'Parts Ordered', '#111827', '#FB923C'),
 (10, 'Waiting Customer', '#111827', '#F472B6');

INSERT INTO exp_tables.fingroup ("group", "desc") VALUES
 ('AR', 'Receivables'),
 ('SALE', 'Sales'),
 ('COGS', 'Cost of Sales'),
 ('INV', 'Inventory');

INSERT INTO exp_tables.findiv (div, "desc") VALUES ('01', 'Calgary');

INSERT INTO exp_tables.findept (dept, "desc") VALUES
 ('10', 'Service'),
 ('20', 'Safe Work'),
 ('30', 'Install'),
 ('40', 'Access Control'),
 ('50', 'Key Systems'),
 ('60', 'Emergency');

INSERT INTO exp_tables.finfiscal (fiscalid, counter, fiscalstart, name)
VALUES ('fiscal-2026-demo', 1, '2026-01-01 00:00:00', 'FY2026');

INSERT INTO exp_tables.finperiod (periodid, fiscalid, counter, datebegin, dateend)
VALUES ('202605', 'fiscal-2026-demo', 5, '2026-05-01 00:00:00', '2026-05-31 23:59:59');

INSERT INTO exp_tables.coa (
 account, id, "desc", dept, div, "group", type, isdept, accountid, inactive,
 reconbeginbal, reconendbal, overheadmethod, wipaccount, category1099
) VALUES
 ('1100', 'AR', 'Accounts Receivable', '10', '01', 'AR', 'A', 0, 'acct-ar-demo', 0, 0, 0, 0, 0, 0),
 ('4100', 'SA', 'Locksmith Service Sales', '10', '01', 'SALE', 'I', 0, 'acct-sales-demo', 0, 0, 0, 0, 0, 0),
 ('5100', 'CG', 'Locksmith Parts COGS', '10', '01', 'COGS', 'E', 0, 'acct-cogs-demo', 0, 0, 0, 0, 0, 0),
 ('1300', 'IN', 'Truck Inventory', '10', '01', 'INV', 'A', 0, 'acct-inventory-demo', 0, 0, 0, 0, 0, 0),
 ('2200', 'TX', 'GST Payable', '10', '01', 'SALE', 'L', 0, 'acct-tax-demo', 0, 0, 0, 0, 0, 0);

INSERT INTO exp_tables.terms (term, type, netdue, paidwithin, netdueday, nxtmoday, discday, discount, termid)
VALUES
 ('Due on Receipt', 0, 0, 0, 0, 0, 0, 0, 'term-due-receipt'),
 ('Net 15', 0, 15, 0, 0, 0, 0, 0, 'term-net-15'),
 ('Net 30', 0, 30, 0, 0, 0, 0, 0, 'term-net-30'),
 ('Net 45', 0, 45, 0, 0, 0, 0, 0, 'term-net-45'),
 ('Net 60', 0, 60, 0, 0, 0, 0, 0, 'term-net-60'),
 ('2/10 Net 30', 0, 30, 0, 0, 0, 10, 2, 'term-2-10-net-30');

INSERT INTO exp_tables.creditratings (name, inactive, color, restrictdispatch)
VALUES
 ('A', 0, 4, 0),
 ('B', 0, 2, 0),
 ('C', 0, 3, 0),
 ('COD', 0, 6, 0);

INSERT INTO exp_tables.taxcodes (
 code, "desc", sales, acct1, tdesc1, rate1, vendor1, acct2, tdesc2, rate2, vendor2,
 acct3, tdesc3, rate3, vendor3, acct4, tdesc4, rate4, vendor4,
 labor1, labor2, labor3, labor4, material1, material2, material3, material4,
 other1, other2, other3, other4, servagr1, servagr2, servagr3, servagr4,
 costacct, piggy, acct5, acct6, tdesc5, tdesc6, rate5, rate6, vendor5, vendor6,
 labor5, labor6, material5, material6, other5, other6, servagr5, servagr6, gstpsttax
) VALUES
 ('GST5', 'GST 5%', 1, '2200', 'GST', 5.0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL,
 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, '5100', 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0),
 ('NONE', 'No Tax', 1, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL,
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '5100', 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0),
 ('GSTHST', 'GST/HST Combined', 1, '2200', 'GST/HST', 13.0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL,
 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, '5100', 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0),
 ('PST7', 'PST 7%', 1, '2200', 'PST', 7.0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL,
 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, '5100', 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0),
 ('GSTPST', 'GST 5% + PST 7%', 1, '2200', 'GST+PST', 12.0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL,
 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, '5100', 0, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO exp_tables.sldept (dept, "desc", debit, credit, deptid, division, inactive)
VALUES
 ('10', 'Service', '1100', '4100', 'dept-service-demo', '01', 0),
 ('20', 'Safe Work', '1100', '4100', 'dept-safe-demo', '01', 0),
 ('30', 'Install', '1100', '4100', 'dept-install-demo', '01', 0),
 ('40', 'Access Control', '1100', '4100', 'dept-access-demo', '01', 0),
 ('50', 'Key Systems', '1100', '4100', 'dept-keys-demo', '01', 0),
 ('60', 'Emergency', '1100', '4100', 'dept-emergency-demo', '01', 0);

INSERT INTO exp_tables.warehous (wh, "desc", inactive)
VALUES
 ('0001', 'Main Stock', 0),
 ('0002', 'Ava Van', 0),
 ('0003', 'Mason Van', 0),
 ('0004', 'Jordan Van', 0),
 ('0005', 'Riley Van', 0),
 ('0006', 'Casey Van', 0),
 ('0007', 'Quinn Van', 0),
 ('0008', 'Skyler Van', 0),
 ('0009', 'Drew Van', 0),
 ('0010', 'Remi Van', 0);

INSERT INTO exp_tables.dispatchpriority (name, color, inactive)
VALUES ('HIGH', 1, 0), ('STD', 2, 0), ('LOW', 3, 0), ('EMRG', 5, 0), ('RUSH', 6, 0);

INSERT INTO exp_tables.dispatchtype (name, billable, inactive)
VALUES ('SERV', 1, 0), ('SAFE', 1, 0), ('INST', 1, 0), ('ACCS', 1, 0), ('EMRG', 1, 0), ('CONS', 0, 0);

INSERT INTO exp_tables.counter (name, next)
VALUES
 ('Customer', '0001016'),
 ('Dispatch', '000116'),
 ('Employee', '0016'),
 ('Invoice', '0000002016'),
 ('PO', '000000000000106'),
 ('GJ', '000001');

INSERT INTO exp_tables.employee (
 empno, empname, skill, servicenum, search, lastname, firstname, add1, city, state, zip,
 license, rate, overhead, percent, phone, dept, email, inactive, routefrom,
 monstart, monend, tuestart, tueend, wedstart, wedend, thustart, thuend, fristart, friend,
 maritalstatus, payperiodtype, prddactive, sex, ethnicgroup, title, employdate,
 vacationallowed, latitude, longitude
) VALUES
 ('0001', 'Ava Nguyen', 'COM', '4035551101', 'AVA', 'Nguyen', 'Ava', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-LOCK-1001', 42, 18, 0, '4035551101', '10', 'ava@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 1, 0, 'Commercial Locksmith', '2023-04-10 00:00:00', 80, 5104541, -1140572),
 ('0002', 'Mason Patel', 'SAF', '4035551102', 'MAS', 'Patel', 'Mason', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-SAFE-2002', 48, 20, 0, '4035551102', '20', 'mason@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 1, 0, 'Safe Technician', '2022-09-05 00:00:00', 80, 5104541, -1140572),
 ('0003', 'Lena Brooks', 'DSP', '4035551103', 'LEN', 'Brooks', 'Lena', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-DISP-3003', 34, 12, 0, '4035551103', '10', 'dispatch@calgarylocksafe.test', 0, 0,
 '07:00', '16:00', '07:00', '16:00', '07:00', '16:00', '07:00', '16:00', '07:00', '16:00',
 0, 1, 1, 2, 0, 'Dispatcher', '2024-01-15 00:00:00', 80, 5104541, -1140572),
 ('0004', 'Jordan Chen', 'ACC', '4035551104', 'JOR', 'Chen', 'Jordan', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-ACC-4004', 52, 22, 0, '4035551104', '40', 'jordan@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 1, 0, 'Access Control Specialist', '2021-11-20 00:00:00', 80, 5104541, -1140572),
 ('0005', 'Riley Okafor', 'KEY', '4035551105', 'RIL', 'Okafor', 'Riley', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-KEY-5005', 45, 16, 0, '4035551105', '50', 'riley@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 1, 0, 'Key Systems Specialist', '2023-02-14 00:00:00', 80, 5104541, -1140572),
 ('0006', 'Casey Tremblay', 'EMR', '4035551106', 'CAS', 'Tremblay', 'Casey', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-EMR-6006', 55, 24, 0, '4035551106', '60', 'casey@calgarylocksafe.test', 0, 0,
 '00:00', '23:59', '00:00', '23:59', '00:00', '23:59', '00:00', '23:59', '00:00', '23:59',
 0, 1, 1, 1, 0, 'Emergency Locksmith', '2020-06-01 00:00:00', 80, 5104541, -1140572),
 ('0007', 'Quinn Singh', 'INS', '4035551107', 'QUI', 'Singh', 'Quinn', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-INST-7007', 46, 18, 0, '4035551107', '30', 'quinn@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 1, 0, 'Install Technician', '2022-03-08 00:00:00', 80, 5104541, -1140572),
 ('0008', 'Skyler Kim', 'COM', '4035551108', 'SKY', 'Kim', 'Skyler', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-LOCK-8008', 40, 16, 0, '4035551108', '10', 'skyler@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 2, 0, 'Commercial Locksmith', '2024-05-12 00:00:00', 80, 5104541, -1140572),
 ('0009', 'Drew MacDonald', 'SAF', '4035551109', 'DRE', 'MacDonald', 'Drew', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-SAFE-9009', 50, 21, 0, '4035551109', '20', 'drew@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 1, 0, 'Safe Technician', '2021-08-19 00:00:00', 80, 5104541, -1140572),
 ('0010', 'Remi Larsson', 'ACC', '4035551110', 'REM', 'Larsson', 'Remi', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-ACC-1010', 54, 23, 0, '4035551110', '40', 'remi@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 2, 0, 'Access Control Specialist', '2022-12-03 00:00:00', 80, 5104541, -1140572),
 ('0011', 'Taylor Wright', 'KEY', '4035551111', 'TAY', 'Wright', 'Taylor', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-KEY-1111', 44, 17, 0, '4035551111', '50', 'taylor@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 1, 0, 'Key Systems Specialist', '2023-07-22 00:00:00', 80, 5104541, -1140572),
 ('0012', 'Alex Fernandez', 'COM', '4035551112', 'ALE', 'Fernandez', 'Alex', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-LOCK-1212', 41, 17, 0, '4035551112', '10', 'alex@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 1, 0, 'Commercial Locksmith', '2024-02-01 00:00:00', 80, 5104541, -1140572),
 ('0013', 'Jamie Nakamura', 'INS', '4035551113', 'JAM', 'Nakamura', 'Jamie', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-INST-1313', 47, 19, 0, '4035551113', '30', 'jamie@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 2, 0, 'Install Technician', '2021-04-18 00:00:00', 80, 5104541, -1140572),
 ('0014', 'Morgan Silva', 'SAF', '4035551114', 'MOR', 'Silva', 'Morgan', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-SAFE-1414', 49, 20, 0, '4035551114', '20', 'morgan@calgarylocksafe.test', 0, 0,
 '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00', '08:00', '17:00',
 0, 1, 1, 2, 0, 'Safe Technician', '2023-09-30 00:00:00', 80, 5104541, -1140572),
 ('0015', 'Dakota Rossi', 'EMR', '4035551115', 'DAK', 'Rossi', 'Dakota', '410 10 Ave SW', 'Calgary', 'AB', 'T2R 0A8',
 'AB-EMR-1515', 56, 25, 0, '4035551115', '60', 'dakota@calgarylocksafe.test', 0, 0,
 '00:00', '23:59', '00:00', '23:59', '00:00', '23:59', '00:00', '23:59', '00:00', '23:59',
 0, 1, 1, 1, 0, 'Emergency Locksmith', '2020-01-10 00:00:00', 80, 5104541, -1140572);

INSERT INTO exp_tables.users ("user", password, techid, deviceid, uncname)
VALUES
 ('ADMIN', 'admin', NULL, NULL, 'Local admin'),
 ('AVA', 'demo', '0001', '0002', 'Ava Nguyen'),
 ('MASON', 'demo', '0002', '0003', 'Mason Patel'),
 ('LENA', 'demo', '0003', NULL, 'Lena Brooks'),
 ('JORDAN', 'demo', '0004', '0004', 'Jordan Chen'),
 ('RILEY', 'demo', '0005', '0005', 'Riley Okafor'),
 ('CASEY', 'demo', '0006', '0006', 'Casey Tremblay'),
 ('QUINN', 'demo', '0007', '0007', 'Quinn Singh'),
 ('SKYLER', 'demo', '0008', '0008', 'Skyler Kim'),
 ('DREW', 'demo', '0009', '0009', 'Drew MacDonald'),
 ('REMI', 'demo', '0010', '0010', 'Remi Larsson'),
 ('TAYLOR', 'demo', '0011', '0011', 'Taylor Wright'),
 ('ALEX', 'demo', '0012', '0012', 'Alex Fernandez'),
 ('JAMIE', 'demo', '0013', '0013', 'Jamie Nakamura'),
 ('MORGAN', 'demo', '0014', '0014', 'Morgan Silva');

INSERT INTO exp_tables.vendor (
 vendor, company, firstname, add1, city, state, zip, phone1, terms, account, discount,
 email, weburl, vendornotes, defaultlocationid, print1099, vendorinactive, defaultaccountid
) VALUES
 ('ALGO', 'Allegion Canada', 'Inside Sales', '1076 Lakeshore Rd E', 'Mississauga', 'ON', 'L5E 1E4', '9055550101', 'Net 30', 'ALG-CLSD', 5,
 'orders@allegion.example', 'https://www.allegion.ca', 'Schlage, Von Duprin, and LCN hardware supplier.', 'vloc-algo-main', 0, 0, 'acct-inventory-demo'),
 ('MULK', 'Mul-T-Lock Western', 'Key Systems Desk', '1820 32 Ave NE', 'Calgary', 'AB', 'T2E 7A6', '4035550102', 'Net 15', 'MTL-CLSD', 7,
 'orders@multlock.example', 'https://www.mul-t-lock.com', 'High security cylinders and key systems.', 'vloc-mulk-main', 0, 0, 'acct-inventory-demo'),
 ('AMSE', 'AMSEC Safe Supply', 'Safe Parts Desk', '720 Industrial Way', 'Vancouver', 'BC', 'V5K 0A1', '6045550103', 'Net 30', 'AMS-CLSD', 3,
 'parts@amsec.example', 'https://www.americansecuritysafes.com', 'Safe locks, dials, and replacement handles.', 'vloc-amse-main', 0, 0, 'acct-inventory-demo'),
 ('KABA', 'Kaba Ilco Canada', 'Sales Desk', '55 Commerce Valley Dr W', 'Thornhill', 'ON', 'L3T 7V5', '9055550104', 'Net 30', 'KAB-CLSD', 4,
 'sales@kaba.example', 'https://www.kaba-ilco.com', 'Key blanks, key machines, and Ilco products.', 'vloc-kaba-main', 0, 0, 'acct-inventory-demo'),
 ('HIDG', 'HID Global', 'Channel Partner', '611 Center Ridge Dr', 'Austin', 'TX', '78753', '5125550105', 'Net 45', 'HID-CLSD', 6,
 'partner@hidglobal.example', 'https://www.hidglobal.com', 'Proximity cards, readers, and access credentials.', 'vloc-hidg-main', 0, 0, 'acct-inventory-demo'),
 ('ASSA', 'ASSA ABLOY Canada', 'Distribution', '1550 Meyerside Dr', 'Mississauga', 'ON', 'L5T 1X3', '9055550106', 'Net 30', 'ASS-CLSD', 5,
 'orders@assaabloy.example', 'https://www.assaabloy.com', 'Door hardware, closers, and panic devices.', 'vloc-assa-main', 0, 0, 'acct-inventory-demo'),
 ('YALE', 'Yale Commercial', 'Inside Sales', '225 Episcopal Rd', 'Berlin', 'CT', '06037', '8605550107', 'Net 30', 'YAL-CLSD', 4,
 'sales@yalecommercial.example', 'https://www.yalecommercial.com', 'Commercial locks, exit devices, and padlocks.', 'vloc-yale-main', 0, 0, 'acct-inventory-demo'),
 ('DETE', 'Detex Corporation', 'Sales', '302 N Walnut Creek Dr', 'Mansfield', 'TX', '76063', '8175550108', 'Net 15', 'DET-CLSD', 5,
 'sales@detex.example', 'https://www.detex.com', 'Exit alarms, door prop alarms, and guards.', 'vloc-dete-main', 0, 0, 'acct-inventory-demo'),
 ('STAN', 'Stanley Security', 'Account Manager', '1213 N Main St', 'Greensboro', 'NC', '27401', '3365550109', 'Net 45', 'STA-CLSD', 8,
 'account@stanleysecurity.example', 'https://www.stanleysecurity.com', 'Integrated security solutions and access control.', 'vloc-stan-main', 0, 0, 'acct-inventory-demo'),
 ('HES', 'HES Electric Strikes', 'Orders', '9145 Centennial St', 'Penticton', 'BC', 'V2A 6B1', '2505550110', 'Net 30', 'HES-CLSD', 4,
 'orders@hes.example', 'https://www.hesinnovations.com', 'Electric strikes and locking accessories.', 'vloc-hes-main', 0, 0, 'acct-inventory-demo'),
 ('SARG', 'Sargent Manufacturing', 'Customer Service', '100 Sargent Dr', 'New Haven', 'CT', '06511', '2035550111', 'Net 30', 'SAR-CLSD', 5,
 'service@sargent.example', 'https://www.sargentlock.com', 'Mortise locks, cylindrical locks, and exit devices.', 'vloc-sarg-main', 0, 0, 'acct-inventory-demo'),
 ('CORB', 'Corbin Russwin', 'Sales Support', '225 Episcopal Rd', 'Berlin', 'CT', '06037', '8605550112', 'Net 30', 'COR-CLSD', 4,
 'support@corbinrusswin.example', 'https://www.corbinrusswin.com', 'Architectural hardware and key systems.', 'vloc-corb-main', 0, 0, 'acct-inventory-demo'),
 ('FALC', 'Falcon Lock', 'Inside Sales', '225 Episcopal Rd', 'Berlin', 'CT', '06037', '8605550113', 'Net 15', 'FAL-CLSD', 5,
 'sales@falconlock.example', 'https://www.falconlock.com', 'Exit devices, locks, and door closers.', 'vloc-falc-main', 0, 0, 'acct-inventory-demo'),
 ('MED', 'Medeco Security Locks', 'Key Control', '3625 Allegheny Dr', 'Salem', 'VA', '24153', '5405550114', 'Net 30', 'MED-CLSD', 6,
 'keycontrol@medeco.example', 'https://www.medeco.com', 'High security locks and patented key control.', 'vloc-med-main', 0, 0, 'acct-inventory-demo'),
 ('SECU', 'Securitron Magnalock', 'Orders', '550 S Rock Blvd', 'Sparks', 'NV', '89431', '7755550115', 'Net 30', 'SEC-CLSD', 5,
 'orders@securitron.example', 'https://www.securitron.com', 'Magnetic locks and access control accessories.', 'vloc-secu-main', 0, 0, 'acct-inventory-demo');

INSERT INTO exp_tables.vendorlocations (
 vendor, listid, locname, locadd1, loccity, locstate, loczip, contactname1,
 contactemail1, phone1, locinactive
) VALUES
 ('ALGO', 'vloc-algo-main', 'Canadian Distribution', '1076 Lakeshore Rd E', 'Mississauga', 'ON', 'L5E 1E4', 'Inside Sales', 'orders@allegion.example', '9055550101', 0),
 ('MULK', 'vloc-mulk-main', 'Calgary Counter', '1820 32 Ave NE', 'Calgary', 'AB', 'T2E 7A6', 'Dana Ruiz', 'orders@multlock.example', '4035550102', 0),
 ('AMSE', 'vloc-amse-main', 'Western Safe Parts', '720 Industrial Way', 'Vancouver', 'BC', 'V5K 0A1', 'Neil Fraser', 'parts@amsec.example', '6045550103', 0),
 ('KABA', 'vloc-kaba-main', 'Toronto Distribution', '55 Commerce Valley Dr W', 'Thornhill', 'ON', 'L3T 7V5', 'Sarah Lin', 'sales@kaba.example', '9055550104', 0),
 ('HIDG', 'vloc-hidg-main', 'Austin HQ', '611 Center Ridge Dr', 'Austin', 'TX', '78753', 'Marcus Webb', 'partner@hidglobal.example', '5125550105', 0),
 ('ASSA', 'vloc-assa-main', 'Mississauga DC', '1550 Meyerside Dr', 'Mississauga', 'ON', 'L5T 1X3', 'Priya Nair', 'orders@assaabloy.example', '9055550106', 0),
 ('YALE', 'vloc-yale-main', 'Berlin Office', '225 Episcopal Rd', 'Berlin', 'CT', '06037', 'James Holt', 'sales@yalecommercial.example', '8605550107', 0),
 ('DETE', 'vloc-dete-main', 'Mansfield Plant', '302 N Walnut Creek Dr', 'Mansfield', 'TX', '76063', 'Rachel Green', 'sales@detex.example', '8175550108', 0),
 ('STAN', 'vloc-stan-main', 'Greensboro Hub', '1213 N Main St', 'Greensboro', 'NC', '27401', 'David Park', 'account@stanleysecurity.example', '3365550109', 0),
 ('HES', 'vloc-hes-main', 'Penticton Office', '9145 Centennial St', 'Penticton', 'BC', 'V2A 6B1', 'Linda Wu', 'orders@hes.example', '2505550110', 0),
 ('SARG', 'vloc-sarg-main', 'New Haven Factory', '100 Sargent Dr', 'New Haven', 'CT', '06511', 'Tom Bradley', 'service@sargent.example', '2035550111', 0),
 ('CORB', 'vloc-corb-main', 'Berlin Office', '225 Episcopal Rd', 'Berlin', 'CT', '06037', 'Angela Ross', 'support@corbinrusswin.example', '8605550112', 0),
 ('FALC', 'vloc-falc-main', 'Berlin Distribution', '225 Episcopal Rd', 'Berlin', 'CT', '06037', 'Chris Dale', 'sales@falconlock.example', '8605550113', 0),
 ('MED', 'vloc-med-main', 'Salem HQ', '3625 Allegheny Dr', 'Salem', 'VA', '24153', 'Nina Patel', 'keycontrol@medeco.example', '5405550114', 0),
 ('SECU', 'vloc-secu-main', 'Sparks DC', '550 S Rock Blvd', 'Sparks', 'NV', '89431', 'Omar Hassan', 'orders@securitron.example', '7755550115', 0);

INSERT INTO exp_tables.invcat (cat) VALUES ('LOCKS'), ('KEYS'), ('SAFE'), ('ACCESS'), ('HARDWARE'), ('TOOLS'), ('ELECTRONIC'), ('BATTERIES');

INSERT INTO exp_tables.invscat (cat, subcat, applymarkp, markupcode, pricebk)
VALUES
 ('LOCKS', 'DEADBOLT', 'Y', 'A', 'STD'),
 ('LOCKS', 'CYLINDER', 'Y', 'A', 'STD'),
 ('LOCKS', 'MORTISE', 'Y', 'A', 'STD'),
 ('KEYS', 'DUPLICATE', 'Y', 'B', 'STD'),
 ('KEYS', 'MASTER', 'Y', 'B', 'STD'),
 ('SAFE', 'PARTS', 'Y', 'A', 'STD'),
 ('SAFE', 'ELECTRONIC', 'Y', 'A', 'STD'),
 ('ACCESS', 'KEYPAD', 'Y', 'A', 'STD'),
 ('ACCESS', 'READER', 'Y', 'A', 'STD'),
 ('ACCESS', 'CONTROLLER', 'Y', 'A', 'STD'),
 ('HARDWARE', 'CLOSER', 'Y', 'A', 'STD'),
 ('HARDWARE', 'PANIC', 'Y', 'A', 'STD'),
 ('HARDWARE', 'HINGE', 'Y', 'A', 'STD'),
 ('TOOLS', 'PICK', 'Y', 'C', 'STD'),
 ('TOOLS', 'DRILL', 'Y', 'C', 'STD'),
 ('TOOLS', 'INSTALL', 'Y', 'C', 'STD'),
 ('ELECTRONIC', 'CAMERA', 'Y', 'A', 'STD'),
 ('ELECTRONIC', 'POWER', 'Y', 'A', 'STD'),
 ('BATTERIES', 'PRIMARY', 'Y', 'B', 'STD'),
 ('BATTERIES', 'RECHARGEABLE', 'Y', 'B', 'STD');

INSERT INTO exp_tables.inven (
 part, "desc", type, cat, subcat, averagec, bprice, lastprice, cunits, buysellr,
 markupcode, pricea, priceb, pricec, runits, costdb, costcr, salesdb, salescr,
 bin, pricebook, parttype, posthist, vendor, salestype, notes, billrate, nontaxable,
 equippost, wamonths, mfg, model, reorderqua, reorderlev, search1, bcost, overhead,
 frplabor, inactive, ismarkup, itemid, shortdesc, spiffmethod, spiffvalue, nocommission
) VALUES
 ('LABOR-COMM', 'Commercial locksmith labor - hourly', 'L', 'LOCKS', 'CYLINDER', 0, 0, 0, 'HR', 1, 'A', 125, 125, 125, 'HR', '5100', '1300', '1100', '4100', 'N/A', 'STD', 'LABOR', 1, NULL, 'L', 'Billable locksmith time.', 125, 0, 0, 0, 'CLS', 'LABOR', 0, 0, 'LAB', 0, 0, 0, 0, 0, 'item-labor-comm', 'Labor', 0, 0, 0),
 ('TRIP-LOCAL', 'Local service trip charge', 'O', 'LOCKS', 'CYLINDER', 0, 0, 0, 'EA', 1, 'A', 49, 49, 49, 'EA', '5100', '1300', '1100', '4100', 'N/A', 'STD', 'TRIP', 1, NULL, 'O', 'Standard Calgary trip charge.', 49, 0, 0, 0, 'CLS', 'TRIP', 0, 0, 'TRIP', 0, 0, 0, 0, 0, 'item-trip-local', 'Trip', 0, 0, 0),
 ('TRIP-AFTERHRS', 'After-hours trip surcharge', 'O', 'LOCKS', 'CYLINDER', 0, 0, 0, 'EA', 1, 'A', 89, 89, 89, 'EA', '5100', '1300', '1100', '4100', 'N/A', 'STD', 'TRIP', 1, NULL, 'O', 'After-hours and weekend trip charge.', 89, 0, 0, 0, 'CLS', 'TRIP', 0, 0, 'TRIP', 0, 0, 0, 0, 0, 'item-trip-afterhrs', 'After-Hrs Trip', 0, 0, 0),
 ('TRIP-REMOTE', 'Remote area trip charge', 'O', 'LOCKS', 'CYLINDER', 0, 0, 0, 'EA', 1, 'A', 129, 129, 129, 'EA', '5100', '1300', '1100', '4100', 'N/A', 'STD', 'TRIP', 1, NULL, 'O', 'Outlying areas and rural locations.', 129, 0, 0, 0, 'CLS', 'TRIP', 0, 0, 'TRIP', 0, 0, 0, 0, 0, 'item-trip-remote', 'Remote Trip', 0, 0, 0),
 ('TRIP-EMERGENCY', 'Emergency call-out charge', 'O', 'LOCKS', 'CYLINDER', 0, 0, 0, 'EA', 1, 'A', 175, 175, 175, 'EA', '5100', '1300', '1100', '4100', 'N/A', 'STD', 'TRIP', 1, NULL, 'O', 'Emergency lockout and urgent response.', 175, 0, 0, 0, 'CLS', 'TRIP', 0, 0, 'TRIP', 0, 0, 0, 0, 0, 'item-trip-emergency', 'Emergency Trip', 0, 0, 0),
 ('PART-DEADBOLT-GRADE1', 'Grade 1 commercial deadbolt, satin chrome', 'M', 'LOCKS', 'DEADBOLT', 68, 82, 64, 'EA', 1, 'A', 159, 149, 139, 'EA', '5100', '1300', '1100', '4100', 'A3', 'STD', 'PART', 1, 'ALGO', 'M', 'Heavy duty storefront and office deadbolt.', 0, 0, 0, 0, 'Schlage', 'B660P', 4, 2, 'DBOLT', 68, 8, 0, 0, 0, 'item-deadbolt-grade1', 'Grade 1 Deadbolt', 0, 0, 0),
 ('PART-DEADBOLT-GRADE2', 'Grade 2 residential deadbolt, brushed nickel', 'M', 'LOCKS', 'DEADBOLT', 42, 55, 38, 'EA', 1, 'A', 99, 89, 79, 'EA', '5100', '1300', '1100', '4100', 'A4', 'STD', 'PART', 1, 'YALE', 'M', 'Standard residential deadbolt.', 0, 0, 0, 0, 'Yale', 'YRD256', 6, 3, 'DBOLT', 42, 5, 0, 0, 0, 'item-deadbolt-grade2', 'Grade 2 Deadbolt', 0, 0, 0),
 ('PART-SFIC-CORE', 'SFIC interchangeable core, keyed alike', 'M', 'LOCKS', 'CYLINDER', 28, 36, 27, 'EA', 1, 'A', 72, 68, 64, 'EA', '5100', '1300', '1100', '4100', 'B2', 'STD', 'PART', 1, 'MULK', 'M', 'Best-style interchangeable core for rekey work.', 0, 0, 0, 0, 'Mul-T-Lock', 'SFIC-6', 12, 6, 'CORE', 28, 6, 0, 0, 0, 'item-sfic-core', 'SFIC Core', 0, 0, 0),
 ('PART-IC-CORE', 'IC core, Schlage LFIC, 6-pin', 'M', 'LOCKS', 'CYLINDER', 32, 42, 30, 'EA', 1, 'A', 85, 79, 72, 'EA', '5100', '1300', '1100', '4100', 'B3', 'STD', 'PART', 1, 'ALGO', 'M', 'Schlage large format interchangeable core.', 0, 0, 0, 0, 'Schlage', 'LFIC-6', 8, 4, 'CORE', 32, 7, 0, 0, 0, 'item-ic-core', 'IC Core', 0, 0, 0),
 ('PART-KEY-SCHLAGE', 'Schlage SC1 key blank', 'M', 'KEYS', 'DUPLICATE', 0.85, 1.1, 0.8, 'EA', 1, 'B', 5.5, 4.5, 3.95, 'EA', '5100', '1300', '1100', '4100', 'K1', 'STD', 'PART', 1, 'ALGO', 'M', 'Common residential and commercial key blank.', 0, 0, 0, 0, 'Ilco', 'SC1', 100, 40, 'SC1', 0.85, 0.25, 0, 0, 0, 'item-key-schlage-sc1', 'SC1 Key', 0, 0, 0),
 ('PART-KEY-KWIKSET', 'Kwikset KW1 key blank', 'M', 'KEYS', 'DUPLICATE', 0.75, 1.0, 0.7, 'EA', 1, 'B', 4.95, 3.95, 3.5, 'EA', '5100', '1300', '1100', '4100', 'K2', 'STD', 'PART', 1, 'ALGO', 'M', 'Standard Kwikset key blank.', 0, 0, 0, 0, 'Ilco', 'KW1', 100, 40, 'KW1', 0.75, 0.22, 0, 0, 0, 'item-key-kwikset-kw1', 'KW1 Key', 0, 0, 0),
 ('PART-KEYPAD-LOCK', 'Standalone keypad lever lock', 'M', 'ACCESS', 'KEYPAD', 155, 185, 148, 'EA', 1, 'A', 329, 309, 289, 'EA', '5100', '1300', '1100', '4100', 'C4', 'STD', 'PART', 1, 'ALGO', 'M', 'Battery powered keypad lock for staff entrances.', 0, 0, 0, 0, 'Schlage', 'CO-100', 2, 1, 'KPAD', 155, 10, 0, 0, 0, 'item-keypad-lock', 'Keypad Lock', 0, 0, 0),
 ('PART-KEYPAD-MORTISE', 'Keypad mortise lock, networked', 'M', 'ACCESS', 'KEYPAD', 285, 345, 265, 'EA', 1, 'A', 599, 559, 519, 'EA', '5100', '1300', '1100', '4100', 'C5', 'STD', 'PART', 1, 'SARG', 'M', 'Networked keypad mortise for high traffic doors.', 0, 0, 0, 0, 'Sargent', 'KP-8200', 2, 1, 'KPAD', 285, 18, 0, 0, 0, 'item-keypad-mortise', 'Keypad Mortise', 0, 0, 0),
 ('PART-SAFE-DIAL', 'Mechanical safe dial and lock kit', 'M', 'SAFE', 'PARTS', 96, 118, 92, 'EA', 1, 'A', 245, 229, 219, 'EA', '5100', '1300', '1100', '4100', 'S1', 'STD', 'PART', 1, 'AMSE', 'M', 'Replacement dial and lock package for safe service.', 0, 0, 0, 0, 'AMSEC', 'DLK-1', 3, 1, 'SAFE', 96, 12, 0, 0, 0, 'item-safe-dial-kit', 'Safe Dial Kit', 0, 0, 0),
 ('PART-SAFE-ELECTRONIC', 'Electronic safe lock, audit trail', 'M', 'SAFE', 'ELECTRONIC', 145, 175, 135, 'EA', 1, 'A', 375, 349, 329, 'EA', '5100', '1300', '1100', '4100', 'S2', 'STD', 'PART', 1, 'AMSE', 'M', 'Digital safe lock with audit and time delay.', 0, 0, 0, 0, 'AMSEC', 'ESL-10', 2, 1, 'SAFE', 145, 15, 0, 0, 0, 'item-safe-electronic', 'Electronic Safe Lock', 0, 0, 0),
 ('PART-MAGLOCK', 'Electromagnetic lock, 1200 lbs', 'M', 'ACCESS', 'CONTROLLER', 125, 155, 115, 'EA', 1, 'A', 289, 269, 249, 'EA', '5100', '1300', '1100', '4100', 'M1', 'STD', 'PART', 1, 'SECU', 'M', 'Surface mount maglock for access control.', 0, 0, 0, 0, 'Securitron', 'M62', 3, 1, 'MAG', 125, 12, 0, 0, 0, 'item-maglock', 'Maglock', 0, 0, 0),
 ('PART-STRIKE-EL', 'Electric strike, fail secure', 'M', 'ACCESS', 'CONTROLLER', 68, 85, 62, 'EA', 1, 'A', 159, 149, 139, 'EA', '5100', '1300', '1100', '4100', 'M2', 'STD', 'PART', 1, 'HES', 'M', 'Electric strike for metal and wood frames.', 0, 0, 0, 0, 'HES', '1006CS', 4, 2, 'STRK', 68, 8, 0, 0, 0, 'item-strike-el', 'Electric Strike', 0, 0, 0),
 ('PART-READER-PROX', 'Proximity card reader, HID', 'M', 'ACCESS', 'READER', 85, 105, 78, 'EA', 1, 'A', 199, 185, 175, 'EA', '5100', '1300', '1100', '4100', 'R1', 'STD', 'PART', 1, 'HIDG', 'M', 'Standard HID ProxPoint reader.', 0, 0, 0, 0, 'HID', 'ProxPoint', 4, 2, 'READ', 85, 10, 0, 0, 0, 'item-reader-prox', 'Prox Reader', 0, 0, 0),
 ('PART-READER-BIO', 'Biometric fingerprint reader', 'M', 'ACCESS', 'READER', 195, 245, 180, 'EA', 1, 'A', 449, 419, 389, 'EA', '5100', '1300', '1100', '4100', 'R2', 'STD', 'PART', 1, 'HIDG', 'M', 'Fingerprint reader with card fallback.', 0, 0, 0, 0, 'HID', 'iCLASS SE RB25', 2, 1, 'READ', 195, 18, 0, 0, 0, 'item-reader-bio', 'Bio Reader', 0, 0, 0),
 ('PART-CAMERA-DOME', 'IP dome camera, 4MP', 'M', 'ELECTRONIC', 'CAMERA', 145, 185, 135, 'EA', 1, 'A', 349, 329, 309, 'EA', '5100', '1300', '1100', '4100', 'V1', 'STD', 'PART', 1, 'STAN', 'M', 'Indoor dome camera with IR and WDR.', 0, 0, 0, 0, 'Stanley', 'DOME-4MP', 3, 1, 'CAM', 145, 15, 0, 0, 0, 'item-camera-dome', 'Dome Camera', 0, 0, 0),
 ('PART-CAMERA-BULLET', 'IP bullet camera, 4MP', 'M', 'ELECTRONIC', 'CAMERA', 125, 165, 115, 'EA', 1, 'A', 299, 279, 259, 'EA', '5100', '1300', '1100', '4100', 'V2', 'STD', 'PART', 1, 'STAN', 'M', 'Outdoor bullet camera with IR and IP67.', 0, 0, 0, 0, 'Stanley', 'BULLET-4MP', 3, 1, 'CAM', 125, 13, 0, 0, 0, 'item-camera-bullet', 'Bullet Camera', 0, 0, 0),
 ('PART-PANIC-BAR', 'Panic exit device, rim type', 'M', 'HARDWARE', 'PANIC', 185, 225, 175, 'EA', 1, 'A', 425, 399, 375, 'EA', '5100', '1300', '1100', '4100', 'H1', 'STD', 'PART', 1, 'ASSA', 'M', 'Rim panic device for commercial egress.', 0, 0, 0, 0, 'Von Duprin', '99', 2, 1, 'PANIC', 185, 18, 0, 0, 0, 'item-panic-bar', 'Panic Bar', 0, 0, 0),
 ('PART-CLOSER-GRADE1', 'Door closer, grade 1, adjustable', 'M', 'HARDWARE', 'CLOSER', 95, 120, 88, 'EA', 1, 'A', 225, 209, 195, 'EA', '5100', '1300', '1100', '4100', 'H2', 'STD', 'PART', 1, 'ASSA', 'M', 'Heavy duty door closer for commercial doors.', 0, 0, 0, 0, 'LCN', '4040XP', 4, 2, 'CLOSE', 95, 10, 0, 0, 0, 'item-closer-grade1', 'Door Closer', 0, 0, 0),
 ('PART-HINGE-BB', 'Ball bearing hinge, 4.5in', 'M', 'HARDWARE', 'HINGE', 12, 16, 10, 'EA', 1, 'A', 29, 25, 22, 'EA', '5100', '1300', '1100', '4100', 'H3', 'STD', 'PART', 1, 'ASSA', 'M', 'Commercial ball bearing hinge pair.', 0, 0, 0, 0, 'Hager', 'BB1279', 20, 8, 'HINGE', 12, 2, 0, 0, 0, 'item-hinge-bb', 'BB Hinge', 0, 0, 0),
 ('PART-THRESHOLD', 'Door threshold, aluminum', 'M', 'HARDWARE', 'HINGE', 18, 24, 16, 'EA', 1, 'A', 45, 39, 35, 'EA', '5100', '1300', '1100', '4100', 'H4', 'STD', 'PART', 1, 'ASSA', 'M', 'Standard aluminum door threshold.', 0, 0, 0, 0, 'Pemko', '2005AT', 8, 3, 'THRSH', 18, 3, 0, 0, 0, 'item-threshold', 'Threshold', 0, 0, 0),
 ('PART-WEATHERSTRIP', 'Door weatherstrip, silicone', 'M', 'HARDWARE', 'HINGE', 6, 9, 5, 'EA', 1, 'A', 18, 15, 12, 'EA', '5100', '1300', '1100', '4100', 'H5', 'STD', 'PART', 1, 'ASSA', 'M', 'Silicone weatherstrip for door frames.', 0, 0, 0, 0, 'Pemko', 'S88D', 15, 6, 'WEATH', 6, 1, 0, 0, 0, 'item-weatherstrip', 'Weatherstrip', 0, 0, 0),
 ('PART-KEY-BLANK-ASSORTED', 'Assorted key blanks, box of 50', 'M', 'KEYS', 'DUPLICATE', 22, 30, 20, 'EA', 1, 'B', 65, 55, 49, 'EA', '5100', '1300', '1100', '4100', 'K3', 'STD', 'PART', 1, 'KABA', 'M', 'Mixed key blanks for common residential locks.', 0, 0, 0, 0, 'Ilco', 'MIX-50', 5, 2, 'BLANK', 22, 4, 0, 0, 0, 'item-key-blank-assorted', 'Key Blanks', 0, 0, 0),
 ('PART-KEY-BLANK-HIGHSEC', 'High security key blank, Medeco', 'M', 'KEYS', 'MASTER', 18, 25, 16, 'EA', 1, 'B', 55, 49, 42, 'EA', '5100', '1300', '1100', '4100', 'K4', 'STD', 'PART', 1, 'MED', 'M', 'Patented Medeco key blank, restricted.', 0, 0, 0, 0, 'Medeco', 'M3-KEY', 10, 4, 'BLANK', 18, 3, 0, 0, 0, 'item-key-blank-highsec', 'High Sec Key', 0, 0, 0),
 ('PART-TOOL-PICK-SET', 'Professional lock pick set', 'M', 'TOOLS', 'PICK', 45, 65, 40, 'EA', 1, 'C', 125, 109, 95, 'EA', '5100', '1300', '1100', '4100', 'T1', 'STD', 'PART', 1, 'KABA', 'M', 'Complete pick set for locksmiths.', 0, 0, 0, 0, 'SouthOrd', 'PXS-14', 2, 1, 'PICK', 45, 6, 0, 0, 0, 'item-tool-pick-set', 'Pick Set', 0, 0, 0),
 ('PART-TOOL-DRILL-KIT', 'Lock drill kit with bits', 'M', 'TOOLS', 'DRILL', 85, 115, 78, 'EA', 1, 'C', 225, 199, 175, 'EA', '5100', '1300', '1100', '4100', 'T2', 'STD', 'PART', 1, 'KABA', 'M', 'Hardened drill bits for safe and lock drilling.', 0, 0, 0, 0, 'HPC', 'DRILL-KIT', 2, 1, 'DRILL', 85, 10, 0, 0, 0, 'item-tool-drill-kit', 'Drill Kit', 0, 0, 0),
 ('PART-TOOL-INSTALL-KIT', 'Door hardware install kit', 'M', 'TOOLS', 'INSTALL', 55, 75, 50, 'EA', 1, 'C', 149, 129, 115, 'EA', '5100', '1300', '1100', '4100', 'T3', 'STD', 'PART', 1, 'KABA', 'M', 'Jigs, templates, and tools for lock install.', 0, 0, 0, 0, 'HPC', 'INST-KIT', 2, 1, 'INST', 55, 7, 0, 0, 0, 'item-tool-install-kit', 'Install Kit', 0, 0, 0),
 ('PART-TOOL-DIAGNOSTIC', 'Lock diagnostic tool', 'M', 'TOOLS', 'PICK', 125, 165, 115, 'EA', 1, 'C', 325, 295, 269, 'EA', '5100', '1300', '1100', '4100', 'T4', 'STD', 'PART', 1, 'KABA', 'M', 'Electronic lock analyzer and scope.', 0, 0, 0, 0, 'HPC', 'DIAG-PRO', 1, 1, 'DIAG', 125, 15, 0, 0, 0, 'item-tool-diagnostic', 'Diagnostic Tool', 0, 0, 0),
 ('PART-TOOL-KEY-MACHINE', 'Key duplicating machine', 'M', 'TOOLS', 'PICK', 485, 625, 450, 'EA', 1, 'C', 1199, 1099, 999, 'EA', '5100', '1300', '1100', '4100', 'T5', 'STD', 'PART', 1, 'KABA', 'M', 'Semi-automatic key cutting machine.', 0, 0, 0, 0, 'Ilco', '009', 1, 1, 'MACH', 485, 55, 0, 0, 0, 'item-tool-key-machine', 'Key Machine', 0, 0, 0),
 ('PART-TOOL-SAFE-DRILL', 'Safe drilling rig', 'M', 'TOOLS', 'DRILL', 245, 325, 225, 'EA', 1, 'C', 599, 549, 499, 'EA', '5100', '1300', '1100', '4100', 'T6', 'STD', 'PART', 1, 'KABA', 'M', 'Professional safe drilling rig with bits.', 0, 0, 0, 0, 'HPC', 'SAFE-DRILL', 1, 1, 'SFD', 245, 28, 0, 0, 0, 'item-tool-safe-drill', 'Safe Drill', 0, 0, 0),
 ('PART-BATTERY-CR123', 'CR123A lithium battery', 'M', 'BATTERIES', 'PRIMARY', 3.5, 5, 3, 'EA', 1, 'B', 9, 7.5, 6.5, 'EA', '5100', '1300', '1100', '4100', 'P1', 'STD', 'PART', 1, 'ALGO', 'M', '3V lithium battery for locks and sensors.', 0, 0, 0, 0, 'Duracell', 'CR123A', 50, 20, 'BATT', 3.5, 0.5, 0, 0, 0, 'item-battery-cr123', 'CR123 Battery', 0, 0, 0),
 ('PART-BATTERY-AA-LITHIUM', 'AA lithium battery, 4-pack', 'M', 'BATTERIES', 'PRIMARY', 6, 9, 5, 'EA', 1, 'B', 18, 15, 12, 'EA', '5100', '1300', '1100', '4100', 'P2', 'STD', 'PART', 1, 'ALGO', 'M', '1.5V AA lithium for keypad locks.', 0, 0, 0, 0, 'Energizer', 'L91', 30, 12, 'BATT', 6, 1, 0, 0, 0, 'item-battery-aa-lithium', 'AA Lithium', 0, 0, 0);

INSERT INTO exp_tables.invquan (part, wh, aisle, bin, minquan, reorder)
VALUES
 ('PART-DEADBOLT-GRADE1', '0001', 'A', 'A3', 2, 4),
 ('PART-DEADBOLT-GRADE1', '0002', 'A', 'A3', 1, 2),
 ('PART-DEADBOLT-GRADE1', '0004', 'A', 'A3', 1, 2),
 ('PART-DEADBOLT-GRADE2', '0001', 'A', 'A4', 3, 6),
 ('PART-DEADBOLT-GRADE2', '0005', 'A', 'A4', 2, 4),
 ('PART-SFIC-CORE', '0001', 'B', 'B2', 6, 12),
 ('PART-SFIC-CORE', '0002', 'B', 'B2', 2, 6),
 ('PART-SFIC-CORE', '0006', 'B', 'B2', 2, 4),
 ('PART-IC-CORE', '0001', 'B', 'B3', 4, 8),
 ('PART-IC-CORE', '0003', 'B', 'B3', 2, 4),
 ('PART-KEY-SCHLAGE', '0001', 'K', 'K1', 40, 100),
 ('PART-KEY-SCHLAGE', '0002', 'K', 'K1', 20, 50),
 ('PART-KEY-SCHLAGE', '0007', 'K', 'K1', 15, 30),
 ('PART-KEY-KWIKSET', '0001', 'K', 'K2', 40, 100),
 ('PART-KEY-KWIKSET', '0003', 'K', 'K2', 20, 50),
 ('PART-KEYPAD-LOCK', '0001', 'C', 'C4', 1, 2),
 ('PART-KEYPAD-LOCK', '0004', 'C', 'C4', 1, 2),
 ('PART-KEYPAD-MORTISE', '0001', 'C', 'C5', 1, 2),
 ('PART-KEYPAD-MORTISE', '0005', 'C', 'C5', 1, 1),
 ('PART-SAFE-DIAL', '0001', 'S', 'S1', 1, 3),
 ('PART-SAFE-DIAL', '0003', 'S', 'S1', 1, 1),
 ('PART-SAFE-DIAL', '0009', 'S', 'S1', 1, 1),
 ('PART-SAFE-ELECTRONIC', '0001', 'S', 'S2', 1, 2),
 ('PART-SAFE-ELECTRONIC', '0003', 'S', 'S2', 1, 1),
 ('PART-MAGLOCK', '0001', 'M', 'M1', 1, 2),
 ('PART-MAGLOCK', '0004', 'M', 'M1', 1, 1),
 ('PART-MAGLOCK', '0008', 'M', 'M1', 1, 1),
 ('PART-STRIKE-EL', '0001', 'M', 'M2', 2, 4),
 ('PART-STRIKE-EL', '0004', 'M', 'M2', 1, 2),
 ('PART-STRIKE-EL', '0008', 'M', 'M2', 1, 2),
 ('PART-READER-PROX', '0001', 'R', 'R1', 2, 4),
 ('PART-READER-PROX', '0004', 'R', 'R1', 1, 2),
 ('PART-READER-BIO', '0001', 'R', 'R2', 1, 2),
 ('PART-READER-BIO', '0005', 'R', 'R2', 1, 1),
 ('PART-CAMERA-DOME', '0001', 'V', 'V1', 1, 2),
 ('PART-CAMERA-DOME', '0008', 'V', 'V1', 1, 1),
 ('PART-CAMERA-BULLET', '0001', 'V', 'V2', 1, 2),
 ('PART-CAMERA-BULLET', '0008', 'V', 'V2', 1, 1),
 ('PART-PANIC-BAR', '0001', 'H', 'H1', 1, 2),
 ('PART-PANIC-BAR', '0002', 'H', 'H1', 1, 1),
 ('PART-CLOSER-GRADE1', '0001', 'H', 'H2', 2, 4),
 ('PART-CLOSER-GRADE1', '0002', 'H', 'H2', 1, 2),
 ('PART-CLOSER-GRADE1', '0007', 'H', 'H2', 1, 2),
 ('PART-HINGE-BB', '0001', 'H', 'H3', 10, 20),
 ('PART-HINGE-BB', '0002', 'H', 'H3', 5, 10),
 ('PART-THRESHOLD', '0001', 'H', 'H4', 3, 6),
 ('PART-WEATHERSTRIP', '0001', 'H', 'H5', 6, 12),
 ('PART-KEY-BLANK-ASSORTED', '0001', 'K', 'K3', 3, 6),
 ('PART-KEY-BLANK-HIGHSEC', '0001', 'K', 'K4', 4, 8),
 ('PART-KEY-BLANK-HIGHSEC', '0006', 'K', 'K4', 2, 4),
 ('PART-TOOL-PICK-SET', '0001', 'T', 'T1', 1, 2),
 ('PART-TOOL-DRILL-KIT', '0001', 'T', 'T2', 1, 2),
 ('PART-TOOL-DRILL-KIT', '0003', 'T', 'T2', 1, 1),
 ('PART-TOOL-INSTALL-KIT', '0001', 'T', 'T3', 1, 2),
 ('PART-TOOL-DIAGNOSTIC', '0001', 'T', 'T4', 1, 1),
 ('PART-TOOL-KEY-MACHINE', '0001', 'T', 'T5', 1, 1),
 ('PART-TOOL-SAFE-DRILL', '0001', 'T', 'T6', 1, 1),
 ('PART-TOOL-SAFE-DRILL', '0003', 'T', 'T6', 1, 1),
 ('PART-BATTERY-CR123', '0001', 'P', 'P1', 20, 40),
 ('PART-BATTERY-CR123', '0002', 'P', 'P1', 10, 20),
 ('PART-BATTERY-AA-LITHIUM', '0001', 'P', 'P2', 12, 24),
 ('PART-BATTERY-AA-LITHIUM', '0002', 'P', 'P2', 6, 12);

INSERT INTO exp_tables.venparts (vendor, part, venpart, lastpurchaseprice, datelastpurchase)
VALUES
 ('ALGO', 'PART-DEADBOLT-GRADE1', 'B660P-626', 64, '2026-04-18 00:00:00'),
 ('ALGO', 'PART-KEY-SCHLAGE', 'SC1-BLANK', 0.8, '2026-04-20 00:00:00'),
 ('ALGO', 'PART-KEYPAD-LOCK', 'CO100-CY70-KP', 148, '2026-04-12 00:00:00'),
 ('ALGO', 'PART-IC-CORE', 'LFIC-6-SC', 30, '2026-04-15 00:00:00'),
 ('ALGO', 'PART-BATTERY-CR123', 'CR123A-DUR', 3, '2026-04-22 00:00:00'),
 ('ALGO', 'PART-BATTERY-AA-LITHIUM', 'L91-ENER', 5, '2026-04-25 00:00:00'),
 ('MULK', 'PART-SFIC-CORE', 'SFIC-6-KA', 27, '2026-04-22 00:00:00'),
 ('MULK', 'PART-KEY-BLANK-HIGHSEC', 'M3-KEY-REST', 16, '2026-04-28 00:00:00'),
 ('AMSE', 'PART-SAFE-DIAL', 'DLK-1', 92, '2026-04-08 00:00:00'),
 ('AMSE', 'PART-SAFE-ELECTRONIC', 'ESL-10-AUD', 135, '2026-04-10 00:00:00'),
 ('KABA', 'PART-KEY-KWIKSET', 'KW1-BLANK', 0.7, '2026-04-18 00:00:00'),
 ('KABA', 'PART-KEY-BLANK-ASSORTED', 'MIX-50-BOX', 20, '2026-04-20 00:00:00'),
 ('KABA', 'PART-TOOL-PICK-SET', 'PXS-14', 40, '2026-04-05 00:00:00'),
 ('KABA', 'PART-TOOL-DRILL-KIT', 'DRILL-KIT-HPC', 78, '2026-04-12 00:00:00'),
 ('KABA', 'PART-TOOL-INSTALL-KIT', 'INST-KIT-HPC', 50, '2026-04-14 00:00:00'),
 ('KABA', 'PART-TOOL-DIAGNOSTIC', 'DIAG-PRO', 115, '2026-04-16 00:00:00'),
 ('KABA', 'PART-TOOL-KEY-MACHINE', '009-ILCO', 450, '2026-03-20 00:00:00'),
 ('KABA', 'PART-TOOL-SAFE-DRILL', 'SAFE-DRILL-HPC', 225, '2026-03-25 00:00:00'),
 ('HIDG', 'PART-READER-PROX', 'ProxPoint-Plus', 78, '2026-04-15 00:00:00'),
 ('HIDG', 'PART-READER-BIO', 'iCLASS-RB25', 180, '2026-04-18 00:00:00'),
 ('ASSA', 'PART-PANIC-BAR', '99-RIM-36', 175, '2026-04-12 00:00:00'),
 ('ASSA', 'PART-CLOSER-GRADE1', '4040XP-SC', 88, '2026-04-14 00:00:00'),
 ('ASSA', 'PART-HINGE-BB', 'BB1279-45', 10, '2026-04-16 00:00:00'),
 ('ASSA', 'PART-THRESHOLD', '2005AT-36', 16, '2026-04-18 00:00:00'),
 ('ASSA', 'PART-WEATHERSTRIP', 'S88D-BRN', 5, '2026-04-20 00:00:00'),
 ('YALE', 'PART-DEADBOLT-GRADE2', 'YRD256-NR', 38, '2026-04-22 00:00:00'),
 ('SECU', 'PART-MAGLOCK', 'M62-1200', 115, '2026-04-10 00:00:00'),
 ('HES', 'PART-STRIKE-EL', '1006CS-32D', 62, '2026-04-12 00:00:00'),
 ('STAN', 'PART-CAMERA-DOME', 'DOME-4MP-IR', 135, '2026-04-15 00:00:00'),
 ('STAN', 'PART-CAMERA-BULLET', 'BULLET-4MP-IP', 115, '2026-04-18 00:00:00'),
 ('SARG', 'PART-KEYPAD-MORTISE', 'KP-8200-LN', 265, '2026-04-20 00:00:00'),
 ('MED', 'PART-KEY-BLANK-HIGHSEC', 'M3-KEY-MED', 16, '2026-04-25 00:00:00');

INSERT INTO exp_tables.customer (
 custno, lastname, firstname, add1, city, state, zip, phone1, creditrate, terms,
 pricecode, discount, latecharge, statement, requirepo, post, defpriority,
 salesperson, customerinactive, dateadded, datemodified, fullname, website
) VALUES
 ('0001001', 'Bow Valley Medical Clinic', 'Accounts Payable', '220 8 Ave SW', 'Calgary', 'AB', 'T2P 1B5', '4035552101', 'A', 'Net 30',
 'A', 0, 0, 1, 1, 'Y', 'STD', '0003', 0, '2026-05-01 09:00:00', '2026-05-01 09:00:00', 'Bow Valley Medical Clinic', 'https://bowvalleyclinic.example'),
 ('0001002', 'Prairie Bean Cafe', 'Jordan Ellis', '1215 9 Ave SE', 'Calgary', 'AB', 'T2G 0S9', '4035552102', 'B', 'Due on Receipt',
 'A', 0, 0, 1, 0, 'Y', 'HIGH', '0003', 0, '2026-05-01 09:15:00', '2026-05-01 09:15:00', 'Prairie Bean Cafe', 'https://prairiebean.example'),
 ('0001003', 'Northstar Property Group', 'Facilities Desk', '707 5 St SW', 'Calgary', 'AB', 'T2P 0Y3', '4035552103', 'A', 'Net 15',
 'A', 5, 0, 1, 1, 'Y', 'STD', '0003', 0, '2026-05-01 09:30:00', '2026-05-01 09:30:00', 'Northstar Property Group', 'https://northstarproperties.example'),
 ('0001004', 'Calgary Central Office Tower', 'Property Management', '140 4 Ave SW', 'Calgary', 'AB', 'T2P 3N4', '4035552104', 'A', 'Net 30',
 'A', 0, 0, 1, 1, 'Y', 'STD', '0003', 0, '2026-05-01 09:45:00', '2026-05-01 09:45:00', 'Calgary Central Office Tower', 'https://ccotower.example'),
 ('0001005', 'Heritage Hills Retail Plaza', 'Operations', '855 Heritage Dr SE', 'Calgary', 'AB', 'T2H 3A6', '4035552105', 'B', 'Net 15',
 'A', 0, 0, 1, 0, 'Y', 'STD', '0003', 0, '2026-05-01 10:00:00', '2026-05-01 10:00:00', 'Heritage Hills Retail Plaza', 'https://heritagehills.example'),
 ('0001006', 'Riverside Warehouse District', 'Security Desk', '3216 17 Ave SE', 'Calgary', 'AB', 'T2A 0R1', '4035552106', 'C', 'Due on Receipt',
 'A', 0, 0, 1, 0, 'Y', 'LOW', '0003', 0, '2026-05-01 10:15:00', '2026-05-01 10:15:00', 'Riverside Warehouse District', 'https://riversidewh.example'),
 ('0001007', 'Westbrook High School', 'Facilities', '4416 5 St SW', 'Calgary', 'AB', 'T2S 2B3', '4035552107', 'A', 'Net 30',
 'A', 10, 0, 1, 1, 'Y', 'STD', '0003', 0, '2026-05-01 10:30:00', '2026-05-01 10:30:00', 'Westbrook High School', 'https://westbrookhs.example'),
 ('0001008', 'Parkside Condominiums', 'Condo Board', '1108 6 Ave SW', 'Calgary', 'AB', 'T2P 5K1', '4035552108', 'A', 'Net 15',
 'A', 0, 0, 1, 1, 'Y', 'STD', '0003', 0, '2026-05-01 10:45:00', '2026-05-01 10:45:00', 'Parkside Condominiums', 'https://parksidecondo.example'),
 ('0001009', 'First Calgary Bank', 'Branch Operations', '645 7 Ave SW', 'Calgary', 'AB', 'T2P 0Y8', '4035552109', 'A', 'Net 30',
 'A', 0, 0, 1, 1, 'Y', 'HIGH', '0003', 0, '2026-05-01 11:00:00', '2026-05-01 11:00:00', 'First Calgary Bank', 'https://firstcalgarybank.example'),
 ('0001010', 'Ironworks Gym', 'Manager', '1133 17 Ave SW', 'Calgary', 'AB', 'T2T 5B4', '4035552110', 'B', 'Due on Receipt',
 'A', 0, 0, 1, 0, 'Y', 'STD', '0003', 0, '2026-05-01 11:15:00', '2026-05-01 11:15:00', 'Ironworks Gym', 'https://ironworksgym.example'),
 ('0001011', 'Shoppers Drug Mart #4521', 'Store Manager', '2525 36 St NE', 'Calgary', 'AB', 'T1Y 5T4', '4035552111', 'A', 'Net 30',
 'A', 0, 0, 1, 1, 'Y', 'STD', '0003', 0, '2026-05-01 11:30:00', '2026-05-01 11:30:00', 'Shoppers Drug Mart #4521', 'https://shoppersdm.example'),
 ('0001012', 'Southcentre Mall', 'Security Office', '100 Anderson Rd SE', 'Calgary', 'AB', 'T2J 3V1', '4035552112', 'A', 'Net 15',
 'A', 5, 0, 1, 1, 'Y', 'STD', '0003', 0, '2026-05-01 11:45:00', '2026-05-01 11:45:00', 'Southcentre Mall', 'https://southcentremall.example'),
 ('0001013', 'Calgary International Airport', 'Facilities Mgmt', '2000 Airport Rd NE', 'Calgary', 'AB', 'T2E 6W8', '4035552113', 'A', 'Net 30',
 'A', 0, 0, 1, 1, 'Y', 'HIGH', '0003', 0, '2026-05-01 12:00:00', '2026-05-01 12:00:00', 'Calgary International Airport', 'https://yycairport.example'),
 ('0001014', 'Fairmont Palliser Hotel', 'Chief Engineer', '133 9 Ave SW', 'Calgary', 'AB', 'T2P 2M7', '4035552114', 'A', 'Net 30',
 'A', 0, 0, 1, 1, 'Y', 'STD', '0003', 0, '2026-05-01 12:15:00', '2026-05-01 12:15:00', 'Fairmont Palliser Hotel', 'https://fairmontpalliser.example'),
 ('0001015', 'Alberta Manufacturing Ltd', 'Plant Security', '2805 32 Ave NE', 'Calgary', 'AB', 'T1Y 6B8', '4035552115', 'B', 'Net 45',
 'A', 0, 0, 1, 0, 'Y', 'STD', '0003', 0, '2026-05-01 12:30:00', '2026-05-01 12:30:00', 'Alberta Manufacturing Ltd', 'https://abmfg.example');

INSERT INTO exp_tables.location (
 custno, locno, add1, add2, city, state, zip, phone1, notes, taxcode, laborrate,
 helperrate, zone, contact, salutation, branch, tripcharge, taxfrp, email,
 streetnum, street, latitude, longitude, locname, disableemails, geofenceupdated,
 contact2, email2, jobtitle1, jobtitle2, locationinactive, emailtasks1, emailtasks2,
 emailtasks3, emailtasks4, emailtasks5, emailtasks6, receivesnotifications
) VALUES
 ('0001001', '00001', '220 8 Ave SW', 'Suite 400', 'Calgary', 'AB', 'T2P 1B5', '4035552101',
 'Medical clinic with controlled medication cabinet and restricted keyway.', 'GST5', 125, 85, 'DT', 'Mia Hart', 'Mia', 'Downtown', 49, 1,
 'facilities@bowvalleyclinic.example', '220', '8 Ave SW', 5104660, -1140708, 'Clinic Main Suite', 0, 1, 'Omar Reed', 'ap@bowvalleyclinic.example', 'Office Manager', 'Accounts Payable', 0, 1, 1, 1, 0, 0, 0, 1),
 ('0001002', '00001', '1215 9 Ave SE', NULL, 'Calgary', 'AB', 'T2G 0S9', '4035552102',
 'Cafe front door, rear alley door, drop safe, and cash office.', 'GST5', 125, 85, 'IN', 'Jordan Ellis', 'Jordan', 'Inglewood', 49, 1,
 'owner@prairiebean.example', '1215', '9 Ave SE', 5103932, -1140362, 'Cafe Storefront', 0, 1, 'Sam Iqbal', 'manager@prairiebean.example', 'Owner', 'Manager', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001003', '00001', '707 5 St SW', 'Floor 12', 'Calgary', 'AB', 'T2P 0Y3', '4035552103',
 'Commercial office tower common doors and tenant changeovers.', 'GST5', 125, 85, 'DT', 'Priya Shah', 'Priya', 'Downtown', 49, 1,
 'facilities@northstarproperties.example', '707', '5 St SW', 5104930, -1140743, 'Northstar Office Tower', 0, 1, 'Evan Cole', 'ap@northstarproperties.example', 'Facilities Manager', 'Accounts Payable', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001004', '00001', '140 4 Ave SW', 'Lobby', 'Calgary', 'AB', 'T2P 3N4', '4035552104',
 'Class A office tower, 32 floors, master key system and access control.', 'GST5', 125, 85, 'DT', 'Rebecca Liu', 'Rebecca', 'Downtown', 49, 1,
 'property@ccotower.example', '140', '4 Ave SW', 5104820, -1140680, 'CCO Tower Main', 0, 1, 'Mark Torres', 'security@ccotower.example', 'Property Manager', 'Security Director', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001005', '00001', '855 Heritage Dr SE', 'Unit 100', 'Calgary', 'AB', 'T2H 3A6', '4035552105',
 'Retail plaza with 24 units, shared parking and loading dock access.', 'GST5', 125, 85, 'SE', 'Daniel Park', 'Daniel', 'Heritage', 49, 1,
 'ops@heritagehills.example', '855', 'Heritage Dr SE', 5103120, -1140480, 'Heritage Plaza Main', 0, 1, 'Sarah Kim', 'maintenance@heritagehills.example', 'Operations Manager', 'Maintenance Lead', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001006', '00001', '3216 17 Ave SE', 'Bay 12', 'Calgary', 'AB', 'T2A 0R1', '4035552106',
 'Industrial warehouse complex, 8 units, truck bay and perimeter fencing.', 'GST5', 125, 85, 'SE', 'Ahmed Hassan', 'Ahmed', 'Riverside', 49, 1,
 'security@riversidewh.example', '3216', '17 Ave SE', 5102850, -1140250, 'Riverside Warehouse 12', 0, 1, 'Lisa Wong', 'admin@riversidewh.example', 'Security Manager', 'Admin', 0, 1, 1, 1, 0, 0, 0, 1),
 ('0001007', '00001', '4416 5 St SW', 'Main Building', 'Calgary', 'AB', 'T2S 2B3', '4035552107',
 'Public high school, 1200 students, 45 classrooms, gym and auditorium.', 'GST5', 125, 85, 'SW', 'Patricia Moore', 'Patricia', 'Westbrook', 49, 1,
 'facilities@westbrookhs.example', '4416', '5 St SW', 5104250, -1140850, 'Westbrook High Main', 0, 1, 'James Chen', 'it@westbrookhs.example', 'Facilities Manager', 'IT Director', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001008', '00001', '1108 6 Ave SW', 'Concierge', 'Calgary', 'AB', 'T2P 5K1', '4035552108',
 '24-story condo tower, 180 units, underground parking and amenity floor.', 'GST5', 125, 85, 'DT', 'Robert Singh', 'Robert', 'Parkside', 49, 1,
 'board@parksidecondo.example', '1108', '6 Ave SW', 5104750, -1140720, 'Parkside Tower Lobby', 0, 1, 'Maria Garcia', 'management@parksidecondo.example', 'Board President', 'Property Manager', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001009', '00001', '645 7 Ave SW', 'Main Branch', 'Calgary', 'AB', 'T2P 0Y8', '4035552109',
 'Bank branch with vault, safety deposit boxes, and ATM lobby.', 'GST5', 125, 85, 'DT', 'Jennifer Walsh', 'Jennifer', 'Downtown', 49, 1,
 'branch@firstcalgarybank.example', '645', '7 Ave SW', 5104900, -1140750, 'First Calgary Main', 0, 1, 'Michael Brown', 'security@firstcalgarybank.example', 'Branch Manager', 'Security Officer', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001010', '00001', '1133 17 Ave SW', 'Ground Floor', 'Calgary', 'AB', 'T2T 5B4', '4035552110',
 '24-hour gym with locker rooms, front desk, and rear service entrance.', 'GST5', 125, 85, 'SW', 'Chris Anderson', 'Chris', 'Ironworks', 49, 1,
 'manager@ironworksgym.example', '1133', '17 Ave SW', 5104100, -1140600, 'Ironworks Main', 0, 1, 'Nicole Taylor', 'maintenance@ironworksgym.example', 'General Manager', 'Maintenance', 0, 1, 1, 1, 0, 0, 0, 1),
 ('0001011', '00001', '2525 36 St NE', 'Storefront', 'Calgary', 'AB', 'T1Y 5T4', '4035552111',
 'Pharmacy with narcotics safe, consultation room, and staff area.', 'GST5', 125, 85, 'NE', 'Amanda Foster', 'Amanda', 'Northeast', 49, 1,
 'manager@shoppersdm.example', '2525', '36 St NE', 5105500, -1139800, 'Shoppers #4521', 0, 1, 'David Lee', 'pharmacy@shoppersdm.example', 'Store Manager', 'Pharmacist', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001012', '00001', '100 Anderson Rd SE', 'Security Office', 'Calgary', 'AB', 'T2J 3V1', '4035552112',
 'Regional mall with 180 stores, food court, and multi-level parking.', 'GST5', 125, 85, 'SE', 'Stephanie Grant', 'Stephanie', 'Southcentre', 49, 1,
 'security@southcentremall.example', '100', 'Anderson Rd SE', 5103200, -1140650, 'Southcentre Security', 0, 1, 'Ryan Clark', 'ops@southcentremall.example', 'Security Director', 'Operations', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001013', '00001', '2000 Airport Rd NE', 'Terminal Building', 'Calgary', 'AB', 'T2E 6W8', '4035552113',
 'Airport terminal with restricted areas, customs, and baggage handling.', 'GST5', 125, 85, 'NE', 'Andrew Mitchell', 'Andrew', 'Airport', 49, 1,
 'facilities@yycairport.example', '2000', 'Airport Rd NE', 5106000, -1139200, 'YYC Terminal', 0, 1, 'Laura Adams', 'security@yycairport.example', 'Facilities Manager', 'Security Director', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001014', '00001', '133 9 Ave SW', 'Engineering', 'Calgary', 'AB', 'T2P 2M7', '4035552114',
 'Historic hotel with 407 rooms, ballroom, restaurant, and back-of-house.', 'GST5', 125, 85, 'DT', 'Thomas Wright', 'Thomas', 'Palliser', 49, 1,
 'engineering@fairmontpalliser.example', '133', '9 Ave SW', 5104700, -1140690, 'Palliser Engineering', 0, 1, 'Helen Zhou', 'gm@fairmontpalliser.example', 'Chief Engineer', 'General Manager', 0, 1, 1, 1, 1, 0, 0, 1),
 ('0001015', '00001', '2805 32 Ave NE', 'Plant 1', 'Calgary', 'AB', 'T1Y 6B8', '4035552115',
 'Manufacturing plant with 3 buildings, tool crib, and shipping dock.', 'GST5', 125, 85, 'NE', 'Kevin O''Brien', 'Kevin', 'Northeast', 49, 1,
 'security@abmfg.example', '2805', '32 Ave NE', 5105600, -1139700, 'AB Mfg Plant 1', 0, 1, 'Sandra Miller', 'ops@abmfg.example', 'Plant Security', 'Operations Manager', 0, 1, 1, 1, 0, 0, 0, 1);

INSERT INTO exp_tables.customercontacts (id, custno, locnum, name, phone, email)
VALUES
 (9001, '0001001', '00001', 'Mia Hart', '4035553101', 'facilities@bowvalleyclinic.example'),
 (9002, '0001002', '00001', 'Jordan Ellis', '4035553102', 'owner@prairiebean.example'),
 (9003, '0001003', '00001', 'Priya Shah', '4035553103', 'facilities@northstarproperties.example'),
 (9004, '0001004', '00001', 'Rebecca Liu', '4035553104', 'property@ccotower.example'),
 (9005, '0001005', '00001', 'Daniel Park', '4035553105', 'ops@heritagehills.example'),
 (9006, '0001006', '00001', 'Ahmed Hassan', '4035553106', 'security@riversidewh.example'),
 (9007, '0001007', '00001', 'Patricia Moore', '4035553107', 'facilities@westbrookhs.example'),
 (9008, '0001008', '00001', 'Robert Singh', '4035553108', 'board@parksidecondo.example'),
 (9009, '0001009', '00001', 'Jennifer Walsh', '4035553109', 'branch@firstcalgarybank.example'),
 (9010, '0001010', '00001', 'Chris Anderson', '4035553110', 'manager@ironworksgym.example'),
 (9011, '0001011', '00001', 'Amanda Foster', '4035553111', 'manager@shoppersdm.example'),
 (9012, '0001012', '00001', 'Stephanie Grant', '4035553112', 'security@southcentremall.example'),
 (9013, '0001013', '00001', 'Andrew Mitchell', '4035553113', 'facilities@yycairport.example'),
 (9014, '0001014', '00001', 'Thomas Wright', '4035553114', 'engineering@fairmontpalliser.example'),
 (9015, '0001015', '00001', 'Kevin O''Brien', '4035553115', 'security@abmfg.example');

INSERT INTO exp_tables.jobs (
 name, custno, supervisor, start, projend, post, jobid, location, jobstatus,
 jobnotes, inactive, jobsalesperson, defaultdeptid, certifiedjob, jobtype
) VALUES
 ('Clinic restricted keyway rekey', '0001001', '0001', '2026-05-04 08:00:00', '2026-05-04 17:00:00', 'Y', 'job-demo-clinic-rekey', '00001', 1,
 'Rekey treatment rooms and medication cabinet to restricted keyway.', 0, '0003', 'dept-service-demo', 0, 1),
 ('Cafe safe lockout and dial service', '0001002', '0002', '2026-05-03 18:00:00', '2026-05-03 22:00:00', 'Y', 'job-demo-cafe-safe', '00001', 1,
 'After-hours safe lockout, dial replacement, and manager code reset.', 0, '0003', 'dept-safe-demo', 0, 2),
 ('Office keypad access upgrade', '0001003', '0001', '2026-05-06 09:00:00', '2026-05-06 15:00:00', 'Y', 'job-demo-property-access', '00001', 0,
 'Install standalone keypad lever on staff entrance and issue master code.', 0, '0003', 'dept-install-demo', 0, 1),
 ('CCO Tower master key system', '0001004', '0005', '2026-05-08 08:00:00', '2026-05-15 17:00:00', 'Y', 'job-demo-office-master', '00001', 0,
 'Design and implement 4-level master key system for 32-floor tower.', 0, '0003', 'dept-keys-demo', 0, 1),
 ('Heritage Plaza rekey all units', '0001005', '0001', '2026-05-10 09:00:00', '2026-05-12 17:00:00', 'Y', 'job-demo-retail-rekey', '00001', 0,
 'Rekey all 24 retail units after tenant turnover. New restricted keyway.', 0, '0003', 'dept-service-demo', 0, 1),
 ('Riverside warehouse perimeter audit', '0001006', '0004', '2026-05-12 08:00:00', '2026-05-12 16:00:00', 'Y', 'job-demo-warehouse-audit', '00001', 0,
 'Security audit of all perimeter doors, gates, and loading dock locks.', 0, '0003', 'dept-access-demo', 0, 1),
 ('Westbrook High master key', '0001007', '0005', '2026-05-15 08:00:00', '2026-05-22 17:00:00', 'Y', 'job-demo-school-master', '00001', 0,
 'Grand master key system for 45 classrooms, gym, auditorium, and offices.', 0, '0003', 'dept-keys-demo', 0, 1),
 ('Parkside condo fob system', '0001008', '0004', '2026-05-18 09:00:00', '2026-05-20 17:00:00', 'Y', 'job-demo-condo-fob', '00001', 0,
 'Install proximity fob access for main entrance, parking, and amenity floor.', 0, '0003', 'dept-access-demo', 0, 1),
 ('Bank vault lock upgrade', '0001009', '0002', '2026-05-20 18:00:00', '2026-05-21 06:00:00', 'Y', 'job-demo-bank-vault', '00001', 0,
 'Upgrade vault combination lock to electronic with dual control and audit.', 0, '0003', 'dept-safe-demo', 0, 2),
 ('Gym locker rekey', '0001010', '0001', '2026-05-22 06:00:00', '2026-05-22 14:00:00', 'Y', 'job-demo-gym-lockers', '00001', 0,
 'Rekey 200 gym lockers and install new hasp locks on locker room doors.', 0, '0003', 'dept-service-demo', 0, 1),
 ('Pharmacy safe compliance', '0001011', '0002', '2026-05-25 08:00:00', '2026-05-25 16:00:00', 'Y', 'job-demo-pharmacy-safe', '00001', 0,
 'Narcotics safe compliance audit, combination change, and bolt work inspection.', 0, '0003', 'dept-safe-demo', 0, 2),
 ('Mall access control upgrade', '0001012', '0004', '2026-05-28 20:00:00', '2026-06-02 06:00:00', 'Y', 'job-demo-mall-access', '00001', 0,
 'Upgrade 12 service entrance readers to biometric with card fallback.', 0, '0003', 'dept-access-demo', 0, 1),
 ('Airport TSA lock compliance', '0001013', '0006', '2026-06-01 22:00:00', '2026-06-02 06:00:00', 'Y', 'job-demo-airport-tsa', '00001', 0,
 'TSA-approved lock installation on all restricted area access points.', 0, '0003', 'dept-emergency-demo', 0, 1),
 ('Hotel guest room rekey', '0001014', '0001', '2026-06-03 08:00:00', '2026-06-05 18:00:00', 'Y', 'job-demo-hotel-rekey', '00001', 0,
 'Rekey all 407 guest rooms after security incident. New keycard system.', 0, '0003', 'dept-service-demo', 0, 1),
 ('Manufacturing plant access', '0001015', '0004', '2026-06-08 07:00:00', '2026-06-12 17:00:00', 'Y', 'job-demo-mfg-access', '00001', 0,
 'Install maglocks and card readers on all 3 plant buildings with central control.', 0, '0003', 'dept-access-demo', 0, 1);

INSERT INTO exp_tables.dispatch (
 custno, locno, billloc, zone, dispatch, calledinby, terms, ponum, recdate, rectime, recby,
 priority, invoice, complete, techtime, multitech, notes, invoiced, jobnumber, sort,
 ahsdispatch, quotesource, servfreqflag, servagrorderparts
) VALUES
 ('0001002', '00001', '00001', 'IN', '000101', 'Jordan Ellis', 'DOR', NULL, '2026-05-03 18:12:00', '18:12', 'LENA',
 'HIGH', '0000002001', '2026-05-03 21:20:00', 2.25, 'N', 'Owner locked out of drop safe after combination drift. Replace dial kit and verify opening.', 1, 'job-demo-cafe-safe', 'SAFE', 1, 'PHONE', 0, 0),
 ('0001001', '00001', '00001', 'DT', '000102', 'Mia Hart', 'N30', 'BVMC-4521', '2026-05-04 08:05:00', '08:05', 'LENA',
 'STD', '0000002002', '2026-05-04 15:40:00', 4.00, 'N', 'Rekey six office cylinders, cut ten restricted keys, and tag cabinet keys.', 1, 'job-demo-clinic-rekey', 'LOCK', 0, 'EMAIL', 0, 0),
 ('0001003', '00001', '00001', 'DT', '000103', 'Priya Shah', 'N15', 'NSPG-8892', '2026-05-06 08:30:00', '08:30', 'LENA',
 'STD', '0000002003', NULL, 1.50, 'N', 'Install keypad lock on staff entrance. Pending final manager walkthrough.', 0, 'job-demo-property-access', 'ACCS', 0, 'PHONE', 0, 0),
 ('0001004', '00001', '00001', 'DT', '000104', 'Rebecca Liu', 'N30', 'CCOT-2026-001', '2026-05-08 08:15:00', '08:15', 'LENA',
 'STD', '0000002004', NULL, 8.00, 'N', 'Master key system design phase. Site survey and key schedule preparation.', 0, 'job-demo-office-master', 'KEYS', 0, 'EMAIL', 0, 0),
 ('0001005', '00001', '00001', 'SE', '000105', 'Daniel Park', 'N15', 'HHP-4522', '2026-05-10 09:00:00', '09:00', 'LENA',
 'STD', '0000002005', NULL, 6.00, 'N', 'Rekey unit 5-8 after tenant departure. Install new deadbolts on loading dock.', 0, 'job-demo-retail-rekey', 'LOCK', 0, 'PHONE', 0, 0),
 ('0001006', '00001', '00001', 'SE', '000106', 'Ahmed Hassan', 'DOR', NULL, '2026-05-12 08:00:00', '08:00', 'LENA',
 'HIGH', '0000002006', '2026-05-12 14:30:00', 5.50, 'N', 'Perimeter security audit. Found 3 compromised locks on north fence line.', 1, 'job-demo-warehouse-audit', 'AUDT', 0, 'PHONE', 0, 0),
 ('0001007', '00001', '00001', 'SW', '000107', 'Patricia Moore', 'N30', 'WBHS-2026-001', '2026-05-15 08:00:00', '08:00', 'LENA',
 'STD', '0000002007', NULL, 7.00, 'N', 'Grand master key system week 1. Rekey administrative offices and staff areas.', 0, 'job-demo-school-master', 'KEYS', 0, 'EMAIL', 0, 0),
 ('0001008', '00001', '00001', 'DT', '000108', 'Robert Singh', 'N30', 'PSC-2026-001', '2026-05-18 09:00:00', '09:00', 'LENA',
 'STD', '0000002008', NULL, 5.00, 'N', 'Fob system installation day 1. Wire readers at main entrance and parking gate.', 0, 'job-demo-condo-fob', 'ACCS', 0, 'EMAIL', 0, 0),
 ('0001009', '00001', '00001', 'DT', '000109', 'Jennifer Walsh', 'N30', 'FCB-2026-001', '2026-05-20 18:00:00', '18:00', 'LENA',
 'EMRG', '0000002009', NULL, 10.00, 'N', 'Vault lock upgrade overnight. Install ESL-10 with dual control and time delay.', 0, 'job-demo-bank-vault', 'SAFE', 0, 'PHONE', 0, 0),
 ('0001010', '00001', '00001', 'SW', '000110', 'Chris Anderson', 'DOR', NULL, '2026-05-22 06:00:00', '06:00', 'LENA',
 'STD', '0000002010', NULL, 6.50, 'N', 'Gym locker rekey day 1. Complete floors 1-2, 100 lockers.', 0, 'job-demo-gym-lockers', 'LOCK', 0, 'PHONE', 0, 0),
 ('0001011', '00001', '00001', 'NE', '000111', 'Amanda Foster', 'N30', 'SDM-2026-001', '2026-05-25 08:00:00', '08:00', 'LENA',
 'HIGH', '0000002011', NULL, 5.00, 'N', 'Narcotics safe compliance audit. Check bolt work, combination, and audit log.', 0, 'job-demo-pharmacy-safe', 'SAFE', 0, 'EMAIL', 0, 0),
 ('0001012', '00001', '00001', 'SE', '000112', 'Stephanie Grant', 'N15', 'SCM-2026-001', '2026-05-28 20:00:00', '20:00', 'LENA',
 'RUSH', '0000002012', NULL, 12.00, 'N', 'Mall access control upgrade night shift. Replace 6 readers with biometric units.', 0, 'job-demo-mall-access', 'ACCS', 0, 'PHONE', 0, 0),
 ('0001013', '00001', '00001', 'NE', '000113', 'Andrew Mitchell', 'N30', 'YYC-2026-001', '2026-06-01 22:00:00', '22:00', 'LENA',
 'EMRG', '0000002013', NULL, 6.00, 'N', 'TSA lock compliance installation on restricted area doors. Night shift.', 0, 'job-demo-airport-tsa', 'INST', 0, 'PHONE', 0, 0),
 ('0001014', '00001', '00001', 'DT', '000114', 'Thomas Wright', 'N30', 'FPH-2026-001', '2026-06-03 08:00:00', '08:00', 'LENA',
 'STD', '0000002014', NULL, 8.00, 'N', 'Hotel guest room rekey day 1. Floors 1-10, 160 rooms.', 0, 'job-demo-hotel-rekey', 'LOCK', 0, 'EMAIL', 0, 0),
 ('0001015', '00001', '00001', 'NE', '000115', 'Kevin O''Brien', 'N45', 'ABM-2026-001', '2026-06-08 07:00:00', '07:00', 'LENA',
 'STD', '0000002015', NULL, 9.00, 'N', 'Manufacturing plant maglock installation day 1. Plant 1 main entrance and shipping.', 0, 'job-demo-mfg-access', 'ACCS', 0, 'EMAIL', 0, 0);

INSERT INTO exp_tables.disptech (
 dispatch, serviceman, counter, status, dispdate, disptime, timeon, timeoff, dateoff,
 dispatcher, complete, promdate, tpromdate, tpromtime, zone, priority, terms, techtime,
 sortdate, sorttime, mobile, poreceived, timeentrycreated, hourspayed
) VALUES
 ('000101', '0002', '001', 'Complete', '2026-05-03 18:30:00', '18:30', '18:55', '21:10', '2026-05-03 21:10:00', 'LENA', 'Y', '2026-05-03', '2026-05-03 19:00:00', '19:00', 'IN', 'HIGH', 'DOR', 2.25, '2026-05-03 18:30:00', '18:30', 1, 0, 1, 2.25),
 ('000102', '0001', '001', 'Complete', '2026-05-04 08:30:00', '08:30', '09:00', '13:00', '2026-05-04 13:00:00', 'LENA', 'Y', '2026-05-04', '2026-05-04 09:00:00', '09:00', 'DT', 'STD', 'N30', 4.00, '2026-05-04 08:30:00', '08:30', 1, 1, 1, 4.00),
 ('000103', '0001', '001', 'Scheduled', '2026-05-06 09:00:00', '09:00', NULL, NULL, NULL, 'LENA', 'N', '2026-05-06', '2026-05-06 09:00:00', '09:00', 'DT', 'STD', 'N15', 1.50, '2026-05-06 09:00:00', '09:00', 1, 1, 0, 0),
 ('000104', '0005', '001', 'InProgress', '2026-05-08 08:30:00', '08:30', '09:00', NULL, NULL, 'LENA', 'N', '2026-05-08', '2026-05-08 09:00:00', '09:00', 'DT', 'STD', 'N30', 8.00, '2026-05-08 08:30:00', '08:30', 1, 1, 1, 4.00),
 ('000105', '0001', '001', 'Scheduled', '2026-05-10 09:00:00', '09:00', NULL, NULL, NULL, 'LENA', 'N', '2026-05-10', '2026-05-10 09:00:00', '09:00', 'SE', 'STD', 'N15', 6.00, '2026-05-10 09:00:00', '09:00', 1, 1, 0, 0),
 ('000106', '0004', '001', 'Complete', '2026-05-12 08:30:00', '08:30', '09:00', '14:30', '2026-05-12 14:30:00', 'LENA', 'Y', '2026-05-12', '2026-05-12 09:00:00', '09:00', 'SE', 'HIGH', 'DOR', 5.50, '2026-05-12 08:30:00', '08:30', 1, 0, 1, 5.50),
 ('000107', '0005', '001', 'InProgress', '2026-05-15 08:00:00', '08:00', '08:30', NULL, NULL, 'LENA', 'N', '2026-05-15', '2026-05-15 08:30:00', '08:30', 'SW', 'STD', 'N30', 7.00, '2026-05-15 08:00:00', '08:00', 1, 1, 1, 3.50),
 ('000108', '0004', '001', 'Scheduled', '2026-05-18 09:00:00', '09:00', NULL, NULL, NULL, 'LENA', 'N', '2026-05-18', '2026-05-18 09:00:00', '09:00', 'DT', 'STD', 'N30', 5.00, '2026-05-18 09:00:00', '09:00', 1, 1, 0, 0),
 ('000109', '0002', '001', 'Scheduled', '2026-05-20 18:00:00', '18:00', NULL, NULL, NULL, 'LENA', 'N', '2026-05-20', '2026-05-20 18:00:00', '18:00', 'DT', 'EMRG', 'N30', 10.00, '2026-05-20 18:00:00', '18:00', 1, 1, 0, 0),
 ('000110', '0001', '001', 'Scheduled', '2026-05-22 06:00:00', '06:00', NULL, NULL, NULL, 'LENA', 'N', '2026-05-22', '2026-05-22 06:00:00', '06:00', 'SW', 'STD', 'DOR', 6.50, '2026-05-22 06:00:00', '06:00', 1, 0, 0, 0),
 ('000111', '0002', '001', 'Scheduled', '2026-05-25 08:00:00', '08:00', NULL, NULL, NULL, 'LENA', 'N', '2026-05-25', '2026-05-25 08:00:00', '08:00', 'NE', 'HIGH', 'N30', 5.00, '2026-05-25 08:00:00', '08:00', 1, 1, 0, 0),
 ('000112', '0004', '001', 'Scheduled', '2026-05-28 20:00:00', '20:00', NULL, NULL, NULL, 'LENA', 'N', '2026-05-28', '2026-05-28 20:00:00', '20:00', 'SE', 'RUSH', 'N15', 12.00, '2026-05-28 20:00:00', '20:00', 1, 1, 0, 0),
 ('000113', '0006', '001', 'Scheduled', '2026-06-01 22:00:00', '22:00', NULL, NULL, NULL, 'LENA', 'N', '2026-06-01', '2026-06-01 22:00:00', '22:00', 'NE', 'EMRG', 'N30', 6.00, '2026-06-01 22:00:00', '22:00', 1, 1, 0, 0),
 ('000114', '0001', '001', 'Scheduled', '2026-06-03 08:00:00', '08:00', NULL, NULL, NULL, 'LENA', 'N', '2026-06-03', '2026-06-03 08:00:00', '08:00', 'DT', 'STD', 'N30', 8.00, '2026-06-03 08:00:00', '08:00', 1, 1, 0, 0),
 ('000115', '0004', '001', 'Scheduled', '2026-06-08 07:00:00', '07:00', NULL, NULL, NULL, 'LENA', 'N', '2026-06-08', '2026-06-08 07:00:00', '07:00', 'NE', 'STD', 'N45', 9.00, '2026-06-08 07:00:00', '07:00', 1, 1, 0, 0);

INSERT INTO exp_tables.dispparts (dispatch, counter, wh, prod, "desc", quan, noprint, price, jobclass, accepted)
VALUES
 ('000101', 1, '0003', 'PART-SAFE-DIAL', 'Mechanical safe dial and lock kit', 1, 0, 245, 'SAFE', 1),
 ('000101', 2, '0003', 'LABOR-COMM', 'Safe service labor', 2.25, 0, 125, 'SAFE', 1),
 ('000101', 3, '0003', 'TRIP-LOCAL', 'After-hours local trip charge', 1, 0, 49, 'SAFE', 1),
 ('000102', 1, '0002', 'PART-SFIC-CORE', 'SFIC interchangeable core, keyed alike', 6, 0, 72, 'LOCK', 1),
 ('000102', 2, '0001', 'PART-KEY-SCHLAGE', 'Restricted key copies', 10, 0, 5.5, 'LOCK', 1),
 ('000102', 3, '0002', 'LABOR-COMM', 'Commercial rekey labor', 4, 0, 125, 'LOCK', 1),
 ('000102', 4, '0002', 'TRIP-LOCAL', 'Local trip charge', 1, 0, 49, 'LOCK', 1),
 ('000103', 1, '0001', 'PART-KEYPAD-LOCK', 'Standalone keypad lever lock', 1, 0, 329, 'ACCS', 1),
 ('000103', 2, '0001', 'LABOR-COMM', 'Access control install labor', 1.5, 0, 125, 'ACCS', 1),
 ('000104', 1, '0006', 'PART-KEY-BLANK-HIGHSEC', 'High security key blanks for master system', 20, 0, 55, 'KEYS', 1),
 ('000104', 2, '0006', 'LABOR-COMM', 'Master key system design labor', 8, 0, 125, 'KEYS', 1),
 ('000105', 1, '0001', 'PART-DEADBOLT-GRADE1', 'Grade 1 commercial deadbolt', 4, 0, 159, 'LOCK', 1),
 ('000105', 2, '0001', 'PART-SFIC-CORE', 'SFIC core for new tenant', 4, 0, 72, 'LOCK', 1),
 ('000105', 3, '0001', 'LABOR-COMM', 'Rekey and install labor', 6, 0, 125, 'LOCK', 1),
 ('000106', 1, '0004', 'PART-DEADBOLT-GRADE1', 'Replacement deadbolt for fence gate', 3, 0, 159, 'AUDT', 1),
 ('000106', 2, '0004', 'PART-MAGLOCK', 'Maglock for loading dock', 1, 0, 289, 'AUDT', 1),
 ('000106', 3, '0004', 'LABOR-COMM', 'Security audit and install labor', 5.5, 0, 125, 'AUDT', 1),
 ('000107', 1, '0006', 'PART-KEY-BLANK-ASSORTED', 'Assorted key blanks for school', 50, 0, 65, 'KEYS', 1),
 ('000107', 2, '0006', 'PART-KEY-BLANK-HIGHSEC', 'High security blanks for admin', 15, 0, 55, 'KEYS', 1),
 ('000107', 3, '0006', 'LABOR-COMM', 'Master key system labor', 7, 0, 125, 'KEYS', 1),
 ('000108', 1, '0004', 'PART-READER-PROX', 'Proximity reader for main entrance', 2, 0, 199, 'ACCS', 1),
 ('000108', 2, '0004', 'PART-READER-PROX', 'Proximity reader for parking gate', 1, 0, 199, 'ACCS', 1),
 ('000108', 3, '0004', 'LABOR-COMM', 'Access control install labor', 5, 0, 125, 'ACCS', 1),
 ('000109', 1, '0003', 'PART-SAFE-ELECTRONIC', 'Electronic safe lock with audit', 1, 0, 375, 'SAFE', 1),
 ('000109', 2, '0003', 'LABOR-COMM', 'Vault lock upgrade labor', 10, 0, 125, 'SAFE', 1),
 ('000109', 3, '0003', 'TRIP-AFTERHRS', 'After-hours trip surcharge', 1, 0, 89, 'SAFE', 1),
 ('000110', 1, '0002', 'PART-DEADBOLT-GRADE2', 'Grade 2 deadbolt for locker room', 4, 0, 99, 'LOCK', 1),
 ('000110', 2, '0002', 'PART-KEY-KWIKSET', 'Key blanks for locker keys', 200, 0, 4.95, 'LOCK', 1),
 ('000110', 3, '0002', 'LABOR-COMM', 'Locker rekey labor', 6.5, 0, 125, 'LOCK', 1),
 ('000111', 1, '0003', 'PART-SAFE-DIAL', 'Safe dial inspection kit', 1, 0, 245, 'SAFE', 1),
 ('000111', 2, '0003', 'PART-SAFE-ELECTRONIC', 'Electronic lock for narcotics safe', 1, 0, 375, 'SAFE', 1),
 ('000111', 3, '0003', 'LABOR-COMM', 'Safe compliance audit labor', 5, 0, 125, 'SAFE', 1),
 ('000112', 1, '0004', 'PART-READER-BIO', 'Biometric reader for service entrance', 6, 0, 449, 'ACCS', 1),
 ('000112', 2, '0004', 'PART-STRIKE-EL', 'Electric strike for biometric readers', 6, 0, 159, 'ACCS', 1),
 ('000112', 3, '0004', 'LABOR-COMM', 'Night shift access control labor', 12, 0, 125, 'ACCS', 1),
 ('000113', 1, '0006', 'PART-DEADBOLT-GRADE1', 'TSA-approved deadbolt', 8, 0, 159, 'INST', 1),
 ('000113', 2, '0006', 'PART-MAGLOCK', 'Maglock for restricted area', 4, 0, 289, 'INST', 1),
 ('000113', 3, '0006', 'LABOR-COMM', 'TSA compliance installation labor', 6, 0, 125, 'INST', 1),
 ('000114', 1, '0002', 'PART-DEADBOLT-GRADE2', 'Grade 2 deadbolt for guest rooms', 160, 0, 99, 'LOCK', 1),
 ('000114', 2, '0002', 'PART-KEY-KWIKSET', 'Key blanks for guest keys', 400, 0, 4.95, 'LOCK', 1),
 ('000114', 3, '0002', 'LABOR-COMM', 'Guest room rekey labor', 8, 0, 125, 'LOCK', 1),
 ('000115', 1, '0004', 'PART-MAGLOCK', 'Maglock for plant entrances', 6, 0, 289, 'ACCS', 1),
 ('000115', 2, '0004', 'PART-READER-PROX', 'Card reader for plant access', 6, 0, 199, 'ACCS', 1),
 ('000115', 3, '0004', 'LABOR-COMM', 'Plant access control labor', 9, 0, 125, 'ACCS', 1);

INSERT INTO exp_tables.sales (
 invoice, regid, clerk, dispatch, custno, locno, pricecode, dept, invdate, entdate,
 period, billloc, shipname, shipaddr1, shipcsz, invtype, salesman, wh, jobnumber,
 ponum, sort, hold, taxcode, laborcost, printed, amtcash, amtcharge, amtcheck,
 amtcreditc, amtchng, post, exempt, formname, invamount, billcompl, billamount,
 matcost, othercost, slterms, duedate, dispnotes, dispparts, transid, modified,
 araccountid, drawrequestno, readonly, quotestatus, amtappliedcredits,
 taxrate1, taxrate2, taxrate3, taxrate4, taxrate5, taxrate6
) VALUES
 ('0000002001', '01', '0003', '000101', '0001002', '00001', 'A', '20', '2026-05-03 21:30:00', '2026-05-03 21:30:00',
 '202605', '00001', 'Prairie Bean Cafe', '1215 9 Ave SE', 'Calgary AB T2G 0S9', 'Invoice', '0003', '0003', 'job-demo-cafe-safe',
 NULL, 'SAFE', 0, 'GST5', 108, 1, 0, 554.14, 0, 0, 0, 'Y', 0, 'Service Invoice', 554.14, 1, 527.75, 96, 0, 'Due on Receipt', '2026-05-03 23:59:59', 1, 1, 'sale-trans-2001', '2026-05-03 21:30:00',
 'acct-ar-demo', 0, 0, 0, 0, 5, 0, 0, 0, 0, 0),
 ('0000002002', '01', '0003', '000102', '0001001', '00001', 'A', '10', '2026-05-04 15:45:00', '2026-05-04 15:45:00',
 '202605', '00001', 'Bow Valley Medical Clinic', '220 8 Ave SW Suite 400', 'Calgary AB T2P 1B5', 'Invoice', '0003', '0002', 'job-demo-clinic-rekey',
 'BVMC-4521', 'LOCK', 0, 'GST5', 168, 1, 0, 1036.35, 0, 0, 0, 'Y', 0, 'Service Invoice', 1036.35, 1, 987.00, 223, 0, 'Net 30', '2026-06-03 23:59:59', 1, 1, 'sale-trans-2002', '2026-05-04 15:45:00',
 'acct-ar-demo', 0, 0, 0, 0, 5, 0, 0, 0, 0, 0),
 ('0000002003', '01', '0003', '000103', '0001003', '00001', 'A', '30', '2026-05-06 12:00:00', '2026-05-06 12:00:00',
 '202605', '00001', 'Northstar Property Group', '707 5 St SW Floor 12', 'Calgary AB T2P 0Y3', 'Quote', '0003', '0001', 'job-demo-property-access',
 'NSPG-8892', 'ACCS', 0, 'GST5', 63, 0, 0, 542.33, 0, 0, 0, 'N', 0, 'Quote', 542.33, 0, 516.50, 155, 0, 'Net 15', '2026-05-21 23:59:59', 1, 1, 'sale-trans-2003', '2026-05-06 12:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002004', '01', '0003', '000104', '0001004', '00001', 'A', '50', '2026-05-08 17:00:00', '2026-05-08 17:00:00',
 '202605', '00001', 'Calgary Central Office Tower', '140 4 Ave SW Lobby', 'Calgary AB T2P 3N4', 'Quote', '0003', '0006', 'job-demo-office-master',
 'CCOT-2026-001', 'KEYS', 0, 'GST5', 0, 0, 0, 1683.50, 0, 0, 0, 'N', 0, 'Quote', 1683.50, 0, 1603.33, 80, 0, 'Net 30', '2026-06-07 23:59:59', 1, 1, 'sale-trans-2004', '2026-05-08 17:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002005', '01', '0003', '000105', '0001005', '00001', 'A', '10', '2026-05-10 17:00:00', '2026-05-10 17:00:00',
 '202605', '00001', 'Heritage Hills Retail Plaza', '855 Heritage Dr SE Unit 100', 'Calgary AB T2H 3A6', 'Quote', '0003', '0001', 'job-demo-retail-rekey',
 'HHP-4522', 'LOCK', 0, 'GST5', 0, 0, 0, 1423.80, 0, 0, 0, 'N', 0, 'Quote', 1423.80, 0, 1356.00, 68, 0, 'Net 15', '2026-05-25 23:59:59', 1, 1, 'sale-trans-2005', '2026-05-10 17:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002006', '01', '0003', '000106', '0001006', '00001', 'A', '40', '2026-05-12 14:45:00', '2026-05-12 14:45:00',
 '202605', '00001', 'Riverside Warehouse District', '3216 17 Ave SE Bay 12', 'Calgary AB T2A 0R1', 'Invoice', '0003', '0004', 'job-demo-warehouse-audit',
 NULL, 'AUDT', 0, 'GST5', 0, 1, 0, 1252.65, 0, 0, 0, 'Y', 0, 'Service Invoice', 1252.65, 1, 1193.00, 60, 0, 'Due on Receipt', '2026-05-12 23:59:59', 1, 1, 'sale-trans-2006', '2026-05-12 14:45:00',
 'acct-ar-demo', 0, 0, 0, 0, 5, 0, 0, 0, 0, 0),
 ('0000002007', '01', '0003', '000107', '0001007', '00001', 'A', '50', '2026-05-15 16:00:00', '2026-05-15 16:00:00',
 '202605', '00001', 'Westbrook High School', '4416 5 St SW Main Building', 'Calgary AB T2S 2B3', 'Quote', '0003', '0006', 'job-demo-school-master',
 'WBHS-2026-001', 'KEYS', 0, 'GST5', 0, 0, 0, 2100.00, 0, 0, 0, 'N', 0, 'Quote', 2100.00, 0, 2000.00, 100, 0, 'Net 30', '2026-06-14 23:59:59', 1, 1, 'sale-trans-2007', '2026-05-15 16:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002008', '01', '0003', '000108', '0001008', '00001', 'A', '40', '2026-05-18 16:00:00', '2026-05-18 16:00:00',
 '202605', '00001', 'Parkside Condominiums', '1108 6 Ave SW Concierge', 'Calgary AB T2P 5K1', 'Quote', '0003', '0004', 'job-demo-condo-fob',
 'PSC-2026-001', 'ACCS', 0, 'GST5', 0, 0, 0, 1522.50, 0, 0, 0, 'N', 0, 'Quote', 1522.50, 0, 1450.00, 72, 0, 'Net 30', '2026-06-17 23:59:59', 1, 1, 'sale-trans-2008', '2026-05-18 16:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002009', '01', '0003', '000109', '0001009', '00001', 'A', '20', '2026-05-21 07:00:00', '2026-05-21 07:00:00',
 '202605', '00001', 'First Calgary Bank', '645 7 Ave SW Main Branch', 'Calgary AB T2P 0Y8', 'Quote', '0003', '0003', 'job-demo-bank-vault',
 'FCB-2026-001', 'SAFE', 0, 'GST5', 0, 0, 0, 2626.25, 0, 0, 0, 'N', 0, 'Quote', 2626.25, 0, 2501.19, 125, 0, 'Net 30', '2026-06-20 23:59:59', 1, 1, 'sale-trans-2009', '2026-05-21 07:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002010', '01', '0003', '000110', '0001010', '00001', 'A', '10', '2026-05-22 14:30:00', '2026-05-22 14:30:00',
 '202605', '00001', 'Ironworks Gym', '1133 17 Ave SW Ground Floor', 'Calgary AB T2T 5B4', 'Quote', '0003', '0002', 'job-demo-gym-lockers',
 NULL, 'LOCK', 0, 'GST5', 0, 0, 0, 1859.25, 0, 0, 0, 'N', 0, 'Quote', 1859.25, 0, 1770.71, 89, 0, 'Due on Receipt', '2026-05-22 23:59:59', 1, 1, 'sale-trans-2010', '2026-05-22 14:30:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002011', '01', '0003', '000111', '0001011', '00001', 'A', '20', '2026-05-25 14:00:00', '2026-05-25 14:00:00',
 '202605', '00001', 'Shoppers Drug Mart #4521', '2525 36 St NE Storefront', 'Calgary AB T1Y 5T4', 'Quote', '0003', '0003', 'job-demo-pharmacy-safe',
 'SDM-2026-001', 'SAFE', 0, 'GST5', 0, 0, 0, 1312.50, 0, 0, 0, 'N', 0, 'Quote', 1312.50, 0, 1250.00, 62, 0, 'Net 30', '2026-06-24 23:59:59', 1, 1, 'sale-trans-2011', '2026-05-25 14:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002012', '01', '0003', '000112', '0001012', '00001', 'A', '40', '2026-06-02 07:00:00', '2026-06-02 07:00:00',
 '202605', '00001', 'Southcentre Mall', '100 Anderson Rd SE Security', 'Calgary AB T2J 3V1', 'Quote', '0003', '0004', 'job-demo-mall-access',
 'SCM-2026-001', 'ACCS', 0, 'GST5', 0, 0, 0, 5040.00, 0, 0, 0, 'N', 0, 'Quote', 5040.00, 0, 4800.00, 240, 0, 'Net 15', '2026-06-17 23:59:59', 1, 1, 'sale-trans-2012', '2026-06-02 07:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002013', '01', '0003', '000113', '0001013', '00001', 'A', '60', '2026-06-02 06:00:00', '2026-06-02 06:00:00',
 '202605', '00001', 'Calgary International Airport', '2000 Airport Rd NE Terminal', 'Calgary AB T2E 6W8', 'Quote', '0003', '0006', 'job-demo-airport-tsa',
 'YYC-2026-001', 'INST', 0, 'GST5', 0, 0, 0, 2835.00, 0, 0, 0, 'N', 0, 'Quote', 2835.00, 0, 2700.00, 135, 0, 'Net 30', '2026-07-02 23:59:59', 1, 1, 'sale-trans-2013', '2026-06-02 06:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002014', '01', '0003', '000114', '0001014', '00001', 'A', '10', '2026-06-05 17:00:00', '2026-06-05 17:00:00',
 '202605', '00001', 'Fairmont Palliser Hotel', '133 9 Ave SW Engineering', 'Calgary AB T2P 2M7', 'Quote', '0003', '0002', 'job-demo-hotel-rekey',
 'FPH-2026-001', 'LOCK', 0, 'GST5', 0, 0, 0, 17482.50, 0, 0, 0, 'N', 0, 'Quote', 17482.50, 0, 16650.00, 832, 0, 'Net 30', '2026-07-05 23:59:59', 1, 1, 'sale-trans-2014', '2026-06-05 17:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0),
 ('0000002015', '01', '0003', '000115', '0001015', '00001', 'A', '40', '2026-06-12 17:00:00', '2026-06-12 17:00:00',
 '202605', '00001', 'Alberta Manufacturing Ltd', '2805 32 Ave NE Plant 1', 'Calgary AB T1Y 6B8', 'Quote', '0003', '0004', 'job-demo-mfg-access',
 'ABM-2026-001', 'ACCS', 0, 'GST5', 0, 0, 0, 4095.00, 0, 0, 0, 'N', 0, 'Quote', 4095.00, 0, 3900.00, 195, 0, 'Net 45', '2026-07-27 23:59:59', 1, 1, 'sale-trans-2015', '2026-06-12 17:00:00',
 'acct-ar-demo', 0, 0, 1, 0, 5, 0, 0, 0, 0, 0);

INSERT INTO exp_tables.salesemp (invoice, count, credit, emp, reghr, othr, labamt, overhead, dispatch)
VALUES
 ('0000002001', '001', 100, '0002', 2.25, 0, 281.25, 45, '000101'),
 ('0000002002', '001', 100, '0001', 4.00, 0, 500.00, 72, '000102'),
 ('0000002003', '001', 100, '0001', 1.50, 0, 187.50, 27, '000103'),
 ('0000002004', '001', 100, '0005', 8.00, 0, 1000.00, 176, '000104'),
 ('0000002005', '001', 100, '0001', 6.00, 0, 750.00, 108, '000105'),
 ('0000002006', '001', 100, '0004', 5.50, 0, 687.50, 121, '000106'),
 ('0000002007', '001', 100, '0005', 7.00, 0, 875.00, 140, '000107'),
 ('0000002008', '001', 100, '0004', 5.00, 0, 625.00, 115, '000108'),
 ('0000002009', '001', 100, '0002', 10.00, 0, 1250.00, 200, '000109'),
 ('0000002010', '001', 100, '0001', 6.50, 0, 812.50, 104, '000110'),
 ('0000002011', '001', 100, '0002', 5.00, 0, 625.00, 100, '000111'),
 ('0000002012', '001', 100, '0004', 12.00, 0, 1500.00, 276, '000112'),
 ('0000002013', '001', 100, '0006', 6.00, 0, 750.00, 144, '000113'),
 ('0000002014', '001', 100, '0001', 8.00, 0, 1000.00, 128, '000114'),
 ('0000002015', '001', 100, '0004', 9.00, 0, 1125.00, 207, '000115');

INSERT INTO exp_tables.salesled (
 invoice, count, prod, firstline, "desc", quan, price, amount, wh, ptype, jbclass,
 sdebit, scredit, cost, cdebit, ccredit, tax1, tax2, tax3, tax4, epa, miscnum,
 refrlbs, noprint, taxed, costed, entryid, tax5, tax6, assemblyquan, markupvalue,
 spiff, accepted, quotecosttype
) VALUES
 ('0000002001', '001', 'PART-SAFE-DIAL', 1, 'Mechanical safe dial and lock kit', 1, 245, 245, '0003', 'M', 'SAFE', '1100', '4100', 96, '5100', '1300', 12.25, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2001-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002001', '002', 'LABOR-COMM', 0, 'Safe service labor', 2.25, 125, 281.25, '0003', 'L', 'SAFE', '1100', '4100', 108, '5100', '1300', 14.0625, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2001-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002001', '003', 'TRIP-LOCAL', 0, 'After-hours local trip charge', 1, 49, 49, '0003', 'O', 'SAFE', '1100', '4100', 0, '5100', '1300', 2.45, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2001-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002002', '001', 'PART-SFIC-CORE', 1, 'SFIC interchangeable core, keyed alike', 6, 72, 432, '0002', 'M', 'LOCK', '1100', '4100', 168, '5100', '1300', 21.6, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2002-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002002', '002', 'PART-KEY-SCHLAGE', 0, 'Restricted key copies', 10, 5.5, 55, '0001', 'M', 'LOCK', '1100', '4100', 8.5, '5100', '1300', 2.75, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2002-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002002', '003', 'LABOR-COMM', 0, 'Commercial rekey labor', 4, 125, 500, '0002', 'L', 'LOCK', '1100', '4100', 168, '5100', '1300', 25, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2002-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002002', '004', 'TRIP-LOCAL', 0, 'Local trip charge', 1, 49, 49, '0002', 'O', 'LOCK', '1100', '4100', 0, '5100', '1300', 2.45, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2002-004', 0, 0, 0, 0, 0, 1, 0),
 ('0000002003', '001', 'PART-KEYPAD-LOCK', 1, 'Standalone keypad lever lock', 1, 329, 329, '0001', 'M', 'ACCS', '1100', '4100', 155, '5100', '1300', 16.45, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2003-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002003', '002', 'LABOR-COMM', 0, 'Access control install labor', 1.5, 125, 187.5, '0001', 'L', 'ACCS', '1100', '4100', 63, '5100', '1300', 9.375, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2003-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002004', '001', 'PART-KEY-BLANK-HIGHSEC', 1, 'High security key blanks for master system', 20, 55, 1100, '0006', 'M', 'KEYS', '1100', '4100', 360, '5100', '1300', 55, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2004-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002004', '002', 'LABOR-COMM', 0, 'Master key system design labor', 8, 125, 1000, '0006', 'L', 'KEYS', '1100', '4100', 0, '5100', '1300', 50, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2004-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002005', '001', 'PART-DEADBOLT-GRADE1', 1, 'Grade 1 commercial deadbolt', 4, 159, 636, '0001', 'M', 'LOCK', '1100', '4100', 272, '5100', '1300', 31.8, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2005-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002005', '002', 'PART-SFIC-CORE', 0, 'SFIC core for new tenant', 4, 72, 288, '0001', 'M', 'LOCK', '1100', '4100', 112, '5100', '1300', 14.4, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2005-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002005', '003', 'LABOR-COMM', 0, 'Rekey and install labor', 6, 125, 750, '0001', 'L', 'LOCK', '1100', '4100', 0, '5100', '1300', 37.5, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2005-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002006', '001', 'PART-DEADBOLT-GRADE1', 1, 'Replacement deadbolt for fence gate', 3, 159, 477, '0004', 'M', 'AUDT', '1100', '4100', 204, '5100', '1300', 23.85, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2006-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002006', '002', 'PART-MAGLOCK', 0, 'Maglock for loading dock', 1, 289, 289, '0004', 'M', 'AUDT', '1100', '4100', 125, '5100', '1300', 14.45, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2006-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002006', '003', 'LABOR-COMM', 0, 'Security audit and install labor', 5.5, 125, 687.5, '0004', 'L', 'AUDT', '1100', '4100', 0, '5100', '1300', 34.375, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2006-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002007', '001', 'PART-KEY-BLANK-ASSORTED', 1, 'Assorted key blanks for school', 50, 65, 3250, '0006', 'M', 'KEYS', '1100', '4100', 1100, '5100', '1300', 162.5, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2007-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002007', '002', 'PART-KEY-BLANK-HIGHSEC', 0, 'High security blanks for admin', 15, 55, 825, '0006', 'M', 'KEYS', '1100', '4100', 270, '5100', '1300', 41.25, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2007-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002007', '003', 'LABOR-COMM', 0, 'Master key system labor', 7, 125, 875, '0006', 'L', 'KEYS', '1100', '4100', 0, '5100', '1300', 43.75, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2007-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002008', '001', 'PART-READER-PROX', 1, 'Proximity reader for main entrance', 2, 199, 398, '0004', 'M', 'ACCS', '1100', '4100', 170, '5100', '1300', 19.9, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2008-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002008', '002', 'PART-READER-PROX', 0, 'Proximity reader for parking gate', 1, 199, 199, '0004', 'M', 'ACCS', '1100', '4100', 85, '5100', '1300', 9.95, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2008-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002008', '003', 'LABOR-COMM', 0, 'Access control install labor', 5, 125, 625, '0004', 'L', 'ACCS', '1100', '4100', 0, '5100', '1300', 31.25, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2008-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002009', '001', 'PART-SAFE-ELECTRONIC', 1, 'Electronic safe lock with audit', 1, 375, 375, '0003', 'M', 'SAFE', '1100', '4100', 145, '5100', '1300', 18.75, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2009-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002009', '002', 'LABOR-COMM', 0, 'Vault lock upgrade labor', 10, 125, 1250, '0003', 'L', 'SAFE', '1100', '4100', 0, '5100', '1300', 62.5, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2009-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002009', '003', 'TRIP-AFTERHRS', 0, 'After-hours trip surcharge', 1, 89, 89, '0003', 'O', 'SAFE', '1100', '4100', 0, '5100', '1300', 4.45, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2009-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002010', '001', 'PART-DEADBOLT-GRADE2', 1, 'Grade 2 deadbolt for locker room', 4, 99, 396, '0002', 'M', 'LOCK', '1100', '4100', 168, '5100', '1300', 19.8, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2010-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002010', '002', 'PART-KEY-KWIKSET', 0, 'Key blanks for locker keys', 200, 4.95, 990, '0002', 'M', 'LOCK', '1100', '4100', 140, '5100', '1300', 49.5, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2010-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002010', '003', 'LABOR-COMM', 0, 'Locker rekey labor', 6.5, 125, 812.5, '0002', 'L', 'LOCK', '1100', '4100', 0, '5100', '1300', 40.625, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2010-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002011', '001', 'PART-SAFE-DIAL', 1, 'Safe dial inspection kit', 1, 245, 245, '0003', 'M', 'SAFE', '1100', '4100', 96, '5100', '1300', 12.25, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2011-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002011', '002', 'PART-SAFE-ELECTRONIC', 0, 'Electronic lock for narcotics safe', 1, 375, 375, '0003', 'M', 'SAFE', '1100', '4100', 145, '5100', '1300', 18.75, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2011-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002011', '003', 'LABOR-COMM', 0, 'Safe compliance audit labor', 5, 125, 625, '0003', 'L', 'SAFE', '1100', '4100', 0, '5100', '1300', 31.25, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2011-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002012', '001', 'PART-READER-BIO', 1, 'Biometric reader for service entrance', 6, 449, 2694, '0004', 'M', 'ACCS', '1100', '4100', 1170, '5100', '1300', 134.7, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2012-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002012', '002', 'PART-STRIKE-EL', 0, 'Electric strike for biometric readers', 6, 159, 954, '0004', 'M', 'ACCS', '1100', '4100', 408, '5100', '1300', 47.7, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2012-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002012', '003', 'LABOR-COMM', 0, 'Night shift access control labor', 12, 125, 1500, '0004', 'L', 'ACCS', '1100', '4100', 0, '5100', '1300', 75, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2012-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002013', '001', 'PART-DEADBOLT-GRADE1', 1, 'TSA-approved deadbolt', 8, 159, 1272, '0006', 'M', 'INST', '1100', '4100', 544, '5100', '1300', 63.6, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2013-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002013', '002', 'PART-MAGLOCK', 0, 'Maglock for restricted area', 4, 289, 1156, '0006', 'M', 'INST', '1100', '4100', 500, '5100', '1300', 57.8, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2013-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002013', '003', 'LABOR-COMM', 0, 'TSA compliance installation labor', 6, 125, 750, '0006', 'L', 'INST', '1100', '4100', 0, '5100', '1300', 37.5, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2013-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002014', '001', 'PART-DEADBOLT-GRADE2', 1, 'Grade 2 deadbolt for guest rooms', 160, 99, 15840, '0002', 'M', 'LOCK', '1100', '4100', 6720, '5100', '1300', 792, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2014-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002014', '002', 'PART-KEY-KWIKSET', 0, 'Key blanks for guest keys', 400, 4.95, 1980, '0002', 'M', 'LOCK', '1100', '4100', 280, '5100', '1300', 99, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2014-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002014', '003', 'LABOR-COMM', 0, 'Guest room rekey labor', 8, 125, 1000, '0002', 'L', 'LOCK', '1100', '4100', 0, '5100', '1300', 50, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2014-003', 0, 0, 0, 0, 0, 1, 0),
 ('0000002015', '001', 'PART-MAGLOCK', 1, 'Maglock for plant entrances', 6, 289, 1734, '0004', 'M', 'ACCS', '1100', '4100', 750, '5100', '1300', 86.7, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2015-001', 0, 0, 0, 0, 0, 1, 0),
 ('0000002015', '002', 'PART-READER-PROX', 0, 'Card reader for plant access', 6, 199, 1194, '0004', 'M', 'ACCS', '1100', '4100', 510, '5100', '1300', 59.7, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2015-002', 0, 0, 0, 0, 0, 1, 0),
 ('0000002015', '003', 'LABOR-COMM', 0, 'Plant access control labor', 9, 125, 1125, '0004', 'L', 'ACCS', '1100', '4100', 0, '5100', '1300', 56.25, 0, 0, 0, 0, 0, 0, 0, 1, 1, 'sl-2015-003', 0, 0, 0, 0, 0, 1, 0);

INSERT INTO exp_tables.po (
 po, date, vendor, custno, locno, dispatch, shipname, shipaddr1, shipaddr3, memo,
 datereq, buyer, terms, shipvia, confirmto, status, billed, transtype,
 orderplaced, vendorlocid, periodid
) VALUES
 ('000000000000101', '2026-05-01 10:00:00', 'MULK', '0001001', '00001', '000102', 'Calgary Lock & Safe Demo', '410 10 Ave SW', 'Calgary AB T2R 0A8',
 'Restock SFIC cores after clinic rekey.', '2026-05-06 00:00:00', '0003', 'Net 15', 'Courier', 'Dana Ruiz', 'O', 0, 1, 1, 'vloc-mulk-main', '202605'),
 ('000000000000102', '2026-05-02 11:00:00', 'ALGO', '0001003', '00001', '000103', 'Calgary Lock & Safe Demo', '410 10 Ave SW', 'Calgary AB T2R 0A8',
 'Keypad lock and deadbolt replenishment.', '2026-05-07 00:00:00', '0003', 'Net 30', 'Courier', 'Inside Sales', 'O', 0, 1, 1, 'vloc-algo-main', '202605'),
 ('000000000000103', '2026-05-08 09:00:00', 'KABA', '0001004', '00001', '000104', 'Calgary Lock & Safe Demo', '410 10 Ave SW', 'Calgary AB T2R 0A8',
 'Master key system blanks and tools.', '2026-05-13 00:00:00', '0003', 'Net 30', 'Courier', 'Sarah Lin', 'O', 0, 1, 1, 'vloc-kaba-main', '202605'),
 ('000000000000104', '2026-05-12 14:00:00', 'ASSA', '0001006', '00001', '000106', 'Calgary Lock & Safe Demo', '410 10 Ave SW', 'Calgary AB T2R 0A8',
 'Panic bars, closers, and hinges for warehouse audit.', '2026-05-17 00:00:00', '0003', 'Net 30', 'Courier', 'Priya Nair', 'O', 0, 1, 1, 'vloc-assa-main', '202605'),
 ('000000000000105', '2026-05-20 16:00:00', 'AMSE', '0001009', '00001', '000109', 'Calgary Lock & Safe Demo', '410 10 Ave SW', 'Calgary AB T2R 0A8',
 'Electronic safe locks for vault upgrade.', '2026-05-25 00:00:00', '0003', 'Net 30', 'Courier', 'Neil Fraser', 'O', 0, 1, 1, 'vloc-amse-main', '202605');

INSERT INTO exp_tables.poled (
 po, counter, part, "desc", quan, price, amount, received, job, jobid, deptid,
 itemid, costtype, accountid, entrytype, cleared, dispatchno
) VALUES
 ('000000000000101', '001', 'PART-SFIC-CORE', 'SFIC interchangeable core, keyed alike', 12, 27, 324, 12, 'Clinic restricted keyway rekey', 'job-demo-clinic-rekey', 'dept-service-demo', 'PART-SFIC-CORE', 1, 'acct-inventory-demo', 1, 0, '000102'),
 ('000000000000101', '002', 'PART-KEY-BLANK-HIGHSEC', 'High security key blank, Medeco', 10, 16, 160, 10, 'Clinic restricted keyway rekey', 'job-demo-clinic-rekey', 'dept-service-demo', 'PART-KEY-BLANK-HIGHSEC', 1, 'acct-inventory-demo', 1, 0, '000102'),
 ('000000000000102', '001', 'PART-KEYPAD-LOCK', 'Standalone keypad lever lock', 2, 148, 296, 1, 'Office keypad access upgrade', 'job-demo-property-access', 'dept-install-demo', 'PART-KEYPAD-LOCK', 1, 'acct-inventory-demo', 1, 0, '000103'),
 ('000000000000102', '002', 'PART-DEADBOLT-GRADE1', 'Grade 1 commercial deadbolt, satin chrome', 4, 64, 256, 4, 'Office keypad access upgrade', 'job-demo-property-access', 'dept-install-demo', 'PART-DEADBOLT-GRADE1', 1, 'acct-inventory-demo', 1, 0, '000103'),
 ('000000000000102', '003', 'PART-IC-CORE', 'IC core, Schlage LFIC, 6-pin', 2, 30, 60, 2, 'Office keypad access upgrade', 'job-demo-property-access', 'dept-install-demo', 'PART-IC-CORE', 1, 'acct-inventory-demo', 1, 0, '000103'),
 ('000000000000103', '001', 'PART-KEY-BLANK-HIGHSEC', 'High security key blank, Medeco', 50, 16, 800, 50, 'CCO Tower master key system', 'job-demo-office-master', 'dept-keys-demo', 'PART-KEY-BLANK-HIGHSEC', 1, 'acct-inventory-demo', 1, 0, '000104'),
 ('000000000000103', '002', 'PART-KEY-BLANK-ASSORTED', 'Assorted key blanks, box of 50', 10, 20, 200, 10, 'CCO Tower master key system', 'job-demo-office-master', 'dept-keys-demo', 'PART-KEY-BLANK-ASSORTED', 1, 'acct-inventory-demo', 1, 0, '000104'),
 ('000000000000103', '003', 'PART-TOOL-PICK-SET', 'Professional lock pick set', 1, 40, 40, 1, 'CCO Tower master key system', 'job-demo-office-master', 'dept-keys-demo', 'PART-TOOL-PICK-SET', 1, 'acct-inventory-demo', 1, 0, '000104'),
 ('000000000000104', '001', 'PART-PANIC-BAR', 'Panic exit device, rim type', 3, 175, 525, 3, 'Riverside warehouse perimeter audit', 'job-demo-warehouse-audit', 'dept-access-demo', 'PART-PANIC-BAR', 1, 'acct-inventory-demo', 1, 0, '000106'),
 ('000000000000104', '002', 'PART-CLOSER-GRADE1', 'Door closer, grade 1, adjustable', 4, 88, 352, 4, 'Riverside warehouse perimeter audit', 'job-demo-warehouse-audit', 'dept-access-demo', 'PART-CLOSER-GRADE1', 1, 'acct-inventory-demo', 1, 0, '000106'),
 ('000000000000104', '003', 'PART-HINGE-BB', 'Ball bearing hinge, 4.5in', 20, 10, 200, 20, 'Riverside warehouse perimeter audit', 'job-demo-warehouse-audit', 'dept-access-demo', 'PART-HINGE-BB', 1, 'acct-inventory-demo', 1, 0, '000106'),
 ('000000000000105', '001', 'PART-SAFE-ELECTRONIC', 'Electronic safe lock, audit trail', 2, 135, 270, 2, 'Bank vault lock upgrade', 'job-demo-bank-vault', 'dept-safe-demo', 'PART-SAFE-ELECTRONIC', 1, 'acct-inventory-demo', 1, 0, '000109'),
 ('000000000000105', '002', 'PART-SAFE-DIAL', 'Mechanical safe dial and lock kit', 1, 92, 92, 1, 'Bank vault lock upgrade', 'job-demo-bank-vault', 'dept-safe-demo', 'PART-SAFE-DIAL', 1, 'acct-inventory-demo', 1, 0, '000109');

INSERT INTO exp_tables.invrec (
 key, count, part, "desc", cost, quan, recdate, ponum, vendor, job, wh,
 debitacct, jbclass, posted, dispatchno
) VALUES
 ('IR-101', '001', 'PART-SFIC-CORE', 'SFIC interchangeable core, keyed alike', 27, 12, '2026-05-05 10:20:00', '000000000000101', 'MULK', 'Clinic restricted keyway rekey', '0001', '1300', 'LOCK', 'Y', '000102'),
 ('IR-101', '002', 'PART-KEY-BLANK-HIGHSEC', 'High security key blank, Medeco', 16, 10, '2026-05-05 10:20:00', '000000000000101', 'MULK', 'Clinic restricted keyway rekey', '0001', '1300', 'LOCK', 'Y', '000102'),
 ('IR-102', '001', 'PART-KEYPAD-LOCK', 'Standalone keypad lever lock', 148, 1, '2026-05-05 14:10:00', '000000000000102', 'ALGO', 'Office keypad access upgrade', '0001', '1300', 'ACCS', 'Y', '000103'),
 ('IR-102', '002', 'PART-DEADBOLT-GRADE1', 'Grade 1 commercial deadbolt, satin chrome', 64, 4, '2026-05-05 14:10:00', '000000000000102', 'ALGO', 'Office keypad access upgrade', '0001', '1300', 'ACCS', 'Y', '000103'),
 ('IR-102', '003', 'PART-IC-CORE', 'IC core, Schlage LFIC, 6-pin', 30, 2, '2026-05-05 14:10:00', '000000000000102', 'ALGO', 'Office keypad access upgrade', '0001', '1300', 'ACCS', 'Y', '000103'),
 ('IR-103', '001', 'PART-KEY-BLANK-HIGHSEC', 'High security key blank, Medeco', 16, 50, '2026-05-13 09:30:00', '000000000000103', 'KABA', 'CCO Tower master key system', '0001', '1300', 'KEYS', 'Y', '000104'),
 ('IR-103', '002', 'PART-KEY-BLANK-ASSORTED', 'Assorted key blanks, box of 50', 20, 10, '2026-05-13 09:30:00', '000000000000103', 'KABA', 'CCO Tower master key system', '0001', '1300', 'KEYS', 'Y', '000104'),
 ('IR-103', '003', 'PART-TOOL-PICK-SET', 'Professional lock pick set', 40, 1, '2026-05-13 09:30:00', '000000000000103', 'KABA', 'CCO Tower master key system', '0001', '1300', 'KEYS', 'Y', '000104'),
 ('IR-104', '001', 'PART-PANIC-BAR', 'Panic exit device, rim type', 175, 3, '2026-05-17 11:00:00', '000000000000104', 'ASSA', 'Riverside warehouse perimeter audit', '0001', '1300', 'AUDT', 'Y', '000106'),
 ('IR-104', '002', 'PART-CLOSER-GRADE1', 'Door closer, grade 1, adjustable', 88, 4, '2026-05-17 11:00:00', '000000000000104', 'ASSA', 'Riverside warehouse perimeter audit', '0001', '1300', 'AUDT', 'Y', '000106'),
 ('IR-104', '003', 'PART-HINGE-BB', 'Ball bearing hinge, 4.5in', 10, 20, '2026-05-17 11:00:00', '000000000000104', 'ASSA', 'Riverside warehouse perimeter audit', '0001', '1300', 'AUDT', 'Y', '000106'),
 ('IR-105', '001', 'PART-SAFE-ELECTRONIC', 'Electronic safe lock, audit trail', 135, 2, '2026-05-25 08:00:00', '000000000000105', 'AMSE', 'Bank vault lock upgrade', '0001', '1300', 'SAFE', 'Y', '000109'),
 ('IR-105', '002', 'PART-SAFE-DIAL', 'Mechanical safe dial and lock kit', 92, 1, '2026-05-25 08:00:00', '000000000000105', 'AMSE', 'Bank vault lock upgrade', '0001', '1300', 'SAFE', 'Y', '000109');

INSERT INTO exp_tables.reportview (
 reportid, viewid, name, reporttitle, systemview, orderby, descending,
 privateview, username, onlyicanmodify, isdefault
) VALUES
 ('77F6BF9D-1755-4455-8DB2-764E5AAA10AC', '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1', 'Demo Customers', 'Demo Customers', -1, 'fullname', 0, 0, 'ADMIN', 0, -1),
 ('74A25B4E-3554-4909-AF70-664C3651B61E', '86c3e36d-102c-44f4-9b42-f0f57d3c9dc2', 'Demo Vendors', 'Demo Vendors', -1, 'companyname', 0, 0, 'ADMIN', 0, -1),
 ('0F7FEFB3-5ADA-4F8F-8F25-FD7325202003', '4b011415-5e18-4a27-b8ff-253a7ea16a10', 'Demo Inventory', 'Demo Inventory', -1, 'item', 0, 0, 'ADMIN', 0, -1),
 ('FD910303-2BFD-4DFE-9C91-42CEAE1C2E34', '60790320-c434-4425-a1e5-9f7f4d5c2a8f', 'Demo Invoices', 'Demo Invoices', -1, 'invoicedate', -1, 0, 'ADMIN', 0, -1),
 ('6CEE39FA-4D47-4848-AD9D-A323F3B4DD6C', '6c7fbe33-d0fd-4f95-af9c-40862265b9e4', 'Demo Quotes', 'Demo Quotes', -1, 'quotedate', -1, 0, 'ADMIN', 0, -1),
 ('8293BC95-5935-4D31-B0C4-55B7E4BDA5FA', '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2', 'Demo Purchase Orders', 'Demo Purchase Orders', -1, 'date', -1, 0, 'ADMIN', 0, -1),
 ('112F7688-CBE4-47E2-A33E-F6C7FFA6AA33', 'd901fe5f-9249-49c4-8a3f-5e176626aef1', 'Demo Dispatches', 'Demo Dispatches', -1, 'datereceived', -1, 0, 'ADMIN', 0, -1);

INSERT INTO exp_tables.reportviewcustomfield (
 reportid, viewid, fieldindex, fieldname, "group", width, sortdirection,
 groupaggregate, datatype
) VALUES
 ('77F6BF9D-1755-4455-8DB2-764E5AAA10AC', '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1', 1, 'fullname', 0, 220, 1, 0, 0),
 ('77F6BF9D-1755-4455-8DB2-764E5AAA10AC', '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1', 2, 'locationname', 0, 180, 0, 0, 0),
 ('77F6BF9D-1755-4455-8DB2-764E5AAA10AC', '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1', 3, 'locationaddress1', 0, 190, 0, 0, 0),
 ('77F6BF9D-1755-4455-8DB2-764E5AAA10AC', '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1', 4, 'locationcity', 0, 140, 0, 0, 0),
 ('77F6BF9D-1755-4455-8DB2-764E5AAA10AC', '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1', 5, 'phone1', 0, 130, 0, 0, 0),
 ('77F6BF9D-1755-4455-8DB2-764E5AAA10AC', '9b3de3b7-84d4-42e5-bb3f-a02e301f06c1', 6, 'email1', 0, 230, 0, 0, 0),

 ('74A25B4E-3554-4909-AF70-664C3651B61E', '86c3e36d-102c-44f4-9b42-f0f57d3c9dc2', 1, 'companyname', 0, 220, 1, 0, 0),
 ('74A25B4E-3554-4909-AF70-664C3651B61E', '86c3e36d-102c-44f4-9b42-f0f57d3c9dc2', 2, 'locationname', 0, 180, 0, 0, 0),
 ('74A25B4E-3554-4909-AF70-664C3651B61E', '86c3e36d-102c-44f4-9b42-f0f57d3c9dc2', 3, 'city', 0, 140, 0, 0, 0),
 ('74A25B4E-3554-4909-AF70-664C3651B61E', '86c3e36d-102c-44f4-9b42-f0f57d3c9dc2', 4, 'phone1', 0, 130, 0, 0, 0),
 ('74A25B4E-3554-4909-AF70-664C3651B61E', '86c3e36d-102c-44f4-9b42-f0f57d3c9dc2', 5, 'emailaddress', 0, 230, 0, 0, 0),

 ('0F7FEFB3-5ADA-4F8F-8F25-FD7325202003', '4b011415-5e18-4a27-b8ff-253a7ea16a10', 1, 'item', 0, 180, 1, 0, 0),
 ('0F7FEFB3-5ADA-4F8F-8F25-FD7325202003', '4b011415-5e18-4a27-b8ff-253a7ea16a10', 2, 'description', 0, 260, 0, 0, 0),
 ('0F7FEFB3-5ADA-4F8F-8F25-FD7325202003', '4b011415-5e18-4a27-b8ff-253a7ea16a10', 3, 'category', 0, 130, 0, 0, 0),
 ('0F7FEFB3-5ADA-4F8F-8F25-FD7325202003', '4b011415-5e18-4a27-b8ff-253a7ea16a10', 4, 'quantityinstock', 0, 130, 0, 0, 0),
 ('0F7FEFB3-5ADA-4F8F-8F25-FD7325202003', '4b011415-5e18-4a27-b8ff-253a7ea16a10', 5, 'basecost', 0, 120, 0, 0, 1),
 ('0F7FEFB3-5ADA-4F8F-8F25-FD7325202003', '4b011415-5e18-4a27-b8ff-253a7ea16a10', 6, 'pricea', 0, 120, 0, 0, 1),

 ('FD910303-2BFD-4DFE-9C91-42CEAE1C2E34', '60790320-c434-4425-a1e5-9f7f4d5c2a8f', 1, 'invoice', 0, 140, 0, 0, 0),
 ('FD910303-2BFD-4DFE-9C91-42CEAE1C2E34', '60790320-c434-4425-a1e5-9f7f4d5c2a8f', 2, 'customerfullname', 0, 240, 0, 0, 0),
 ('FD910303-2BFD-4DFE-9C91-42CEAE1C2E34', '60790320-c434-4425-a1e5-9f7f4d5c2a8f', 3, 'dispatch', 0, 130, 0, 0, 0),
 ('FD910303-2BFD-4DFE-9C91-42CEAE1C2E34', '60790320-c434-4425-a1e5-9f7f4d5c2a8f', 4, 'invoicedate', 0, 150, 2, 0, 3),
 ('FD910303-2BFD-4DFE-9C91-42CEAE1C2E34', '60790320-c434-4425-a1e5-9f7f4d5c2a8f', 5, 'invoicetype', 0, 130, 0, 0, 0),
 ('FD910303-2BFD-4DFE-9C91-42CEAE1C2E34', '60790320-c434-4425-a1e5-9f7f4d5c2a8f', 6, 'invoicetotal', 0, 130, 0, 0, 1),

 ('6CEE39FA-4D47-4848-AD9D-A323F3B4DD6C', '6c7fbe33-d0fd-4f95-af9c-40862265b9e4', 1, 'quote', 0, 140, 0, 0, 0),
 ('6CEE39FA-4D47-4848-AD9D-A323F3B4DD6C', '6c7fbe33-d0fd-4f95-af9c-40862265b9e4', 2, 'customerfullname', 0, 240, 0, 0, 0),
 ('6CEE39FA-4D47-4848-AD9D-A323F3B4DD6C', '6c7fbe33-d0fd-4f95-af9c-40862265b9e4', 3, 'dispatch', 0, 130, 0, 0, 0),
 ('6CEE39FA-4D47-4848-AD9D-A323F3B4DD6C', '6c7fbe33-d0fd-4f95-af9c-40862265b9e4', 4, 'quotedate', 0, 150, 2, 0, 3),
 ('6CEE39FA-4D47-4848-AD9D-A323F3B4DD6C', '6c7fbe33-d0fd-4f95-af9c-40862265b9e4', 5, 'quotestatus', 0, 130, 0, 0, 0),
 ('6CEE39FA-4D47-4848-AD9D-A323F3B4DD6C', '6c7fbe33-d0fd-4f95-af9c-40862265b9e4', 6, 'invoicetotal', 0, 130, 0, 0, 1),

 ('8293BC95-5935-4D31-B0C4-55B7E4BDA5FA', '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2', 1, 'po', 0, 170, 0, 0, 0),
 ('8293BC95-5935-4D31-B0C4-55B7E4BDA5FA', '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2', 2, 'vendorcompany', 0, 220, 0, 0, 0),
 ('8293BC95-5935-4D31-B0C4-55B7E4BDA5FA', '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2', 3, 'date', 0, 150, 2, 0, 3),
 ('8293BC95-5935-4D31-B0C4-55B7E4BDA5FA', '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2', 4, 'postatus', 0, 130, 0, 0, 0),
 ('8293BC95-5935-4D31-B0C4-55B7E4BDA5FA', '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2', 5, 'partdescription', 0, 260, 0, 0, 0),
 ('8293BC95-5935-4D31-B0C4-55B7E4BDA5FA', '9a8bf8df-f97c-4d6e-b7df-cc3e8edca7f2', 6, 'amount', 0, 130, 0, 0, 1),

 ('112F7688-CBE4-47E2-A33E-F6C7FFA6AA33', 'd901fe5f-9249-49c4-8a3f-5e176626aef1', 1, 'dispatch', 0, 130, 0, 0, 0),
 ('112F7688-CBE4-47E2-A33E-F6C7FFA6AA33', 'd901fe5f-9249-49c4-8a3f-5e176626aef1', 2, 'customerfullname', 0, 240, 0, 0, 0),
 ('112F7688-CBE4-47E2-A33E-F6C7FFA6AA33', 'd901fe5f-9249-49c4-8a3f-5e176626aef1', 3, 'locationname', 0, 180, 0, 0, 0),
 ('112F7688-CBE4-47E2-A33E-F6C7FFA6AA33', 'd901fe5f-9249-49c4-8a3f-5e176626aef1', 4, 'datereceived', 0, 150, 2, 0, 3),
 ('112F7688-CBE4-47E2-A33E-F6C7FFA6AA33', 'd901fe5f-9249-49c4-8a3f-5e176626aef1', 5, 'status', 0, 130, 0, 0, 0),
 ('112F7688-CBE4-47E2-A33E-F6C7FFA6AA33', 'd901fe5f-9249-49c4-8a3f-5e176626aef1', 6, 'techname', 0, 160, 0, 0, 0);

UPDATE exp_tables.counter
SET next = lpad(GREATEST(next::integer, (SELECT COALESCE(MAX(custno::integer), 0) + 1 FROM exp_tables.customer))::text, 7, '0')
WHERE name = 'Customer';

UPDATE exp_tables.counter
SET next = lpad(GREATEST(next::integer, (SELECT COALESCE(MAX(dispatch::integer), 0) + 1 FROM exp_tables.dispatch))::text, 6, '0')
WHERE name = 'Dispatch';

UPDATE exp_tables.counter
SET next = lpad(GREATEST(next::integer, (SELECT COALESCE(MAX(empno::integer), 0) + 1 FROM exp_tables.employee))::text, 4, '0')
WHERE name = 'Employee';

UPDATE exp_tables.counter
SET next = lpad(GREATEST(next::integer, (SELECT COALESCE(MAX(invoice::integer), 0) + 1 FROM exp_tables.sales))::text, 10, '0')
WHERE name = 'Invoice';

UPDATE exp_tables.counter
SET next = lpad(GREATEST(next::bigint, (SELECT COALESCE(MAX(po::bigint), 0) + 1 FROM exp_tables.po))::text, 15, '0')
WHERE name = 'PO';

UPDATE exp_tables.counter
SET next = lpad(GREATEST(next::integer, (SELECT COALESCE(MAX(trannumber), 0) + 1 FROM exp_tables.finledger))::text, 6, '0')
WHERE name = 'GJ';

COMMIT;
