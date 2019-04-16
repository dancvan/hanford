% function to determine the Gaussian q from a given R and W
% Taken from A. Brooks Mode Matching tool library
function overlap = GaussianQOverlap(q1, q2)
lambda = 1064E-9;

% q1
q1inv = 1./q1;
R1 = 1./real(q1inv);
Wsq1 = -lambda./(  imag(q1inv) * pi );
W1 = sqrt(Wsq1);
% q2
q2inv = 1./q2;
R2 = 1./real(q2inv);
Wsq2 = -lambda./(  imag(q2inv) * pi );
W2 = sqrt(Wsq2);

% get into matrix form;
R1 = R1(:)';
R2 = R2(:)';
W1 = W1(:)';
W2 = W2(:)';

% get the overlap
dr = mean(W2)/400;
rmax = 8000*dr;
r = dr/2:dr:rmax;
r = r(:);


% bug = fields should be -1 not -2 in exponent [Aidan 8-Mar-2018]
% E1 = exp(-2*(r.^2)*(1./W1.^2)) .* exp(1i*2*pi/lambda*(r.^2)*(1./R1));
% E2 = exp(-2*(r.^2)*(1./W2.^2)) .* exp(1i*2*pi/lambda*(r.^2)*(1./R2));
E1 = exp(-(r.^2)*(1./W1.^2)) .* exp(1i*2*pi/lambda*(r.^2)*(1./R1)/2);
E2 = exp(-(r.^2)*(1./W2.^2)) .* exp(1i*2*pi/lambda*(r.^2)*(1./R2)/2);


r2 = r*ones(1, numel(R1));
overlap = real(sum(r2.*E1.*conj(E2)).*sum(r2.*E2.*conj(E1))./( ...
    sum(r2.*E1.*conj(E1)).*sum(r2.*E2.*conj(E2))));


