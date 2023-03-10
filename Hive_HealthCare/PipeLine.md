# End to End Implementation:

# 1. Import client data to distributed filesystem of warehouse 


- Moving data from the Client Source. 
- Client Source MySQL : HealthCare Database consisting of 13 tables.
- Redirect to the path : C:\Program Files\MySQL\MySQL Server 8.0\bin to create a database dump file.
- MySQL Dump : 

             mysqldump -u root -p --port=3308 healthcare_db > healthcare.sql in cmd prompt Administrator.

- Drag and Place the dump file from the local System to Cloudera. 

             mysqldump -u root -p --port=3308 healthcare < healthcare.sql

-  It creates a healthcare database in MySQL with the tables extracted from Dump File.
-  Source : MySQL  and Target : Hive, So the tables have to be Ingested to hive from RDBMS using Scoop import.

            sqoop import-all-tables \
            --connect jdbc:mysql://localhost:3306/healthcare \
            --username root \
            --hive-import  \
            --m 1
- By default, the Table's are stored in user/hive/warehouse from the above cmd.
- Here the tables are stored in default database.

# 2. Implement data analysis with hive queries on internal tables
