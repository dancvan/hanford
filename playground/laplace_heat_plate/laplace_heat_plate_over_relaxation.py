#!/usr/bin/env python
import numpy as np
import matplotlib.pyplot as plt

#Set iteration number
maxIter = 200

#Set dimensions of square region of interest
lenX = lenY = 200
delta = 1

#numerical parameters
fopt = 2 - (2*np.pi)/float(lenX)

#BCs
Ttop = 100
Tbottom = 0
Tleft = 0
Tright = 70

# Initial guess of what the temperature of inside will be
Tguess = 30

#Set interpolation and colormap
colorinterp = 50
colormap = plt.cm.coolwarm

#Set meshgrid
X, Y = np.meshgrid(np.arange(0, lenX), np.arange(0, lenY))

T = np.empty((lenX, lenY))
T.fill(Tguess)

#Set BC
T[(lenY-1):, :] = Ttop
T[:1, :] = Tbottom
T[:, (lenX-1):] = Tright
T[:, :1] = Tleft

# Iteration
print("Please wait for a moment")
for iteration in range(0, maxIter):
	for i in range(1, lenX-1, delta):
		for j in range(1, lenY-1, delta):
			T[i,j] = (1-fopt) * T[i,j] + fopt*.25*(T[i+1][j] + T[i-1][j] + T[i][j+1]+ T[i][j-1])

print("Iteration finished")

#Set contour
plt.title("Contour of Temperature")
plt.contourf(X,Y,T, colorinterp, cmap=colormap)

#Set Colorbar
plt.colorbar()

#Show the result in the plot winow
plt.show()
print("")


