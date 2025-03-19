function [h p] = israndom(r1,R)
% détermine si la valeur de r est aléatoire (h = 0) ou non (h = 1)(Pearson's r)
% les valeurs de la population de r-value de référence peut être fournie ou
% pas - il est conseillé de la fournir pour plus de rapidité (randomized_r)

FischerZ    = @(x) 0.5*log((1+x)./(1-x));% transformée en Z
n = length(r1);
if nargin < 2
    [CI R] = randomized_r(n);
end
r1  = FischerZ(r1);
N   = length(R);


% compute statistics
% -------------------
% distribution
[ll ul x f]      = confint(FischerZ(R));
SD               = f.*(1-f)/N;% variance
Z                = (f - 0.5)./sqrt(SD);% test statistique

ind              = Z>0;
p_values         = NaN(1,N);
p_values(ind)    = 2*(1-normcdf(Z(ind),0,sqrt(N)));
p_values(~ind)   = 2*normcdf(Z(~ind),0,sqrt(N));

p_values(p_values>1) = 1;
[xxx ind]   = min(abs(x-r1));

if isempty(ind)
    p = 1;
else
    p = p_values(ind);
end
if p<0.05
    h = 1;
else
    h  = 0;
end
