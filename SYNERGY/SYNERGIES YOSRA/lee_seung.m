function [W_final,H_final,cout] = lee_seung(A,n,varargin)
    % LEE_SEUNG : 
    % fonction de factorisation matricielle. Cette fonction effectue
    % plusieurs factorisations (nbre_iter) et garde celle dont l'erreur est
    % la plus faible.
    %
    % Lee, D. D. and H. S. Seung (2001).
    % "Algorithms for Non-negative Matrix Factorization." 
    % Advances In Neural Information Processing Systems: 556-562.
    %
    % MODELE
    %   A = W*H
    % OPTION
    %   'nbre_iter' : nombre d'itérations défaut = 15
    %   'max_iter'  : maximum d'itération pour un cycle de calcul
    %   'initial'   :  matrice initiale
    %   'methode'   : les updates rules selon les fonctions de cout déterminées,
    %   i.e., 
    %           'euclidian': see lee and seung 2001
    %           'divergence': ref = idem
    % auteur: NA Turpin (2017)
    
% ===========================
%   Valeurs par défaut
    max_iter    = 1E6;
    nbre_iter   = 10;
    initialW    = [];
    initialH    = [];
    methode     = 'euclidian';
    seuil       = 1E-6;% si le pourcentage de descente <seuil arret de l'algo
    RANDOM_INIT = false;
    ACP_INIT    = true;
    REGULAR     = true;

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
                case 'initialh'
                    initialH = varargin{i+1};
                case 'methode'
                    methode  =  varargin{i+1};
                case 'seuil'
                    seuil = varargin{i+1};
                case 'initial'
                    switch varargin{i+1}
                        case 'rand'
                            RANDOM_INIT = true;
                            ACP_INIT    = false;
                        case 'acp'
                            % default
                    end
                case 'regular'
                    REGULAR = varargin{i+1};
            end
        end
    end

 
%   =========================================
    norm_temp = 1E8;
    W_final = [];
    H_final  = [];
    if ACP_INIT
        % l'acp 'fixe' la solution
        nbre_iter = 1;
    end
    if isempty(initialW)
        % normalisation avant extraction (améliore la convergence)
        mm = max(A);
        A = bsxfun(@rdivide,A,mm);
    end
    
    for k = 1:nbre_iter
        % ----------------------
        % initialisation
        % ----------------------
        [nl,nc] = size(A);
        if RANDOM_INIT
            W = rand(nl,n);
            H = rand(n,nc);
        end
        if ACP_INIT
            % initialisation par les solutions de l'acp (prend en compte les
            % corrélations et normalise les solutions i.e., moins aléatoires)
            if n>1
                [W H] = ACP(A,n,'positif','true','type','corr');
            else
                W = mean(A,2);
                H = W\A;
            end
%             W= abs(W);
%             H=  abs(H);
            W(W<0)=0.2*max(abs(W(:)));
            H(H<0)=0.2*max(abs(H(:)));
        end
        if ~isempty(initialW)
            W = initialW;
            W = max(W,0);
%             H = W\A;
%             H = H.*(H>0) + rand(n,nc).*(H<=0); 
        end
        if ~isempty(initialH)
            H = initialH;
            H = max(H,0);
%             W = (H'\A')';
%             W = W.*(W>0) + rand(nl,n).*(W<=0);
        end
        switch methode
            case 'euclidian'
                 temp = norm(A-W*H,'fro');
            case 'divergence'
                 temp = sum(sum(A.*log(A./(W*H))-A+W*H));
        end
        if nargout>2
           cout(k).data(1) = temp;
        end
        % ----------------------
        % routine principale
        % ----------------------
        switch methode
            case 'euclidian'
                if REGULAR
                    for i =1:max_iter
                      W = W.*(A*H')./(W*(H*H')+1E-8);%W = W.*(A*H')./(W*H*H'+1E-8);
                      H = H.*(W'*A)./((W'*W)*H+1E-8);% H = H.*(W'*A)./(W'*W*H+1E-8);
                      if abs(temp-norm(A-W*H,'fro'))/temp<seuil
                         break;
                      end
                      temp = norm(A-W*H,'fro');
                      if nargout>2
                        cout(k).data(i) = temp;
                        %plot(cout(k).data);pause(0.01)
                        plot(W);pause(0.05)
                      end
                    end
                else% non regular version 
                    M = (1:size(W,1)).^2;
                    M = M/sum(M);
                    M = repmat(M(:),1,size(W,2));
                  for i =1:max_iter
                      W = W -(W*(H*H')-2*A*H'+(M*M')*W);
                      W = max(W,0);
                      H = 2*H.*(W'*A)./((W'*W)*H+1E-8);
                      if  abs(temp-( norm(A-W*H,'fro') + trace(M'*W))/temp)<1E-1
                         break;
                      end
                      temp = norm(A-W*H,'fro')+ trace(M'*W);
                      if nargout>2
                        cout(k).data(i) = temp;
                        %plot(cout(k).data);pause(0.01)
                        plot(W);pause(0.05)
                      end
                  end
               end
            case 'divergence'
                for i = 1:max_iter
                  H =  H.*(W'*(A./(W*H)))./repmat(sum(W)',1,nc);
                  W = W.*((A./(W*H))*H')./repmat(sum(H,2)',nl,1);
                  W = W./repmat(sum(W),nl,1);
                  if abs(temp-sum(sum(A.*log(A./(W*H))-A+W*H)))/temp<seuil
                     break;
                  end
                  temp = sum(sum(A.*log(A./(W*H))-A+W*H));
                  if nargout>2
                    cout(k).data(i+1) = temp;
                  end
                end
        end
        if i==max_iter
            warning('arret de l''algorithme alors que le seuil n''était pas atteint!');
        end
        % ne garder que le meilleur des k essais...
        switch methode
            case 'euclidian'
                if norm(A-W*H,'fro')<norm_temp
                    norm_temp = norm(A-W*H,'fro');
                    W_final = W;
                    H_final = H;
                end
            case 'divergence'
                if sum(sum(A.*log(A./(W*H))-A+W*H))<norm_temp
                    norm_temp = sum(sum(A.*log(A./(W*H))-A+W*H));
                    W_final = W;
                    H_final = H;
                end
        end   
    end
    
    % restore the original scaling
    if isempty(initialW)
        H_final = bsxfun(@times,H_final,mm);
        A       = bsxfun(@times,A,mm);
    end
    % normalization of the solution
    try
        [W_final,H_final] = prajanorm(A,W_final,H_final);
    catch e
        fprintf('warning; variance not redistributed properly\n');
        disp(e.message)
    end
    
    
    
    function [W2,H2] = prajanorm(A,W,H)
    % Projection sur des axes normalisés 
    % cette normalisation de la solution n'a pas d'effet sur la variance
        err = A-W*H;
 
        H2= H./repmat(sqrt(diag(H*H')),1,size(H,2));
        W2 = (A-err)*pinv(H2);
    end

%     % fonction pour le version alternative de lee seung
%      peu efficace
%     function [mu] = optimal_gradient(A,W,H)
%         mu= 1;n = 1;
%         for ii = 1:50
%             if f(A,W -(mu+n)*(W*(H*H') + (M*M')*W),H) < f(A,W -mu*(W*(H*H') + (M*M')*W),H)
%                 mu = mu +n;
%             else
%                 if f(A,W -(mu+n)*(W*(H*H') + (M*M')*W),H) >= f(A,W -mu*(W*(H*H') + (M*M')*W),H)
%                     return;
%                 else
%                     n = 0.5*n;
%                 end
%             end
%         end
%     end
%     function cout  = f(A,W,H)
%         cout = norm(A-W*H,'fro') + trace(M'*W);
%     end

end