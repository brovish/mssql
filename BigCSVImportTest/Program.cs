using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace BigCSVImportTest {
    class Program {
        private static SqlConnection myConnection;

        static void Main(string[] args) {
            //some things to consider. Disable indexes in an already existing table, changing the recovery-model to 'Simple'

            Console.WriteLine("Hello World!");
            //string[] lines = File.ReadAllLines("allCountries.txt");
            var lines = File.ReadLines("allCountries.txt");
            //foreach (string line in lines) {
            //    string[] col = line.Split(',');
            //    // process col[0], col[1], col[2]
            //}

            DataTable datatable = new DataTable();
            datatable.TableName = "allCountries";

            DateTime startTime = DateTime.Now;
            StreamReader streamreader = new StreamReader("allCountries.txt");
            char[] delimiter = new char[] { '\t' };
            //string[] columnheaders = streamreader.ReadLine().Split(delimiter);
            //foreach (string columnheader in columnheaders) {
            //    datatable.Columns.Add(columnheader); // I've added the column headers here.
            //}
            string[] columnheaders = { "GeoNameId",
                                        "Name",
                                        "AsciiName",
                                        "AlternateNames",
                                        "Latitude",
                                        "Longitude",
                                        "FeatureClass",
                                        "FeatureCode",
                                        "CountryCode",
                                        "Cc2",
                                        "Admin1Code",
                                        "Admin2Code",
                                        "Admin3Code",
                                        "Admin4Code",
                                        "Population",
                                        "Elevation",
                                        "Dem",
                                        "Timezone",
                                        "ModificationDate",
                                        };
            foreach (string columnheader in columnheaders) {
                datatable.Columns.Add(columnheader); // I've added the column headers here.
            }

            myConnection = new SqlConnection(@"Server=DATSUN-BM,1401;Database=BigCSVImportTest;User Id=sa; Password=passw0rd1!;");
            myConnection.Open();
            int count = 0;
            int millionsYouWantToRead = 0;
            while (streamreader.Peek() > 0) {
                if (millionsYouWantToRead == 6)
                    break;
                if (count < 2000000) {
                    DataRow datarow = datatable.NewRow();
                    datarow.ItemArray = streamreader.ReadLine().Split(delimiter);
                    datatable.Rows.Add(datarow);
                    count++;
                } else {
                    SqlBulkCopy bulkcopy = new SqlBulkCopy(myConnection);
                    bulkcopy.DestinationTableName = datatable.TableName;
                    try {
                        bulkcopy.WriteToServer(datatable);
                    } catch (Exception e) {
                        Console.WriteLine(e.Message);
                    }
                    count = 0;
                    datatable.Clear();
                    millionsYouWantToRead = millionsYouWantToRead + 2;
                }

            }

            DateTime endTime = DateTime.Now;
            double totalSeconds = (endTime - startTime).TotalSeconds;
            Console.WriteLine($"Total time in seconds for {millionsYouWantToRead} millon records is {totalSeconds}");
        }
    }
}
