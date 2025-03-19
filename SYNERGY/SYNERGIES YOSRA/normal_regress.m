function [b var_explained] = normal_regress(x,y,robust)
% régression orthogonale à partir des résultats d'une ACP
% l'option robust( = 1 ou 0) permte d'effectuer cette régression de manière
% robuste
%     reference:
%     Ricardo Maronna (2005) Principal Components and Orthogonal Regression
%     Based on Robust Scales, Technometrics, 47:3, 264-273, DOI: 10.1198/004017005000000166

    x = x(:);y = y(:);
    if nargin <3
        robust = false;
    end
    v = [x y];
    if robust
        maxiter = 20;
        
        % première estimation
        centre = npmean(v);
        [vector val] = eig(cov(v));
      
        orth_old =  vector(:,1);
        for i = 1:maxiter

            % calcul des résidus    
            err = sum((bsxfun(@minus,v,centre)*orth_old).^2,2);
            dev   = 2.985*1.4826*median(abs(err));% tuning cte * MAD
            w = exp(-(err/dev).^2); % poids
            w = w/sum(w);
            centre = sum(bsxfun(@times,w,v)); % recalcul du centre
            
            % calcul du vecteur via la matrice de covariance 'optimale'
            [vector xxx] = eig([x-centre(1) y-centre(2)]'*diag(w)*[x-centre(1) y-centre(2)]);
            b(2) = vector(2,2)/vector(1,2);
            b(1) = centre(2) - b(2)*centre(1); 

            orth_new =  vector(:,1);
            if (1-abs(orth_new'*orth_old))<1E-12
                break; 
            end

            orth_old = orth_new;
        end
    else
        centre = mean(v);
        [vector val] = eig(cov(v));
    end
    % détermination des coeff
    b(2) = vector(2,2)/vector(1,2);
    b(1) = centre(2) - b(2)*centre(1); 
    
    % variance expliquée
    u = bsxfun(@minus,v,centre);    
    var_explained =  1-sum((u*vector(:,1)).^2)/sum(u(:).^2);
    
end
