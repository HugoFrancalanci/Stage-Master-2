function [p,SCEt,SCEf,SCEe] = VAF(A,W,H,varargin)
%   VAF : 
%   Calcul des variances issus de la décomposition matricielle
%   La variance totale est définie comme la trace de la matrice de covariance
%   des données originales. le modèle : 
%       A = W*H + e  ou 'e' est l'erreur
%
%   INPUT : 
%       A la matrice initiale
%       W scores
%       H loading
%       
%   OUTPUT :
%       SCEt : variance totale (scalaire)
%       SCEf : variance des synergies (vecteur)
%       SCEe : variance attribuable à l'erreur (scalaire)
%       
%
%   OPTIONs :
%   Les méthodes sont tirés de la literrature et rapidement expliquées
%   ci dessous avec le code lui même.
%   'methode' = 1 à 4
%   'affichage' = 'true' pour afficher les résultats
%

%   ===========================
%     Valeurs par défaut
    affichage = 0;
    methode = 5;
    
    


%   ===========================
%     Vérifications à l'entrée de la fonction 
%     et lecture des options
%   ===========================
    
    if nargin<3
        error('Il faut 3 arguments au minimum à l''entrée de la fonction VAF !');
    end
    if (rem(length(varargin),2)==1)
      error('Il doit manquer une option à l''entrée de la fonction VAF');
    else
        for i=1:2:(length(varargin)-1)
            switch lower (varargin{i})
                case 'methode'
                    methode = varargin{i+1};
                case 'affichage'
                    if strcmpi(varargin{i+1},'true')
                        affichage = 1;
                    end
            end
        end
    end


%   ===========================
%   matrice centrée et nbre synergies
    nbre_syn = size(W,2);
     

    switch methode
        
%       ===========================        
        case 1
%       ===========================
%       méthode 1 : (voir literrature)
%       Le résidus est divisé par la trace de la matrice  de cov
%       r² = 1-||EMGr-EMGo||²/||EMGo-mean(EMGo||²
        message = 'r² = 1-||EMGr-EMGo||²/||EMGo-mean(EMGo)||²';
    
        Ac = centrer(A);        
        SCEt = Ac(:)'*Ac(:);
        err = A-W*H;
        SCEf = ones(1,nbre_syn)*NaN;
        SCEe = err(:)'*err(:);
        
%       ===========================
        case 2
%       ===========================
%       méthode 2 : PROJECTION CENTREE
%       Vectorisation et projection sur le vecteur A 
%       (rapports de normes)
        message = 'Rapport à la norme de la matrice initiale vectorisée centrées';
        A = centrer(A);
        SCEt = A(:)'*A(:);%<=> trace(A'*A)
        for i = 1:nbre_syn
            u = centrer(W(:,i)*H(i,:));
            SCEf(i) = A(:)'*u(:);
        end
        ee = centrer(A-W*H);
        SCEe = A(:)'*ee(:);
%       ===========================
        case 3
%       ===========================
%       méthode 3 : PROJECTION NON CENTREE
%       Vectorisation et projection sur le vecteur A 
%       (rapports de normes)
        message = 'Rapport à la norme de la matrice initiale vectorisée';

        SCEt = A(:)'*A(:);%<=> trace(A'*A)
        for i = 1:nbre_syn
            u = W(:,i)*H(i,:);
            SCEf(i) = A(:)'*u(:);
        end
        ee = A-W*H;
        SCEe = A(:)'*ee(:);
%       ===========================        
        case 4
%       ===========================
%       méthode 4 : TRACE DE LA MATRICE DE COVARIANCE
%       Utilisation des matrices centrées par collonnes
        message = 'Traces des matrices de covariances (matrices centrées)'; 
        Ac = centrer(A);
        SCEt = trace(Ac'*Ac);
        err = centrer(A-W*H);
        
        for i = 1:nbre_syn
            temp = centrer(W(:,i)*H(i,:));
            for j = 1:nbre_syn
                M(i,j) = trace(temp'*centrer(W(:,j)*H(j,:)));
            end
            M(i,j+1) = trace(temp'*err);
            M(nbre_syn+1,i) = trace(temp'*err);
        end

        M(i+1,j+1) = trace(err'*err);
        SCEf = sum(M(:,1:nbre_syn));
        SCEe = sum(M(:,end));
        
%       ===========================   
        case 5
%       ===========================
%       méthode 5 : TRACE DE LA MATRICE DE 'COV' (NON CENTREE)
%       Méthode de Torres-Oviedo  J. neuropsysiol (2007)
%       - sauf pour les Var syn i
%       r² = 1-||EMGr - EMGo||²/||EMGo||²
        message = 'r² = 1-||residual||²/||EMG||²';
        
        SCEt = A(:)'*A(:);
        err = A-W*H;
        for i = 1:nbre_syn
            temp = W(:,i)*H(i,:);
            M(:,i) = temp(:);
        end
        M = [M,err(:)];
        M = M'*M;
        SCEf = sum(M(:,1:nbre_syn));
        SCEe = sum(M(:,end));

%       ===========================        
        case 6
%       ===========================
%       méthode 5 :
%       Les matrices sont vectorisées et centrées. On fait ensuite le
%       rapport de leurs normes
        message = 'Rapport de normes (matrices vectorisées puis centrées)'; 

        %   Matrice centrée
        Ac = A-mean(A(:));
        SCEt = Ac(:)'*Ac(:);
        err = A-W*H;err = err(:)-mean(err(:));
        for i = 1:nbre_syn
            temp =W(:,i)*H(i,:);
            M(:,i) = temp(:)-mean(temp(:));
        end
        M = [M,err(:)];
        M = M'*M;
        SCEf = sum(M(:,1:nbre_syn));
        SCEe = sum(M(:,end));
%       ===========================        
        case 7
%       ===========================
%       méthode 7 :
        % simple corrélation (on perd de l'information en 'réduisant'=> la
        % somme des SCEf n'est pas égale à la vaf totale
        message = 'Rapports centrés réduits (r²)'; 
        
        Ac = zscore(A);
        SCEt = 1;
        for i = 1:nbre_syn
            WH=zscore(W(:,i)*H(i,:));
            SCEf(i) =  Ac(:)'*WH(:)/(size(A,1)*size(A,2)-1);
        end
        WH = zscore(W*H);
        SCEe = 1-Ac(:)'*WH(:)/(size(A,1)*size(A,2)-1);
        
    end
    
    p = 1-SCEe/SCEt;
    if affichage
%       ===========================
%       affichage des résultats
%       ===========================
        fprintf('\n VAF : %s \n',message) 
        fprintf('\n\t VAF  : \t \t%f\n',100*(1-SCEe/SCEt)),
        fprintf('\t var résidus :\t%f\n',100*SCEe/SCEt),
        fprintf('\t ----------------------\n'),
        for i = 1:nbre_syn
           fprintf('\t var syn %u :\t%f\n',i,100*SCEf(i)./SCEt),
        end
        fprintf('\t ----------------------\n'),
        fprintf('\t somme variances facteurs :\t%f \n',100*sum(SCEf)/SCEt),
        fprintf('\n'),
    end
    
    function M = centrer(X)
        M = X-repmat(mean(X),size(X,1),1);
    end
    
end
    