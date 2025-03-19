function [SCEt,SCEf,SCEe,r] = VAFddl(A,W,H,varargin)
%   VAFddl : Calcul des variances issus de la d�composition matricielle
%   pour chaque muscle (chaque dimension initiale)
%   La variance totale est d�finie comme la trace de la matrice de covariance
%   des donn�es originales. le mod�le : 
%       A = W*H + e  o� 'e' est l'erreur
%
%   INPUT : 
%       A la matrice initiale
%       W scores
%       H loading
%       
%   OUTPUT :
%       SCEt : variance totale (scalaire)
%       SCEf : variance des variables initiales (vecteur)
%       SCEe : variance attribuable � l'erreur (scalaire)
%       
%
%   OPTIONs :
%   Les m�thodes sont rapidement expliqu�es
%   ci dessous avec le code lui m�me.
%   'methode' = 1 � 2
%   'affichage' = 'true' pour afficher les r�sultats
%

%   ===========================
%     Valeurs par d�faut
    affichage = 0;
    methode = 3;
    
    


%   ===========================
%     V�rifications � l'entr�e de la fonction 
%     et lecture des options
%   ===========================
    
    if nargin<3
        error('Il faut 3 arguments au minimum � l''entr�e de la fonction VAFddl !');
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
    
    switch methode

  %  ===========================        
        case 1
%       ===========================
%       m�thode 1 : 
     
%       Le r�sidus est divis� par la trace de la matrice  de cov
%       r� = 1-||EMGr-EMGo||�/||EMGo-mean(EMGo)||� 
%       M�thode de d'Avella (2006) : les r� total est la moyenne des r� de
%       chaque ddl 
            r = [];
            message = 'r� = 1-||EMGr-EMGo||�/||EMGo-mean(EMGo||�';
            nbre_mus = size(A,2);

            Ac = centrer(A);       
            SCEt = Ac(:)'*Ac(:);
            err = A-W*H;
            WH = W*H;
            for i = 1:nbre_mus
                SCEf(i) = nbre_mus*trace((A(:,i)-WH(:,i))'*(A(:,i)-WH(:,i)))/SCEt;
            end
            r = diag(corr(A,W*H)).^2;% r�
            SCEe = err(:)'*err(:);
            if affichage
%       ===========================
%       affichage des r�sultats 
%       ===========================
                fprintf('\n VAFddl : methode %u _  %s \n ',methode,message) 
                fprintf('\t r� total :\t\t%f\n',1-SCEe/SCEt),
                fprintf('\t r�sidus : \t\t%f\n',SCEe/SCEt),
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t r� \t\t\t r� (Pearson) \n');
                for i = 1:nbre_mus
                   fprintf('\t\t%u \t\t %f \t\t %f \n',i,1-SCEf(i),corr(A(:,i),WH(:,i))^2)
                end
                fprintf('\t ----------------------\n'),
                fprintf('\t moyenne des r� :\t%f \n',mean(1-SCEf)),
            end
%       ===========================        
        case 2
%       ===========================
%       m�thode 2 :
%       Utilisation des matrices centr�es par collonnes
%       On a les variances expliqu�es par chacunes des dimensions (i.e. les
%       muscles) et le coeff de corr�lation entre l'�volution EMG initiale
%       et reconstruite
        message = 'Traces des matrices de covariances (matrices centr�es)'; 
         WH = centrer(W*H);
         err = centrer(A-WH);
         Ac = centrer(A);
         inter = diag(err'*WH); % int�raction
         SCEt = diag(Ac'*Ac)';
         for i =1:size(A,2)
             SCEf(i) = sum(WH(:,i).^2) + inter(i);
         end
         r = diag(corr(A,W*H)).^2;% r�
         SCEe = trace(err'*err)+sum(inter);
            if affichage
%       ===========================
%       affichage des r�sultats 
%       ===========================

                fprintf('\n VAFddl : methode %u _  %s \n ',methode,message) 
                fprintf('\t var total :\t\t%f\n',100*(1-SCEe/sum(SCEt)));
                fprintf('\t r�sidus : \t\t%f\n',100*SCEe/sum(SCEt))
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t var init \t var reconstruite\t r� \t\t\t r� (Pearson)\n')
                for i = 1:size(A,2)
                   fprintf('\t\t%u \t\t %f \t\t %f \t\t %f \t\t %f\n',i,100*SCEt(i)/sum(SCEt),100*SCEf(i)/sum(SCEt),SCEf(i)/SCEt(i),r(i))
                end
                fprintf('\t ----------------------\n'),
                fprintf('\t somme:\t\t %f\t\t%f \n',100*sum(SCEt/sum(SCEt)),100*sum(SCEf./sum(SCEt))),
            end
%       ===========================        
        case 3
%       =========================== 
%       M�thode de Torres-Oviedo  J. neuropsysiol (2007)
        message = 'r� (muscle i) = 1-sum of square(residus muscle i)/total sum of square (muscle i)'; 
        SCEt = sum(A(:).^2);
        err = A-W*H;
        for i = 1:size(A,2)
            SCEf(i) = 1 - sum(err(:,i).^2)/sum(A(:,i).^2);
        end
        SCEe = sum(err(:).^2);% ne sert � rien celui l�
        r = diag(corr(A,W*H)).^2;
%       ===========================
%       affichage des r�sultats 
%       ===========================
            if affichage
                fprintf('\n VAFddl : %s \n ',message) 
                fprintf('\t var total :\t\t%f\n',100*(1-SCEe/SCEt)),
                fprintf('\t r�sidus   :\t\t%f\n',100*SCEe/SCEt),
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t  r� \t\t\t r� (Pearson)\n')
                for i = 1:size(A,2)
                   fprintf('\t\t%u \t\t %f \t\t %f\n',i,SCEf(i),r(i))
                end
                fprintf('\t ----------------------\n'),
                fprintf('\t moyenne:\t %f \n',mean(SCEf)),
            end
%       ===========================        
        case 4
%       ===========================

       %       M�thode de Torres-Oviedo 2  J. neuropsysiol (2007)
        message = 'r� (muscle i) = 1-sum of square(residus muscle i)/total sum of square (muscle i) (vecteurs centr�s)';
        Ac = centrer(A);
        SCEt = sum(Ac(:).^2);
        err = centrer(A-W*H);
        for i = 1:size(A,2)
            SCEf(i) = 1 - sum(err(:,i).^2)/sum(Ac(:,i).^2);
        end
        SCEe = sum(err(:).^2);
        r = diag(corr(A,W*H)).^2;
%       ===========================
%       affichage des r�sultats 
%       ===========================
            if affichage
                fprintf('\n VAFddl : %s \n ',message) 
                fprintf('\t var total :\t\t%f\n',100*(1-SCEe/SCEt)),
                fprintf('\t r�sidus   :\t\t%f\n',100*SCEe/sum(SCEt)),
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t  r� \t\t\t (Pearson)r�\n')
                for i = 1:size(A,2)
                   fprintf('\t\t%u \t\t %f \t\t %f\n',i,SCEf(i),r(i))
                end
                fprintf('\t ----------------------\n'),
                fprintf('\t moyenne:\t %f \n',mean(SCEf)),
            end
%       ===========================        
        case 5
%       ===========================
    % matrices centr�es r�duites (les corr�lations)
    message = 'r� (matrices centr�es r�duites)';
        Ac = zscore(A);
        WH = zscore(W*H);
        SCEt = 1;
        SCEf = diag(Ac'*WH/(size(A,1)-1)).^2;
        SCEe = 1-Ac(:)'*WH(:)/(size(A,1)*size(A,2)-1);
        %       ===========================
%       affichage des r�sultats 
%       ===========================
            if affichage
                fprintf('\n VAFddl : methode %u _  %s \n ',methode,message) 
                fprintf('\t var total :\t\t%f\n',100*(1-SCEe/SCEt)),
                fprintf('\t r�sidus   :\t\t%f\n',100*SCEe/sum(SCEt)),
                fprintf('\t ----------------------\n'),
                fprintf('\t muscle \t  r�\n')
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






            