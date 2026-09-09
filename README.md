# Infrastructure & Database Reliability Assessment

Complete repository containing Terraform AWS architecture specifications, Docker container configurations, PostgreSQL relational schemas, query tuning strategies, and database recovery pipelines.

---

## 1. Local Database Environment

### Requirements
* Docker & Docker Compose Plugin
* PostgreSQL Client Tools (`psql`) - *Optional*

### Startup Procedure
Run the local environment using Docker Compose:
```bash
docker compose up -d
```
This automatically handles database initialization (`db/init.sql`) and data generation (`scripts/seed.sql`).

### Verification
Confirm dataset initialization:
```bash
docker exec -it local_postgres psql -U postgres -d booking_db -c "SELECT COUNT(*) FROM hotel_bookings;"
```

---

## 2. Query Optimization

### Benchmark Target
```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

### Execution Strategy & Composite Indexing
A dedicated compound index with payload inclusion was applied:

```sql
CREATE INDEX idx_hotel_bookings_city_created_org_status 
ON hotel_bookings (city, created_at, org_id, status) 
INCLUDE (amount);
```

### Technical Justification
1. **Filtering Mechanics (`city`, `created_at`)**: Placing high-cardinality strict matching columns (`city`) first, followed by range predicates (`created_at`), isolates matching index ranges early without scanning the underlying table heap.
2. **Aggregation Aligning (`org_id`, `status`)**: Appending grouping parameters directly to the index key array allows PostgreSQL to handle execution operations in a single index scan pass.
3. **Index-Only Scans (`INCLUDE (amount)`)**: Covering `amount` directly inside the leaf structures allows full statement execution directly from index pages, skipping Heap Tuple fetching.

---

## 3. Disaster Recovery Pipelines

Make sure the scripts are executable:
```bash
chmod +x scripts/backup.sh scripts/restore.sh
```

### Execution
1. **Trigger Automated Dump:**
   ```bash
   ./scripts/backup.sh
   ```
   Outputs a compressed timestamp archive in `./backups/`.

2. **Purge active table rows (Simulate Failure):**
   ```bash
   docker exec -it local_postgres psql -U postgres -d booking_db -c "TRUNCATE hotel_bookings CASCADE;"
   ```

3. **Execute System Restore:**
   ```bash
   ./scripts/restore.sh
   ```

4. **Verify Data Recovery:**
   ```bash
   docker exec -it local_postgres psql -U postgres -d booking_db -c "SELECT COUNT(*) FROM hotel_bookings;"
   ```

---

## 4. Terraform Validation & Planning

Validate infrastructure states without provisioning active AWS nodes:

```bash
cd infra/envs/dev

# 1. Format Verification
terraform fmt -check ../..

# 2. Initialization
terraform init -backend=false

# 3. Static Validation
terraform validate

# 4. Plan Output Execution
terraform plan -refresh=false
```
