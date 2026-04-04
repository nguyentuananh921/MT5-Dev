// SqLiteTest.cpp : This file contains the 'main' function. Program execution begins and ends there.
//
#include "pch.h"
#include <iostream>
#include <string>
#include <windows.h>

#include <string.h>     // for strcpy_s, strcat_s
#include <stdlib.h>     // for _countof
#include <stdio.h>      // for printf
#include <errno.h>      // for return values
#include "sqlite3.h"

using namespace std;

//--- flag to see all stages
#define EXECUTION_LOG_MODE false
//--- type test function
typedef bool(*TTestFunction)(string, string&, double&);


//--- constants
string ones[] = { "","one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
string teens[] = { "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen","sixteen", "seventeen", "eighteen", "nineteen" };
string tens[] = { "", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety" };
//+---------------------------------------------------------------------+
//| C++ converting number to words                                      |
//| stackoverflow.com/questions/40252753/c-converting-number-to-words/  |
//+---------------------------------------------------------------------+
string NumberToString(long long number)
{
	//---
	if (number < 10)
		return(ones[(int)number]);
	if (number < 20)
		return(teens[(int)(number - 10)]);
	if (number < 100)
		return(tens[(int)(number / 10)] + ((number % 10 != 0) ? " " + NumberToString(number % 10) : ""));
	if (number < 1000)
		return(NumberToString(number / 100) + " hundred" + ((number % 100 != 0) ? " " + NumberToString(number % 100) : ""));
	if (number < 1000000)
		return(NumberToString(number / 1000) + " thousand" + ((number % 1000 != 0) ? " " + NumberToString(number % 1000) : ""));
	if (number < 1000000000)
		return(NumberToString(number / 1000000) + " million" + ((number % 1000000 != 0) ? " " + NumberToString(number % 1000000) : ""));
	if (number < 1000000000000)
		return(NumberToString(number / 1000000000) + " billion" + ((number % 1000000000 != 0) ? " " + NumberToString(number % 1000000000) : ""));
	//---
	return("error");
}


// https://www.tutorialspoint.com/sqlite/sqlite_c_cpp.htm
//+---------------------------------------------------------------------+
//| callback                                                            |
//+---------------------------------------------------------------------+
static int callback(void *NotUsed, int argc, char **argv, char **azColName)
{
	return 0;
	printf("!!!!!!!!!!!!!!!!!!!!!!!!callback\n");
	for (int i = 0; i < argc; i++)
	{
		printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
	}
	printf("\n");
	return 0;
}
//--- Database Speed Comparison
//--- https://sqlite.org/speed.html
//--- https://web.archive.org/web/20130321040427/http://www.sergeant.org/sqlite_vs_pgsync.html
//+---------------------------------------------------------------------+
//| Test 1: 1000 INSERTs                                                |
//+---------------------------------------------------------------------+
//| Because it does not have a central server to coordinate access,     |
//| SQLite must close and reopen the database file, and thus invalidate |
//| its cache, for each transaction.                                    |
//| In this test, each SQL statement is a separate transaction so       |
//| the database file must be opened and closed and the cache           |
//| must be flushed 1000 times.                                         |
//| In spite of this, the asynchronous version of SQLite is still       |
//| nearly as fast as MySQL. Notice how much slower the synchronous,    |
//| version is however. SQLite calls fsync() after each synchronous     |
//| transaction to make sure that all data is safely on the disk surface|
//| before continuing. For most of the 13 seconds in the synchronous    |
//| test, SQLite was sitting idle waiting on disk I / O to complete.    |
//+---------------------------------------------------------------------+
bool Test1(string database_name, string &test_name, double &test_elapsed_time)
{
	//---
	//--- INSERT INTO t1 VALUES(1, 13153, 'thirteen thousand one hundred fifty three');
	//--- INSERT INTO t1 VALUES(2, 75560, 'seventy five thousand five hundred sixty');
	//--- ... 995 lines omitted
	//--- INSERT INTO t1 VALUES(998, 66289, 'sixty six thousand two hundred eighty nine');
	//--- INSERT INTO t1 VALUES(999, 24322, 'twenty four thousand three hundred twenty two');
	//--- INSERT INTO t1 VALUES(1000, 94142, 'ninety four thousand one hundred forty two');
	//--- PostgreSQL:      4.373
	//--- MySQL : 0.114
	//--- SQLite 2.7.6 : 13.061
	//--- SQLite 2.7.6 (nosync) : 0.223
	//---
	sqlite3 *db;
	char *zErrMsg = 0;
//---
	test_name = "Test 1: 1000 INSERTs";
	test_elapsed_time = 0;
	if (database_name == "")
	{
		printf("Error. Database file not specified.\n");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.\n");

	//--- 2. create table t1
	string sql_request2 = "CREATE TABLE t1(a INTEGER, b INTEGER, c VARCHAR(100));";
	//--- execute SQL statement
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("2. Table t1 created successfully.\n");


	//--- 3. Prepare 1000 INSERT requests
	if (EXECUTION_LOG_MODE)
		printf("3. Prepare 1000 INSERT requests.\n");


	//--- 3. Perform 1000 INSERT requests
	const int total_requests = 1000;
	//--- prepare requests
	string SQL_requests[total_requests] = { };
	for (int i = 0; i < total_requests; i++)
	{
		SQL_requests[i] = "INSERT INTO t1 VALUES(" + to_string(i) + ", " + to_string(i) + ",'" + NumberToString(i) + "');";
	}
	//---
	if (EXECUTION_LOG_MODE)
		printf("4. Perform 1000 INSERT requests...\n");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);
	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}
	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	else
	{
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		printf("Errors = %d.\n", total_errors);
		return(false);
	}
	//--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 2: 25000 INSERTs in a transaction                              |
//+---------------------------------------------------------------------+
//| When all the INSERTs are put in a transaction, SQLite no longer has |
//| to close and reopen the database or invalidate its cache between    |
//| each statement.                                                     |
//| It also does not have to do any fsync()s until the very end.        |
//| When unshackled in this way, SQLite is much faster than either      |
//| PostgreSQL and MySQL.                                               |
//+---------------------------------------------------------------------+
bool Test2(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- BEGIN;
	//--- CREATE TABLE t2(a INTEGER, b INTEGER, c VARCHAR(100));
	//--- INSERT INTO t2 VALUES(1, 59672, 'fifty nine thousand six hundred seventy two');
	//--- ... 24997 lines omitted
	//--- INSERT INTO t2 VALUES(24999, 89569, 'eighty nine thousand five hundred sixty nine');
	//--- INSERT INTO t2 VALUES(25000, 94666, 'ninety four thousand six hundred sixty six');
	//--- COMMIT;
	//--- PostgreSQL:    4.900
	//--- MySQL:      2.184
	//--- SQLite 2.7.6 : 0.914
	//--- SQLite 2.7.6 (nosync) : 0.757
	sqlite3 *db;
	char *zErrMsg = 0;

	test_name = "Test 2: 25000 INSERTs in a transaction";
	test_elapsed_time = 0;
	if (database_name == "")
	{
		printf("Error. Database file not specified.\n");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.\n");

	//--- 2. Prepare 25000 INSERT requests
	if (EXECUTION_LOG_MODE)
		printf("2. Prepare 25000 INSERT requests.\n");
	const int total_requests = 25000;
	//--- prepare requests
	string SQL_requests[total_requests] = { };
	//--- prepare requests
	for (int i = 0; i < total_requests; i++)
	{
		SQL_requests[i] = "INSERT INTO t2 VALUES(" + to_string(i) + ", " + to_string(i) + ",'" + NumberToString(i) + "');";
	}


	//--- 3. begin transaction
	if (EXECUTION_LOG_MODE)
		printf("3. Perform transaction BEGIN, Create table, 25000 INSERTs, COMMIT.");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	string sql_request1 = "BEGIN;";
	//--- execute SQL statement
	rc = sqlite3_exec(db, sql_request1.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}

	//--- 4. create table t1
	string sql_request2 = "CREATE TABLE t2(a INTEGER, b INTEGER, c VARCHAR(100));";
	//--- execute SQL statement
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- 5. perform 25000 INSERTs
	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}

	//--- 4. commit transaction
	string sql_request3 = "COMMIT;";
	//--- execute SQL statement
	rc = sqlite3_exec(db, sql_request3.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	else
	{
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		printf("Errors = %d.\n", total_errors);
		return(false);
	}
	//--- close database
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 3: 25000 INSERTs into an indexed table                         |
//+---------------------------------------------------------------------+
//| There were reports that SQLite did not perform as well on an        |
//| indexed table. This test was recently added to disprove those       |
//| rumors. It is true that SQLite is not as fast at creating new index |
//| entries as the other engines (see Test 6 below) but its overall     |
//| speed is still better.                                              |
//+---------------------------------------------------------------------+
bool Test3(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- BEGIN;
	//--- CREATE TABLE t3(a INTEGER, b INTEGER, c VARCHAR(100));
	//--- CREATE INDEX i3 ON t3(c);
	//--- ... 24998 lines omitted
	//--- INSERT INTO t3 VALUES(24999, 88509, 'eighty eight thousand five hundred nine');
	//--- INSERT INTO t3 VALUES(25000, 84791, 'eighty four thousand seven hundred ninety one');
	//--- COMMIT;
	//---
	//--- PostgreSQL:    8.175
	//--- MySQL : 3.197
	//--- SQLite 2.7.6 : 1.555
	//--- SQLite 2.7.6 (nosync) : 1.402
	sqlite3 *db;
	char *zErrMsg = 0;

	test_name = "Test 3: 25000 INSERTs into an indexed table";
	test_elapsed_time = 0;
	if (database_name == "")
	{
		printf("Error. Database file not specified.\n");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.\n");

	//--- 2. Prepare 25000 INSERT requests
	if (EXECUTION_LOG_MODE)
		printf("2. Prepare 25000 INSERT requests.\n");

	const int total_requests = 25000;
	//--- prepare requests
	string SQL_requests[total_requests] = { };
	for (int i = 0; i < total_requests; i++)
	{
		SQL_requests[i] = "INSERT INTO t3 VALUES(" + to_string(i) + ", " + to_string(i) + ",'" + NumberToString(i) + "');";
	}

	if (EXECUTION_LOG_MODE)
		printf("3. Perform transaction BEGIN, Create table, Create index, 25000 INSERTs, COMMIT.\n");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	//--- 3. begin transaction
	string sql_request1 = "BEGIN;";
	rc = sqlite3_exec(db, sql_request1.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}


	//--- 4. create table t1
	string sql_request2 = "CREATE TABLE t3(a INTEGER, b INTEGER, c VARCHAR(100));";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}

	//--- 5. create index t1
	string sql_request3 = "CREATE INDEX i3 ON t3(c);";
	rc = sqlite3_exec(db, sql_request3.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- 6. perform 25000 INSERTs
	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}

	//--- 7. commit transaction
	string sql_request4 = "COMMIT;";
	rc = sqlite3_exec(db, sql_request4.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}

	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	else
	{
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		printf("Errors = %d.\n", total_errors);
		return(false);
	}
	//--- close database
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 4: 100 SELECTs without an index                                |
//+---------------------------------------------------------------------+
//| This test does 100 queries on a 25000 entry table without an index, |
//| thus requiring a full table scan. Prior versions of SQLite used to  |
//| be slower than PostgreSQL and MySQL on this test, but recent        |
//| performance enhancements have increased its speed so that it is     |
//| now the fastest of the group.                                       |
//+---------------------------------------------------------------------+
bool Test4(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- BEGIN;
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 0 AND b < 1000;
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 100 AND b < 1100;
	//--- ... 96 lines omitted
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 9800 AND b < 10800;
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 9900 AND b < 10900;
	//--- COMMIT;
	//---
	//--- PostgreSQL:    3.629
	//--- MySQL : 2.760
	//--- SQLite 2.7.6 : 2.494
	//--- SQLite 2.7.6 (nosync) : 2.526
	sqlite3 *db;
	char *zErrMsg = 0;

	test_name = "Test 4: 100 SELECTs without an index";
	test_elapsed_time = 0;
	if (database_name == "")
	{
		printf("Error. Database file not specified.\n");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.\n");
	//--- 2. Prepare 100 requests
	if (EXECUTION_LOG_MODE)
		printf("2. Prepare 100 SELECT requests.\n");

	const int total_requests = 100;
	//--- prepare requests
	string SQL_requests[total_requests] = { };
	for (int i = 0; i < total_requests; i++)
	{
		SQL_requests[i] = "SELECT count(*), avg(b) FROM t2 WHERE b >=" + to_string(i * 100) + " AND b < " + to_string((i * 100) + 1000) + ";";
	}

	if (EXECUTION_LOG_MODE)
		printf("3. Perform transaction BEGIN, 100 SELECTs, COMMIT.\n");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	//--- 3. begin transaction
	string sql_request1 = "BEGIN;";
	rc = sqlite3_exec(db, sql_request1.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- 4. perform 100 SELECT
	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}

	//--- 5. commit transaction
	string sql_request2 = "COMMIT;";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	else
	{
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		printf("Errors = %d.\n", total_errors);
		return(false);
	}

	//--- close database
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 5: 100 SELECTs on a string comparison                          |
//+---------------------------------------------------------------------+
//| This test still does 100 full table scans but it uses uses string   |
//| comparisons instead of numerical comparisons.                       |
//| SQLite is over three times faster than PostgreSQL here and          |
//| about 30 % faster than MySQL.                                       |
//+---------------------------------------------------------------------+
bool Test5(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- BEGIN;
	//--- SELECT count(*), avg(b) FROM t2 WHERE c LIKE '%one%';
	//--- SELECT count(*), avg(b) FROM t2 WHERE c LIKE '%two%';
	//--- ... 96 lines omitted
	//--- SELECT count(*), avg(b) FROM t2 WHERE c LIKE '%ninety nine%';
	//--- SELECT count(*), avg(b) FROM t2 WHERE c LIKE '%one hundred%';
	//--- COMMIT;
	//---
	//--- PostgreSQL:    13.409
	//--- MySQL : 4.640
	//--- SQLite 2.7.6 : 3.362
	//--- SQLite 2.7.6 (nosync) : 3.372
	//---
	sqlite3 *db;
	char *zErrMsg = 0;

	test_name = "Test 5: 100 SELECTs on a string comparison";
	test_elapsed_time = 0;
	if (database_name == "")
	{
		printf("Error. Database file not specified.\n");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.\n");

	//--- 2. Prepare 100 requests
	if (EXECUTION_LOG_MODE)
		printf("2. Prepare 100 SELECT requests.\n");

	//--- prepare requests
	const int total_requests = 100;
	string SQL_requests[total_requests] = { };
	for (int i = 0; i < total_requests; i++)
	{
		int rnd = (int)round(100.0*rand()/32768.0);
		SQL_requests[i] = "SELECT count(*), avg(b) FROM t2 WHERE c LIKE '%" + NumberToString(rnd) + "%';";
	}

	if (EXECUTION_LOG_MODE)
		printf("3. Perform transaction BEGIN, 100 SELECTs with LIKE, COMMIT.\n");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	//--- 3. begin transaction
	string sql_request2 = "BEGIN;";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- 4. perform 100 SELECTs
	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}

	//--- 5. commit transaction
	string sql_request3 = "COMMIT;";
	rc = sqlite3_exec(db, sql_request3.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}

	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	else
	{
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		printf("Errors = %d.\n", total_errors);
		return(false);
	}
	 //--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 6: Creating an index                                           |
//+---------------------------------------------------------------------+
//| SQLite is slower at creating new indices.This is not a huge problem |
//| (since new indices are not created very often) but it is something  |
//| that is being worked on.                                            |
//| Hopefully, future versions of SQLite will do better here.           |
//+---------------------------------------------------------------------+
bool Test6(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- CREATE INDEX i2a ON t2(a);
	//--- CREATE INDEX i2b ON t2(b);
	//---
	//--- PostgreSQL:    0.381
	//--- MySQL : 0.318
	//--- SQLite 2.7.6 : 0.777
	//--- SQLite 2.7.6 (nosync) : 0.659
	sqlite3 *db;
	char *zErrMsg = 0;

	test_name = "Test 6: Creating an index";
	test_elapsed_time = 0;
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");

	if (EXECUTION_LOG_MODE)
		printf("2. Create indexes i2a and i2b.");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	string sql_request1 = "CREATE INDEX i3a ON t2(a);";
	rc = sqlite3_exec(db, sql_request1.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}

	string sql_request2 = "CREATE INDEX i2b ON t2(b);";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- stop timer and compute the elapsed time in milliseconds
	QueryPerformanceCounter(&time2);
	test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
    //--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 7: 5000 SELECTs with an index                                  |
//+---------------------------------------------------------------------+
//| All three database engines run faster when they have indices        |
//| to work with. But SQLite is still the fastest.                      |
//+---------------------------------------------------------------------+
bool Test7(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 0 AND b < 100;
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 100 AND b < 200;
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 200 AND b < 300;
	//--- ... 4994 lines omitted
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 499700 AND b < 499800;
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 499800 AND b < 499900;
	//--- SELECT count(*), avg(b) FROM t2 WHERE b >= 499900 AND b < 500000;
	//---
	//--- PostgreSQL:    4.614
	//--- MySQL : 1.270
	//--- SQLite 2.7.6 : 1.121
	//--- SQLite 2.7.6 (nosync) : 1.162
	sqlite3 *db;
	char *zErrMsg = 0;
	test_name = "Test 7: 5000 SELECTs with an index";
	test_elapsed_time = 0;
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");


	//--- 2. Prepare 5000 requests
	const int total_requests = 5000;
	if (EXECUTION_LOG_MODE)
		printf("2. Prepare %d SELECT requests.", total_requests);
	//--- prepare requests
	string SQL_requests[total_requests] = { };
	for (int i = 0; i < total_requests; i++)
	{
		SQL_requests[i] = "SELECT count(*), avg(b) FROM t2 WHERE b >=" + to_string(i * 100) + " AND b < " + to_string((i * 100) + 1000) + ";";
	}

	if (EXECUTION_LOG_MODE)
		printf("3. Perform %d SELECTs", total_requests);
	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	//--- 3. perform SELECTs
	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}
	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	else
	{
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		printf("Errors = %d.\n", total_errors);
		return(false);
	}
	 //--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 8: 1000 UPDATEs without an index                               |
//+---------------------------------------------------------------------+
//| For this particular UPDATE test, MySQL is consistently five or ten  |
//| times slower than PostgreSQL and SQLite. I do not know why.         |
//| MySQL is normally a very fast engine.                               |
//| Perhaps this problem has been addressed in later versions of MySQL. |
//+---------------------------------------------------------------------+
bool Test8(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- BEGIN;
	//--- UPDATE t1 SET b = b * 2 WHERE a >= 0 AND a < 10;
	//--- UPDATE t1 SET b = b * 2 WHERE a >= 10 AND a < 20;
	//--- ... 996 lines omitted
	//--- UPDATE t1 SET b = b * 2 WHERE a >= 9980 AND a < 9990;
	//--- UPDATE t1 SET b = b * 2 WHERE a >= 9990 AND a < 10000;
	//--- COMMIT;
	//---
	//--- PostgreSQL:    1.739
	//--- MySQL : 8.410
	//--- SQLite 2.7.6 : 0.637
	//--- SQLite 2.7.6 (nosync) : 0.638
	sqlite3 *db;
	char *zErrMsg = 0;
	test_elapsed_time = 0;
	test_name = "Test 8: 1000 UPDATEs without an index";
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");

	
	//--- 2. Prepare 1000 UPDATE requests
	const int total_requests = 1000;
	if (EXECUTION_LOG_MODE)
		printf("2. Prepare %d UPDATE requests.", total_requests);

	//--- prepare requests
	string SQL_requests[total_requests] = { };
	for (int i = 0; i < total_requests; i++)
	{
		SQL_requests[i] = "UPDATE t1 SET b = b * 2 WHERE a >= " + to_string(i * 10) + " AND a <" + to_string((i + 1) * 10) + ";";
	}
	if (EXECUTION_LOG_MODE)
		printf("3. Perform transaction BEGIN, 1000 UPDATE, COMMIT.");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	//--- 3. begin transaction
	string sql_request1 = "BEGIN;";
	rc = sqlite3_exec(db, sql_request1.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}

	//--- 4. perform 1000 UPDATEs
	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}

	//--- 5. commit transaction
	string sql_request2 = "COMMIT;";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	else
	{
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		printf("Errors = %d.\n", total_errors);
		return(false);
	}
	 //--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 9: 25000 UPDATEs with an index                                 |
//+---------------------------------------------------------------------+
//|  As recently as version 2.7.0, SQLite ran at about the same speed   |
//|  as MySQL on this test. But recent optimizations to SQLite have     |
//|  more than doubled speed of UPDATEs.                                |
//+---------------------------------------------------------------------+
bool Test9(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- BEGIN;
	//--- UPDATE t2 SET b = 468026 WHERE a = 1;
	//--- UPDATE t2 SET b = 121928 WHERE a = 2;
	//--- ... 24996 lines omitted
	//--- UPDATE t2 SET b = 35065 WHERE a = 24999;
	//--- UPDATE t2 SET b = 347393 WHERE a = 25000;
	//--- COMMIT;
	//---
	//--- PostgreSQL:    18.797
	//--- MySQL : 8.134
	//--- SQLite 2.7.6 : 3.520
	//--- SQLite 2.7.6 (nosync) : 3.104
	sqlite3 *db;
	char *zErrMsg = 0;
	test_elapsed_time = 0;
	test_name = "Test 9: 25000 UPDATEs with an index";
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");

	const int total_requests = 25000;
	//--- 2. Prepare 25000 UPDATE requests
	if (EXECUTION_LOG_MODE)
		printf("2. Prepare %d UPDATE requests.", total_requests);

	//--- prepare requests
	string SQL_requests[total_requests] = { };
	for (int i = 0; i < total_requests; i++)
	{
		int rnd = (int)round(800000.0*rand() / 32768.0);
		SQL_requests[i] = "UPDATE t2 SET b = " + to_string(rnd) + " WHERE a = " + to_string(i) + ";";
	}
	if (EXECUTION_LOG_MODE)
		printf("3. Perform transaction BEGIN, 25000 UPDATEs, COMMIT.");


	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	//--- 3. begin transaction
	string sql_request2 = "BEGIN;";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}


	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}
	//--- 5. commit transaction
	string sql_request3 = "COMMIT;";
	rc = sqlite3_exec(db, sql_request3.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}


	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	else
	{
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		printf("Errors = %d.\n", total_errors);
		return(false);
	}

	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 10: 25000 text UPDATEs with an index                           |
//+---------------------------------------------------------------------+
//| Here again, version 2.7.0 of SQLite used to run at about the same   |
//| speed as MySQL. But now version 2.7.6 is over two times faster      |
//| than MySQL and over twenty times faster than PostgreSQL.            |
//| In fairness to PostgreSQL, it started thrashing on this test.       |
//| A knowledgeable administrator might be able to get PostgreSQL to    |
//| run a lot faster here by tweaking and tuning the server a little.   |
//+---------------------------------------------------------------------+
bool Test10(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- BEGIN;
	//--- UPDATE t2 SET c = 'one hundred forty eight thousand three hundred eighty two' WHERE a = 1;
	//--- UPDATE t2 SET c = 'three hundred sixty six thousand five hundred two' WHERE a = 2;
	//--- ... 24996 lines omitted
	//--- UPDATE t2 SET c = 'three hundred eighty three thousand ninety nine' WHERE a = 24999;
	//--- UPDATE t2 SET c = 'two hundred fifty six thousand eight hundred thirty' WHERE a = 25000;
	//--- COMMIT;
	//--- PostgreSQL:    48.133
	//--- MySQL : 6.982
	//--- SQLite 2.7.6 : 2.408
	//--- SQLite 2.7.6 (nosync) : 1.725
	//---
	sqlite3 *db;
	char *zErrMsg = 0;
	test_elapsed_time = 0;
	test_name = "Test 10: 25000 text UPDATEs with an index";
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");
	
	const int total_requests = 25000;
	//--- 2. Prepare 25000 UPDATE requests
	if (EXECUTION_LOG_MODE)
		printf("2. Prepare %d UPDATE requests.", total_requests);


	//--- prepare requests
	string SQL_requests[total_requests] = { };
	for (int i = 0; i < total_requests; i++)
	{
		int rnd = (int)round(25000.0*rand() / 32768.0);
		SQL_requests[i] = "UPDATE t2 SET c = '" + to_string(rnd) + "' WHERE a = " + to_string(i) + ";";
	}

	if (EXECUTION_LOG_MODE)
		printf("3. Perform transaction BEGIN, 25000 UPDATEs, COMMIT.");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	//--- 3. begin transaction
	string sql_request1 = "BEGIN;";
	rc = sqlite3_exec(db, sql_request1.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}

	//--- 4. perform 25000 UPDATEs
	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}

	//--- 5. commit transaction
	string sql_request2 = "COMMIT;";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	else
	{
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		printf("Errors = %d.\n", total_errors);
		return(false);
	}
	 //--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 11: INSERTs from a SELECT                                      |
//+---------------------------------------------------------------------+
//| The asynchronous SQLite is just a shade slower than MySQL on this   |
//| test. (MySQL seems to be especially adept at INSERT...SELECT        |
//| statements.) The PostgreSQL engine is still thrashing - most of the |
//| 61 seconds it used were spent waiting on disk I/O.                  |
//+---------------------------------------------------------------------+
bool Test11(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- BEGIN;
	//--- INSERT INTO t1 SELECT b, a, c FROM t2;
	//--- INSERT INTO t2 SELECT b, a, c FROM t1;
	//--- COMMIT;
	//--- PostgreSQL:    61.364
	//--- MySQL : 1.537
	//--- SQLite 2.7.6 : 2.787
	//--- SQLite 2.7.6 (nosync) : 1.599
	//---
	sqlite3 *db;
	char *zErrMsg = 0;
	test_elapsed_time = 0;
	test_name = "Test 11: INSERTs from a SELECT";
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");

	if (EXECUTION_LOG_MODE)
		printf("2. Perform transaction BEGIN, INSERTS, COMMIT.");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);
	//--- 3. begin transaction
	string sql_request1 = "BEGIN;";
	rc = sqlite3_exec(db, sql_request1.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- 4. INSERT 1
	string sql_request2 = "INSERT INTO t1 SELECT b, a, c FROM t2;";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- 5. INSERT 2
	string sql_request3 = "INSERT INTO t2 SELECT b, a, c FROM t1;";
	rc = sqlite3_exec(db, sql_request3.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- 6. commit transaction
	string sql_request4 = "COMMIT;";
	rc = sqlite3_exec(db, sql_request4.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- stop timer and compute the elapsed time in milliseconds
	QueryPerformanceCounter(&time2);
	test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
	sqlite3_free(zErrMsg);
	//--- close database
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 12: DELETE without an index                                    |
//+---------------------------------------------------------------------+
//| The synchronous version of SQLite is the slowest of the group in    |
//| this test, but the asynchronous version is the fastest.             |
//| The difference is the extra time needed to execute fsync().         |
//+---------------------------------------------------------------------+
bool Test12(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- DELETE FROM t2 WHERE c LIKE '%fifty%';
	//---
	//--- PostgreSQL:    1.509
	//--- MySQL : 0.975
	//--- SQLite 2.7.6 : 4.004
	//--- SQLite 2.7.6 (nosync) : 0.560
	sqlite3 *db;
	char *zErrMsg = 0;
	test_elapsed_time = 0;
	test_name = "Test 12: DELETE without an index";
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");
	//---
	if (EXECUTION_LOG_MODE)
		printf("2. DELETE request");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);
	//--- 2. DELETE
	string sql_request = "DELETE FROM t2 WHERE c LIKE '%fifty%'";
	rc = sqlite3_exec(db, sql_request.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	QueryPerformanceCounter(&time2);
	test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
	//--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 13: DELETE with an index                                       |
//+---------------------------------------------------------------------+
//| This test is significant because it is one of the few where         |
//| PostgreSQL is faster than MySQL.                                    |
//| The asynchronous SQLite is, however, faster then both the other two.|
//+---------------------------------------------------------------------+
bool Test13(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- DELETE FROM t2 WHERE a > 10 AND a < 20000;
	//---
	//--- PostgreSQL:    1.316
	//--- MySQL : 2.262
	//--- SQLite 2.7.6 : 2.068
	//--- SQLite 2.7.6 (nosync) : 0.752
	sqlite3 *db;
	char *zErrMsg = 0;
	test_elapsed_time = 0;
	test_name = "Test 13: DELETE with an index";
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");
	
	//---
	if (EXECUTION_LOG_MODE)
		printf("2. DELETE request");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);
	//--- 2. DELETE
	string sql_request = "DELETE FROM t2 WHERE a > 10 AND a < 20000;";
	rc = sqlite3_exec(db, sql_request.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
//---
	QueryPerformanceCounter(&time2);
	test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
	//--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 14: A big INSERT after a big DELETE                            |
//+---------------------------------------------------------------------+
//| This test does 100 queries on a 25000 entry table without an index, |
//| thus requiring a full table scan.Prior versions of SQLite used to   |
//| be slower than PostgreSQL and MySQL on this test, but recent        |
//| performance enhancements have increased its speed so that it is     |
//| now the fastest of the group.                                       |
//+---------------------------------------------------------------------+
bool Test14(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- INSERT INTO t2 SELECT * FROM t1;
	//--- PostgreSQL:    13.168
	//--- MySQL : 1.815
	//--- SQLite 2.7.6 : 3.210
	//--- SQLite 2.7.6 (nosync) : 1.485
	sqlite3 *db;
	char *zErrMsg = 0;
	test_elapsed_time = 0;
	test_name = "Test 14: A big INSERT after a big DELETE";
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");

	//---
	if (EXECUTION_LOG_MODE)
		printf("2. Big INSERT request");


	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);
	//--- 2. INSERT
	string sql_request = "INSERT INTO t2 SELECT * FROM t1;";
	rc = sqlite3_exec(db, sql_request.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	QueryPerformanceCounter(&time2);
	test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;

	//--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 15: A big DELETE followed by many small INSERTs                |
//+---------------------------------------------------------------------+
//| SQLite is very good at doing INSERTs within a transaction,          |
//| which probably explains why it is so much faster                    |
//| than the other databases at this test.                              |
//+---------------------------------------------------------------------+
bool Test15(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- BEGIN;
	//--- DELETE FROM t1;
	//--- INSERT INTO t1 VALUES(1, 10719, 'ten thousand seven hundred nineteen');
	//--- ... 11997 lines omitted
	//--- INSERT INTO t1 VALUES(11999, 72836, 'seventy two thousand eight hundred thirty six');
	//--- INSERT INTO t1 VALUES(12000, 64231, 'sixty four thousand two hundred thirty one');
	//--- COMMIT;
	//--- PostgreSQL:    4.556
	//--- MySQL : 1.704
	//--- SQLite 2.7.6 : 0.618
	//--- SQLite 2.7.6 (nosync) : 0.406
	sqlite3 *db;
	char *zErrMsg = 0;

	test_name = "Test 15: A big DELETE followed by many small INSERTs";
	test_elapsed_time = 0;
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");
	
	//--- prepare 12000 INSERT requests.
	const int total_requests = 12000;
	//--- prepare requests
	//--- prepare requests
	string SQL_requests[total_requests] = { };
	for (int i = 0; i < total_requests; i++)
	{
		int rnd = (int)round(100.0*rand() / 32768.0);
		SQL_requests[i] = "INSERT INTO t1 VALUES(" + to_string(i) + ", " + to_string(rnd) + ",'" + NumberToString(rnd) + "');";
	}


	//--- 3. begin transaction
	if (EXECUTION_LOG_MODE)
		printf("3. Perform transaction BEGIN, DELETE, 12000 INSERTs, COMMIT.");
	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);

	string sql_request1 = "BEGIN;";
	rc = sqlite3_exec(db, sql_request1.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//---
	string sql_request2 = "DELETE FROM t1;";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//---
	int total_errors = 0;
	for (int i = 0; i < total_requests; i++)
	{
		const char *sql = SQL_requests[i].c_str();
		rc = sqlite3_exec(db, sql, callback, 0, &zErrMsg);
		if (rc != SQLITE_OK)
			total_errors++;
	}

	//---
	string sql_request3 = "COMMIT;";
	rc = sqlite3_exec(db, sql_request3.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- check results
	if (total_errors == 0)
	{
		//--- stop timer and compute the elapsed time in milliseconds
		QueryPerformanceCounter(&time2);
		test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
		//printf("Test1: Elapsed time= %f ms.\n", elapsedTime);
	}
	//--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| Test 16: DROP TABLE                                                 |
//+---------------------------------------------------------------------+
//| SQLite is slower than the other databases when it comes to dropping |
//| tables. This probably is because when SQLite drops a table,         |
//| it has to go through and erase the records in the database file     |
//| that deal with that table.                                          |
//| MySQL and PostgreSQL, on the other hand, use separate files to      |
//| represent each table so they can drop a table simply by deleting    |
//| a file, which is much faster.                                       |
//| On the other hand, dropping tables is not a very common operation so|
//| if SQLite takes a little longer, that is not seen as a big problem. |
//+---------------------------------------------------------------------+
bool Test16(string database_name, string &test_name, double &test_elapsed_time)
{
	//--- DROP TABLE t1;
	//--- DROP TABLE t2;
	//--- DROP TABLE t3;
	//--- PostgreSQL:    0.135
	//--- MySQL : 0.015
	//--- SQLite 2.7.6 : 0.939
	//--- SQLite 2.7.6 (nosync) : 0.254
	sqlite3 *db;
	char *zErrMsg = 0;
	test_elapsed_time = 0;
	test_name = "Test 16: DROP TABLE";
	if (database_name == "")
	{
		printf("Error. Database file not specified.");
		return(false);
	}
	//--- 1. open database
	int rc = sqlite3_open(database_name.c_str(), &db);
	if (rc)
	{
		fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
		return(false);
	}
	if (EXECUTION_LOG_MODE)
		printf("1. Database opened successfully.");
	
	//---
	if (EXECUTION_LOG_MODE)
		printf("2. DROP TABLES");

	LARGE_INTEGER frequency, time1, time2;
	//--- get ticks per second and start timer
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&time1);
	//---
	string sql_request1 = "DROP TABLE t1;";
	rc = sqlite3_exec(db, sql_request1.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//---
	string sql_request2 = "DROP TABLE t2;";
	rc = sqlite3_exec(db, sql_request2.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//---
	string sql_request3 = "DROP TABLE t3;";
	rc = sqlite3_exec(db, sql_request3.c_str(), callback, 0, &zErrMsg);
	if (rc != SQLITE_OK)
	{
		fprintf(stderr, "SQL error: \n");
		sqlite3_free(zErrMsg);
		sqlite3_close(db);
		return(false);
	}
	//--- stop timer and compute the elapsed time in milliseconds
	QueryPerformanceCounter(&time2);
	test_elapsed_time = (time2.QuadPart - time1.QuadPart) * 1000.0 / frequency.QuadPart;
	 //--- close database
	sqlite3_free(zErrMsg);
	sqlite3_close(db);
	//---
	return(true);
}

//+------------------------------------------------------------------+
//| RunTest                                                          |
//+------------------------------------------------------------------+
bool RunTest(TTestFunction func, string database_name)
{
	string test_name = "";
	double test_time = 0;
	if (!func(database_name, test_name, test_time))
	{
		printf("%s failed.",test_name.c_str());
		return(false);
	}
	else
		printf("%s: finished. Elapsed time = %f ms.\n", test_name.c_str(), test_time);
	//---
	return(true);
}
//+------------------------------------------------------------------+
//| FileExist                                                        |
//+------------------------------------------------------------------+
bool FileExist(const char *fname)
{
	FILE *tmp;
	tmp = fopen(fname, "r");
	if (!tmp)
		return(false);
	fclose(tmp);
//---
	return(true);
}
//+------------------------------------------------------------------+
//| StartSQLLiteTests                                                |
//+------------------------------------------------------------------+
bool StartSQLLiteTests(string database_name)
{
	//--- check file name
	if (database_name == "")
	{
		printf("Error. Database file not specified.\n");
		return(false);
	}
	//--- check database file, if exist, try delete it
	if (FileExist(database_name.c_str()))
	{
		if (!DeleteFile(database_name.c_str()))
		{
			printf("Error. Cannot delete database file %s ", database_name.c_str());
			return(false);
		}
	}
	//--- set initial rand seed
	srand(1);
	//---
	printf("SQLite tests started.\n");
	//---
	if (!RunTest(Test1, database_name))
		return(false);
	if (!RunTest(Test2, database_name))
		return(false);
	if (!RunTest(Test3, database_name))
		return(false);
	if (!RunTest(Test4, database_name))
		return(false);
	if (!RunTest(Test5, database_name))
		return(false);
	if (!RunTest(Test6, database_name))
		return(false);
	if (!RunTest(Test7, database_name))
		return(false);
	if (!RunTest(Test8, database_name))
		return(false);
	if (!RunTest(Test9, database_name))
		return(false);
	if (!RunTest(Test10, database_name))
		return(false);
	if (!RunTest(Test11, database_name))
		return(false);
	if (!RunTest(Test12, database_name))
		return(false);
	if (!RunTest(Test13, database_name))
		return(false);
	if (!RunTest(Test14, database_name))
		return(false);
	if (!RunTest(Test15, database_name))
		return(false);
	if (!RunTest(Test16, database_name))
		return(false);
	//---
	return(true);
}
//+---------------------------------------------------------------------+
//| main                                                                |
//+---------------------------------------------------------------------+
int main()
{
	string database_name = "test_database.db";
	if (!StartSQLLiteTests(database_name))
	{
		printf("SQLite tests failed.");
		return(-1);
	}
	//---
	return 0;
}