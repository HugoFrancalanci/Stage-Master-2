function c_val = nancorr(x,y, option)
% nancorr
% USE
% nancorr(X,[],'sp')
% nancorr(X,Y)
% correlation ou produit scalaire normalisé qui omet les valeurs NaN

% auteur NA Turpin 2014

if nargin <3
    option = 'corr';
end
SCALAR_PRODUCT = 0;
if strcmp( option , 'sp')
   SCALAR_PRODUCT = 1;
end

if nargin >1
    if isempty(y)
        y = x; % autocorrélation
    end
elseif nargin==1
    y = x;
end

if ~SCALAR_PRODUCT
    % obtenir les z values (attention aux notation x_ et x)
    x_ =  bsxfun(@minus,x,nanmean(x));
    y_ =  bsxfun(@minus,y,nanmean(y));
    x_ =  bsxfun(@rdivide,x_,sqrt(nansum(x_.^2)));% diviser par la norme
    y_ =  bsxfun(@rdivide,y_,sqrt(nansum(y_.^2)));

    for i = 1:size(x,2)
        for j = 1:size(y,2)
            c_val(i,j) = nansum(x_(:,i).*y_(:,j));
        end
    end


else
    x_ = bsxfun(@rdivide,x,sqrt(nansum(x.^2)));% diviser par la norme
    y_ = bsxfun(@rdivide,y,sqrt(nansum(y.^2)));
    
    for i = 1:size(x,2)
        for j = 1:size(y,2)
            c_val(i,j) = nansum(x_(:,i).*y_(:,j));
        end
    end
    
end


end