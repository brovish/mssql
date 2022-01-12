using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;

namespace BigCSVImportTest2
{
    class Program
    {
        private static SqlConnection myConnection;

        static void Main(string[] args)
        {
            //some things to consider. Disable indexes in an already existing table, changing the recovery-model to 'Simple'

            Console.WriteLine("Hello World!");
            //var lines = File.ReadLines(@"C:\Temp\netcdfs\csv\FACT 2010 - 2014.csv");

            DataTable datatable = new DataTable();
            datatable.TableName = "Fact1";

            DateTime startTime = DateTime.Now;
            StreamReader streamreader = new StreamReader(@"C:\Temp\netcdfs\csv\FACT 2010 - 2014.csv");
            char[] delimiter = new char[] { ',' };
            //string[] columnheaders = streamreader.ReadLine().Split(delimiter);
            //foreach (string columnheader in columnheaders) {
            //    datatable.Columns.Add(columnheader); // I've added the column headers here.
            //}
            string[] columnheaders = { "X1",
                                        "X1.1",
                                        "X"
                                        };
            //foreach (string columnheader in columnheaders)
            //{
            //    datatable.Columns.Add(columnheader); // I've added the column headers here.
            //}

            datatable.Columns.Add("X1", typeof(SqlInt32));
            datatable.Columns.Add("X1.1", typeof(SqlInt32));
            datatable.Columns.Add("X", typeof(SqlDecimal));


            myConnection = new SqlConnection(@"Server=DATSUN-BM\sql2019;Database=NetCDFWarehouse;Trusted_Connection=True;");
            myConnection.Open();
            int count = 0;
            int millionsYouWantToRead = 0;
            while (streamreader.Peek() > 0)
            {
                //if (millionsYouWantToRead == 8)
                //    break;
                if (count < 2000000)
                {
                    DataRow datarow = datatable.NewRow();
                    string[] colVals = streamreader.ReadLine().Split(delimiter);

                    List<object> modColVals = new List<object>();
                    modColVals.Add(int.Parse(colVals[0]));
                    modColVals.Add(int.Parse(colVals[1]));

                    decimal temp;
                    decimal? numericValue = decimal.TryParse(colVals[2], out temp) ? temp : (decimal?)null;
                    modColVals.Add(numericValue);


                    datarow.ItemArray = modColVals.ToArray();
                    datatable.Rows.Add(datarow);
                    count++;
                }
                else
                {
                    SqlBulkCopy bulkcopy = new SqlBulkCopy(myConnection);
                    bulkcopy.DestinationTableName = datatable.TableName;
                    try
                    {
                        bulkcopy.WriteToServer(datatable);
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.Message);
                    }
                    count = 0;
                    datatable.Clear();
                    millionsYouWantToRead = millionsYouWantToRead + 2;

                    using (SqlCommand command = new SqlCommand("CHECKPOINT", myConnection))
                        command.ExecuteNonQuery();
                }

            }

            DateTime endTime = DateTime.Now;
            double totalSeconds = (endTime - startTime).TotalSeconds;
            Console.WriteLine($"Total time in seconds for {millionsYouWantToRead} millon records is {totalSeconds}");
        }
    }
}
