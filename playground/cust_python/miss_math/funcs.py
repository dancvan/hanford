import numpy as np

def num_after_point(x):
    s = str(x)
    if not '.' in s:
        return 0
    return len(s) - s.index('.') - 1

def step(t,x,y):
	t_array = t
	index = np.where(t_array==x)[0][0]
	u = np.zeros(len(t))
	u[index:] = y
	return u

