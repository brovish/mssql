using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;
using System.Data.SqlClient;

namespace RetryDeadlocksDemo
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        public void RetryDeadlocks()
        {
            int retries = 10;
            while (retries > 0)
            {
                try
                {
                    // place sql code here
                    using (SqlConnection conn = new SqlConnection("Server=.;Database=DeadlockDemo;Trusted_Connection=True;"))
                    {
                        using (SqlCommand cmd = conn.CreateCommand())
                        {
                            cmd.CommandText = "EXEC [BookmarkLookupSelect] 4;";
                            cmd.CommandType = CommandType.Text;
                            conn.Open();
                            cmd.ExecuteScalar();
                            conn.Close();
                        }
                    }
                    textBox1.Text = "Succeeded!";
                    retries = 0;
                }
                catch (SqlException exception)
                {
                    // exception is a deadlock
                    if (exception.Number == 1205)
                    {
                        retries--; 
                        textBox1.Text = exception.Message;
                        textBox1.Text += string.Format("\r Retrying transaction.  Retries remaining = {0}", retries);
                        // Delay processing to allow retry.
                        Thread.Sleep(100);
                    }
                    // exception is not a deadlock
                    else
                    {
                        throw;
                    }
                }
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            RetryDeadlocks();
        }


    }
}
