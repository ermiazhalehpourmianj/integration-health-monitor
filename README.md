# Order Sync Reconciliation & Integration Health Monitor  
**Enterprise order reconciliation + integration monitoring using SQL Server, SQL Agent, and Power BI.**

![Power BI Integration Health Dashboard](powerbi/screenshots/dashboard_overview.png)

---

## Overview  
In real-world enterprise stacks, Sales systems and ERP/fulfillment platforms drift out of sync. This repo ships a **production-pattern reconciliation monitor** that:

- compares Sales vs ERP orders on schedule  
- detects missing or mismatched records  
- logs issues with business context  
- surfaces integration health KPIs in Power BI  

If you’ve ever dealt with broken APIs, delayed syncs, or “why is this order not in ERP?”, this is the exact tool you build.

---

## Business Context (Problem)  
In distributed environments, order data can fall out of sync due to:

- integration/API failures  
- partial writes or retries without idempotency  
- event delays / queue backlogs  
- data mapping errors  
- manual overrides  

Without monitoring, these issues sit unnoticed and create fulfillment delays, revenue leakage, and support chaos.

---

## Solution  
This system acts as an **integration health monitor**:

1. **Sales orders** and **ERP orders** are stored in separate tables.  
2. A scheduled SQL Agent job runs reconciliation every 5 minutes.  
3. A stored procedure compares both systems using `order_id`.  
4. Issues are written into `reconciliation_log` with type + notes.  
5. Power BI reads the log and visualizes **reliability + risk**.

---

## Architecture  
```text
Sales DB (sales_orders)      ERP DB (erp_orders)
          │                          │
          └──────────┬───────────────┘
                     ▼
        sp_reconcile_orders (T-SQL)
                     ▼
      reconciliation_log (issue store)
                     ▼
        Power BI Dashboard (KPIs)
````

---

## Core Features

### Detects

- **Missing_In_ERP** — Sales order never arrived in ERP
    
- **Amount_Mismatch** — numeric mismatch beyond tolerance
    
- **Status_Mismatch** — lifecycle drift between systems
    

### Implements

- **Idempotent schema + job setup** scripts
    
- **Scheduled SQL Agent reconciliation**
    
- **Structured issue log** for audit + ops
    
- **Power BI integration reliability dashboard**
    

---

## Data Model

**sales_orders**

- `order_id` (PK)
    
- `customer`
    
- `amount`
    
- `status`
    
- `created_at`, `updated_at`
    

**erp_orders**

- same schema as `sales_orders`
    

**reconciliation_log**

- `log_id` (PK identity)
    
- `order_id`
    
- `issue_type`
    
- `sales_amount`, `erp_amount`
    
- `sales_status`, `erp_status`
    
- `detected_at`, `resolved_at`
    
- `notes`
    

---

## Repository Structure

```text
integration-health-monitor/
├── sql/
│   ├── schema/
│   │   ├── sales_orders.sql
│   │   ├── erp_orders.sql
│   │   └── reconciliation_log.sql
│   ├── stored-procedures/
│   │   ├── sp_reconcile_orders.sql
│   │   └── sp_start_job.sql
│   ├── jobs/
│   │   └── sql_agent_job_setup.sql
│   └── test-data/
│       ├── generate_sales_orders.py
│       ├── generate_erp_orders.py
│       └── sample_data.csv
├── powerbi/
│   ├── dashboard.pbix
│   └── screenshots/
│       └── dashboard_overview.png
└── README.md
```

---

## SQL Components

### Tables

Scripts in `sql/schema/` create all 3 core tables.

### Stored Procedures

- **`sp_reconcile_orders`**
    
    - inserts **Missing_In_ERP**, **Amount_Mismatch**, **Status_Mismatch**
        
    - enriches log entries with notes and values
        
- **`sp_start_job`**
    
    - helper proc to manually trigger SQL Agent job
        

### SQL Agent Job

- **`sql_agent_job_setup.sql`** creates the job **Order Sync Reconciliation**
    
- runs every 5 minutes
    
- executes:
    
    ```sql
    EXEC OrderSyncMonitor.dbo.sp_reconcile_orders;
    ```
    

---

## Power BI Dashboard

Located in `powerbi/dashboard.pbix` with screenshot in `powerbi/screenshots/`.

The dashboard tracks:

- **Total Issues**
    
- **Issues by Type**
    
- **Total Value at Risk**
    
- **Unresolved Issues (detail table)**
    

This is the exact layout used in integration ops teams: quick KPIs + breakdown + actionable detail.

---

## Quick Start

### 1) Create database and tables

Run in order:

```sql
-- 1. Tables
sql/schema/sales_orders.sql
sql/schema/erp_orders.sql
sql/schema/reconciliation_log.sql

-- 2. Stored procedures
sql/stored-procedures/sp_reconcile_orders.sql
sql/stored-procedures/sp_start_job.sql

-- 3. SQL Agent job
sql/jobs/sql_agent_job_setup.sql
```

### 2) Generate sample data

From `sql/test-data/`:

```bash
python generate_sales_orders.py
python generate_erp_orders.py
```

Import the CSVs into:

- `dbo.sales_orders`
    
- `dbo.erp_orders`
    

### 3) Run reconciliation

Option A — manually:

```sql
EXEC dbo.sp_reconcile_orders;
SELECT * FROM dbo.reconciliation_log ORDER BY detected_at DESC;
```

Option B — via Agent job:

```sql
EXEC msdb.dbo.sp_start_job @job_name = 'Order Sync Reconciliation';
```

### 4) Open Power BI

- Open `powerbi/dashboard.pbix`
    
- Point it to your SQL Server
    
- Refresh dataset
    

---

## Testing Notes

The ERP generator intentionally creates realistic enterprise drift:

- ~10% missing orders
    
- ~15% amount mismatches
    
- ~15% status mismatches
    

So every run produces a believable reconciliation workload.

---
