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

namespace HandlingDeadlocksDemo
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void CallSQL()
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
        }

        public void HandleDeadlocks()
        {
            try
            {
                // place sql code here
                CallSQL();

                textBox1.Text = "Succeeded!";
            }
            catch (SqlException exception)
            {
                // exception is a deadlock
                if (exception.Number == 1205)
                {
                    textBox1.Text = "We're sorry, but your transaction could not be completed and will need to be resubmitted to the server.\r The specific error message was:\r\r" + exception.Message;
                }
                // exception is not a deadlock
                else
                {
                    throw;
                }
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            CallSQL();
            //HandleDeadlocks();
        }
    }
}
