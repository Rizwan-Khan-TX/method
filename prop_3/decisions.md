```markdown id="oe2syv"
# Design Decisions and Trade-Offs

## 1. here I am only using data `linking` to SQL server
## 2. can use that to directly load data in Kimball style data warehouse, again assuming CDC data, with soft deletes and SCD2 approach

IMHO, This is the simplest approach, although it avoids Python completely, but we can always wrap this around python to achieve following

- dynamically infer schemas or new data sources
- wrap all sql scripts through pyodbc and execute on SQL 
- this provides all data availability in one easy to access layer (SQL developers are easy to find vs python experts)
- readability for reviewers