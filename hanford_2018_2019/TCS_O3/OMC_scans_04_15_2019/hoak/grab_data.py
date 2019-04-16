#! /usr/bin/python
from numpy import *
import matplotlib
matplotlib.use("Agg")
from matplotlib.font_manager import FontProperties
import pylab
from scipy import signal
from scipy.optimize import curve_fit
import cdsutils
import time, commands


def decimate(x, q, n=None, ftype='iir', axis=-1):
    if not isinstance(q, int):
        raise TypeError("q must be an integer")
    if n is None:
        if ftype == 'fir':
            n = 30
        else:
            n = 3
    if ftype == 'fir':
        b = signal.firwin(n + 1, 1. / q, window='hamming')
        a = 1.
    else:
        b, a = signal.cheby1(n, 0.05, 0.8 / q)

    y = signal.filtfilt(b, a, x)
    sl = [slice(None)] * y.ndim
    sl[axis] = slice(None, None, q)
    return y[sl]




start_gps = 1125133458
duration = 310

Fs = 512

y = cdsutils.getdata(['H1:OMC-PZT2_MON_DC_OUT_DQ','H1:OMC-DCPD_SUM_OUT_DQ'],duration,start_gps)

fs_pzt = y[0].sample_rate
fs_dcpd =  y[1].sample_rate

q_pzt = int(fs_pzt/Fs)
q_dcpd = int(fs_dcpd/Fs)

pzt = decimate(y[0].data,q_pzt)
dcpd_sum = decimate(y[1].data,q_dcpd)

t1 = arange(0,duration,1/512.)

output_data = zeros((len(dcpd_sum),3))

for i in range(len(dcpd_sum)):
    output_data[i,0] = t1[i]
    output_data[i,1] = pzt[i]
    output_data[i,2] = dcpd_sum[i]


savetxt('/ligo/www/www/exports/dhoak/PRMI_on_31Aug2015.txt',output_data,fmt='%.6f',delimiter='\t')


fignum=0

fignum=fignum+1
pylab.figure(fignum)

"""
pylab.subplot(2,1,1)
pylab.plot(t1,pzt,'r.',markersize=3)

pylab.grid(True, which='both', linestyle=':', alpha=0.4)

pylab.subplot(2,1,2)
pylab.semilogy(t1,dcpd_sum,'k.',markersize=3)
"""
pylab.semilogy(pzt,dcpd_sum,'k.',markersize=3)

pylab.grid(True, which='both', linestyle=':', alpha=0.4)

#pylab.ylabel('OMC DCPD Sum [mA]')
#pylab.xlabel('PZT2 Output [V]')

#pylab.xlim(80,100)
#pylab.ylim(0.1,1)

pylab.savefig('plots/sweep.png')

