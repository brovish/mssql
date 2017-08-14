using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

[Serializable]
[SqlUserDefinedAggregate(
   Format.Native,
   IsInvariantToDuplicates = false,
   IsInvariantToNulls = true,
   IsInvariantToOrder = true,
   IsNullIfEmpty = false)]
public struct Skew
{
    private double rx;		// running sum of current values (x)
    private double rx2;		// running sum of squared current values (x^2)
    private double r2x;		// running sum of doubled current values (2x)
    private double rx3;		// running sum of current values raised to power 3 (x^3)
    private double r3x2;	// running sum of tripled squared current values (3x^2)
    private double r3x;		// running sum of tripled current values (3x)
    private Int64 rn;		// running count of rows

    public void Init()
    {
        rx = 0;
        rx2 = 0;
        r2x = 0;
        rx3 = 0;
        r3x2 = 0;
        r3x = 0;
        rn = 0;
    }

    public void Accumulate(SqlDouble inpVal)
    {
        if (inpVal.IsNull)
        {
            return;
        }
        rx = rx + inpVal.Value;
        rx2 = rx2 + Math.Pow(inpVal.Value, 2);
        r2x = r2x + 2 * inpVal.Value;
        rx3 = rx3 + Math.Pow(inpVal.Value, 3);
        r3x2 = r3x2 + 3 * Math.Pow(inpVal.Value, 2);
        r3x = r3x + 3 * inpVal.Value;
        rn = rn + 1;
    }

    public void Merge(Skew Group)
    {
        this.rx = this.rx + Group.rx;
        this.rx2 = this.rx2 + Group.rx2;
        this.r2x = this.r2x + Group.r2x;
        this.rx3 = this.rx3 + Group.rx3;
        this.r3x2 = this.r3x2 + Group.r3x2;
        this.r3x = this.r3x + Group.r3x;
        this.rn = this.rn + Group.rn;
    }

    public SqlDouble Terminate()
    {
        double myAvg = (rx / rn);
        double myStDev = Math.Pow((rx2 - r2x * myAvg + rn * Math.Pow(myAvg, 2)) / (rn - 1), 1d / 2d);
        double mySkew = (rx3 - r3x2 * myAvg + r3x * Math.Pow(myAvg, 2) - rn * Math.Pow(myAvg, 3)) /
                        Math.Pow(myStDev, 3) * rn / (rn - 1) / (rn - 2);
        return (SqlDouble)mySkew;
    }

}


[Serializable]
[SqlUserDefinedAggregate(
   Format.Native,
   IsInvariantToDuplicates = false,
   IsInvariantToNulls = true,
   IsInvariantToOrder = true,
   IsNullIfEmpty = false)]
public struct Kurt
{
    private double rx;		// running sum of current values (x)
    private double rx2;		// running sum of squared current values (x^2)
    private double r2x;		// running sum of doubled current values (2x)
    private double rx4;		// running sum of current values raised to power 4 (x^4)
    private double r4x3;	// running sum of quadrupled current values raised to power 3 (4x^3)
    private double r6x2;	// running sum of squared current values multiplied by 6 (6x^2)
    private double r4x;		// running sum of quadrupled current values (4x)
    private Int64 rn;		// running count of rows

    public void Init()
    {
        rx = 0;
        rx2 = 0;
        r2x = 0;
        rx4 = 0;
        r4x3 = 0;
        r6x2 = 0;
        r4x = 0;
        rn = 0;
    }

    public void Accumulate(SqlDouble inpVal)
    {
        if (inpVal.IsNull)
        {
            return;
        }
        rx = rx + inpVal.Value;
        rx2 = rx2 + Math.Pow(inpVal.Value, 2);
        r2x = r2x + 2 * inpVal.Value;
        rx4 = rx4 + Math.Pow(inpVal.Value, 4);
        r4x3 = r4x3 + 4 * Math.Pow(inpVal.Value, 3);
        r6x2 = r6x2 + 6 * Math.Pow(inpVal.Value, 2);
        r4x = r4x + 4 * inpVal.Value;
        rn = rn + 1;
    }

    public void Merge(Kurt Group)
    {
        this.rx = this.rx + Group.rx;
        this.rx2 = this.rx2 + Group.rx2;
        this.r2x = this.r2x + Group.r2x;
        this.rx4 = this.rx4 + Group.rx4;
        this.r4x3 = this.r4x3 + Group.r4x3;
        this.r6x2 = this.r6x2 + Group.r6x2;
        this.r4x = this.r4x + Group.r4x;
        this.rn = this.rn + Group.rn;
    }

    public SqlDouble Terminate()
    {
        double myAvg = (rx / rn);
        double myStDev = Math.Pow((rx2 - r2x * myAvg + rn * Math.Pow(myAvg, 2)) / (rn - 1), 1d / 2d);
        double myKurt = (rx4 - r4x3 * myAvg + r6x2 * Math.Pow(myAvg, 2) - r4x * Math.Pow(myAvg, 3) + rn * Math.Pow(myAvg, 4)) /
                        Math.Pow(myStDev, 4) * rn * (rn + 1) / (rn - 1) / (rn - 2) / (rn - 3) -
                        3 * Math.Pow((rn - 1), 2) / (rn - 2) / (rn - 3);
        return (SqlDouble)myKurt;
    }

}
