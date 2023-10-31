// Copy all authz_umichlib tables from Oracle to MariaDB.
//
// As of Spark 3.2.1, we must use the MySQL Connector/J to connect to MariaDB
// because of some dialect / datatype issues.
//
// This was used with Spark 3.2.1, via spark-shell.
// Depends on MySQL Connector/J and Oracle JDBC (ojdbc11) driver.
//
// The connection strings must be set in the ORACLE_DB_URL and MYSQL_DB_URL environment variables.
//
// The packages can be downloaded via Maven and this script can be run "immediately":
//
//   spark-shell --packages com.oracle.database.jdbc:ojdbc11:21.5.0.0,mysql:mysql-connector-java:8.0.29 -I migrate.sc
// 
// This should leave you in the Spark shell, which you can exit with `exit` or Ctrl-d.
import java.util.Properties
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.DataFrameReader
import org.apache.spark.sql.DataFrameWriter

// Oracle connection string, e.g.,
// jdbc:oracle:thin:<username>/<password>@<hostname>:1521:<sid>
// jdbc:oracle:thin:somebody/pw@localhost:1521:orcl
val ourl = scala.util.Properties.envOrElse("ORACLE_DB_URL", "ORACLE_DB_URL not set in env")

// MariaDB/MySQL connection string, e.g.,
// jdbc:mysql://<hostname>:3306/<database>?user=<username>&password=<password>
// jdbc:mysql://localhsot:3306/authz_umichlib?user=somebody&password=pw
val murl = scala.util.Properties.envOrElse("MYSQL_DB_URL", "MYSQL_DB_URL not set in env")

// Read a table from Oracle.
// This builds a DataFrameReader, then loads it to give a DataFrame.
def oread(table:String) : DataFrame = {
    spark.read.format("jdbc")
        .option("driver", "oracle.jdbc.OracleDriver")
        .option("url", ourl)
        .option("dbtable", table)
        .load()
}

// Write a DataFrame to a MariaDB/MySQL table.
// This takes a loaded DataFrame and a table name.
// The config here expects the table to exist and uses TRUNCATE rather than DROP.
def mwrite(df:DataFrame, table:String) = {
    df.write.format("jdbc")
        .option("driver", "com.mysql.cj.jdbc.Driver")
        .option("url", murl)
        .option("dbtable", table)
        .option("sessionInitStatement", "SET FOREIGN_KEY_CHECKS=0")
        .mode("overwrite")
        .option("truncate", "true")
        .save()
}

// Copy a table from the Oracle database to the MariaDB/MySQL database.
def migrate(table:String) = {
    mwrite(oread(table), table)
}

migrate("aa_user")
migrate("aa_user_grp")
migrate("aa_inst")
migrate("aa_is_member_of_inst")
migrate("aa_is_member_of_grp")
migrate("aa_coll")
migrate("aa_coll_obj")
migrate("aa_network")
migrate("aa_may_access")
