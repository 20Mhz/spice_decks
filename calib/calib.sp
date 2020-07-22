* Calibration for AMIS 0.5um
* Author: Ronald Valenzuela
* Description:
*   Obtain values of Cg, Cdn and Cdp for
* hand calculation
*
* Results 3/21/2014
* Cg= 1.487 fF/um (L=0.6u)
* wn_diff = 224.8632u

.lib  '/remote/cae1107/ronaldv/CD/ON.PDK/hspice/current/ami_c5n.T22Y.lib'  TT
.param supply=3.3

* Params 
.param trs='0.1n'
.param CperMicron=optrange(1f,0.01f, 30f)
*.param WN_DIFF=optrange(3u,1u, 1000u)
.param WN_DIFF=224.86u
.meas inputCap param = 'CperMicron*16*(6+3)*1u'
.meas CdPerMic param ='inputCap/WN_DIFF'

* Subcircuits
.SUBCKT invx1 A Y vdd gnd 
* SET A,P 0 to account only for gate cap
mpup Y A vdd vdd ami06p m=1 L=0.6u W=6u AS=0 PS=0 AD=0 PD=0
mpdn Y A gnd gnd ami06n m=1 L=0.6u W=3u AS=0 PS=0 AD=0 PD=0
.ENDS

* Netlist 
Vvdd  vdd gnd 'supply' 
Vinput A1 gnd PWL 0 0 0.1n 0 '0.1n+trs' 'supply' 1n 'supply' '1n+trs'  0
** reference chain
x1 A1 Y1 vdd gnd invx1 m=4
x2 Y1 Y2 vdd gnd invx1 m=16
x3 Y2 Y3 vdd gnd invx1 m=64
x4 Y3 Y4 vdd gnd invx1 m=256
** Gate Cap 
x5 A1 Y1_CG vdd gnd invx1 m=4
x6 Y1_CG Y2_CG vdd gnd invx1 m=16
CG Y2_CG gnd 'CperMicron*64*(6+3)'
** Diff Cap
x7 A1 Y1_CD vdd gnd invx1 m=1
x8 Y1_CD Y2_CD vdd gnd invx1 m=4
mpdn  Y2_CD gnd gnd gnd ami06n m=1 L=0.6u W='WN_DIFF' AS='1.5u*WN_DIFF' PS='WN_DIFF+2*1.5u' AD='1.5u*WN_DIFF' PD='WN_DIFF+2*1.5u'

* Analysis
*.tran 1p 2n 
.probe v(Y2)
.option post brief accurate

* Measurements 
.measure CperMic param = 'CperMicron'
** Delay = ln(2)*RC
** (tran_size*tran_count*delay)/ln(2)*gate_count*C
.measure RP param = '(6*16*invR)/(0.69315*64*(CperMic*9+3*CdPerMic))' 
.measure RN param = '(3*16*invF)/(0.69315*64*(CperMic*9+3*CdPerMic))' 

.meas tran invR 
+ TRIG v(Y1)  VAL='supply*0.5' fall=1
+ TARG v(Y2) VAL='supply*0.5' rise=1
.meas tran capR 
+ TRIG v(Y1_CG)  VAL='supply*0.5' fall=1
+ TARG v(Y2_CG) VAL='supply*0.5' rise=1
.meas tran diffR 
+ TRIG v(Y1_CD)  VAL='supply*0.5' fall=1
+ TARG v(Y2_CD) VAL='supply*0.5' rise=1

.meas tran invF 
+ TRIG v(Y1)  VAL='supply*0.5' rise=1
+ TARG v(Y2) VAL='supply*0.5' fall=1
.meas tran capF 
+ TRIG v(Y1_CG)  VAL='supply*0.5' rise=1
+ TARG v(Y2_CG) VAL='supply*0.5' fall=1
.meas tran diffF 
+ TRIG v(Y1_CD)  VAL='supply*0.5' rise=1
+ TARG v(Y2_CD) VAL='supply*0.5' fall=1

.meas errorR param='abs(invR- capR)' goal=1f
.meas errorF param='abs(invF- capF)' goal=1f

.meas ediff_r param='abs(invR- diffR)' goal=1f
.meas ediff_f param='abs(invF- diffF)' goal=1f


* Opt
.model optmod opt itropt=100
.tran 0.3ps 2ns SWEEP OPTIMIZE = optrange
+ RESULTS=errorR,errorF MODEL=optmod
.end
*.model optmod opt itropt=100
*.tran 0.3ps 2ns SWEEP OPTIMIZE = optrange
*+ RESULTS=ediff_r,ediff_f MODEL=optmod
*.end
