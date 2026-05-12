```markdown id="oe2syv"
# Design Decisions and Trade-Offs

## 1. Chose pandas over Spark or distributed frameworks

The provided datasets were relatively small (~500 transaction rows), so pandas provided a lightweight and highly readable implementation without introducing unnecessary infrastructure complexity.

This decision prioritized:
- simplicity
- maintainability
- rapid development
- readability for reviewers

---

## 2. Used SQL Server instead of SQLite or DuckDB

SQL Server was selected because it aligns closely with enterprise analytical serving environments and reflects platforms commonly used in production data warehouse ecosystems.

The implementation intentionally remained lightweight despite using an enterprise database platform.

---

## 3. Implemented quarantine-based data quality handling

Invalid records are quarantined instead of silently dropped.

This approach preserves:
- auditability
- traceability
- operational transparency

Each rejected record includes a `dq_reason` field to clearly identify validation failures.

---

## 4. Separated ingestion, validation, transformation, and load layers

The pipeline was intentionally structured into modular layers to improve:
- readability
- maintainability
- extensibility
- testing isolation

This separation also mirrors common enterprise data engineering and warehouse processing patterns.

---

## 5. Added additional anomaly checks beyond requirements

In addition to required validations, the pipeline also checks for:
- negative quantities
- negative unit prices

These were treated as invalid business transactions and quarantined accordingly.

---

## 6. Kept implementation intentionally lightweight

The assessment specifically advised against over-engineering.

As a result, the implementation intentionally avoids:
- orchestration frameworks
- distributed compute engines
- heavy abstractions
- complex object-oriented patterns

The focus was placed on:
- clean structure
- understandable logic
- operational clarity
- maintainable code