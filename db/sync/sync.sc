// Copy all authz_umichlib tables from Oracle to MariaDB.
//
// As of Spark 3.2.1, we must use the MySQL Connector/J to connect to MariaDB
// because of some dialect / datatype issues.
//
// As of Spark 3.4.1, the MariaDB connector works, as long as the permitMysqlScheme
// parameter is used on the connection.
//
// Spark 3.5.1 has some problem with a plan string buffer size limit, apparently
// related to an upgrade to the Jackson version. It looks to be configurable.
//
// This works with Spark 3.4.1 (-scala image variants), via spark-shell.
// Depends on MariaDB connector and Oracle JDBC (ojdbc11) driver.
//
// The connection strings must be set in the ORACLE_URL and MARIADB_URL environment variables.
//
// If running in a container built with the companion Dockerfile, the conf/spark-defaults.conf
// already sets the the Ivy directory and specifies the packages, and the build
// will have downloaded them to the cache, with spark-shell on the PATH. The default command
// will also be to run this file and terminate. If you need something else:
// 
// The packages can be downloaded via Maven and this script can be run "immediately":
//
//   spark-shell --packages com.oracle.database.jdbc:ojdbc11:21.5.0.0,org.mariadb.jdbc:mariadb-java-client:3.3.3 -I sync.sc
//
// When running in a container based on the official Spark image, you will need to
// specify a directory that can be written/created for the Maven/Ivy downloads, e.g.:
//
//   spark-shell --conf "spark.jars.ivy=/opt/spark/work-dir/ivy" ...
//
// This should leave you in the Spark shell, which you can exit with `exit` or Ctrl-d.
//
// Another approach is to pipe :exit into spark-shell to terminate automatically:
//
//   echo :exit | spark-shell -I sync.sc
import java.util.Properties
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.DataFrameReader
import org.apache.spark.sql.DataFrameWriter

// Oracle connection string, e.g.,
// jdbc:oracle:thin:<username>/<password>@<hostname>:1521:<sid>
// jdbc:oracle:thin:somebody/pw@localhost:1521:orcl
val ourl = scala.util.Properties.envOrElse("ORACLE_URL", "ORACLE_URL not set in env")

// MariaDB/MySQL connection string, e.g.,
// jdbc:mysql://<hostname>:3306/<database>?user=<username>&password=<password>&permitMysqlScheme
// jdbc:mysql://localhost:3306/authz_umichlib?user=somebody&password=pw&permitMysqlScheme
val murl = scala.util.Properties.envOrElse("MARIADB_URL", "MARIADB_URL not set in env")

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
        .option("driver", "org.mariadb.jdbc.Driver")
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
