
% Mars 2018 Script modifié pour comparer 3 conditions - deux à deux

% script d'exemple pour la comparaison de synergies provenant de deux
% conditions différentes
% Pour comparer les synergies:
% 0) extraires les synergies et déterminer leurs nombres, les matrices
%   initiales (enveloppes) doivent être nommées E1 et E2 pour utilser ce
%   script
% 1) comparer directement les 'synergy vectors" via correlations
% 2) utiliser la cross-validation pour tester la similarité des "subspaces"
%    => mesure globale - toutes les synergies en même temps; 
%     c'est un test moins sensibles aux 'petites' différences
% 3) identifier les muscles qui varient le plus entre les deux conditions
%   => uniquement si des différences ont été démontrées aux étapes 1 et 2
%      sinon l'interval de confiance est construit sur des différences petites
%      et peut montrer des différences qui nen sont pas
%% loader des exemples (CTRL + ENTER)
% matrices d'EMG obtenues en aviron sur un sujet expert
% IMPORTANT:
% les EMGs ont été normalisés par les mêmes valeurs dans les deux conditions
clear all
% addpath \\10.89.24.15\e\Bureau\Yosra\Yosra-Maryam\Data_Adults\EMG;
path='F:\Projet Synergie musculaire\Lokomat_Adults\Data_Adults\EMG\';
subject='FabienD';
file_names=dir([path subject '\results_*']);
for i=1:size(file_names,1)
    results{i}=load([path subject '\' file_names(i).name]);
end

%% load muscle.mat
% on a ajouter des conditions pour les sujets ou le GM ou le SOL ne
% fonctionnaient pas...
%FAIRE ATTETION POUR CHANGER LA CONDITION VOULUE

subjects_GM= {'AnnieP'; 'ColombeB'; 'DianeH'; 'EvelyneD'};
subjects_SOL= {'BenjaminG'; 'EmilieD'; 'GuillaumeG'; 'YoannB'};
if any(strcmp(subjects_GM,subject))  
for i=7:9   %changer en fonction des conditions 1:3, 4:6, 7:9 etc
    E{1, i}=results{1, i}.Data.EMG_concat(:,[1:4,6]);
end
elseif  any(strcmp(subjects_SOL,subject))
   for i=7:9   %changer en fonction des conditions 1:3, 4:6, 7:9 etc
    E{1, i}=results{1, i}.Data.EMG_concat(:,[1:3,5:6]);
   end 
else
    for i=7:9  %changer en fonction des conditions 1:3, 4:6, 7:9 etc
    E{1, i}=results{1, i}.Data.EMG_concat;
end
end

E=E(1,7:9);
if any(strcmp(subjects_GM,subject))     
    muscle= {'RF' 'VM' 'ST' 'GM' 'TA'};
elseif any(strcmp(subjects_SOL,subject))    %exist(subject,Subjects_GM); 
    muscle= {'RF' 'VM' 'ST' 'GM' 'SOL'};
else
    muscle= {'RF' 'VM' 'ST' 'GM' 'SOL' 'TA'};
end


longueur_cycle = 500;
%%   0) EXTRAIRES LES SYNERGIES ET DÉTERMINER LEURS NOMBRES
m                 = size(E{1, 1},2); % nombre de muscles
if ~exist('muscle','var')vaf
    muscle         = eval(['{' sprintf('''mus.%u'' ',1:m) '}']);
end
if ~exist('longueur_cycle','var')
    longueur_cycle = [];
end

% extraires les synergies dans les conditions séparément

for i=1:3 %% changer 1:3 4:6 et 7:9 en fonction de la condition voulue 10 est la marche sur sol 
%    fprintf('--------- CONDITION 1 -----------\n')
   [condition{1, i}.vaf condition{1, i}.xxx condition{1, i}.Nb condition{1, i}.WW condition{1, i}.HH] = numsyn(E{1, i});
   [condition{1, i}.vaf_m condition{1, i}.vaf_sd] = bootstrapvaf(E{1, i},longueur_cycle);
   condition{1, i}.N  =  round(mean(condition{1, i}.Nb));
end

% Etape de verification 
prompt='enter the matrix of N';
N=input(prompt);
comparisons=[1 2 3 1];

% RENTRER UNE MATRICE DES N (Nombre de syn) pour chaue condition [X Y Z]
for i=1:length(comparisons)-1
  if N(comparisons(i))~=N(comparisons(i+1));
    fprintf(['nombre de synergie différent a priori\n',...
            'vérifier si la variance est distribuée différemment\n',...
             'ou si la différence est réelle\n']);
   end
end
%% ----------- VAF --------------------
colorset={'b','g','r'};
y_loc=[0.99,1.1,1.2];
fig = figure();

for i=1:3;
   h1(i)=plot((1:length(condition{1, i}.vaf_m))-0.1,[condition{1, i}.vaf_m(:)]','o','color',colorset{i});
   hold 'on'
   h2(i)=errorbar((1:length(condition{1, i}.vaf_m))-0.1,condition{1, i}.vaf_m,1.96*condition{1, i}.vaf_sd,'color',colorset{i});
   annotation('arrow',0.1 + 0.8*[N(i) N(i)]/(m+1),[0.90 0.1+condition{1, i}.vaf_m(N(i))*0.75],...
           'color',colorset{i});
end
legend(h1,{'cond.1','cond.2','cond.3'});

 for i=1:length(comparisons)-1
    significant{i} = condition{1, comparisons(i)}.vaf_m-1.96*condition{1, comparisons(i)}.vaf_sd>condition{1, comparisons(i+1)}.vaf_m+1.96*condition{1, comparisons(i+1)}.vaf_sd | ...
              condition{1, comparisons(i+1)}.vaf_m-1.96*condition{1, comparisons(i+1)}.vaf_sd>condition{1, comparisons(i)}.vaf_m+1.96*condition{1, comparisons(i)}.vaf_sd;
 
for k = 1:length(significant{i})
    
    if significant{i}(k)
         text(k,y_loc(i),'*','fontsize',12,'color',colorset{i});
         hold on
    end
end

end

box off;
xlabel('# of synergy','fontsize',14);
ylabel('VAF(%)','fontsize',14);
line([0 m],[0.9 0.9],'color',[1 1 1]*0.7,'linestyle','--');
xlim([0.5 m+0.5])
% saveas(fig,sprintf('VAF.jpeg',k),); % will create FIG1, FIG2,...

 % SAUVEGADER VAF
 
%%
% calculer le r critique pour définir la similarité obtenue par chance
% --------------------------

[R_critic{1,1} R Rsub_critic{1,1} R2{1,1}] = randomized_r([N(1),m]);
[R_critic{1,2} R Rsub_critic{1,2} R2{1,2}] = randomized_r([N(1),m]);
[R_critic{1,3} R Rsub_critic{1,3} R2{1,3}] = randomized_r([N(2),m]);

%%
% ---------- VISUALISATION ---------------
for i=1:3
   close all
   condition{1,i}.w = [];condition{1,i}.h = [];
   condition{1,i}.w(:,:)  = condition{1,i}.WW(:,1:N(i),N(i));
   condition{1,i}.h(:,:)  = condition{1,i}.HH(1:N(i),:,N(i));
end

% Lire en litterature quel nombre de synergie prendre si on compare plusieurs comparaison  
%  for i=1:length(comparisons)-1
%      % permutation pour faire correspondre les synergies
%      if N(comparisons(i))>=N(comparisons(i+1))
%          perm = permutation_matrice(condition{1,comparisons(i+1)}.h',condition{1,comparisons(i)}.h'); % matrice de permutation
%          condition{1,comparisons(i+1)}.h = perm'*condition{1,comparisons(i+1)}.h;                      % transformations
%          condition{1,comparisons(i+1)}.w = condition{1,comparisons(i+1)}.w*perm;
%      else
%         perm = permutation_matrice(condition{1,comparisons(i)}.h',condition{1,comparisons(i+1)}.h'); % matrice de permutation
%         condition{1,comparisons(i)}.h = perm'*condition{1,comparisons(i)}.h;                      % transformations
%         condition{1,comparisons(i)}.w = condition{1,comparisons(i)}.w*perm;
%      end
%    
%  end

save_path=[path subject '\'];
newSubFolder = sprintf('%s','result_fig');
cd(save_path)
% Finally, create the folder if it doesn't exist already.
if ~exist(newSubFolder, 'dir')
  mkdir(newSubFolder);
end
save_path=[save_path newSubFolder '\'];
filename={'BW30_Guid30';'BW30_Guid50';'BW30_Guid70'};

 for i=1:3
     voir_synergies([],condition{1,i}.w,condition{1,i}.h,[],muscle,longueur_cycle);
%       filename = sprintf('%s%02d.jpeg','visual_synergy',i);
       print([save_path filename{i}], '-djpeg')
       print([save_path filename{i}], '-djpeg')
 end

%%%% Ajouter manuellement si on a plus de conditions 
fprintf('--------- CONDITION 1 -----------\n')
VAF(E{1,1},condition{1,1}.w,condition{1,1}.h,'affichage','true');
VAFddl(E{1,1},condition{1,1}.w,condition{1,1}.h,'affichage','true');
fprintf('--------- CONDITION 2 -----------\n')
VAF(E{1,2},condition{1,2}.w,condition{1,2}.h,'affichage','true');
VAFddl(E{1,2},condition{1,2}.w,condition{1,2}.h,'affichage','true');
fprintf('--------- CONDITION 3 -----------\n')
VAF(E{1,3},condition{1,3}.w,condition{1,3}.h,'affichage','true');
VAFddl(E{1,3},condition{1,3}.w,condition{1,3}.h,'affichage','true');
%% 1) COMPARER DIRECTEMENT LES 'SYNERGY VECTORS" VIA CORRELATIONS
counter=1;
for i=1:length(comparisons)-1
   [r{1,i},p{1,i},theta{1,i},r_tot{1,i}]=...
       stat_corelation(condition{1,comparisons(i)}.h,condition{1,comparisons(i+1)}.h,...
       N(comparisons(i)),N(comparisons(i+1)),R2{1,i},Rsub_critic{1,i},R_critic{1,i},muscle,m);

%% 2) UTILISER LA CROSS-VALIDATION POUR TESTER LA SIMILARITÉ DES SUBSPACES
%   = intra vs. inter group comparison (cross-validation)
% la méthode est basée sur du bootstapping et donne des résultats
% différents à chaque fois que la méthode est utilisée
% une différence >5% peut être considérée comme importante
% --------------------------------------------
 [IA{1,i} IR{1,i} IAm{1,i} IRm{1,i} stat{1,i}] = ...
     iicrossvalidation(E{comparisons(i)},E{comparisons(i+1)},min(N(comparisons(i)),N(comparisons(i+1))),muscle,true);

%% 3) IDENTIFIER LES MUSCLES QUI VARIENT LE PLUS ENTRE LES DEUX CONDITIONS
% à utiliser uniquement si des différences significatives sont observées 
% dans les tests ci dessus
% l'analyse peut s'
% pv = les p-values pour les weightings de chaque synergie (ligne) et 
% chaque muscle (colonne)
%
% --------------------------------------------
[residuals{1,i} pv{1,i}] = compare_synergies(condition{1,comparisons(i)}.h,condition{1,comparisons(i+1)}.h,muscle,true);
end
%%  ANNEXE: comparer les contributions relatives
%  les contributions sont variables et dépendent de l'activation des
%  synergies, peut être une analyse interressante pour une analyse muscle
%  par muscle...mais les résultats sont très variables
[contr{1,1} res{1,1}]   = voir_contribution(E{1,1},condition{1,1}.w,condition{1,1}.h,longueur_cycle,muscle);
[contr{1,2} res{1,2}] = voir_contribution(E{1,2},condition{1,2}.w,condition{1,2}.h,longueur_cycle,muscle);
[contr{1,3} res{1,3}] = voir_contribution(E{1,3},condition{1,3}.w,condition{1,3}.h,longueur_cycle,muscle);
%%
if ~isempty(longueur_cycle)
    nbcycle(1) =  floor(size(E{1,1},1)/longueur_cycle);
    nbcycle(2) =  floor(size(E{1,2},1)/longueur_cycle);
    nbcycle(3) = floor(size(E{1,3},1)/longueur_cycle);
else
    nbcycle(1) =  1;
    nbcycle(2) =  1;
    nbcycle(3) =  1;
end


for i=1:length(comparisons)-1
    figure();
for k = 1:max(N(comparisons(i)),N(comparisons(i+1)))
    subplot(max(N(comparisons(i)),N(comparisons(i+1))),10,(k-1)*10+1:(k-1)*10+8)
    bar([contr{1,comparisons(i)}(k,:)' contr{1,comparisons(i+1)}(k,:)'],1);
    if nbcycle(comparisons(i))>1 && nbcycle(comparisons(i+1))>1
        hold 'on';
        SD{1,comparisons(i)}(:,:)  = std(res{1,comparisons(i)}(k,:,:),[],3);
        SD{1,comparisons(i+1)}(:,:) = std(res{1,comparisons(i+1)}(k,:,:),[],3);
        errorbar((1:m)-0.125,contr{1,comparisons(i)}(k,:),SD{1,comparisons(i)},'linestyle','none',...
                'linewidth',1,'color','k')
        errorbar((1:m)+0.125,contr{1,comparisons(i+1)}(k,:),SD{1,comparisons(i+1)},'linestyle','none',...
                'linewidth',1,'color','k')
        % test stat
        for j= 1:m
            temp{1,comparisons(i)}(:,:) = res{1,comparisons(i)}(k,j,:);
            temp{1,comparisons(i+1)}(:,:) = res{1,comparisons(i+1)}(k,j,:);
            p{1,i} = ranksum(temp{1,comparisons(i)}(:),temp{1,comparisons(i+1)}(:));
            % critère d'une contribution significativement différente
            % diff > 10% & statistiqument différent (bonferroni correction)
            if p{1,i}<(0.05/(m*N(i))) && abs(contr{1,comparisons(i)}(k,j)-contr{1,comparisons(i+1)}(k,j))>0.1
                text(j,1.1,'*','fontsize',15,'color','r');
            end
        end
    end
    colormap gray;
    set(gca,'XGrid','on','Xtick',1:m,'XTickLabel',[],'TickDir','out');
    box off;
    if k ==1
        title('contribution de chaque synergie à chaque muscle (en %)');
    end
    xlim([0.5 m+0.5])
    ylim([0 1.2]);
    
    % contribution totale
    if nbcycle(comparisons(i))>1 && nbcycle(comparisons(i+1))>1
        subplot(max(N(comparisons(i)),N(comparisons(i+1))),10,(k-1)*10+9:k*10);
        m_contr{1,comparisons(i)}  = mean(mean(res{1,comparisons(i)}(k,:,:),2),3);
        sd_contr{1,comparisons(i)} = std(mean(res{1,comparisons(i)}(k,:,:),2),[],3);

        m_contr{1,comparisons(i+1)}  = mean(mean(res{1,comparisons(i+1)}(k,:,:),2),3);
        sd_contr{1,comparisons(i+1)} = std(mean(res{1,comparisons(i+1)}(k,:,:),2),[],3);
       
        bar(1,m_contr{1,comparisons(i)},'facecolor','k');hold 'on';
        bar(2,m_contr{1,comparisons(i+1)},'facecolor','w')
        errorbar(1:2,[m_contr{1,comparisons(i)} m_contr{1,comparisons(i+1)}],...
            [sd_contr{1,comparisons(i)} sd_contr{1,comparisons(i+1)}],...
                'linestyle','none',...
                'linewidth',1,'color','k');
        set(gca,'XGrid','on','Xtick',1:2,'XTickLabel',[],'yticklabel',[],...
            'TickDir','out');
        box off;
        xlim([0.5 2.5])
        ylim([0 1.2]);
        if k==1
            title('mean contr.','fontsize',10);
        end
        % stats
        temp{1,comparisons(i)} = [];temp{1,comparisons(i)} = mean(res{1,comparisons(i)}(k,:,:),2);
        temp{1,comparisons(i+1)} = [];temp{1,comparisons(i+1)} = mean(res{1,comparisons(i+1)}(k,:,:),2);
        [xxx{1,i} p1{1,i}] = ttest2(temp{1,comparisons(i)}(:),temp{1,comparisons(i+1)}(:));
        if p1{1,i}<(0.05)
            text(1.5,1.1,'*','fontsize',15,'color','r');
        end
        text(1.1,1,sprintf('p=%1.3f',p1{1,i}),'fontsize',11,'color','k');
    end
end
subplot(max(N(comparisons(i)),N(comparisons(i+1))),10,(k-1)*10+1:(k-1)*10+8);
set(gca,'Xtick',1:length(muscle),'XTickLabel',muscle);
legend({'cond.1','cond.2'});
end

%% Sauvegarder les figures de résultas 
% IMPORTANT: Changer le nom des fichiers en fonction de la condition testée

figname={'Mucle_Cont_BW30_Guid30';'nSynergy_BW30_Guid30';'Mucle_Cont_BW30_Guid50';'nSynergy_BW30_Guid50';'Mucle_Cont_BW30_Guid70';'nSynergy_BW30_Guid70';...
    'Crossvalidation_BW30_Guid30-BW30_Guid50';'ComparaisonSyn_BW30_Guid30-BW30_Guid50';'Temp1'; 'Weighting_BW30_Guid30';...
    'Crossvalidation_BW30_Guid50-BW30_Guid70';'ComparaisonSyn_BW30_Guid50-BW30_Guid70';'Temp2'; 'Weighting_BW30_Guid50';...
    'Crossvalidation_BW30_Guid30-BW30_Guid70';'ComparaisonSyn_BW30_Guid30-BW30_Guid70'; 'Temp3';'Weighting_BW30_Guid70';...
    'Contribution chaque synergie par muscle_BW30_Guid30';'Contribution chaque synergie par muscle2_BW30_Guid30';...
    'Contribution chaque synergie par muscle_BW30_Guid50';'Contribution chaque synergie par muscle2_BW30_Guid50';...
    'Contribution chaque synergie par muscle_BW30_Guid70';'Contribution chaque synergie par muscle2_BW30_Guid70';...
    'ComparaisonCont_BW30_Guid30-BW30_Guid30'; 'ComparaisonCont_BW30_Guid30-BW30_Guid50'; 'ComparaisonCont_BW30_Guid30-BW30_Guid70'};
for i = 1:24
      fig = figure(i);
      % Output the figure
     filename = sprintf('%s.jpeg', figname{i});
     print([save_path filename], '-djpeg');
end

%%
% filename={'BW30_Guid30';'BW30_Guid50';'BW30_Guid70'};

% 
%     files = dir( fullfile(save_path,'*tif') );  %list all figure files
%     file = {files.name};
%     name=file{:,end};
%     shortname1=name(1:6);%extract 'figure' from the file to make sure it's of the same kind
%     if shortname1=='figure'
%     shortname2=name(1:end-4);%find the number of file
%     n=str2num(shortname2(end));%returns the number of the file 
% n=3;   
% i=1;  % to access the ith element of figures
%   for k=1:n%(n+1):(n+numel(figures))
%     baseFileName = sprintf('figure_%s.tif',filename(k));
%     fullFileName = fullfile(save_path,baseFileName);
%     saveas(figure(i),fullFileName); 
%     i = i+1; % increment
%  end

    
