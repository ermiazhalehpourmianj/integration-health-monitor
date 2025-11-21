USE msdb;
GO

IF OBJECT_ID('dbo.sp_start_job', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_start_job;
GO

CREATE PROCEDURE dbo.sp_start_job
    @job_name NVARCHAR(128)
AS
BEGIN
    EXEC msdb.dbo.sp_start_job @job_name = @job_name;
END;
GO
