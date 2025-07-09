# Jasmine's Data Pipeline Maintenance Plan

Team members:

1. Jasmine Glancy
    - Expertise: Profit & Experiments - Experience working with finances and statistical risk assessment
    - Pipeline Responsibilities:
      - Primary owner of the [Unit-Level Profit Pipeline](#unit-level-profit-pipeline-for-experiments) and [Engagement Pipeline](#engagement-pipeline).
      - Secondary owner of the [Profit Pipeline](#profit-pipeline) and [Daily Growth Pipeline](#daily-growth-for-experiments-pipeline).
2. Miles Lopez
   - Expertise: Profit & Investors - previous experience working with investors and accounting
   - Pipeline Responsibilities:
     - Primary owner of the [Profit Pipeline](#profit-pipeline) and [Aggregate Profit Pipeline](#aggregate-profit-pipeline-for-investors).
     - Secondary owner of the [Aggregate Growth Pipeline](#aggregate-growth-reported-for-investors-pipeline) and [Aggregate Engagement Pipeline](#aggregate-engagement-for-investors-pipeline).
3. Jackson Long - Growth & Experiments
   - Expertise: Growth & Experiments - previous experience working on teams that have experienced massive growth
   - Pipeline Responsibilities:
     - Primary owner of the [Growth Pipeline](#growth-pipeline) and [Daily Growth Pipeline](#daily-growth-for-experiments-pipeline).
     - Secondary owner of the [Unit-Level Profit Pipeline](#unit-level-profit-pipeline-for-experiments) and [Engagement Pipeline](#engagement-pipeline).
  
4. Hudson King - Growth & Investors
   - Expertise: Growth & Investors - Team leader
   - Pipeline Responsibilities:
     - Primary owner of the [Aggregate Growth Pipeline](#aggregate-growth-reported-for-investors-pipeline) and [Aggregate Engagement Pipeline](#aggregate-engagement-for-investors-pipeline).
     - Secondary owner of the [Aggregate Profit Pipeline](#aggregate-profit-pipeline-for-investors) and [Growth Pipeline](#growth-pipeline)

## Upstream Datasets Runbook

### Profit Pipeline

Ingests raw data from sales, expenses, and other financial sources. Cleans, transforms, and loads the financial and operational data to calculate and report the company's profit metrics.

**Primary Owner:** Miles Lopez

**Secondary Owner:** Jasmine Glancy

**Standard Procedures:**  

- If there is no header row in the sales file and the file contains non-null values, `OFFSET 1` and give the column names their proper aliases:
  - transaction_id
  - date
  - product_id
  - product_name
  - customer_id
  - quantity_sold
  - unit_price
  - total_sales_amount
  - cost_of_goods_sold
  - gross_profit
  - expense_type
  - expense_amount
  - region
  - salesperson_id
  - currency

**Critical Downstream Team:** Profit team

### Unit-Level Profit Pipeline for Experiments

Processes and analyzes profit data at the most granular level—typically per transaction, product, or customer—to support business experiments (such as A/B tests, pilot programs, or feature rollouts).

**Primary Owner:** Jasmine Glancy

**Secondary Owner:** Jackson Long

**Common Issues:**

- Occasionally sales data arrives late from the legacy servers
- *Known Issue*: pipeline fails if the sales data file is missing a header row
  
**Standard Procedures:**  

- If the profit pipeline fails, contact the [Profit Pipeline owners](#profit-pipeline)
- For data delays: Contact Ray Charley if with Sales sales data isn't received by 2 days after the expected deadline
  
**Critical Downstream Team:** Profit team

### Aggregate Profit Pipeline for Investors

This pipeline turns detailed operational profit data into high-level, investor-ready summaries and reports, enabling clear communication of the company’s financial performance to external stakeholders.

**Primary Owner:** Miles Lopez

**Secondary Owner:** Hudson King

**Common Issues:**

- Occasionally sales data arrives late from the legacy servers
- *Known Issue*: pipeline fails if the sales data file is missing a header row

**Standard Procedures:**  

- If the profit pipeline fails, contact the [Profit Pipeline owners](#profit-pipeline)
- For data delays: Contact Ray Charley with Sales if sales data isn't received by 2 days after the expected deadline

**Critical Downstream Team:** Profit team

### Growth Pipeline

Enables the organization to monitor, analyze, and act on growth trends by providing timely and accurate growth data.

**Primary Owner:** Jackson Long

**Secondary Owner:** Hudson King

**Common Issues:**

- Duplicated records
- Timezone mis-alignment

**Standard Procedures:**  

- Filter duplicated records
- Timezones must be converted to align

**Critical Downstream Team:** Growth team

### Aggregate Growth Reported for Investors Pipeline

Turns detailed growth data into high-level, investor-ready summaries and reports, enabling clear, accurate communication of the company’s growth story to external stakeholders.

**Primary Owner:** Hudson King

**Secondary Owner:** Miles Lopez

**Common Issues:**

- Sometimes skews into out of memory exceptions

**Standard Procedures:**  

- Enable adaptive execution using Spark 3

### Daily Growth for Experiments Pipeline

Provides timely, experiment-focused daily growth insights, helping teams quickly evaluate the effectiveness of business experiments and make data-driven decisions.

**Primary Owner:** Jackson Long

**Secondary Owner:** Jasmine Glancy

**Common Issues:**

- Occasional misassignment bugs and metric calculation errors
- Data may sometimes arrive late

**Standard Procedures:**  Follow up with [Growth Pipeline](#growth-pipeline) if there are any delays or misassignment bugs

**Critical Downstream Team:** Growth team

### Engagement Pipeline

Enables the organization to monitor, analyze, and act on user engagement trends by providing timely and accurate engagement data.

**Primary Owner:** Jasmine Glancy

**Secondary Owner:** Jackson Long

**Common Issues:**

- Bots need to be cleaned out of the data

**Standard Procedures:**  If the user is determined to be a bot, filter them out of the results

**Critical Downstream Team:** Price team

### Aggregate Engagement for Investors Pipeline

Turns detailed engagement data into high-level, investor-ready summaries and reports, enabling clear, accurate communication of the company’s engagement story to external stakeholders.

**Primary Owner:** Hudson King

**Secondary Owner:** Miles Lopez

**Common Issues:**

- Use Azure Data Factory to clear the tasks for the selected partitioned dates in the [engagement pipeline](#engagement-pipeline) to ensure this pipeline is updated with the correct data when you use backfill

**Standard Procedures:** To clear tasks, please refer to the [Microsoft Docs](#https://learn.microsoft.com/en-us/fabric/data-factory/delete-data-activity).

## On-Call Schedule

Each person has a 24 hour on-call schedule starting at midnight. On-call rotates every 7 days.

The same holiday is not scheduled for the same person more than every 4 years. Employees are able to trade holiday on-call shifts, but not assigned on-call shifts. If team members turn over, new team members inherit the freed holidays from the previous team member.

### SLA (Service Level Agreement)

**Objective:**  
Define the expected reliability, timeliness, and quality standards for all pipelines.

**Availability:**  

- Pipelines are expected to run successfully **99.5% of scheduled runs per month**.

**Timeliness:**  

- Data must be available to downstream teams by **8:00 AM UTC** each business day.
- Delays greater than **1 hour** must be communicated to all stakeholders.

**Data Quality:**  

- No more than **0.1% of records** may be dropped or fail validation per run.
- All critical fields (e.g., transaction_id, date, amount) must be non-null.

**Incident Response:**  

- Critical failures must be acknowledged within **15 minutes** during business hours.
- Resolution or workaround must be provided within **3 hours** of incident detection.

**Escalation:**  

- If the SLA is breached, escalate to Data Engineering Manager and notify the downstream team leads.

**Review:**  

- SLA compliance is reviewed **monthly** in the team’s operations meeting.
