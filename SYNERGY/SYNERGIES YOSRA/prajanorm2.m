function [W2,H2] = prajanorm2(A,W,H,option)
% ne distribut la variance que sur les poids

% de même que pour prajanorm et prajanor2 on lève l'indétermination de la solution en
% normalisant un des facteur, ici W, cad
% A = WH + e
% A-e = WH
% on transforme W en W_norm et on retrouve W en faisant
% H_norm =  W_norm^(-1)(A-e)


% option : 1 = normaliser par la norme de W (par défaut)
%          0 = normaliser par le max


if nargin <4
    option = 1;
end

 err = A-W*H;
 
 if option
    W2= W./repmat(sqrt(diag(W'*W))',size(W,1),1);
 else
    W2 = W./repmat(max(W),size(W,1),1);
 end
 H2 = pinv(W2)*(A-err);
    


end