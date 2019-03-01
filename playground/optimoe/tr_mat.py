import numpy as np
import numpy.linalg as LA

class tr_mat:
    
	def rt_gouy(RTM):
		[w,v] = LA.eig(RTM)
		gp = np.arccos(np.real(w[0]))
		q1 = v[0,0]/v[1,0]
		q2 = v[0,1]/v[1,1]
		if np.imag(q1) >= 0:
			gp = 2*np.pi - gp
		return gp