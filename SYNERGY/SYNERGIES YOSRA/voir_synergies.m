function voir_synergies(t,WW,HH,n,nom_voies,length_cycle)

col = {'r' 'b' 'g' 'm' 'c' 'y' 'k'};
STD = [];
CI  = [];
CoA_ = [];
FROM_3D = 1;%from 3D matrix
if nargin <6
    length_cycle = [];
        if nargin <5
            nom_voies =  [];
            if nargin <4
                n = [];
            end
        end
end
if isempty(n)
    FROM_3D = 0;
    n       = size(WW,2);    
end
if isstruct(HH)
    STD    = HH(n).std;
    CI     = HH(n).inf;
    HH     = HH(n).mean;
    FROM_3D = 0;
end
l = size(WW,1);
m = size(HH,2);
if FROM_3D
    H = HH(1:n,:,n);
    W = WW(:,1:n,n);
else
    H = HH;
    W = WW;
end
if isempty(t)
    t = 0:(l-1);
end
if ~isempty(length_cycle)
    u = util();
    W = u.pattern_moyen(W,length_cycle);
    t = linspace(0,100,length_cycle);
    [CoA_ PoA SDoA] = COA(W);
    CoA_  = min(t)+CoA_*(max(t)-min(t));
    PoA  = min(t)+PoA*(max(t)-min(t));
    SDoA = SDoA*(max(t)-min(t));
end
if isempty(nom_voies)
    nom_voies = eval(['{' sprintf('''mus.%u'' ',1:m) '}']);
end

% AFFICHER LES WEIGHTINGS
    figure;
    ligne = floor(((1:n)+3)/4);  
    x_ = 1:m;
    for j =1:n
       subplot(4,max(ligne),j);
       bar(x_,H(j,:),'facecolor',col{mod(j-1,7)+1}); 
       hold 'on'
       if ~isempty(STD)
            errorbar(x_,H(j,:),STD(j,:),'linestyle','none',...
                'linewidth',2,'color',col{mod(j-1,7)+1})
            ind = CI(j,:)<0;
            bar(x_(ind),H(j,ind),'FaceColor',[1 1 1]*0.7);
            errorbar(x_(ind),H(j,ind),STD(j,ind),'linestyle','none','color',[1 1 1]*0.7)
       end
       title(sprintf('syn #%u',j));
       if j ==n
        set(gca,'Xtick',1:length(nom_voies),'XTickLabel',nom_voies);
       else
           set(gca,'XTickLabel',[]);
       end
       yl = get(gca,'ylim');
       set(gca,'ylim',[0 yl(2)],'xlim',[0.5 m+0.5],'TickDir','out');
       box off;          
    end
    
    % AFFICHER LES ACTIVATIONS
    figure();
    for j = 1:n
        subplot(max(ligne),4,j);
        plot(t,W(:,j),'LineWidth',2.5,'color',col{mod(j-1,7)+1});
        title(sprintf('syn #%u',j));
       
        box 'off'
        xlim([t(1) t(end)]);
        if ~isempty(CoA_)
           hold 'on'
           plot([CoA_(j) CoA_(j)],[1.05 1.05]*max(W(:,j)),'sk');
           plot([PoA(j) PoA(j)],[1.05 1.05]*max(W(:,j)),'+r');
           if CoA_(j)-1.96*SDoA(j)<0
               line([0 CoA_(j)+1.96*SDoA(j)],[1.05 1.05]*max(W(:,j)),'color','k');
               line([t(end)-(1.96*SDoA(j)-CoA_(j)) t(end)],[1.05 1.05]*max(W(:,j)),'color','k');
           else
               line([CoA_(j)-1.96*SDoA(j) CoA_(j)+1.96*SDoA(j)],[1.05 1.05]*max(W(:,j)),'color','k');
           end
        end
        yl(j,:) = get(gca,'ylim');
    end 
    yl = [min(yl(:,1)) max(yl(:,2))];
    for j = 1:n
        subplot(max(ligne),4,j);
        set(gca,'ylim',yl);
    end
end