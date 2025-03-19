function [CI R CIsub Rsub] = randomized_r(vectors,N,p)
% Determine l'interval de confiance (CI) pour des vecteurs aléatoires
% R = Les N valeurs aléatoires crées
% si "vectors" est un scalaire il indique la dimension du vecteur souhaité
% sinon vecteurs sont les vecteurs à partirs desquels une procédure de
% bootstrapping sera effectuée (i.e., les H à la sortie de lee_seung par
% exemple)
SYN = false;   
if nargin< 3
    p = 0.95;
    if nargin <2
        N = 5000;
    end
end
if max(size(vectors))==1
    dimension = vectors;
    BOOTSTRAP = false;
elseif max(size(vectors))==2
    dimension = vectors(2);
    nbsyn     = vectors(1);
    BOOTSTRAP = false;
else
    dimension = size(vectors,2);
    nbsyn     = size(vectors,1);
    BOOTSTRAP = true;
end
vectors =  vectors(:);
n_       = length(vectors);
if dimension ==1
    error('impossible de calculer les corrélations');
end
if nbsyn>1
    SYN = true;
end

R    = [];
Rsub = [];
if BOOTSTRAP
    for i = 1:N
        % pour les vecteurs individuels
        ind = ceil(rand(n_,1)*(n_-1) + 1);% resampling
        ind = ind(1:dimension);
        u = vectors(ind,1);
        ind = ceil(rand(n_,1)*(n_-1) + 1);% resampling
        ind = ind(1:dimension);
        v = vectors(ind,1);
        R(i) = corr(u,v); 
        % pour les synergies
        if SYN
            ind = ceil(rand(n_,1)*(n_-1) + 1);% resampling
            u   = reshape(vectors(ind),nbsyn,dimension);
            ind = ceil(rand(n_,1)*(n_-1) + 1);% resampling
            v   = reshape(vectors(ind),nbsyn,dimension);
            Rsub(i) = subspace(u',v'); 
        end           
    end
else
    for i = 1:N
        u = rand(dimension,1);
        v = rand(dimension,1);
        R(i) = corr(u,v);
        
        if SYN
            u = rand(nbsyn,dimension);
            v = rand(nbsyn,dimension);
            Rsub(i) = cos(subspace(u',v'));
        end
    end
end
% confidence interval   
[ll ul] = confint(R,p);
CI = [ll ul]; 
if SYN
    [ll ul] = confint(Rsub,p);
    CIsub = [ll ul]; 
else
    CIsub = [];
end







