import os 
import time
import timeit
import numpy as np
from enum import Enum
from scipy.optimize import minimize
from scipy.optimize import Bounds
import scipy.stats as scs 
from scipy.stats import norm
from matplotlib import pyplot as plt
import matplotlib.mlab as mlab
import multiprocessing as mp
import sys

supply=1.8
class sim_type(Enum):
    GATECAP = 1
    DIFFCAP = 2
    INVR = 3
    INVF = 4
    INV = 5
    FULL_WAVE = 6
    FULL_WAVE_DEBUG = 7

def spice_invFO4(cap, mode=sim_type.GATECAP, tf=2):
    import ngspyce
    with open('./capValues.inc','w') as f:
        f.write(f'.param supply={float(supply)}\n')
        f.write(f'.param CperMicron={float(cap)}f\n')
        f.write(f'.param CdperMicron={float(cap)}f\n')
    ngspyce.source('calib.sp')
    r=ngspyce.cmd(f'tran 1p {tf}n')
    # Get Inverter Baseline Delays
    r=ngspyce.cmd(f'meas tran invR TRIG v(Y1)  VAL={supply*0.5} fall=1  TARG v(Y2) VAL={supply*0.5} rise=1 ')
    #print(r)
    invR=float(ngspyce.vector('invR')*scale)
    r=ngspyce.cmd(f'meas tran invF TRIG v(Y1)  VAL={supply*0.5} rise=1  TARG v(Y2) VAL={supply*0.5} fall=1 ')
    invF=float(ngspyce.vector('invF')*scale)
    if (mode == sim_type.GATECAP):
        # Get Inverter delays loaded by Cgate 
        r=ngspyce.cmd(f'meas tran capR TRIG v(Y1_CG)  VAL={supply*0.5} fall=1  TARG v(Y2_CG) VAL={supply*0.5} rise=1 ')
        capR=float(ngspyce.vector('capR')*scale)
        r=ngspyce.cmd(f'meas tran capF TRIG v(Y1_CG)  VAL={supply*0.5} rise=1  TARG v(Y2_CG) VAL={supply*0.5} fall=1 ')
        capF=float(ngspyce.vector('capF')*scale)
        #return abs(invR-capR) + abs(invF-capF)
        a =  abs(invR-capR)
        b = abs(invF-capF)
        #print(f'invR: {invR}')
        #print(f'invF: {invF}')
        #print(f'invR/invF {invR/invF}')
        #print(f'a: {a}')
        #print(f'b: {b}')
        print(f'#',end='', flush=True)
        sys.stdout.flush()
        return a + b + abs(a-b)
    elif (mode == sim_type.DIFFCAP):
        # Get Inverter delays loaded by Diff Cap
        r=ngspyce.cmd(f'meas tran diffR TRIG v(Y1_CD)  VAL={supply*0.5} fall=1  TARG v(Y2_CD) VAL={supply*0.5} rise=1 ')
        diffR=float(ngspyce.vector('diffR')*scale)
        r=ngspyce.cmd(f'meas tran diffF TRIG v(Y1_CD)  VAL={supply*0.5} rise=1  TARG v(Y2_CD) VAL={supply*0.5} fall=1 ')
        diffF=float(ngspyce.vector('diffF')*scale)
        #print(f'invR: {invR}')
        #print(f'invF: {invF}')
        #print(f'diffR: {diffR}')
        #print(f'diffF: {diffF}')
        print(f'#',end='', flush=True)
        sys.stdout.flush()
        return abs(invR-diffR) + abs(invF-diffF)
    elif (mode==sim_type.INVR):
        return invR 
    elif (mode==sim_type.INVF):
        return invF 
    elif (mode==sim_type.INV):
        return (invR+invF)/2 
    elif (mode==sim_type.FULL_WAVE):
        return  ngspyce.vector('v(Y1)')*scale,ngspyce.vector('v(Y2)')*scale
    elif (mode==sim_type.FULL_WAVE_DEBUG):
        return  ngspyce.vector('v(Y1)')*scale,ngspyce.vector('v(Y2)')*scale,ngspyce.vector('v(Y2_CG)')*scale,ngspyce.vector('v(Y2_CD)')*scale,

def spice_invFO4_optGCAP(x):
    return spice_invFO4(x, sim_type.GATECAP)

def spice_invFO4_optDCAP(x):
    return spice_invFO4(x, sim_type.DIFFCAP)

os.environ["SPICE_SCRIPTS"] = "./" 

# Time it!
start = timeit.default_timer()

scale = 1e12
units = "ps"

# Optimize to get CperMicron
opt=minimize(spice_invFO4_optGCAP, 0.5, method='nelder-mead', options={'xatol': 1e-4, 'disp': True})
CperMicron=float(opt.x)
print(f'Found CperMicron={CperMicron}')
#CperMicron=1.1632
Ctot=CperMicron*16*(1+0.65)
print(f'Total Load={Ctot}')
opt=minimize(spice_invFO4_optDCAP, 1, method='nelder-mead', options={'xatol': 1e-4, 'disp': True})
CdPerMicron=float(opt.x)
print(f'Found CdPerMicron={CdPerMicron}')
#CdPerMicron=0.384
CdPerMicron=0.95

# Timte it!
stop = timeit.default_timer()

print('Found in  %.3f seconds' % (stop-start))
print(f'CperMicron={CperMicron:.4f}f')
print(f'CdperMicron={CdPerMicron:.4f}f')

# Get R from Delay = ln(2)*RC
delay_mean=spice_invFO4(CperMicron, mode=sim_type.INV)
delay_fall=spice_invFO4(CperMicron, mode=sim_type.INVF)
delay_rise=spice_invFO4(CperMicron, mode=sim_type.INVR)
k=np.log(2)
Rmean=delay_mean*1e-12*4.5/(k*Ctot*1e-15)
# Compute R Coefficient so R = RP/W, with W in um
RP=delay_rise*1e-12*6/(k*Ctot*1e-15)
RN=delay_fall*1e-12*3/(k*Ctot*1e-15)
print(f'Delay {delay_mean:.2f}ps')
print(f'Delay Rise {delay_rise:.2f}ps')
print(f'Delay Fall {delay_fall:.2f}ps')
print(f'Ctot  {Ctot:.2f}f')
print(f'R     {Rmean*1e-3:.3f} KOhm')
print(f'RP     {RP*1e-3:.3f} KOhm*u')
print(f'RN     {RN*1e-3:.3f} KOhm*u')
print(f'Test: delay {0.7*(Rmean/4.5)*(Ctot*1e-15)*1e+12:3.2}ps')
# Full Wave
#y1,y2=spice_invFO4(CperMicron, mode=sim_type.FULL_WAVE, tf=1.2)
y1,y2,y2_CG,y2_CD=spice_invFO4(CperMicron, mode=sim_type.FULL_WAVE_DEBUG, tf=1.2)

# Plot
plt.plot(y1)
plt.plot(y2)
plt.plot(y2_CG)
plt.plot(y2_CD)
plt.xlabel('Time (%s)' % (units))
plt.ylabel('Voltage (V)')
plt.title('Delay')
plt.grid(True)
plt.savefig('inv_delay.png')
plt.show()
