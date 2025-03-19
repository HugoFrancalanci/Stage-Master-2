function [h w perm] = permuter_synergies(h,href,w,wref)
% procedure pour permuter les synergies
if nargin <4
    wref = [];
    if nargin <3
        w = [];
    end
end
if isempty(wref)
    perm = permutation_matrice(h',href');
else
    perm = permutation_matrice(h',href',w,wref);
end
h = perm'*h;
if ~isempty(w)
    w = w*perm;
end