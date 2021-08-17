* Calibration for Skywater 130nm
* Author: Ronald Valenzuela
* Description:
*   Obtain values of Cg, Cdn and Cdp for
* hand calculation
*
* Results 10/31/2020
* Delay 57.61ps
* Delay Rise 61.24ps
* Delay Fall 53.97ps
* Ctot  30.745f // This is input cap of the 16 inverters
* CperMicron = 1.1642 f/um
* CdiffperMicron = 0.384 f/um
* R     2.231 KOhm
* RP     3.162 KOhm*u
* RN     1.393 KOhm*u

.lib '/Users/ronaldv/Projects/repositories/skywater-pdk/libraries/sky130_fd_pr/latest/models/sky130.lib.spice' tt_MOSFET

.param supply=1.8

* Params 
.param trs='0.1n'
.inc './capValues.inc'
*.param WN_DIFF=224.86u
*.param inputCap = 'CperMicron*16*(1+0.65)*1u'
* This is the input capacitance of 16 inverters
.param Ctot = 30.745f
.param SD_CONT='0.3u'
* Removing 1u because models are scaled to micron
*.param WN_DIFF = 'Ctot/CdPerMicron*1u'
*.param WN_DIFF = 'Ctot/CdPerMicron/16'
.param WN_DIFF = 5 

*.param WN_DIFF = '223u'

* Subcircuits
.SUBCKT invx1 A Y vdd gnd 
* SET A,P 0 to account only for gate cap
*Xpup Y A vdd vdd sky130_fd_pr__pfet_01v8 m=1 L=0.6u W=6u AS=0 PS=0 AD=0 PD=0
Xpup Y A vdd vdd sky130_fd_pr__pfet_01v8 m=1 L=0.15 W=1 AS=0 PS=0 AD=0 PD=0
*Xpdn Y A gnd gnd sky130_fd_pr__nfet_01v8 m=1 L=0.6u W=3u AS=0 PS=0 AD=0 PD=0
Xpdn Y A gnd gnd sky130_fd_pr__nfet_01v8 m=1 L=0.15 W=0.65 AS=0 PS=0 AD=0 PD=0
.ENDS

* Netlist 
Vvdd  vdd gnd 'supply' 
Vinput A1 gnd PWL 0 0 0.1n 0 '0.1n+trs' 'supply' 0.6n 'supply' '1n+trs'  0 dc='supply'
** reference chain
x1 A1 Y1 vdd gnd invx1 m=1
x2 Y1 Y2 vdd gnd invx1 m=4
x3 Y2 Y3 vdd gnd invx1 m=16
x4 Y3 Y4 vdd gnd invx1 m=64
** Gate Cap 
x5 A1 Y1_CG vdd gnd invx1 m=1
x6 Y1_CG Y2_CG vdd gnd invx1 m=4
CG Y2_CG gnd 'CperMicron*16*(1+0.65)'
** Diff Cap
x7 A1 Y1_CD vdd gnd invx1 m=1
x8 Y1_CD Y2_CD vdd gnd invx1 m=4
xpdn  Y2_CD gnd gnd gnd sky130_fd_pr__nfet_01v8 m=16 L=0.15 W='WN_DIFF' AS='SD_CONT*WN_DIFF' PS='WN_DIFF+2*SD_CONT' AD='SD_CONT*WN_DIFF' PD='WN_DIFF+2*SD_CONT'
*xpdn  Y2_CD gnd gnd gnd sky130_fd_pr__nfet_01v8 m=16 L=0.15 W='WN_DIFF' 

* Analysis
.tran 1p 2n 
.probe v(Y1) v(Y2) v(Y1_CG) v(Y2_CG) v(Y1_CD) v(Y2_CD)
.option post brief accurate

.end
