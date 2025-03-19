function [INTRA INTER INTRA_muscle INTER_muscle stat] = iicrossvalidation(E1,E2,N,nom_muscle,AFFICHAGE)
% intra vs inter cross validation
K  = 20  ;%nombre d'itérations total = K*K2
K2 = 10;


m = size(E1,2);
if nargin <5 
    AFFICHAGE = false;
    if nargin <4     
        nom_muscle = [];
    end
end
if isempty(nom_muscle)
    nom_muscle = eval(['{' sprintf('''mus.%u'' ',1:m) '}']);
end
 Z  = @(x) 0.5*log((1+x)./(1-x));
 n1  = size(E1,1);
 n2  = size(E2,1);
 l1  = floor(0.5*n1);
 l2  = floor(0.5*n2);
 
 n = 1;
INTRA = [];
INTER = [];
 wb = waitbar(0,' bootstrapping...');
 for s1_ = 1:K2
     % dataset d'extraction
     ind   = randperm(n1);
     ind2  = randperm(n2); 
     data1  = E1(ind(1:l1),:);
     %data2  = E2(ind2(1:l2),:);  
      % dataset tests
     data1c  = E1(ind(l1+1:end),:); 
     data2c  = E2(ind2(l2+1:end),:); 

     [W1 H1] = lee_seung(data1,N);
         % extraction ds data1
    %bootstapping
    
    for s2_ = 1:K       
        %ind    = ceil(rand(l1,1)*(l1-1) + 1);
        ind1c  = ceil(rand(n1-l1,1)*(n1-l1-1) + 1);
        %ind2   = ceil(rand(l2,1)*(l2-1) + 1);
        ind2c  = ceil(rand(n2-l2,1)*(n2-l2-1) + 1);

        %[W1 H2] = lee_seung(data2(ind2,:),N);

        % data tests avec remplacement
        data1_      = data1c(ind1c,:);
        data2_      = data2c(ind2c,:);

        %INTER
        % H1 => data 2c
        W           = lee_seung_W(data2_,H1,'nbre_iter',1);
        err         = data2_- W*H1;
        INTER(n,1)  = 1 - sum(err(:).^2)/sum(data2_(:).^2);
        INTER_muscle(n,:) = 1 - sum(err.^2)./sum(data2_.^2);

    %     W           = lee_seung_W(data1_,H2,'nbre_iter',1);
    %     err         = data1_- W*H2;
    %     INTER(n,2)  = 1 - sum(err(:).^2)/sum(data1_(:).^2);
    %     INTER_muscle(n,:) = 1 - sum(err.^2)./sum(data1_.^2);


        %INTRA
        % H1 => data1c
        W           = lee_seung_W(data1_,H1,'nbre_iter',1);
        err         = data1_- W*H1;
        INTRA(n,1)  = 1 - sum(err(:).^2)/sum(data1_(:).^2);
        INTRA_muscle(n,:) = 1 - sum(err.^2)./sum(data1_.^2);

    %     W           = lee_seung_W(data2_,H2,'nbre_iter',1);
    %     err         = data2_- W*H2;
    %     INTRA(n,2)  = 1 - sum(err(:).^2)/sum(data2_(:).^2);
    %     INTRA_muscle(n,:) = 1 - sum(err.^2)./sum(data2_.^2);

        waitbar(n/(K*K2),wb,'bootstrapping..'); 
        n = n+1;
    end
 end
 close(wb);
 %%
 % correction terms
  ddl1 = (n1-l1-1)/(m);
  ddl2 = (n2-l2-1)/(m);
  % statistics
    dvaf = mean(INTRA(:)) - mean(INTER(:));
    Z1 = Z(INTRA(:));
    Z2 = Z(INTER(:));
    T  = abs((mean(Z1)-mean(Z2)))/sqrt(0.5*var(Z1)*(ddl1)+0.5*var(Z2)*(ddl2));
    p  = 2*(1-normcdf(T));
    stat.diff = dvaf;
    stat.Z = T;
    stat.p = p;
    
 if AFFICHAGE
     figure();
     bar(1:2,mean([INTRA(:) INTER(:)]),'k','barwidth',0.5);
     hold 'on';
     errorbar(1:2,mean([INTRA(:) INTER(:)]),[sqrt(ddl1)*std(INTRA(:)) sqrt(ddl2)*std(INTER(:))],...
         'linestyle','none','linewidth',2,'color','k')
     xlim([0.5 2.5]);ylim([0 1.1])
    set(gca,'fontsize',18,'Xticklabel','','Ytick',[0:0.2:0.8 0.9 1],'YGrid','on',...
        'xticklabel',{'intra' 'inter'},'TickDir','out');
    ylabel('total VAF(%)')
    box off;   
    if p<0.05
        col = 'r';
    else
        col = 'k';
    end
    line([1 2],[1.05 1.05],'color','k')
    text(1,1.1,sprintf('différence = %3.1f%% (p = %1.3f)',dvaf*100,p),...
               'fontsize',12,'color',col);
% =========================================================================   
%     figure();
%     % vaf pour chaque muscle
% %     ddl1 = ddl1*m;
% %     ddl2 = ddl2*m;
%     mintram = mean(INTRA_muscle);
%     minterm = mean(INTER_muscle);
%     bar(1:m,[mintram' minterm'],1);
%     hold 'on';
%     errorbar((1:m)-0.125,mean(INTRA_muscle),...
%                 sqrt(ddl1)*std(INTRA_muscle),...
%          'linestyle','none','linewidth',1.5,'color','k')
%     errorbar((1:m)+0.125,mean(INTER_muscle),...
%                 sqrt(ddl2)*std(INTER_muscle),...
%          'linestyle','none','linewidth',2,'color','k')
%     legend({'intra-group' 'inter-group'})
%     colormap gray;
%     set(gca,'Ygrid','on','Xtick',1:m,'XTickLabel',nom_muscle,...
%         'fontsize',12);
%     for k = 1:m
%         d = mintram(k) - minterm(k);
%         Z1 = Z(INTRA_muscle(:,k));
%         Z2 = Z(INTER_muscle(:,k));
%         T = abs((mean(Z1)-mean(Z2)))/sqrt(0.5*var(Z1)*(ddl1)+0.5*var(Z2)*(ddl2));
%         p = 2*(1-normcdf(T));
%         if p<0.05
%             col = 'r';
%         else
%             col = 'k';
%         end
%         text(k,max(mintram(k),minterm(k))+0.2,...
%             sprintf('%2.1f%%\np=%1.3f',d*100,p),'fontsize',9,...
%             'color',col);
%     end
%     ylabel('VAF(%)')
%     box off;
%     xlim([0.5 m+0.5])
%     ylim([0 1.2]);
%     
 
 end
 
 % rendre les résultats
 % =====================
 INTRA        = mean(INTRA);
 INTER        = mean(INTER);
 INTRA_muscle = mean(INTRA_muscle);
 INTER_muscle = mean(INTER_muscle);
 