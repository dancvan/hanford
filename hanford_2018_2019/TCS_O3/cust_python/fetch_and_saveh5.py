import numpy as np
import nds2
import h5py

def fetch_and_saveh5(fname, chans, t_start, t_end):
    '''This function takes: in the name you wish to label the .h5 file, a string array of channel names you want to be in the file, and a start and end gps time.This function is intended to be run on LHO CDS. This can be modified if you change what server you wish to connect to but acquiring data may be at a glacial pace. '''
    fname = 'CO2_step_response'
    conn = nds2.connection('h1nds1',8088)
    t_start = 1238858067
    t_end = 1238870468
    data_h5 = conn.fetch(t_start, t_end, chans_update)
    h5f = h5py.File('{}.h5'.format(fname), 'w')
    for i in range(0,len(data_h5)):
        h5f.create_dataset(data_h5[i].name,data=data_h5[i].data)
        h5f[data_h5[i].name].attrs['sample_rate']=data_h5[i].sample_rate
    h5f.close()
