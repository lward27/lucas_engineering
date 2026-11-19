BEGIN;
DO $$
BEGIN
  IF current_database() <> 'oms_test' OR NOT EXISTS (SELECT 1 FROM provider WHERE id='5eed0a00-0000-4000-8000-000000000001' AND "providerName"='Demo Provider') THEN
    RAISE EXCEPTION 'Refusing to seed a mock payment outside the synthetic database';
  END IF;
  IF EXISTS (SELECT 1 FROM work_order WHERE id='5eed0a00-0000-4000-8000-000000000080' AND (provider_id IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000001' OR "workOrderNumber" IS DISTINCT FROM '900002')) THEN
    RAISE EXCEPTION 'Fixture ID belongs to another work order';
  END IF;
  IF EXISTS (SELECT 1 FROM work_order WHERE id='5eed0a00-0000-4000-8000-000000000081' AND (provider_id IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000001' OR "workOrderNumber" IS DISTINCT FROM '900003')) THEN
    RAISE EXCEPTION 'Second fixture ID belongs to another work order';
  END IF;
END $$;
INSERT INTO work_order (id,"workOrderNumber","workOrderType","workOrderStatus","workOrderDescription","workOrderTotal","remainingBalance",customer_id,facility_id,address_id,department_id,branch_id,provider_id) VALUES ('5eed0a00-0000-4000-8000-000000000080','900002','Site Visit','Completed','Synthetic payment demo — no real charge',50,50,'5eed0a00-0000-4000-8000-000000000040','5eed0a00-0000-4000-8000-000000000041','5eed0a00-0000-4000-8000-000000000012','5eed0a00-0000-4000-8000-000000000003','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000001') ON CONFLICT (id) DO NOTHING;
UPDATE work_order SET "workOrderType"='Site Visit' WHERE id='5eed0a00-0000-4000-8000-000000000080' AND provider_id='5eed0a00-0000-4000-8000-000000000001' AND "workOrderNumber"='900002';
INSERT INTO work_order (id,"workOrderNumber","workOrderType","workOrderStatus","workOrderDescription","workOrderTotal","remainingBalance",customer_id,facility_id,address_id,department_id,branch_id,provider_id) VALUES ('5eed0a00-0000-4000-8000-000000000081','900003','Site Visit','Completed','Synthetic browser checkout — no real charge',30,30,'5eed0a00-0000-4000-8000-000000000040','5eed0a00-0000-4000-8000-000000000041','5eed0a00-0000-4000-8000-000000000012','5eed0a00-0000-4000-8000-000000000003','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000001') ON CONFLICT (id) DO NOTHING;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM task WHERE id IN ('5eed0a00-0000-4000-8000-000000000082','5eed0a00-0000-4000-8000-000000000083','5eed0a00-0000-4000-8000-000000000087') AND provider_id IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000001') OR EXISTS (SELECT 1 FROM line_item WHERE id IN ('5eed0a00-0000-4000-8000-000000000084','5eed0a00-0000-4000-8000-000000000085','5eed0a00-0000-4000-8000-000000000088') AND provider_id IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000001') THEN RAISE EXCEPTION 'Payment detail fixture ID belongs to another provider'; END IF;
END $$;
INSERT INTO task (id,"taskNumber","taskProgress","taskAction","taskRequest","workOrder_id",branch_id,provider_id) VALUES
('5eed0a00-0000-4000-8000-000000000082','900080','Completed','Inspect','Synthetic $50 payment task','5eed0a00-0000-4000-8000-000000000080','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000001'),
('5eed0a00-0000-4000-8000-000000000083','900081','Completed','Inspect','Synthetic $30 payment task','5eed0a00-0000-4000-8000-000000000081','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000001') ON CONFLICT (id) DO NOTHING;
INSERT INTO line_item (id,"lineItemNumber","lineItemDescription",task_id,"workOrder_id",branch_id,provider_id,"unitPrice",quantity,price,"isTaxable") VALUES
('5eed0a00-0000-4000-8000-000000000084','900080','Synthetic $50 charge','5eed0a00-0000-4000-8000-000000000082','5eed0a00-0000-4000-8000-000000000080','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000001',50,1,50,false),
('5eed0a00-0000-4000-8000-000000000085','900081','Synthetic $30 charge','5eed0a00-0000-4000-8000-000000000083','5eed0a00-0000-4000-8000-000000000081','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000001',30,1,30,false) ON CONFLICT (id) DO NOTHING;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM work_order WHERE id='5eed0a00-0000-4000-8000-000000000086' AND (provider_id IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000001' OR "workOrderNumber" IS DISTINCT FROM '900004')) THEN RAISE EXCEPTION 'Third fixture ID belongs to another work order'; END IF;
END $$;
INSERT INTO work_order (id,"workOrderNumber","workOrderType","workOrderStatus","workOrderDescription","workOrderTotal","remainingBalance",customer_id,facility_id,address_id,department_id,branch_id,provider_id) VALUES ('5eed0a00-0000-4000-8000-000000000086','900004','Site Visit','Completed','Synthetic browser checkout — no real charge',20,20,'5eed0a00-0000-4000-8000-000000000040','5eed0a00-0000-4000-8000-000000000041','5eed0a00-0000-4000-8000-000000000012','5eed0a00-0000-4000-8000-000000000003','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000001') ON CONFLICT (id) DO NOTHING;
INSERT INTO task (id,"taskNumber","taskProgress","taskAction","taskRequest","workOrder_id",branch_id,provider_id) VALUES ('5eed0a00-0000-4000-8000-000000000087','900082','Completed','Inspect','Synthetic $20 checkout task','5eed0a00-0000-4000-8000-000000000086','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000001') ON CONFLICT (id) DO NOTHING;
INSERT INTO line_item (id,"lineItemNumber","lineItemDescription",task_id,"workOrder_id",branch_id,provider_id,"unitPrice",quantity,price,"isTaxable") VALUES ('5eed0a00-0000-4000-8000-000000000088','900082','Synthetic $20 charge','5eed0a00-0000-4000-8000-000000000087','5eed0a00-0000-4000-8000-000000000086','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000001',20,1,20,false) ON CONFLICT (id) DO NOTHING;
COMMIT;
