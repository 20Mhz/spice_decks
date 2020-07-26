* Calibration for AMIS 0.5um
* Author: Ronald Valenzuela
* Description:
*   Obtain values of Cg, Cdn and Cdp for
* hand calculation
*
* Results 3/21/2014
* Cg= 1.487 fF/um (L=0.6u)
* wn_diff = 224.8632u

.lib  '/Users/ronaldv/Dropbox/MOSIS/ON_PDK/hspice/current/ami_c5n.T22Y.lib'  TT
.param supply=3.3

* Params 
.param trs='0.1n'
.inc './capValues.inc'
*.param WN_DIFF=224.86u
.param inputCap = 'CperMicron*16*(6+3)*1u'
.param Ctot = 223.08f
.param SD_CONT='1.5u'
.param WN_DIFF = 'Ctot/CdPerMicron*1u'
*.param WN_DIFF = '223u'

* Subcircuits
.SUBCKT invx1 A Y vdd gnd 
* SET A,P 0 to account only for gate cap
mpup Y A vdd vdd ami06p m=1 L=0.6u W=6u AS=0 PS=0 AD=0 PD=0
mpdn Y A gnd gnd ami06n m=1 L=0.6u W=3u AS=0 PS=0 AD=0 PD=0
.ENDS

* Netlist 
Vvdd  vdd gnd 'supply' 
Vinput A1 gnd PWL 0 0 0.1n 0 '0.1n+trs' 'supply' 1n 'supply' '1n+trs'  0 dc='supply'
** reference chain
x1 A1 Y1 vdd gnd invx1 m=1
x2 Y1 Y2 vdd gnd invx1 m=4
x3 Y2 Y3 vdd gnd invx1 m=16
x4 Y3 Y4 vdd gnd invx1 m=64
** Gate Cap 
x5 A1 Y1_CG vdd gnd invx1 m=1
x6 Y1_CG Y2_CG vdd gnd invx1 m=4
CG Y2_CG gnd 'CperMicron*16*(6+3)'
** Diff Cap
x7 A1 Y1_CD vdd gnd invx1 m=1
x8 Y1_CD Y2_CD vdd gnd invx1 m=4
mpdn  Y2_CD gnd gnd gnd ami06n m=1 L=0.6u W='WN_DIFF' AS='SD_CONT*WN_DIFF' PS='WN_DIFF+2*SD_CONT' AD='SD_CONT*WN_DIFF' PD='WN_DIFF+2*SD_CONT'

* Analysis
.tran 1p 2n 
.probe v(Y1) v(Y2) v(Y1_CG) v(Y2_CG) v(Y1_CD) v(Y2_CD)
.option post brief accurate

.end
