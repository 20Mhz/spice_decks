import os 
import time
import timeit
import ngspyce
import numpy as np
import scipy.stats as scs 
from scipy.stats import norm
from matplotlib import pyplot as plt
import matplotlib.mlab as mlab

# Make seed consistent through spinit file
with open('spinit','w') as f:
    f.write('set rndseed=1\n')

os.environ["SPICE_SCRIPTS"] = "./" 

# Time it!
start = timeit.default_timer()

# Setup scale/unit
scale = 1e3
units = "mA"

# Run Monte Carlo sims
mc_runs=300
id = np.empty(mc_runs)
for i in range(0,mc_runs):
    ngspyce.source('mc.sp')
    ngspyce.operating_point()
    id[i]=ngspyce.vector('@m.xm1.m1[id]')*scale

# Time it!
stop = timeit.default_timer()
print('MC Simulation took %d samples in %.3f seconds' % (mc_runs, stop-start))

# Get stats
(mu, sigma) = norm.fit(id)
sigma_p100 = sigma/mu*100
print("Vector size: %d" % id.size)
print("Median: %f %s" % (mu, units)) 
print("Standard deviation: %f %s (%.2f%%)" % (sigma, units, sigma_p100))

n, bins, patches = plt.hist(id, 30, density=True, facecolor='green', alpha=0.75)

y = scs.norm.pdf(bins, mu, sigma)
l = plt.plot(bins, y, 'r--', linewidth=2)

# Plot
plt.xlabel('Current (%s)' % (units))
plt.ylabel('Probability')
plt.title('Histogram of Id [$\mu_0$ = %.3f %s, $\sigma$ = %.6f %s (%.2f%%) ]' % (mu, units,sigma, units,sigma_p100))
plt.grid(True)
plt.savefig('mc.png')
plt.show()
