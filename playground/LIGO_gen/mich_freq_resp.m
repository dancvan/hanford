cee = 299792458; 
OMEG = 2*pi*cee/(1064.0*10-9); 
L = 4000.0; 
nu = 1:.1:100000;
nat_nu = 2*pi.*nu;
h0 = 1; 

H = h0*2.0*L*OMEG.*exp((-1i*L*2.0*pi.*nu)/cee).*sin((L*2.0*pi*nu)/cee)./(cee*(L*2.0*pi*nu/cee));

loglog(nu, abs(real(H)))

xlim([1,1000000])