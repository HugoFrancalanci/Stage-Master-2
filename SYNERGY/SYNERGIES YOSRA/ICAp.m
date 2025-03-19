function [W H] = ICAp(A,n)
% ICAp: factorization en composantes peu corr�l�es/ et peu �tendues sous
% conrainte de positivit�
% NOTE:
% Il s'agit d'une tentative de d�finition d'une fonction qui factorizerais 
% la matrice A en deux �l�ments de dimensions (W txn et H nxm ) en 
% utilisant l'optimisation d'une fonction globale (une somme de cost functions)
% ici la distance A-WH; la corr�lation entre les W(:,i), l'�tendue des
% W(:,i) [minimise aussi la corr�latinon entre eux]; un cout de negativit�
% (w>0 p�nalis�s) et enfin une contrainte de smoothness
% les r�sultats ne sont pas mauvais qualitativement bien que la contrainte 
% de smoothness ne soit pas efficace mais l'algorithme est long �
% converger. L'approximation donn�e par Lee_seung voir l'acp sont
% suffisante pour le degr� d'approximation/d'exactitude requis


% autheur: NA Turpin (2015)
[l m] = size(A);

[W H] = lee_seung(A,n);


%% OPTIMISATION

% SET THE OPTIONS
options = optimset('LargeScale','off');
options = optimset(options,'Display','off','GradObj','off');

q = [W(:);H(:)];

% OPTIMISATION
ff = @(p) myfun(p);
qopt = fminunc(ff,q,options);

W = reshape(qopt(1:l*n),l,n);
H = reshape(qopt(l*n+1:(l+m)*n),n,m);

err = A-W*H;
H= H./repmat(sqrt(diag(H*H')),1,size(H,2));
W = (A-err)*pinv(H);

%% objective function
    function cost  = myfun(q)
        W = reshape(q(1:l*n),l,n);
        H = reshape(q(l*n+1:(l+m)*n),n,m);
        cost1 = norm(A-W*H,'fro');% min distance
        cost2 = norm(W'*W-diag(diag(W'*W)),'fro');% min corr
        cost3 = sum(sum(bsxfun(@times,abs(W),(1:l)'.^2)/sum((1:l).^2)));% min �tendue
        cost4 = sum(sum(W(W<0).^2));% contrainte non negative
        cost5 = sum(max(abs(diff(W*H,3,1))));% contrainte de smoothness
        cost = cost1+cost2+cost3+cost4+cost5;
    end
end