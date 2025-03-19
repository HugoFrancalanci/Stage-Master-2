function res = norm2(mat,dim)
% calcule la norme de chaque ligne (dim = 2), de chaque colonne (dim = 1)
% ou de chaque tube de la 3ieme dimension (dim=3)

if nargin <2
    dim = 1;
end
res = sqrt(sum(mat.^2,dim));

end
    