sqlio -kW -t16 -s10 -o8 -fsequential -b8 -BH -LS -Fparam.txt 

sqlio -kW -t8 -s60 -o8 -frandom -b8 -BH -LS D:\testfile.dat > SQLIO_Results.txt
sqlio -kW -t8 -s60 -o8 -frandom -b32 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kW -t8 -s60 -o8 -frandom -b64 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kW -t8 -s60 -o8 -frandom -b128 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kW -t8 -s60 -o8 -frandom -b256 -BH -LS D:\testfile.dat >> SQLIO_Results.txt

sqlio -kR -t8 -s60 -o8 -frandom -b8 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kR -t8 -s60 -o8 -frandom -b32 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kR -t8 -s60 -o8 -frandom -b64 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kR -t8 -s60 -o8 -frandom -b128 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kR -t8 -s60 -o8 -frandom -b256 -BH -LS D:\testfile.dat >> SQLIO_Results.txt

sqlio -kW -t8 -s60 -o8 -fsequential -b8 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kW -t8 -s60 -o8 -fsequential -b32 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kW -t8 -s60 -o8 -fsequential -b64 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kW -t8 -s60 -o8 -fsequential -b128 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kW -t8 -s60 -o8 -fsequential -b256 -BH -LS D:\testfile.dat >> SQLIO_Results.txt

sqlio -kR -t8 -s60 -o8 -fsequential -b8 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kR -t8 -s60 -o8 -fsequential -b32 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kR -t8 -s60 -o8 -fsequential -b64 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kR -t8 -s60 -o8 -fsequential -b128 -BH -LS D:\testfile.dat >> SQLIO_Results.txt
sqlio -kR -t8 -s60 -o8 -fsequential -b256 -BH -LS D:\testfile.dat >> SQLIO_Results.txt

