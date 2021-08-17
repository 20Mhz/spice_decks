Uses FO4 chain of inverters to find equivalent capacitance on gates and diffusions, then uses the delay to estimate transistor's R
```
python3 calib.py
##########################################Optimization terminated successfully.
         Current function value: 1.184000
         Iterations: 21
         Function evaluations: 42
Found CperMicron=1.1632019042968769
Total Load=30.708530273437546
##############################Optimization terminated successfully.
         Current function value: 4.525130
         Iterations: 11
         Function evaluations: 30
Found CdPerMicron=0.95
Found in  453.978 seconds
CperMicron=1.1632f
CdperMicron=0.9500f
Delay 62.35ps
Delay Rise 61.24ps
Delay Fall 63.46ps
Ctot  30.71f
R     13.181 KOhm
RP     17.262 KOhm*u
RN     8.943 KOhm*u
Test: delay 6.3e+01ps 
```
![alt text](https://github.com/20Mhz/spice_decks/blob/sky130/calib/inv_delay.png)
