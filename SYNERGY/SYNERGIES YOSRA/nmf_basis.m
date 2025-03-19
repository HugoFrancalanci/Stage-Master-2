function [W_final,H_final] = nmf_basis(A,n,H_basis,varargin)
% nmf_BASIS
% permet de chercher W et H an connaisssant déjà une partie de la base
% cet algorithme utilise l'update de lee et seung (2001) pour une partie
% uniquement de la base
    
    
    % INITIALISATION:

    nbre_iter = 10;
    max_iter = 1E6;% outner loop
    [nl nc] = size(A);
    seuil = 1E-6;

    INIT_W = 0;
    INIT_H = 0;

    % VERIFICATIONS ET OPTIONS
        if nargin ==0
            error('Aucun argument à l''entrée de la fonction ''nmf_basis'' !');
        end
        if (rem(length(varargin),2)==1)
          error('Il doit manquer une option à l''entrée de la fonction ''nmf_basis''');
        else
            for i=1:2:(length(varargin)-1)
                switch lower (varargin{i})
                    case 'max_iter'
                        max_iter = varargin{i+1};
                    case 'nbre_iter'
                        nbre_iter = varargin{i+1};
                    case 'seuil'
                        seuil = varargin{i+1};
                    case 'initialw'
                        INIT_W = 1;
                        W = varargin{i+1};
                    case 'initialh'
                        INIT_H = 1;
                        H = varargin{i+1};
                end
            end
        end


    norm_temp = 1E8;
    for k = 1:nbre_iter
        % initialisation des matrices
         lr = size(H_basis,1);
         H = [H_basis;rand(n-lr,nc)];
         W = lee_seung_W(A,H);

         % boucle de minimisation du cout
         temp = norm(A-W*H,'fro');  
         for i = 1:max_iter
             %modified update
             bloc = (W'*A)./(W'*W*H +1E-8);
             H(lr+1:end,:) = H(lr+1:end,:).*bloc(lr+1:end,:);
             W = W.*(A*H')./(W*(H*H')+1E-8);
             if abs(temp-norm(A-W*H,'fro'))/temp<seuil
                 break;
             end
             temp = norm(A-W*H,'fro');
         end
         % ne garder que le meilleur des k essais...
         if norm(A-W*H,'fro')<norm_temp
             norm_temp = norm(A-W*H,'fro');
             W_final = W;
             H_final = H;
         end
    end
  % normalisation de la solution
  [W_final,H_final] = prajanorm(A,W_final,H_final);
    
   function [W2,H2] = prajanorm(A_,W_,H_)
   % Projection sur des axes normalisés 
   % cette normalisation de la solution n'a pas d'effet sur la variance
       err = A_-W_*H_; 
       H2= H_./repmat(sqrt(diag(H_*H_')),1,size(H_,2));
       W2 = (A_-err)*pinv(H2);
   end
 
end% end of function