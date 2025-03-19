function [p,SCEt,SCEf,SCEe] = VAF(A,W,H,varargin)
%   VAF : 
%   Calcul des variances issus de la d�composition matricielle
%   La variance totale est d�finie comme la trace de la matrice de covariance
%   des donn�es originales. le mod�le : 
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
%       SCEe : variance attribuable � l'erreur (scalaire)
%       
%
%   OPTIONs :
%   Les m�thodes sont tir�s de la literrature et rapidement expliqu�es
%   ci dessous avec le code lui m�me.
%   'methode' = 1 � 4
%   'affichage' = 'true' pour afficher les r�sultats
%

%   ===========================
%     Valeurs par d�faut
    affichage = 0;
    methode = 5;
    
    


%   ===========================
%     V�rifications � l'entr�e de la fonction 
%     et lecture des options
%   ===========================
    
    if nargin<3
        error('Il faut 3 arguments au minimum � l''entr�e de la fonction VAF !');
    end
    if (rem(length(varargin),2)==1)
      error('Il doit manquer une option � l''entr�e de la fonction VAF');
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
%   matrice centr�e et nbre synergies
    nbre_syn = size(W,2);
     

    switch methode
        
%       ===========================        
        case 1
%       ===========================
%       m�thode 1 : (voir literrature)
%       Le r�sidus est divis� par la trace de la matrice  de cov
%       r� = 1-||EMGr-EMGo||�/||EMGo-mean(EMGo||�
        message = 'r� = 1-||EMGr-EMGo||�/||EMGo-mean(EMGo)||�';
    
        Ac = centrer(A);        
        SCEt = Ac(:)'*Ac(:);
        err = A-W*H;
        SCEf = ones(1,nbre_syn)*NaN;
        SCEe = err(:)'*err(:);
        
%       ===========================
        case 2
%       ===========================
%       m�thode 2 : PROJECTION CENTREE
%       Vectorisation et projection sur le vecteur A 
%       (rapports de normes)
        message = 'Rapport � la norme de la matrice initiale vectoris�e centr�es';
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
%       m�thode 3 : PROJECTION NON CENTREE
%       Vectorisation et projection sur le vecteur A 
%       (rapports de normes)
        message = 'Rapport � la norme de la matrice initiale vectoris�e';

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
%       m�thode 4 : TRACE DE LA MATRICE DE COVARIANCE
%       Utilisation des matrices centr�es par collonnes
        message = 'Traces des matrices de covariances (matrices centr�es)'; 
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
%       m�thode 5 : TRACE DE LA MATRICE DE 'COV' (NON CENTREE)
%       M�thode de Torres-Oviedo  J. neuropsysiol (2007)
%       - sauf pour les Var syn i
%       r� = 1-||EMGr - EMGo||�/||EMGo||�
        message = 'r� = 1-||residual||�/||EMG||�';
        
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
%       m�thode 5 :
%       Les matrices sont vectoris�es et centr�es. On fait ensuite le
%       rapport de leurs normes
        message = 'Rapport de normes (matrices vectoris�es puis centr�es)'; 

        %   Matrice centr�e
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
%       m�thode 7 :
        % simple corr�lation (on perd de l'information en 'r�duisant'=> la
        % somme des SCEf n'est pas �gale � la vaf totale
        message = 'Rapports centr�s r�duits (r�)'; 
        
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
%       affichage des r�sultats
%       ===========================
        fprintf('\n VAF : %s \n',message) 
        fprintf('\n\t VAF  : \t \t%f\n',100*(1-SCEe/SCEt)),
        fprintf('\t var r�sidus :\t%f\n',100*SCEe/SCEt),
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
    