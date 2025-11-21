USE OrderSyncMonitor;
GO

IF OBJECT_ID('dbo.erp_orders', 'U') IS NOT NULL
    DROP TABLE dbo.erp_orders;
GO

CREATE TABLE dbo.erp_orders (
    order_id     NVARCHAR(50)   NOT NULL PRIMARY KEY,
    customer     NVARCHAR(100)  NOT NULL,
    amount       DECIMAL(18,10) NOT NULL,
    status       NVARCHAR(50)   NOT NULL,   -- e.g. Processing, Shipped
    created_at   DATETIME2      NOT NULL,
    updated_at   DATETIME2      NOT NULL
);
