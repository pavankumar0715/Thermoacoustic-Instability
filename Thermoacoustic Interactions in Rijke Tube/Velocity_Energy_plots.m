clear all;
close all;
clc;
Bnn=zeros(20,10);
bnl=zeros(20,10);
X0=zeros(20,1);
X0(1,1)=0.20;u0=0.5;
r=1.4;c0=399.6;
dw=0.0011;Ktbar=397;
K=0.0004;xf=0.29;
tau=0.45;w=@(J) J*pi;
Beta=@(J) sqrt(3)/(r*u0/c0)*K*J*pi*sin(J*pi*xf);
A1=zeros(20,20);
A2=zeros(20,20);
A3=zeros(20,20);
Bm=zeros(20,1);
Um=zeros(20,1);
Pm=zeros(20,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

J=1;j=2;
for i=1:2:20
    Um(i,1)=cos(J*pi*xf);
    A1(i,j)=-1;
    j=j+2;J=J+1;
end
J=1;j=1;
for i=2:2:20
    Pm(i,1)=cos(J*pi*xf);
    Bm(i,1)=-Beta(J);
    A1(i,j)=(w(J)^2);
    j=j+2;J=J+1;
end
c1=0.1;c2=0.06;
zeta=@(J) (c1*(w(J)/pi)+c2*sqrt(pi/w(J)))/(2*pi);
j=2;J=1;
for i=2:2:20
    A1(i,j)=2*J*pi*zeta(J);
    J=J+1;j=j+2;
end
A2=Bm*Um';
A3=Bm*Pm';
Bnn=A1-A2+tau.*A3;
u=[];u(1)=0;
i=2;Xi=X0;
T=[];T(1)=0;
for t=linspace(0.01,50,200)
    T(i)=t;
    X=rk4(tau,Bnn,T(i),T(i-1),0.001,Xi,A2,A3,Um,Pm);
    sumu=0;sume=0;sump=0;
    Xi=X;
    n1(i)=X(1,1);
    n2(i)=X(3,1);
    J=1;M=2;m=1;
    for n=1:1:10
        sumu=sumu+X(m)*cos(n*pi*xf);
        sume=sume+(X(m)^2+(X(M)^2/(J*pi)^2));
        sump=sump+(-1.4*u0/(c0*J*pi)*X(M)*sin(J*pi*xf));
        J=J+1;M=M+2;m=m+2;
    end
    ea(i)=(0.5*sump^2+0.5*(1.4*u0*sumu/c0)^2)/(1.4*(u0)/c0)^2;
    u(i)=sumu;
    p(i)=sump;
    e(i)=sume/(1.4*(u0)/c0)^2;
    i=i+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);
plot(T,u,LineWidth=1);
xlabel('T(s)',FontSize=15);
ylabel("U' (m/s)",FontSize=15);
grid on;
figure(2);
plot(T,n1,LineWidth=1);
xlabel('T(s)',FontSize=15);
ylabel('N_1',FontSize=15);
grid on;
figure(3);
plot(T,n2,LineWidth=1);
xlabel('T(s)',FontSize=15);
ylabel('N_2',FontSize=15);
grid on;
figure(4);
plot(T,e);
xlabel('T(s)',FontSize=15);
ylabel('Acoustic Energy',FontSize=15);
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Xs=rk4(tau,Bnn,T,to,h,x0,A2,A3,Um,Pm)
if((T-tau)<0)
    Udtua= @(X) Um'*X-tau.*Pm'*X;
    f=@(t,X) -Bnn*X;
end
if((T-tau)>=0)
    Udtua=@(X) Um'*X-tau.*Pm'*X;
    Bnl=@(X) 3/4.*Udtua(x0).*A2-3/4*tau.*Udtua(x0).*A3;
    f=@(t,X) -Bnn*X-Bnl(X)*X;
end
n=(T-to)/h;
for i=1:n
    k1=f(to,x0);
    k2=f(to+h/2,x0+0.5.*h.*k1);
    k3=f(to+h/2,x0+0.5.*h.*k2);
    k4=f(to+h,x0+h.*k3);
    k=(h/6).*(k1+2.*k2+2.*k3+k4);
    Xs=x0+k;
    x0=Xs;
    U=Udtua(Xs);
    to=to+h;
end
end
