USE msdb;
GO

/*
    SQL Agent Job: Order Sync Reconciliation
    - Runs dbo.sp_reconcile_orders in OrderSyncMonitor database
    - Scheduled every 5 minutes
*/

DECLARE @job_id UNIQUEIDENTIFIER;

------------------------------------------------------------
-- 1️⃣ Remove existing job (so script is idempotent)
------------------------------------------------------------
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Order Sync Reconciliation')
BEGIN
    EXEC msdb.dbo.sp_delete_job
        @job_name = N'Order Sync Reconciliation';
END;
GO

------------------------------------------------------------
-- 2️⃣ Create the job
------------------------------------------------------------
EXEC msdb.dbo.sp_add_job
    @job_name          = N'Order Sync Reconciliation',
    @enabled           = 1,
    @notify_level_eventlog = 0,
    @description       = N'Reconciles sales_orders and erp_orders and logs mismatches to reconciliation_log.',
    @start_step_id     = 1,
    @owner_login_name  = N'sa',           -- change if needed
    @job_id            = @job_id OUTPUT;
GO

------------------------------------------------------------
-- 3️⃣ Add job step: run reconciliation procedure
------------------------------------------------------------
EXEC msdb.dbo.sp_add_jobstep
    @job_name          = N'Order Sync Reconciliation',
    @step_id           = 1,
    @step_name         = N'Run dbo.sp_reconcile_orders',
    @subsystem         = N'TSQL',
    @command           = N'EXEC OrderSyncMonitor.dbo.sp_reconcile_orders;',
    @database_name     = N'master',       -- proc call includes DB name
    @on_success_action = 1,               -- Quit with success
    @on_fail_action    = 2;               -- Quit with failure
GO

------------------------------------------------------------
-- 4️⃣ Create schedule (every 5 minutes)
------------------------------------------------------------
IF EXISTS (SELECT 1 FROM msdb.dbo.sysschedules WHERE name = N'Every 5 Minutes')
BEGIN
    EXEC msdb.dbo.sp_delete_schedule
        @schedule_name = N'Every 5 Minutes';
END;
GO

EXEC msdb.dbo.sp_add_schedule
    @schedule_name     = N'Every 5 Minutes',
    @enabled           = 1,
    @freq_type         = 4,      -- daily
    @freq_interval     = 1,      -- every day
    @freq_subday_type  = 4,      -- minutes
    @freq_subday_interval
