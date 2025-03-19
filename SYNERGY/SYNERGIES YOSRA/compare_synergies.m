function [residuals p_values] = compare_synergies(H,H2,nom_muscles,AFFICHAGE)
% comparer les synergies (weights) H1 et H2
% détermine les muscles pour lesquels les poids sont significantivement
% différents
m     = size(H,2);
Nsyn  = size(H,1); 
if ~all(size(H2)==[Nsyn m])
    error('non compatible matrixes');
end
if nargin <4
    AFFICHAGE = 0;
    if nargin <3
        nom_muscles   = [];
    end
end
if isempty(nom_muscles)
    nom_muscles   = eval(['{' sprintf('''mus.%u'' ',1:m) '}']);
end

L = 20;
% calcul des résidus
residuals = [];
for k = 1:Nsyn   
    x = H(k,:);y = H2(k,:);
    try 
        temp      = robustfit(x,y,[],[],0);
        brob(k,:) = [0 temp];
    catch err
        disp(err.message)
        brob(k,:) = robust_fit(x,y,0);
    end
    residuals(k,:) = y-brob(k,2)*x-brob(k,1);
end
% condifence interval of the residuals
md  = mean(residuals(:));
sdd = std(residuals(:));
%compute p values
for k = 1:Nsyn
    for i = 1:length(x)
        Z = (residuals(k,i)-md)/sdd;
        p_values(k,i) = 2*(1-normcdf(abs(Z),0,1));
    end
end

if AFFICHAGE
    % affichage
    figure();
    x = [H(:);H2(:)];
    absc = linspace(min(x)-0.25*abs(min(x)-max(x)),max(x)+0.25*abs(min(x)-max(x)),L);
    for k = 1:Nsyn
        x = H(k,:);y = H2(k,:);

        % plotter les régressions
        subplot(2,Nsyn,k)
        scatter(x,y,'filled'); grid on; hold on;  
        plot(absc,brob(k,1)+brob(k,2)*absc,'g','LineWidth',2);
        for i = 1:m
            text(x(i),y(i),nom_muscles{i},'fontsize',9);
        end
        title(['synergie n°',num2str(k)]);
        xlim([absc(1) absc(end)]);
        ylim([absc(1) absc(end)]);
        set(gca,'fontsize',12);
        xlabel('weightings #1')
        ylabel('weightings #2')

        % plotter les résidus
        % ===================
        subplot(2,Nsyn,Nsyn+k);
        plot(x,residuals(k,:),'ko','MarkerFaceColor','k');hold 'on';
        xlabel('weightings #1')
        ylabel('residuals')
        plot(absc,[ones(L,1)*md,ones(L,1)*md+1.96*sdd,ones(L,1)*md-1.96*sdd],'-.k','linewidth',2);
        xlim([absc(1) absc(end)]);
        for i = 1:length(x)
            if p_values(k,i)<0.05
                text(x(i),residuals(k,i),nom_muscles{i},'fontsize',9,'color','r');
                plot(x(i),residuals(k,i),'ro','MarkerFaceColor','r')
            else
                text(x(i),residuals(k,i),nom_muscles{i},'fontsize',9,'color','b');
            end
        end
        set(gca,'fontsize',12);
    end
    
    % adjusted weights
    H2 = H + residuals; 

    figure();
    for k = 1:Nsyn
        subplot(Nsyn,1,k)
        bar([H(k,:)' H2(k,:)'],1);
        if k==1
            title('most different weightings (p<0.05)');
        end
        colormap gray;
        set(gca,'XGrid','on','Xtick',1:m,'XTickLabel',[]);
        box off;
        ylim([-0.1 1.2]);
        for i = 1:m
            if p_values(k,i)<0.05
                text(i,1,'*','fontsize',15,'color','r');
            end
        end
        xlim([0.5 m+0.5])
    end
    set(gca,'Xtick',1:length(nom_muscles),'XTickLabel',nom_muscles);
    legend({'fisrt entry','second entry (adj.)'});
    
end

end