import numpy as np
import numpy.linalg as LA
 
def rt_gouy(RTM):
	[w,v] = LA.eig(RTM)
	gp = np.arccos(np.real(w[0]))
	q1 = v[0,0]/v[1,0]
	q2 = v[0,1]/v[1,1]
	if np.imag(q1) >= 0:
		gp = 2*np.pi - gp
	return gp

def cmirror(ROC):
    return np.matrix([[1.0, 0.0],[-2.0/ROC, 1.0]])

def space(d):
    return np.matrix([[1.0, d],[0.0, 1.0]])

def refrac(n1,n2):
    return np.matrix([[1.0,0.0],[0.0, n1/n2]])

def lens(f):
    return np.matrix([[1.0, 0.0],[-1.0/f, 1.0]])

def thick_lens(R1, R2, n1, n2, t):
    last = np.matrix([[1,0],[(n2-n1)/(R2*n2), n2/n1]])
    thickness = np.matrix([[1.0,0.0],[t, n1/n2]])
    first = np.matrix([[1,0],[(n1-n2)/(R1*n2), n1/n2]])
    return last*thickness*first
