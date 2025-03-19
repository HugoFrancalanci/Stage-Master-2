function [score,loading,latent] = ACP(X,nbre_syn,varargin)
 % ANALYSE EN COMPOSANTE PRINCIPALE
 %      1 ) Calcul les valeurs propres de la matrice de corr�lation
 %          / covariance de X
 %      2 ) Choisi le nombre de synergie (VAF > 90 % par d�faut)
 %      3 ) effectue une rotation (varimax) des facteurs
 %  INPUT
 %      X : matrice [ind,var]
 %         indice ligne : les individus
 %         var les collonnes de variables explicatives
 %  OPTION
 %      'rotation' : d�faut 'true'
 %      'p' : le pourcentage de VAF pour le choix des synergies
 %      'positif' : renverse les facteurs et score s'ils sont tous deux
 %                  positifs
 %      'type'    : correlation, covariance ou robust
 %  OUTPUT
 %      score : l'�volution des synergies
 %      loading : les poids factoriels
 %      latent : les valeurs propres
 
 
 % references
 
 
 
 % auteur: NA Turpin (2017)
 %   ===========================
 
%  Valeurs par d�faut
    rotation = 1;
    p = 0.9; % VAF limite pour d�terminer le nombre de synergies
    fixe =0;
    positif = 1;
    type = 'corr';
    
    


%   ===========================
%     V�rifications � l'entr�e de la fonction 
%     et lecture des options
%   ===========================
    
    if nargin ==0
        error('Aucun argument � l''entr�e de la fonction ''composante_principale'' !');
    end
    if isempty(nbre_syn)
        fixe = 1;
    end
    if (rem(length(varargin),2)==1)
      error('Il doit manquer une option � l''entr�e de la fonction ''composante_principale''');
    else
        for i=1:2:(length(varargin)-1)
            switch lower (varargin{i})
                case 'rotation'
                    if ~strcmpi(varargin{i+1},'true')
                        rotation = 0;
                    end
                case 'p'
                    p = varargin{i+1};
                case 'positif'
                    if ~strcmpi(varargin{i+1},'true')
                        positif = 0;
                    end
                case 'type'
                    type = varargin{i+1};
            end
        end
    end

 
%   =========================================
%       CALCUL DES VALEURS ET VECTEURS PROPRES
%   =========================================
%   On utilise la matrice des corr�lations plutot que la matrice des
%   covariance, qui qui cause une petite diff�rence de variance en les
%   'latent' renvoy�s et ce qui est calcul� par VAF...

    switch type
        case 'corr'
            C = corr(X);
        case 'cov'
            C = cov(X);
        case 'robustcov'
            C = npcov(X);
        case 'robustcorr'
            C = npcov(X);
            d_ = diag(C);
            C = C./sqrt(d_*d_');
    end
    [vecteur_propre, valeur_propre] = eig(C);% valeurs / vecteurs propres
    
%   --------------------------------
%   ranger les valeurs propres
%   --------------------------------
    valeur_propre = diag(valeur_propre);
    val =sort(valeur_propre,'descend');
    permutation = zeros(length(val),length(val));
    for i = 1:length(val)
        permutation(i,find(valeur_propre==val(i)))=1;
    end
    vecteur_propre = vecteur_propre*permutation;
%   --------------------------------
%   choisir le nombre de synergie et les extraire
%   --------------------------------
    
    if fixe
        nbre_syn   = find(cumsum(val)/sum(val)>p,1,'first');
    end
    
    % Varimax rotation
    try
        if rotation && nbre_syn ~= 1
            vecteur_propre = rotatefactors(vecteur_propre(:,1:nbre_syn));
        end
    catch
    end
    
    score = X*vecteur_propre(:,1:nbre_syn);
    loading = vecteur_propre(:,1:nbre_syn)';% pinv = transpos�e !
    %[score,loading] = ranger(X,score,loading);
    
    latent = val;
    
    % renverse les loadings et scores fortements n�gatifs (>80% de la somme
    % des �l�ments). Ne change pas le r�sultat
    if positif
        for i= 1:size(loading,1)
            if sum(loading(i,loading(i,:)>0))/sum(-loading(i,loading(i,:)<0))<1
                loading(i,:) = -loading(i,:);
                score(:,i)   = -score(:,i);
            end
        end
    end
      
end
    
    
