* MC simulation / single transistor
* Author: Ronald Valenzuela
* Description:
* Date: 3/30/2017

.lib  '/Users/ronaldv/Dropbox/MOSIS/ON_PDK/hspice/current/ami_c5n.T22Y.lib'  TT_mc
.param supply=5.0

.param Ldiff='1.2u'
.param W='3u'
.param Lmin='0.6u'

Xm1 vdd vdd gnd gnd ami06n_mc m=1 L='Lmin' W='W' AS='Ldiff*W' PS='2*Ldiff+2*W' AD='Ldiff*W' PD='2*Ldiff+2*W'
Xm2 vdd vdd gnd gnd ami06p_mc m=1 L='Lmin' W='W' AS='Ldiff*W' PS='2*Ldiff+2*W' AD='Ldiff*W' PD='2*Ldiff+2*W'

Vvdd  vdd gnd 'supply' 

*.op
.control
	op
	echo cs_ami06N_u0			 $&cs_ami06N_u0	
	echo cs_ami06N_vth0			 $&cs_ami06N_vth0	
	echo cs_xi			 $&cs_xi
	echo cs_ami06N_Avt        	 $&cs_ami06N_Avt	
	echo cs_ami06N_beta       	 $&cs_ami06N_beta
	echo cs_ami06N_u0_mc      	 $&cs_ami06N_u0_mc
	echo cs_ami06N_vth0_mc    	 $&cs_ami06N_vth0_mc	
*	echo cs_ami06P_u0			 $&cs_ami06P_u0	
*	echo cs_ami06P_vth0			 $&cs_ami06P_vth0	
*	echo cs_xi			 $&cs_xi
*	echo cs_ami06P_Avt        	 $&cs_ami06P_Avt	
*	echo cs_ami06P_beta       	 $&cs_ami06P_beta
*	echo cs_ami06P_u0_mc      	 $&cs_ami06P_u0_mc
*	echo cs_ami06P_vth0_mc    	 $&cs_ami06P_vth0_mc	
*	*let mc_runs = 100
*	*let run = 1
*	*let vector = unitvec(mc_runs)
*	*dowhile run <= mc_runs
*    *	destroy $dt                   $ delete the tran i plot
*	*	set curplot = new
*	*	set scratch = $curplot
*	*	op
*	*	let m1_id = @m.xm1.m1[id]
*	*	print m1_id
*	*	set run = "$&run"
*	*	set dt = $curplot
*	*	setplot $scratch
*	*	*let id[$run] = m1id
*	*	let vector[$run] =  ${dt}.m1_id 
*	*	let run = run + 1
*	*end
*	*plot vector xlimit 1 100 xindices 1 100 vs run
.endc
*Vinput A1 gnd PWL 0 0 0.1n 0 '0.1n+trs' 'supply' 1n 'supply' '1n+trs'  0

