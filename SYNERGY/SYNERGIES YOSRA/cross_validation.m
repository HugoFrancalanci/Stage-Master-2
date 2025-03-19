function [vaf syn_spe] = cross_validation(E,Href)
% CROSS VALIDATION ENTRE LES SYNERGIES
% Le principe est d'extraire les synergies dans une condition test et
% de les utiliser pour expliquer les données d'autres conditions
% si vaf muscle <75 le script cherche des synergies spécifiques:
%
% 1) en initialisant lee seung (ou nmg_PG ici) avec le H de référence 
%    et un W estimé (méthode de Torres-oviedo et coll.) on obtient une
%    estimation de la solution
%
% 2) si la méthode n'est pas satisfaisante (similarité base de ref et
%    base obtenue trop faible) on utilise nmf_basis qui fixe (réellement) 
%    la base (au prix d'être sous optimal et donc de ralentir le
%    processus d'optimisation)
% 
% 3) le processus étant sous optimal (on fixe une partie de la base)
% l'ajout de synergies spécifiques ne permet pas toujours d'obtenir la même
% variance que pour l'estimation initiale(ce qui indique que les synergies de base
% ne sont pas "correctes"
%
% ETAPE 1
%   - mettre les données EMG à expliquer par ces synergies dans un dossier (le
%     nom des fichiers = ...._mat_reference.mat) ;
%   - avoir fait une extraction de synergies pour une condition de référence
%    et donc avoir un H re référence(vecteur des synergies)
% ETAPE 2
%   - taper:
%  >> [vaf syn_spe] = cross_validation

% ENSUITE ATTENDRE...

% auteur NA Turpin 


% 3) CALCULER LA VARIANCE POUR TOUTES LES CONDITIONS
%    ET EXTRAIRE LES SYNERGIES SPECIFIQUES SI VAF_MUSCLE <75%

N = size(Href,1);% nbre de synergies
        
% CALCUL DE LA VARIANCE EXPLIQUÉE PAR HREF DANS E
W         = lee_seung_W(E,Href);
err       = E-W*Href;
vaf       = 1 - sum(err(:).^2)/sum(E(:).^2);
vafmuscle = 1 - sum(err.^2)./sum(E.^2);
fprintf('VAF expliquée %3.2f\n',vaf*100);
fprintf('VAF de %1.0f muscles <75 pourcent\n',sum(vafmuscle<0.75));
if any(vafmuscle <0.75)
   % DÉTERMINATION DU NBRE DE SYNERGIES SPÉCIFIQUES
   Winit = W;
   Hinit = Href;
    k= 0;
    while any(1 - sum(err.^2)./sum(E.^2)<0.75)
        k = k+1;
        if N+k>size(E,2)
            break;
        end
        [Winit Hinit] = lee_seung(E,N+k,...
                            'initialw',[Winit rand(size(W,1),1)],...
                            'initialh',[Hinit;rand(1,size(Href,2))]);
        err = E-Winit*Hinit;
    end
    vafspe    = 1 - sum(err(:).^2)/sum(E(:).^2);
    vafmuscle = 1 - sum(err.^2)./sum(E.^2);
    fprintf(['estimation du nombre de synergies spé: %1.0f\n'...
        'variance totale = %3.2f (+%3.2f)\n'],k,vafspe*100,(vafspe-vaf)*100);
            
    %DETERMINATION DES SYNERGIES SPE
    if k~=0
        [Wp Hp] = nmf_basis(E,N+k,Href,'W',Winit,'H',Hinit);
        % afficher les variances
        err = E-Wp*Hp;
        vafspe = 1 - sum(err(:).^2)/sum(E(:).^2);
        vafmuscle = 1 - sum(err.^2)./sum(E.^2);
        fprintf('variance totale = %3.2f (+%3.2f)\n',vafspe*100,(vafspe-vaf)*100);
        for ll = 1:length(vafmuscle)
            fprintf('%3.2f\t',vafmuscle(ll)*100);
        end
        fprintf('\n');
        if any(1 - sum(err.^2)./sum(E.^2)<0.75)
            fprintf('solution sous-optimale: echec\n');
        end
        figure();        
        for ll = 1:N+k
            subplot(N+k,1,ll)
            if ll<=N
                bar([Hp(ll,:)' Href(ll,:)']);
            else
                bar([Hp(ll,:)]);
            end
        end
    end

end% fin


