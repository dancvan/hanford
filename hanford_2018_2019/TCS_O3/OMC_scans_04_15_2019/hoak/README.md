This project contains a collection of scripts to analyze mode scan data from the OMC.

analyzeModeScan.py is the main script, which calls the following:

--> get_PZT_sweeps - scans data from OMC-PZT2_MON_DC_OUT and finds the times when the PZT was ramping

--> fit_OMC_scan   - fits modes to single PZT sweep, returns mode indices, heights, voltage to frequency fit, etc
                     makes some assumptions about peak structure, i.e. 45MHz sidebands

--> calc_modescan  - calculates various interesting parameters using the modescan output
    	             mode matching for carrier & sidebands, alignment, contrast defect



analyzeModeScan expects an input data file of three columns: time, pzt, dcpd_sum.

The script grab_data.py can be run from a control room computer to generate a text file with this format.




A version of these scripts to analyze a large number of cavity sweeps is kept on the H1 cluster:

/home/dhoak/public_html/modescan

https://ldas-jobs.ligo-wa.caltech.edu/~dhoak/modescan/

On the cluster there is also a script to perform the beacon demodulation for a DARM excitation, following Koji's 
work in alog LHO:17782.