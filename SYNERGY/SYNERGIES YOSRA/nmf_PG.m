function [W,H] = nmf_PG(A,n,varargin)
    % Projected gradient  : 
    % fonction de factorisation matricielle.
    % voir: Zdunek, R. and A. Cichocki (2008). "Fast Nonnegative Matrix
    % Factorization Algorithms Using Projected Gradient Approaches for 
    % Large-Scale Problems." Computational Intelligence and Neuroscience 
    % Article ID 939567, 13 pages.
    % utilise l'algorithme nmf_gpsr_bb.m
    
    % MODELE
    %   A = W*H
    % OPTION
    %   'nbre_iter' : nombre d'itérations défaut = 10000
    %   'max_iter'  : maximum d'itération pour un cycle de calcul
    %
    % auteur: NA Turpin (2011)
    % modifié : novembre 2012
    
% ===========================
%   Valeurs par défaut
    max_iter = 75;
    nbre_iter = 10000;
    initialiserW = 1;
    initialiserH = 1;
    seuil = 1E-5;

%   ===========================
%     Vérifications à l'entrée de la fonction 
%     et lecture des options
%   ===========================
    
    if nargin ==0
        error('Aucun argument à l''entrée de la fonction ''nmf_PG'' !');
    end
    if (rem(length(varargin),2)==1)
      error('Il doit manquer une option à l''entrée de la fonction ''nmf_PG''');
    else
        for i=1:2:(length(varargin)-1)
            switch lower (varargin{i})
                case 'max_iter'
                    max_iter = varargin{i+1};
                case 'nbre_iter'
                    nbre_iter = varargin{i+1};
                case 'initialw'
                    W= varargin{i+1};
                    initialiserW = 0;
                case 'initialh'
                    H = varargin{i+1};
                    initialiserH = 0;
            end
        end
    end

 %   =========================================
        % ----------------------
        % initialisation
        % ----------------------
        [nl,nc] = size(A);
        if ~initialiserW && ~initialiserH
            try
                % initialisation par les solutions de l'ACP (stabilise la
                % solution)
                [W H] = composante_principale(A,'synergie',n,'positif','true');
                W(W<0)=0.2*max(abs(W(:)));
                H(H<0)=0.2*max(abs(H(:)));
                %fprintf('nmf_PG: initialisation par ACP\n');
            catch
                W = rand(nl,n);
                H = rand(n,nc);
            end
        end
         if initialiserW
            W = initialW;
            W = max(W,0);
        end
        if initialiserH
            H = initialH;
            H = max(H,0);
        end
            
        cost = norm(A-W*H,'fro');
    for k = 1:nbre_iter
        % ----------------------
        % routine principale
        % ----------------------
        H = nmf_gpsr_bb(W,A,H,max_iter);
        W = nmf_gpsr_bb(H',A',W',max_iter)';
        cost2 = norm(A-W*H,'fro');
        if abs(cost2-cost)/cost <seuil
            break
        end
       cost = cost2;
    end
    if k == nbre_iter
        warning('nmf_PG : échec de l''optimisation pour le seuil fixé');
    end
    
     % normalisation de la solution
    [W,H] = prajanorm(A,W,H);
    
    
    
    function [W2,H2] = prajanorm(A,W,H)
    % Projection sur des axes normalisés 
    % cette normalisation de la solution n'a pas d'effet sur la variance
        err = A-W*H;
 
        H2= H./repmat(sqrt(diag(H*H')),1,size(H,2));
        W2 = (A-err)*pinv(H2);
    end
end