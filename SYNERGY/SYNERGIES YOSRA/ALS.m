function [W_final,H_final] = ALS(A,n,varargin)
    % Alterating Least Square : 
    % fonction de factorisation matricielle.
    %
    % MODELE
    %   A = W*H
    % OPTION
    %   'nbre_iter' : nombre d'itérations défaut = 15
    %   'max_iter'  : maximum d'itération pour un cycle de 
    %   'mixed'     : true = mixed algorithm cad vecteurs +- mais
    %                 activations non negative
    
% ===========================
%   Valeurs par défaut
    max_iter = 50;
    nbre_iter = 5;
    MIX = 0;
    seuil = 1E-6;
    

%   ===========================
%     Vérifications à l'entrée de la fonction 
%     et lecture des options
%   ===========================
    
    if nargin ==0
        error('Aucun argument à l''entrée de la fonction ''ALS'' !');
    end
    if (rem(length(varargin),2)==1)
      error('Il doit manquer une option à l''entrée de la fonction ''ALS''');
    else
        for i=1:2:(length(varargin)-1)
            switch lower (varargin{i})
                case 'max_iter'
                    max_iter = varargin{i+1};
                case 'nbre_iter'
                    nbre_iter = varargin{i+1};
                case 'mixed'
                    MIX = 1;
            end
        end
    end

 
%   =========================================
    norm_temp = 1E8;
    for k = 1:nbre_iter
        % ----------------------
        % initialisation
        % ----------------------
        [nl,nc] = size(A);
        W = rand(nl,n);H = rand(n,nc);  % débute avec des matrices aléatoires
        temp = norm(A-W*H,'fro');
        % ----------------------
        % routine principale
        % ----------------------
        W = rand(size(A,1),n);
        for i = 1:max_iter
            H = W\A;
            if MIX
            else
                H = H.*(H>=0);
            end
            W = (H'\A')';
            W = W.*(W>0);
            if abs(temp-norm(A-W*H,'fro'))/temp<seuil
             break;
            end
            temp = norm(A-W*H,'fro');
        end
        if norm(A-W*H,'fro')<norm_temp
            norm_temp = norm(A-W*H,'fro');
            W_final = W;
            H_final = H;
        end
    end
    [W_final,H_final] = prajanorm(A,W_final,H_final);
end