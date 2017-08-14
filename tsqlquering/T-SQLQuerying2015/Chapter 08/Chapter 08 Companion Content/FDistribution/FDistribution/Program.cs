using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms.DataVisualization.Charting;

class FDistribution
{
    static void Main(string[] args)
    {
        // Test input arguments
        if (args.Length != 3)
        {
            Console.WriteLine("Please use three arguments: double FValue, int DF1, int DF2.");
            //Console.ReadLine();
            return;
        }

        // Try to convert the input arguments to numbers. 
        // FValue
        double FValue;
        bool test = double.TryParse(args[0], System.Globalization.NumberStyles.Float,
            System.Globalization.CultureInfo.InvariantCulture.NumberFormat, out FValue);
        if (test == false)
        {
            Console.WriteLine("First argument must be double (nnn.n).");
            return;
        }

        // DF1
        int DF1;
        test = int.TryParse(args[1], out DF1);
        if (test == false)
        {
            Console.WriteLine("Second argument must be int.");
            return;
        }

        // DF2
        int DF2;
        test = int.TryParse(args[2], out DF2);
        if (test == false)
        {
            Console.WriteLine("Third argument must be int.");
            return;
        }

        // Calculate the cumulative F distribution function probability
        Chart c = new Chart();
        double result = c.DataManipulator.Statistics.FDistribution(FValue, DF1, DF2);
        Console.WriteLine("Input parameters: " +
            FValue.ToString(System.Globalization.CultureInfo.InvariantCulture.NumberFormat)
            + " " + DF1.ToString() + " " + DF2.ToString());
        Console.WriteLine("Cumulative F distribution function probability: " +
            result.ToString("P"));
    }
}
