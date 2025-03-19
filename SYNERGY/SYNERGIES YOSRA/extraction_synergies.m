%% extraction de synergies à partir d'une matrice E contenant les enveloppes EMG
% E est de dimension t x m, t le temps et m le nombre de muscle
clear; close all;

load('AP22_all_functionals_data.mat')
E = all_data_matrix';

longueur_cycle = 1000;

muscle = {'RDELTA', 'RDELTM', 'RDELTP', 'RTRAPM', 'RTRAPS', 'RSERRA'};
% muscle = {'LDELTA', 'LDELTM', 'LDELTP', 'LTRAPM', 'LTRAPS', 'LSERRA'};

%muscle = {'DELTA', 'DELTM', 'DELTP', 'TRAPM', 'TRAPS', 'SERRA'};

%================================
%           EXTRACTION
%================================
m              = size(E,2); % nombre de muscles
if ~exist('muscle','var')
    muscle         = eval(['{' sprintf('''mus.%u'' ',1:m) '}']);
end

% fonction principale "numsyn"
%  ---------------------------
[vaf vaf2 Nb WW HH] = numsyn(E);

% bootstrapping technique pour estimer la variabilité des synergies
% ---------------------------- 
[vaf_m vaf_sd ha r_val] = bootstrapvaf(E,longueur_cycle); 

% choix du nombre de synergies
% ----------------------------
N = 2;
%% ================================
%           VISUALISATION
% ================================
close all
% ----------- VAF --------------------
fig = figure();
p1 = plot(vaf_m,'o');
hold 'on'
% plot(vaf,'-or')
errorbar(1:length(vaf_m),vaf_m,1.96*vaf_sd);
p2 = plot(vaf_m(:)-1.96*vaf_sd(:),':','color',[1 1 1]*0.7);
     plot( vaf_m(:)+1.96*vaf_sd(:),':','color',[1 1 1]*0.7);
box off;
xlabel('# of synergy','fontsize',14);
ylabel('VAF(%)','fontsize',14);
line([0 m],[0.9 0.9],'color',[1 1 1]*0.7,'linestyle','--');
xlim([0.5 m+0.5])
annotation(fig,'arrow',0.1 + 0.8*[N N]/(m+1),[0.92 0.1+vaf(N)*0.8]);
legend([p1;p2],{'median vaf' '95% conf. int.'})
%% ---------- SYNERGIES ---------------
w = [];h = [];
w(:,:)  = WW(:,1:N,N);
h(:,:)  = HH(1:N,:,N);

VAF(E,w,h,'affichage','true');
VAFddl(E,w,h,'affichage','true');

voir_synergies([],w,h,[],muscle,longueur_cycle);
% voir les contributions de chaque synergy à chaque muscle
voir_contribution(E,w,h,longueur_cycle,muscle,true);



