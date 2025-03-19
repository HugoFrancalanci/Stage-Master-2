function [result,c] = synergies_bien_discriminees(W,H,varargin)
   % Test de similitude des synergies (logical)
   % option
   % 'type_comparaison'
   % (1) : pour comparer les synergies (scores), par défaut
   % (2) : pour comparer les loadings
   % (3) : pour comparer les deux (moyenne pondérée des matrices de
   %       corrélation)
   % (4) : comparer les matrices  W(:,i)*H(i,:) et W(:,j)*H(j,:)
   %       par corrélation de matrice i.e.,
   %       r = trace(A'*B)/sqrt(trace(A'*A)*trace(B'*B));
   % 'p': valeur discrimante
   % 'zone' : zone où peut varier la cross correlation
   % 
   % ==================
   % valeurs par défault
   % ==================
   option = 1;% pour 'type_comparaison'
   p = 0.8;
   zone = 5;
   
   % =================
   %    options
   % =================
   if nargin ==0
        error('Aucun argument à l''entrée de la fonction ''NNMF'' !');
    end
    if (rem(length(varargin),2)==1)
      error('Il doit manquer une option à l''entrée de la fonction ''NNMF''');
    else
        for i=1:2:(length(varargin)-1)
            switch lower (varargin{i})
                case 'type_comparaison'
                    option = varargin{i+1};
                case 'p'
                    p = varargin{i+1};
                case 'zone'
                    zone = varargin{i+1};
            end
        end
    end
%   =================
%   début des calculs
%   =================
    cc = correlation();
    
    switch option
        case 1
            c = cc.max_corr_part(W,W,zone);
        case 2
            c = corr((H.^2)',(H.^2)');
        case 3
            c = cc.Z(cc.Z(0.4*corr((H.^2)',(H.^2)'),1) + 0.6*cc.Z(cc.max_corr_part(W,W,zone),1),-1);
        case 4 
            for i = 1:size(W,2)
                for j = i:size(W,2)
                    A = W(:,i)*H(i,:); B = W(:,j)*H(j,:);
                    c(i,j) = trace(A'*B)/sqrt(trace(A'*A)*trace(B'*B));
                    c(j,i) = c(i,j);
                end
            end 
        case 5
              % idem que  3 mais sans Z transform
            c = 0.4*corr((H.^2)',(H.^2)')+ 0.6*cc.max_corr_part(W,W,zone);
    end
    result = sum(sum(c>p ~= eye(size(W,2))))==0;
    

end