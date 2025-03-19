function [W2,H2] = prajanorm(A,W,H)
% Projection sur des axes normalis�s 

% de m�me que pour prajanorm on l�ve l'ind�termination de la solution en
% normalisant H mais � droite cad : 
% A = WH + e
% A-e = WH
% on transforme H en H_norm et on retrouve W en faisant
% W_norm =  (A-e)H_norm^(-1)


 err = A-W*H;
 
 H2= H./repmat(sqrt(diag(H*H')),1,size(H,2));
 W2 = (A-err)*pinv(H2);
    


end
