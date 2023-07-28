import numpy as np
import matplotlib . pyplot as plt
import math


###############################################

P0 = 101325
gamma = 1.4
R = 287
L = 4
h = 0.001
rho_0 = 1.225

##############################################

T0 = [500, 700, 900, 1100]
m = [-50, -100, -150, -200]
p0 = 2000
dpdx_0 = 0
X = np.arange(0, 4+h, h)

##############################################


def omega(T, n):
    c = math.sqrt(gamma*R*T)
    f = ((2*n-1)*c)/(4*L)
    o = 2*np.pi*f
    return o

##############################################


def f(x, y, z):
    return z


def g(x, y, z, m, T, o):
    return -(m/T)*z - (o**2/(gamma*R*T))*y


def rk4(x, T, m, o, p, dpdx):
    rho = rho_0*300/(T)
    k1 = h * f(x, p, dpdx)
    l1 = h * g(x, p, dpdx, m, T, o)
    k2 = h * f(x + 0.5 * h, p + 0.5 * k1, dpdx+0.5*l1)
    l2 = h * g(x + 0.5 * h, p + 0.5 * k1, dpdx+0.5*l1, m, T, o)
    k3 = h * f(x + 0.5 * h, p + 0.5 * k2, dpdx+0.5*l2)
    l3 = h * g(x + 0.5 * h, p + 0.5 * k2, dpdx+0.5*l2, m, T, o)
    k4 = h * f(x + h, p + k3, dpdx+l3)
    l4 = h * g(x + h, p + k3, dpdx+l3, m, T, o)
    p = p+(k1+2*k2+2*k3+k4)/6
    dpdx = dpdx+(l1+2*l2+2*l3+l4)/6
    u = dpdx/(o*rho)
    return p, dpdx, u

###############################################


def main(n):
    p = []
    u = []
    o = []
    for i in range(4):
        for j in range(len(X)):
            min_p = 10
            T = T0[i]+m[i]*j*h
            o1 = omega(T, n)
            temp_p = []
            temp_dpdx = []
            temp_u = []
            for k in range(len(X)):
                if (k == 0):
                    p1, dpdx1, u1 = rk4(
                        k*h, T0[i]+m[i]*k*h, m[i], o1, p0, dpdx_0)
                else:
                    p1, dpdx1, u1 = rk4(
                        k*h, T0[i]+m[i]*k*h, m[i], o1, temp_p[-1], temp_dpdx[-1])
                temp_p.append(p1)
                temp_dpdx.append(dpdx1)
                temp_u.append(u1)
            if (np.abs(temp_p[-1]) < min_p):
                ret_p = temp_p
                ret_u = temp_u
                ret_o = o1/(2*np.pi)
                min_p = temp_p[-1]
        p.append(ret_p)
        u.append(ret_u)
        o.append(ret_o)
    return p, u, o


###############################################

p, u, o3 = main(3)
p = np.abs(p)
u = np.abs(u)
P1 = p[0]
P2 = p[1]
P3 = p[2]
P4 = p[3]
U1 = u[0]
U2 = u[1]
U3 = u[2]
U4 = u[3]


plt.plot(X, P1, color='blue', label='500')
plt.plot(X, P2, color='red', label='700')
plt.plot(X, P3, color='green', label='900')
plt.plot(X, P4, color='magenta', label='1100')
plt.xlabel("Distance (m)")
plt.ylabel("Pressure (Pa)")
plt.grid()
plt.legend()
plt.show()

plt.plot(X, U1, color='blue', label='500')
plt.plot(X, U2, color='red', label='700')
plt.plot(X, U3, color='green', label='900')
plt.plot(X, U4, color='magenta', label='1100')
plt.xlabel("Distance (m)")
plt.ylabel("Velocity (m/s)")
plt.grid()
plt.legend()
plt.show()

fig, ax1 = plt.subplots()
ax1.set_xlabel('Distance (m)')
ax1.set_ylabel('Pressure', color='red')
ax1.plot(X, P2, label='Pressure', color='red')
plt.legend()
ax1.tick_params(axis='y', labelcolor='red')
ax2 = ax1.twinx()
ax2.set_ylabel('Velocity (m/s)', color='blue')
ax2.plot(X, U2, label='Velocity', color='blue')
ax2.tick_params(axis='y', labelcolor='blue')
plt.legend()
plt.grid()
fig.tight_layout()
plt.show()

###############################################

a1, b1, o1 = main(1)
a2, b2, o2 = main(2)
print(o1)
print(o2)
print(o3)
