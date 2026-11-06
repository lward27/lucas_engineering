-- Adds a supplier demo to the explicitly named synthetic tenant only.
BEGIN;
DO $$
BEGIN
  IF current_database() <> 'oms_test' OR NOT EXISTS (SELECT 1 FROM provider WHERE id='5eed0a00-0000-4000-8000-000000000001' AND "providerName"='Demo Provider') THEN
    RAISE EXCEPTION 'Refusing to seed mock supplier data outside synthetic database';
  END IF;
  IF EXISTS (SELECT 1 FROM product WHERE id='5eed0a00-0000-4000-8000-000000000070' AND (provider_id IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000001' OR "productName" IS DISTINCT FROM 'Mock Supplier Cylinder')) OR EXISTS (SELECT 1 FROM purchase_order WHERE id='5eed0a00-0000-4000-8000-000000000071' AND (provider_id IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000001' OR "purchaseOrderNumber" IS DISTINCT FROM '900001')) OR EXISTS (SELECT 1 FROM purchase_order_detail WHERE id='5eed0a00-0000-4000-8000-000000000072' AND (provider_id IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000001' OR "purchaseOrder_id" IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000071' OR product_id IS DISTINCT FROM '5eed0a00-0000-4000-8000-000000000070')) THEN
    RAISE EXCEPTION 'Fixture IDs already belong to other records';
  END IF;
END $$;
UPDATE provider SET "hasSeclockIntegration"=true WHERE id='5eed0a00-0000-4000-8000-000000000001';
INSERT INTO product (id,"productCode","productName","manufacturerPartNumber","seclockUID",provider_id,branch_id) VALUES ('5eed0a00-0000-4000-8000-000000000070','MOCK-SUPPLIER-1001','Mock Supplier Cylinder','FX-1001','mock-uid-1001','5eed0a00-0000-4000-8000-000000000001','5eed0a00-0000-4000-8000-000000000002') ON CONFLICT (id) DO NOTHING;
INSERT INTO purchase_order (id,"purchaseOrderNumber","purchaseOrderStatus","purchaseOrderNotes",provider_id,branch_id,address_id,contact_id) VALUES ('5eed0a00-0000-4000-8000-000000000071','900001','Not Ordered','Synthetic supplier order; no real order','5eed0a00-0000-4000-8000-000000000001','5eed0a00-0000-4000-8000-000000000002','5eed0a00-0000-4000-8000-000000000010','5eed0a00-0000-4000-8000-000000000030') ON CONFLICT (id) DO NOTHING;
INSERT INTO purchase_order_detail (id,product_id,"purchaseOrder_id","orderQuantity",provider_id,branch_id) VALUES ('5eed0a00-0000-4000-8000-000000000072','5eed0a00-0000-4000-8000-000000000070','5eed0a00-0000-4000-8000-000000000071',2,'5eed0a00-0000-4000-8000-000000000001','5eed0a00-0000-4000-8000-000000000002') ON CONFLICT (id) DO NOTHING;
COMMIT;
