function M = permutation_matrice(M1,M2,H1,H2,poids)
% fourni la matrice de permutation la plus probable entre 2 matrices
% M doit être utilisée pour permuter les lignes ou les collonnes de M1 ou H1
% les matrices de référence étant M2 et H2

% auteur NA turpin


% INITIALISATION ET VÉRIFICATIONS
    if nargin<2
        error('il faut au moins deux matrices à l''entrée de la fonction ''permutation_matrice''');
    end
    if nargin <3
        c = nancorr(M1,M2);
    end
    if nargin==4
        poids = [];
    end
    if nargin >4
        if ~isempty(poids)
            if poids<1 || poids>1
                poids = [];
            end
        end
    end
       
     
% DETERMNATION DE LA MATRICE DE CORRELATION COUPLEE
% (si nbre arguments == 6)
    if nargin>=4
        if isempty(poids)
            poids = corr_adaptative(nancorr(M1,M2),nancorr(H1,H2));
        end
%         C(:,:,1) = nancorr(M1,M2);
%         C(:,:,2) = nancorr(H1,H2);
%         c = max(C,[],3);
        c = poids*nancorr(M1,M2) + (1-poids)*nancorr(H1,H2);
    end

% CREATION DE LA MATRICE DE PERMUTATION
% association par le max de correlation
    N = min(size(c));
    if size(c,1)>size(c,2)
        M = zeros(size(c,1),size(c,1));
    else
        M = zeros(size(c,1),size(c,2));
    end
    for i = 1:N;
        [x,y] = find(c==max(c(:)),1,'first');
        M(x,y) = 1;
        c(x,:) = -inf;
        c(:,y) = -inf;
    end
    
    % cas ou les deux matrices ne sont pas de dimensions égales
    if size(c,1)>size(c,2)
        k = 1;
        for i = 1:size(c,1)
            if all(M(i,:)==0)
                M(i,size(c,2)+k) = 1;
                k = k+1;
            end
        end
    end
        

% DÉTERMINAION DU COEFFICIENT (POIDS) QUI MAXIMISE LA MATRICE DE CORREL  
    function c_adapt = corr_adaptative(c1,c2)
        % cherche le coefficient (poids) qui maximise la matrice de correl (elle
        % doit se rappocher le plus possible de 1) , cad: 
        % on cherche c tq: c*c1(:) + (1-c)*c2(:) =  ones(:), ce qui n'est pas possible
        % mais on veut s'en rapprocher.
        % si A = [c1(:)-c2(:)];  x = [c] et b = ones(:)-c2(:) on a:
        % A*x = b => x = A\b minimise la différence!
        A  = c1(:)-c2(:);
        b = ones(length(c2(:)),1)-c2(:);
        c_adapt = A\b;
    end


    function c_val = nancorr(x,y)
    % nancorr
    % correlation qui omet les valeurs NaN

        x_ =  bsxfun(@minus,x,nanmean(x));
        y_ =  bsxfun(@minus,y,nanmean(y));
        x_ =  bsxfun(@rdivide,x_,sqrt(nansum(x_.^2)));% diviser par la norme
        y_ =  bsxfun(@rdivide,y_,sqrt(nansum(y_.^2)));

        for ii = 1:size(x,2)
            for jj = 1:size(y,2)
                c_val(ii,jj) = nansum(x_(:,ii).*y_(:,jj));
            end
        end
    end
      
end% end of all