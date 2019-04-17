import numpy as np
import matplotlib.pyplot as plt
import scipy.signal as sig


def get_scan_coords(PZT_data):
    deriv = np.zeros(len(PZT_data))
    deriv = [(PZT_data[i]-PZT_data[i-1]) for i in range(0, len(PZT_data))]
    flags = np.zeros(len(deriv))
    for i in range(0, len(deriv)):
        if (deriv[i]>0):
            flags[i]=True
        else: 
            flags[i]=False
    flags_bool=[bool(flags[i]) for i in range(0,len(flags))]

    sort_flags = [flags_bool[i]-flags_bool[i-1] for i in range(0,len(flags))]
    scan_starts = np.where([sort_flags[i]==1 for i in range(0,len(sort_flags))])
    scan_ends = np.where([sort_flags[i]==-1 for i in range(0,len(sort_flags))])
    scan_coords = np.zeros((len(scan_starts[0])-1,2))
    for i in range(0,len(scan_starts[0])-1):
        scan_coords[i] = [int(scan_starts[0][i]), int(scan_ends[0][i+1])]
    scan_coords.astype(int)
    return scan_coords

