function [H_final] = lee_seung_H(A,n,W,varargin)
    % LEE_SEUNG_H
    % version de lee_seung.m qui n'update que H
    
    
% ===========================
%   Valeurs par défaut
    max_iter = 1E6;
    nbre_iter = 10;
    initialH  = [];
    

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
                case 'initialh'
                    initialH = varargin{i+1};
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
        if isempty(initialH)
            H = rand(n,nc);  % débute avec des matrices aléatoires
        else
            H = initialH;
        end
        temp = norm(A-W*H,'fro');
            
        % ----------------------
        % routine principale
        % ----------------------
        for i =1:max_iter
          H = H.*(W'*A)./(W'*W*H+1E-8);% on update uniquement H
          if abs(temp-norm(A-W*H,'fro'))/temp<1E-6
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
    %[W_final,H_final] = prajanorm(A,W_final,H_final);
    [W_final,H_final] = ranger(A,W_final,H_final);
end