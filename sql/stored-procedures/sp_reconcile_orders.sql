USE OrderSyncMonitor;
GO

IF OBJECT_ID('dbo.sp_reconcile_orders', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_reconcile_orders;
GO

CREATE PROCEDURE dbo.sp_reconcile_orders
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------
    -- 1️⃣  Detect orders missing in ERP
    ---------------------------------------------
    INSERT INTO dbo.reconciliation_log (
        order_id, issue_type, sales_amount, sales_status, notes
    )
    SELECT
        s.order_id,
        'Missing_In_ERP' AS issue_type,
        s.amount,
        s.status,
        'Order exists in Sales but not in ERP'
    FROM dbo.sales_orders s
    LEFT JOIN dbo.erp_orders e ON s.order_id = e.order_id
    WHERE e.order_id IS NULL;


    ---------------------------------------------
    -- 2️⃣  Detect Amount Mismatches
    ---------------------------------------------
    INSERT INTO dbo.reconciliation_log (
        order_id, issue_type, sales_amount, erp_amount, sales_status, erp_status, notes
    )
    SELECT
        s.order_id,
        'Amount_Mismatch' AS issue_type,
        s.amount,
        e.amount,
        s.status,
        e.status,
        CONCAT('Sales: ', s.amount, ' <> ERP: ', e.amount)
    FROM dbo.sales_orders s
    INNER JOIN dbo.erp_orders e ON s.order_id = e.order_id
    WHERE ABS(s.amount - e.amount) > 0.01;


    ---------------------------------------------
    -- 3️⃣  Detect Status Mismatches
    ---------------------------------------------
    INSERT INTO dbo.reconciliation_log (
        order_id, issue_type, sales_status, erp_status, notes
    )
    SELECT
        s.order_id,
        'Status_Mismatch' AS issue_type,
        s.status,
        e.status,
        CONCAT('Sales: ', s.status, ' <> ERP: ', e.status)
    FROM dbo.sales_orders s
    INNER JOIN dbo.erp_orders e ON s.order_id = e.order_id
    WHERE s.status <> e.status;

END;
GO
