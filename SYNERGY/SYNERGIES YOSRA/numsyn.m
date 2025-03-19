function [vaf_ vaf2 Nb WW HH] = numsyn(E,varargin)
% number of synergies
% fonction qui permet de déterminer le nombre de synergies
% elle fournit le nombre de synergies déterminées par les méthodes
%'automatiques" de la literrature

% voir plus bas (dans le code) pour un description des méthodes : 

% les méthodes les plus efficaces sont : 
% 1) SURROGATE : CHEUNG ET AL. 2005, voir aussi Hug et al. 2012
% 2) critère de Catell  Tresch et al. 2006
% 3) 90% VAF globale et 75% vaf_ par muscle (le plus utilisé, mais dépend
% grandement du bruit présent).


% OPTIONS:
% verbose
% methode


% auteur: NA Turpin (2012)
% modifié 2014 (velicier)
% modifié 2014 (LMC)

% INITIALISATION:
d = derivation();
VERBOSE = 1;
METHODE = [1 2 3 4 5 6];
Z  = @(x) 0.5*log((1+x)./(1-x));
Nsyn = 1:size(E,2)-1;
Nb = [];

[nl nc] =size(E);

%   ===========================
%     Lecture des options
%   ===========================
    
    if nargin ==0
    elseif (rem(length(varargin),2)==1)
      error('Il doit manquer une option à l''entrée de la fonction ''numsyn''');
    else
        for i=1:2:(length(varargin)-1)
            switch lower (varargin{i})
                case 'verbose'
                    if  strcmp(varargin{i+1},'false');
                        VERBOSE = 0;
                    end
                case 'methode'
                    METHODE = varargin{i+1};
                case 'nsyn'
                    Nsyn = 1:varargin{i+1};
            end
        end
    end
    
    
% OBTENIR LA COURBE DE VAF (MÉTHODE TING ET COLL)
if VERBOSE
    fprintf('calcul de la courbe de variance des données...\n')
    fprintf('===============================================\n')
    wb = waitbar(0,' extracting synergies...');
end

if sum(METHODE==1)~=0
    surrogate = reshape(E(randperm(length(E(:)))),size(E,1),size(E,2));
end

WW =zeros(size(E,1),size(E,2),size(E,2));
HH =zeros(size(E,2),size(E,2),size(E,2));
vaf2 = [];
for i = Nsyn
    
    % extraction et vaf_   
    [W H] = lee_seung(E,i);
    %[W H] = composante_principale(E,i,'type','cov');
       
    err = E-W*H;
    vaf_(i) = 1 - sum(err(:).^2)/sum(E(:).^2);
    vafmuscle(i,:) = 1 - sum(err.^2)./sum(E.^2);  
    
    % garder les synergies extraites dans une matrice
    WW(:,1:i,i) = W;
    HH(1:i,:,i) = H;
    
    
    
    % vaf_ par bootstrapping = la moyenne sur plusieurs extractions
    % de sous parties de données
    
    if sum(METHODE==1)>0
    % extraction pour les surrogate data
    % la pente étant constante on obtient une estimation avec les 5
    % premiers points uniquement
        if i<=5
            [Ws Hs] = lee_seung(surrogate,i);
            %[Ws Hs] = composante_principale(surrogate,i,'type','cov');
            err2 = surrogate-Ws*Hs;
            vaf2(i) = 1 - sum(err2(:).^2)/sum(surrogate(:).^2);
        end
    end
       
    if sum(METHODE==5)~=0
        % critère d'akaike
        n = nl*nc;% elements of E
        k = nl*i + nc*i;% numbr of parameter elements of W and H
        RSS = sum(err(:).^2)/sum(E(:).^2);%mean(err(:).^2);
        AIC = n*log(RSS)+ 2*k;
        
        AICc(i) = AIC + 2*k*(k+1)/(n-k-1);     
    end
    
    if VERBOSE
        waitbar(i/size(E,2),wb,' extracting synergies...');  
    end
end

% détermination du nombre de synergies par diverse méthodes


vaf_ = [vaf_ 1];
vafmuscle = [vafmuscle;ones(size(E,2),size(E,2))];
if VERBOSE
    close(wb);
    assignin('base','vaf_',vaf_);
    assignin('base','vafmuscle',vafmuscle);
    assignin('base','surrogate',vaf2);
end

%DETERMINAITON DU NOMBRE DE SYNERGIES PAR LES DIFFERENTES METHODES 
if VERBOSE
    fprintf('METHODE \t nombre de synergies\n');
end

%-------------------------
% 1)SURROGATE
    % la pente est obtenue par moindre carré (régression) entre 3 pts
    % successifs (pour la pente de xi on teste xi-1, xi et xi+1
    % le point ou la pente est < à 75% des surrogates (cte) donne le nombre de
    % synergies
    ind =0;
if sum(METHODE==1)>0    
    x = 0:length(vaf2);
    y = [0 vaf2];
    pente_surr = mean((x-mean(x)).*(y-mean(y))./((x-mean(x)).*(x-mean(x))));
    y2 = [0 vaf_];
    for ii = 2:length(vaf_)-1
        x = ii-1:ii+1;
        y = y2(ii-1:ii+1);
        pente_vaf = (x-mean(x))*(y-mean(y))'/((x-mean(x))*(x-mean(x))');
        if pente_vaf <= 0.75*pente_surr;
            ind = ii-1;
            break;
        end
    end
    if VERBOSE
        fprintf('slope <= 0.75*slope surrogate(cheung et al.2005):\t %1.0f\n',ind);
    end
    Nb(1) = ind;
end

%-------------------------
% 2) VARIANCE FIXE
% vaf_ globale >0.9 et vaf_ muscle >0.75
% méthode sensible au bruit présent dans les données
if sum(METHODE==2)>0 
    for i = 1:length(vaf_)
        if vaf_(i)>0.9 && all(vafmuscle(i,:)>0.75)
            break;
        end
    end
    if VERBOSE
        fprintf('vaf_>0.9 & vaf_muscle >0.75:\t %1.0f\n',i);
    end
    Nb(2) = i;
end

 %-------------------------
 %3) COURBUR:  critère de CATELL (voir TRESCH 2006)
 if sum(METHODE==3)>0 
     % calcul des variations
     x = (0:length(vaf_));
     x_prime = d.vitesse(x,1);
     x_second = d.acceleration(x,1);
     s = [0 vaf_];
     s_prime = d.vitesse(s,1);
     s_second = d.acceleration(s,1);

     courbure = abs((x_prime.*s_second  -s_prime.*x_second)./((x_prime.^2 + s_prime.^2).^(2/3))) ;
     ind = find(courbure<0.075,1,'first');
     if isempty(ind)
       ind = 0;
     end
    if VERBOSE
        fprintf('critère de Catell (courbure <0.075):\t%1.0f\n',ind);
    end
    Nb(3) = ind;
     % plot des résultats
    %  figure(5)
    %  plot(ones(length(vaf_),1)*0.075,'r');title('courbure','fontsize',16);
    %  hold 'on';
    %  plot(0:length(vaf_),courbure,'g--');
 end
 
%-------------------------
%3) BLF (best linear fit)
if sum(METHODE==4)>0 
     n = length(vaf_);
     for i = 1:n-1
         % régression linéaire et calcul des résidus
         A= [(n-i:n)',ones(i+1,1)];
         res = A*((A'*A)\A')*vaf_(n-i:n)' - vaf_(n-i:n)';% res = Ax - y avec x =  inv(A'*A)A'b;
         SCE(i) = trace(res'*res)/(i+1);% la moyenne des écarts

    %      % plot des résultats
    %      ab = A\vaf_(n-i:n)';
    %      figure(4)
    %      subplot(2,1,1);hold 'on';
    %      plot(0:n,(0:n)*ab(1) +ab(2),'r');
     end
     SCE = flipud(SCE(:));
     ind = find(SCE<5E-5,1,'first');
     if isempty(ind)
       ind = 0;
     end
    if VERBOSE
     fprintf('best linear fit (SCE<5E-5) :\t%1.0f\n',ind);
    end
     Nb(4) = ind;
end

%  figure(4)
%  subplot(2,1,1)
%  plot(0:n,[0 vaf_]);title('BLF','fontsize',12);
%  subplot(2,1,2);plot(SCE);hold 'on';plot(5E-5*ones(length(SCE)),'r');
 
 % ---------------------------
  %7) Akaike criterion
 if sum(METHODE==5)>0 
    [xx ind] = min(AICc);
    delta_AICc = (AICc-xx);
    if VERBOSE
        fprintf('AICc (Akaike criterion):\t %1.0f \t (%3.3f) \t weight = %3.3f\n',ind,xx,exp(-0.5*delta_AICc(ind))/sum(exp(-0.5*delta_AICc)));
    end
    Nb(5) = ind;
 end
 
 
 
 
 
% détermination du nombre de synergies le plus probable
if VERBOSE
    if ~isempty(Nb)
        fprintf('----------------\n nombre de synergies le plus probable:\t%1.0f\n',round(mean(Nb)));
    end
end

% ajustement de VAF
%vaf_ = [0 vaf_ 1];
 
end
 
 
 
 
