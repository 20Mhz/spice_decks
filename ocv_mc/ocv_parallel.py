import os 
import time
import timeit
import numpy as np
import scipy.stats as scs 
from scipy.stats import norm
from matplotlib import pyplot as plt
import matplotlib.mlab as mlab
import multiprocessing as mp

def spice_command(i):
    # Random seed uses pid so need its own instance
    import ngspyce
    ngspyce.source('ocv.sp')
    ngspyce.cmd('tran 1p 2n')
    ngspyce.cmd('meas tran invR TRIG v(Y1)  VAL=2.5 fall=1  TARG v(Y2) VAL=2.5 rise=1 ')
    return np.float(ngspyce.vector('invR')*scale)

# Make sure to empty spinit so seed comes from pid 
with open('spinit','w') as f:
    f.write('\n')

os.environ["SPICE_SCRIPTS"] = "./" 

# Time it!
start = timeit.default_timer()

scale = 1e12
units = "ps"

# Monte Carlo sims
mc_runs=100
inv_delay = np.empty(mc_runs)

pool = mp.Pool(mc_runs)
inv_delay =np.array(pool.map(spice_command,range(1,mc_runs+1)))

# Time it!
stop = timeit.default_timer()
print('MC Simulation took %d samples in %.3f seconds' % (mc_runs, stop-start))
print(inv_delay)

# Get stats
(mu, sigma) = norm.fit(inv_delay)
sigma_p100 = sigma/mu*100
print("Vector size: %d" % inv_delay.size)
print("Median: %f %s" % (mu, units)) 
print("Standard deviation: %f %s (%.2f%%)" % (sigma, units, sigma_p100))

n, bins, patches = plt.hist(inv_delay, 30, density=True, facecolor='green', alpha=0.75)

y = scs.norm.pdf(bins, mu, sigma)
l = plt.plot(bins, y, 'r--', linewidth=2)

# Plot
plt.xlabel('Current (%s)' % (units))
plt.ylabel('Probability')
plt.title('Histogram of Delay [$\mu_0$ = %.3f %s, $\sigma$ = %.3f %s (%.2f%%) ]' % (mu, units,sigma, units, sigma_p100))
plt.grid(True)
plt.savefig('ocv.png')
plt.show()
