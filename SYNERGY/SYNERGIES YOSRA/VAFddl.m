function [SCEt,SCEf,SCEe,r] = VAFddl(A,W,H,varargin)
%   VAFddl : Calcul des variances issus de la décomposition matricielle
%   pour chaque muscle (chaque dimension initiale)
%   La variance totale est définie comme la trace de la matrice de covariance
%   des données originales. le modèle : 
%       A = W*H + e  où 'e' est l'erreur
%
%   INPUT : 
%       A la matrice initiale
%       W scores
%       H loading
%       
%   OUTPUT :
%       SCEt : variance totale (scalaire)
%       SCEf : variance des variables initiales (vecteur)
%       SCEe : variance attribuable à l'erreur (scalaire)
%       
%
%   OPTIONs :
%   Les méthodes sont rapidement expliquées
%   ci dessous avec le code lui même.
%   'methode' = 1 à 2
%   'affichage' = 'true' pour afficher les résultats
%

%   ===========================
%     Valeurs par défaut
    affichage = 0;
    methode = 3;
    
    


%   ===========================
%     Vérifications à l'entrée de la fonction 
%     et lecture des options
%   ===========================
    
    if nargin<3
        error('Il faut 3 arguments au minimum à l''entrée de la fonction VAFddl !');
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
    
    switch methode

  %  ===========================        
        case 1
%       ===========================
%       méthode 1 : 
     
%       Le résidus est divisé par la trace de la matrice  de cov
%       r² = 1-||EMGr-EMGo||²/||EMGo-mean(EMGo)||² 
%       Méthode de d'Avella (2006) : les r² total est la moyenne des r² de
%       chaque ddl 
            r = [];
            message = 'r² = 1-||EMGr-EMGo||²/||EMGo-mean(EMGo||²';
            nbre_mus = size(A,2);

            Ac = centrer(A);       
            SCEt = Ac(:)'*Ac(:);
            err = A-W*H;
            WH = W*H;
            for i = 1:nbre_mus
                SCEf(i) = nbre_mus*trace((A(:,i)-WH(:,i))'*(A(:,i)-WH(:,i)))/SCEt;
            end
            r = diag(corr(A,W*H)).^2;% r²
            SCEe = err(:)'*err(:);
            if affichage
%       ===========================
%       affichage des résultats 
%       ===========================
                fprintf('\n VAFddl : methode %u _  %s \n ',methode,message) 
                fprintf('\t r² total :\t\t%f\n',1-SCEe/SCEt),
                fprintf('\t résidus : \t\t%f\n',SCEe/SCEt),
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t r² \t\t\t r² (Pearson) \n');
                for i = 1:nbre_mus
                   fprintf('\t\t%u \t\t %f \t\t %f \n',i,1-SCEf(i),corr(A(:,i),WH(:,i))^2)
                end
                fprintf('\t ----------------------\n'),
                fprintf('\t moyenne des r² :\t%f \n',mean(1-SCEf)),
            end
%       ===========================        
        case 2
%       ===========================
%       méthode 2 :
%       Utilisation des matrices centrées par collonnes
%       On a les variances expliquées par chacunes des dimensions (i.e. les
%       muscles) et le coeff de corrélation entre l'évolution EMG initiale
%       et reconstruite
        message = 'Traces des matrices de covariances (matrices centrées)'; 
         WH = centrer(W*H);
         err = centrer(A-WH);
         Ac = centrer(A);
         inter = diag(err'*WH); % intéraction
         SCEt = diag(Ac'*Ac)';
         for i =1:size(A,2)
             SCEf(i) = sum(WH(:,i).^2) + inter(i);
         end
         r = diag(corr(A,W*H)).^2;% r²
         SCEe = trace(err'*err)+sum(inter);
            if affichage
%       ===========================
%       affichage des résultats 
%       ===========================

                fprintf('\n VAFddl : methode %u _  %s \n ',methode,message) 
                fprintf('\t var total :\t\t%f\n',100*(1-SCEe/sum(SCEt)));
                fprintf('\t résidus : \t\t%f\n',100*SCEe/sum(SCEt))
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t var init \t var reconstruite\t r² \t\t\t r² (Pearson)\n')
                for i = 1:size(A,2)
                   fprintf('\t\t%u \t\t %f \t\t %f \t\t %f \t\t %f\n',i,100*SCEt(i)/sum(SCEt),100*SCEf(i)/sum(SCEt),SCEf(i)/SCEt(i),r(i))
                end
                fprintf('\t ----------------------\n'),
                fprintf('\t somme:\t\t %f\t\t%f \n',100*sum(SCEt/sum(SCEt)),100*sum(SCEf./sum(SCEt))),
            end
%       ===========================        
        case 3
%       =========================== 
%       Méthode de Torres-Oviedo  J. neuropsysiol (2007)
        message = 'r² (muscle i) = 1-sum of square(residus muscle i)/total sum of square (muscle i)'; 
        SCEt = sum(A(:).^2);
        err = A-W*H;
        for i = 1:size(A,2)
            SCEf(i) = 1 - sum(err(:,i).^2)/sum(A(:,i).^2);
        end
        SCEe = sum(err(:).^2);% ne sert à rien celui là
        r = diag(corr(A,W*H)).^2;
%       ===========================
%       affichage des résultats 
%       ===========================
            if affichage
                fprintf('\n VAFddl : %s \n ',message) 
                fprintf('\t var total :\t\t%f\n',100*(1-SCEe/SCEt)),
                fprintf('\t résidus   :\t\t%f\n',100*SCEe/SCEt),
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t  r² \t\t\t r² (Pearson)\n')
                for i = 1:size(A,2)
                   fprintf('\t\t%u \t\t %f \t\t %f\n',i,SCEf(i),r(i))
                end
                fprintf('\t ----------------------\n'),
                fprintf('\t moyenne:\t %f \n',mean(SCEf)),
            end
%       ===========================        
        case 4
%       ===========================

       %       Méthode de Torres-Oviedo 2  J. neuropsysiol (2007)
        message = 'r² (muscle i) = 1-sum of square(residus muscle i)/total sum of square (muscle i) (vecteurs centrés)';
        Ac = centrer(A);
        SCEt = sum(Ac(:).^2);
        err = centrer(A-W*H);
        for i = 1:size(A,2)
            SCEf(i) = 1 - sum(err(:,i).^2)/sum(Ac(:,i).^2);
        end
        SCEe = sum(err(:).^2);
        r = diag(corr(A,W*H)).^2;
%       ===========================
%       affichage des résultats 
%       ===========================
            if affichage
                fprintf('\n VAFddl : %s \n ',message) 
                fprintf('\t var total :\t\t%f\n',100*(1-SCEe/SCEt)),
                fprintf('\t résidus   :\t\t%f\n',100*SCEe/sum(SCEt)),
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t  r² \t\t\t (Pearson)r²\n')
                for i = 1:size(A,2)
                   fprintf('\t\t%u \t\t %f \t\t %f\n',i,SCEf(i),r(i))
                end
                fprintf('\t ----------------------\n'),
                fprintf('\t moyenne:\t %f \n',mean(SCEf)),
            end
%       ===========================        
        case 5
%       ===========================
    % matrices centrées réduites (les corrélations)
    message = 'r² (matrices centrées réduites)';
        Ac = zscore(A);
        WH = zscore(W*H);
        SCEt = 1;
        SCEf = diag(Ac'*WH/(size(A,1)-1)).^2;
        SCEe = 1-Ac(:)'*WH(:)/(size(A,1)*size(A,2)-1);
        %       ===========================
%       affichage des résultats 
%       ===========================
            if affichage
                fprintf('\n VAFddl : methode %u _  %s \n ',methode,message) 
                fprintf('\t var total :\t\t%f\n',100*(1-SCEe/SCEt)),
                fprintf('\t résidus   :\t\t%f\n',100*SCEe/sum(SCEt)),
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t  r²\n')
                for i = 1:size(A,2)
                   fprintf('\t\t%u \t\t %f \n',i,SCEf(i))
                end
                fprintf('\t ----------------------\n'),
                fprintf('\t moyenne:\t %f \n',mean(SCEf)),
            end
            
    end

    
       
    function M = centrer(X)
        M = X-repmat(mean(X),size(X,1),1);
    end
end






            