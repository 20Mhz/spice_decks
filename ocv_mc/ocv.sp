* Delay Monte Carlo Simulation 
* Author: Ronald Valenzuela
* Description:
*   Obtain values of Cg, Cdn and Cdp for
* hand calculation
*
* Results 3/21/2014
* Cg= 1.487 fF/um (L=0.6u)
* wn_diff = 224.8632u

.lib  '/Users/ronaldv/Dropbox/MOSIS/ON_PDK/hspice/current/ami_c5n.T22Y.lib'  TT_mc
.param supply=5

* Params 
.param trs='0.1n'
*.param CperMicron=optrange(1f,0.01f, 30f)
.param CperMicron=1.487f
*.param WN_DIFF=optrange(3u,1u, 1000u)
.param WN_DIFF=224.86u
*.meas inputCap param = 'CperMicron*16*(6+3)*1u'
*.meas CdPerMic param ='inputCap/WN_DIFF'

* Subcircuits
.SUBCKT invx1 A Y vdd gnd 
* SET A,P 0 to account only for gate cap
.param m='1'
.param Ldiff='1.2u'
.param W='3u'
.param Lmin='0.6u'
xpup Y A vdd vdd ami06p_mc m='m' L='Lmin' W='2*W' AS='Ldiff*W' PS='2*Ldiff+2*W' AD='Ldiff*W' PD='2*Ldiff+2*W'
xpdn Y A gnd gnd ami06n_mc m='m' L='Lmin' W='W' AS='Ldiff*W' PS='2*Ldiff+2*W' AD='Ldiff*W' PD='2*Ldiff+2*W'
.ENDS

* Netlist 
Vvdd  vdd gnd 'supply' 
Vinput A1 gnd PWL 0 0 0.1n 0 '0.1n+trs' 'supply' 1n 'supply' '1n+trs'  0 DC='0'
** reference chain
x1 A1 Y1 vdd gnd invx1 m=4
x2 Y1 Y2 vdd gnd invx1 m=16
x3 Y2 Y3 vdd gnd invx1 m=64
x4 Y3 Y4 vdd gnd invx1 m=256

* Analysis
.tran 1p 2n 
*.meas tran invR 
*+ TRIG v(Y1)  VAL='supply*0.5' fall=1
*+ TARG v(Y2) VAL='supply*0.5' rise=1
*.meas tran invF 
*+ TRIG v(Y1)  VAL='supply*0.5' rise=1
*+ TARG v(Y2) VAL='supply*0.5' fall=1
.probe v(Y1) v(Y2)
.print invR
.option post brief accurate

