USE OrderSyncMonitor;
GO

IF OBJECT_ID('dbo.reconciliation_log', 'U') IS NOT NULL
    DROP TABLE dbo.reconciliation_log;
GO

CREATE TABLE dbo.reconciliation_log (
    log_id        INT IDENTITY(1,1) PRIMARY KEY,
    order_id      NVARCHAR(50)   NOT NULL,
    issue_type    NVARCHAR(50)   NOT NULL,   -- Missing_In_ERP, Amount_Mismatch, Status_Mismatch, etc.
    sales_amount  DECIMAL(18,10) NULL,
    erp_amount    DECIMAL(18,10) NULL,
    sales_status  NVARCHAR(50)   NULL,
    erp_status    NVARCHAR(50)   NULL,
    detected_at   DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
    resolved_at   DATETIME2      NULL,
    notes         NVARCHAR(4000) NULL
);
