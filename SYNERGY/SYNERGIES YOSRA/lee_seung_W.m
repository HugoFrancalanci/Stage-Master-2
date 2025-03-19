function [W_final] = lee_seung_W(A,H,varargin)
    % LEE_SEUNG :version de lee_seung.m qui n'update que W
    
    
% ===========================
%   Valeurs par défaut
    max_iter    = 1E6;
    nbre_iter   = 3;
    initialW    = [];
    seuil       = 1E-6;

%   ===========================
%     Vérifications à l'entrée de la fonction 
%     et lecture des options
%   ===========================
    
    if nargin ==0
        error('Aucun argument à l''entrée de la fonction ''lee_seung'' !');
    end
    if (rem(length(varargin),2)==1)
      error('Il doit manquer une option à l''entrée de la fonction ''lee_seung''');
    else
        for i=1:2:(length(varargin)-1)
            switch lower (varargin{i})
                case 'max_iter'
                    max_iter = varargin{i+1};
                case 'nbre_iter'
                    nbre_iter = varargin{i+1};
                case 'initialw'
                    initialW = varargin{i+1};
            end
        end
    end

 
%   =========================================
    norm_temp = 1E8;
    echec = 0;
    for k = 1:nbre_iter
        % ----------------------
        % initialisation
        % ----------------------
        [nl,nc] = size(A);
        n = size(H,1);
        if isempty(initialW)
            Wr = rand(nl,n);
            W = (H'\A')';
            W = W.*(W>0) + Wr.*(W<=0);
        else
            W = initialW;
        end
        temp = norm(A-W*H,'fro');
            
        % ----------------------
        % routine principale
        % ----------------------
        for i =1:max_iter
          %W = W.*(A*H')./(W*H*H');
          W = W.*(A*H')./(W*H*H'+1E-8);
          if abs(temp-norm(A-W*H,'fro'))/temp<seuil
             break;
          end
          temp = norm(A-W*H,'fro');
        end
        if i==max_iter
            echec = echec+1;
        end
        if norm(A-W*H,'fro')<norm_temp
            norm_temp = norm(A-W*H,'fro');
            W_final = W;
            H_final = H;
        end
    end
    if echec==nbre_iter
        warning('lee_seung_W : échec de l''optimisation pour le seuil fixé');
    end
    try
        [W_final] = prajanorm(A,W_final,H_final);
    catch e
        disp(e.mesage);
    end
end