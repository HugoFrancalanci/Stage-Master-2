function methods = EMG
%% EMG : listes de méthodes calculants les variables liées à l'EMG
%   spectre (temps,valeur) : permet a visualisation directe du signal et de
%   son  spectre
    methods = struct('spectre',@spectre,...
        'spectre2',@spectre2,...
        'spectre3',@spectre3,...
        'MPF',@MPF,...
        'moment_spectral',@moment_spectral,...
        'envelloppe',@envelloppe,...
        'mediane',@mediane,...
        'RMS',@RMS,...
        'var_emg',@var_emg,...
        'moyenne_mobile',@moyenne_mobile,...
        'fast_moyenne_mobile',@fast_moyenne_mobile,...
        'iEMG',@iEMG,...
        'fast_iEMG',@fast_iEMG,...
        'median_emg',@median_emg,...
        'coactivation',@coactivation,...
        'amarant',@amarant);




%%                   visualisation du spectre de fréquence
    function [frequency,s] = spectre(t,Y,option)
        % Si option = 'P', c'est le spectre de puissance qui est calculé.
        
        if length(t)==1
            fr = t;
            t = (0:max(size(Y))-1)/fr;
        else
            fr = 1/(t(2)-t(1));
        end
        frequency = 1/(t(length(t))-t(1))*(0:length(t)-1)';
        s = abs(fft(Y(:)));
        
        if nargin<3
            option = '';
        end
        
        if strcmp(option,'P')
            s = s.*conj(s);
            titre = 'Spectre de puissance';
        else
            titre = 'Spectre';
        end

        if nargout == 0
            figure('NumberTitle','off','Name','Analyse spectrale','units','normalized','position',[0.1 0.1 .8 .8]);
            subplot(2,1,1);
            plot(t,Y,'k');
            title('Signal','FontSize',15);xlabel('time (s)','FontSize',13);

            subplot(2,1,2);
            stem(frequency(1:int16(length(s)/2)),s(1:int16(length(s)/2)),'r','Marker','none');
            title(titre,'FontSize',15);xlabel('fréquence (Hz)','FontSize',13);ylabel('amplitude','FontSize',13);
            text(0.35*max(frequency),0.5*max(s),['fréquence médiane = ',num2str(mediane(t,Y)),'Hz'],'FontSize',11);
            text(0.35*max(frequency),0.4*max(s),['90 % de la puissance < ',num2str(mediane(t,Y,0.9)),' Hz'],'FontSize',11);
            text(0.35*max(frequency),0.3*max(s),['MPF : ',num2str(MPF(t,Y)),' Hz'],'FontSize',11);
            
        end
        frequency = frequency(1:int16(length(frequency)/2));
        s = s(1:int16(length(s)/2));
        
    end
%%
    function [coeff,F,G] = spectre2(t,s,frequences,onde)
        % transformation en ondelettes continues
        % t le temps
        % s : le signal
        % frequence : les fréquences à observer(défaut de 15 à 350 Hz)
        % onde : ondelette à utiliser (défaut :'morlet')
        
        % renvoie : 
        % coeff : les coeff pour chaque fréquence
        % F : les fréquences asoccié à chaque scaling coef
        % G : évolution de la MPF au cours du temps
        
        if nargin <3
            frequences = (15:350);
            onde = 'morl';
        end
        if nargin <4
            onde = 'morl';
        end
        if isempty(frequences)
             frequences = (15:350);
        end
            
            
        
        % ========
        % calculs
        % ========
        mp = MPF(t,s);
        
        dt = mean(diff(t)); % avoir la fréquence d'échantillonnage
        c_fr  = centfrq(onde);% fréquence d'une onde de morlet
        scale = c_fr./(frequences*dt);% avoir les coeffiscients pour les fréquences allant de 15 à 60 Hz
        F = scal2frq(scale,onde,dt);% obtenir les fréquence à partir des scaling coeff <=> 15:60
        F = F(:);
        coeff = cwt(s,scale,onde);
        S = abs(coeff.*coeff);
        S = 100*S./sum(S(:));% la puissance du signal normalisé
        
        fo = 1/(t(end)-t(1));% fourier
        fr = fo*(0:length(t)-1)';
        debut = floor(F(1)/fo);
        fin = floor(F(end)/fo);
        ss = (1/length(s))*abs(fft(s(:)));ss = ss.*conj(ss);ss = ss/max(ss);
        
        if nargout== 0% si on ne demande pas les valeur on affiche
            figure('NumberTitle','off','Name','Analyse spectrale','units','normalized','position',[0.1 0.1 .8 .8]);
        
            % =========
            % plots
            % =========
            subplot(4,4,[2 3 4 6 7 8 10 11 12]);imagesc(t,F,S);%colorbar;
            set(gca,'xtickLabel',[],'Ydir','normal');
            title(['MPF : ',num2str(mp),' Hz'],'fontsize',15);
        end
        % calculer et plotter l'évolution dans le temps de la MPF 
        SM = (S/max(S(:)))>0.01;% on peut enlever: met à zéro si amplitude trop faible
        S  = S.*SM;
        G =  sum(repmat(F,1,size(coeff,2)).*S)./sum(S);
        G(isnan(G))=0;
        if nargout==0
            hold 'on';plot(t,RMS(G,25,1),'--k','linewidth',3);
            limX = get(gca,'xlim');
            limY = get(gca,'ylim');
            
        
            % plotter les données EMGs
            subplot(4,4,[14 15 16]);plot(t,s,'k');set(gca,'xlim',limX); xlabel('temps(s)','fontsize',15);
        
            % mettre sur la gauche le spectre de fourier
            
            subplot(4,4,[1 5 9]);stem(fr(debut:fin),ss(debut:fin),'r','Marker','none');set(gca,'xlim',limY,'xdir','reverse');xlabel('fréquence (Hz)','fontsize',15);
            line([mp mp],[0 1],'color','k','linewidth',3,'linestyle','--');
            view([-90 -90]);
        end
        
    end
% ======================================
%   cohérence : comparaison des spectre de deux signaux
% ======================================
    function spectre3(t,Y)
        fr = 1/(t(length(t))-t(1))*(0:length(t)-1)';
        s = (1/size(Y,1))*abs(fft(Y));
        s1 = s(:,1).*conj(s(:,1));
        s2 = s(:,2).*conj(s(:,2));
        sxy = s(:,1).*conj(s(:,2));
        
        dt = mean(diff(t));
        lenwin = floor(200/dt); % longeur des fenètre d'analyse à 200 ms
        nbre = floor(length(t)/lenwin);
        if nbre < 8
          nbre=8;
        end
        disp(['Segments: ',num2str(floor(length(t)/lenwin)),', Segment length: ',num2str(lenwin),...
          ' sec,  Resolution: ',num2str(1/(lenwin*dt)),' Hz.']);
        
        %[Cxy,f] = cohere(Y(:,1),Y(:,2));
        [Cxy,f] = mscohere(zscore(Y(:,1)),zscore(Y(:,2)),nbre,[],128,1/dt);% pas d'overlaping
        %[ff,tt,cl]=sp2a2_m1(0,Y(:,1),Y(:,2),1/dt,2^3);%plot(ff(:,1),ff(:,4
        %)) pour l'autre cohérence (ne marche pas bien avec ces paramètres)
        
        % calcul de la phase relative grace à la transformation de
        % hilbert( on peut aussi utiliser une ondelette complexe spécifique qui
        % donne une version de la fonction complexe!!)
        A = hilbert(Y);% transformation de la fonction reelle en fonction complexe
        phase = unwrap(angle(A));% à partir de la valeur complexe  trouver l'angle (theta souvent et unwrapper pour assurer une continuité 
        
        figure('NumberTitle','off','Name','Analyse spectrale','units','normalized','position',[0.1 0.1 .8 .8]);
            subplot(3,2,1);
            plot(t,Y(:,1),'k');
            title('Signal 1','FontSize',15);xlabel('time (s)','FontSize',13);
            subplot(3,2,2);
            plot(t,Y(:,2),'k');
            title('Signal 2','FontSize',15);xlabel('time (s)','FontSize',13);
            subplot(3,3,4);
            stem(fr(1:floor(length(fr)/2)),s1(1:floor(length(s1)/2)),'r','Marker','none');
            title('spectre 1','FontSize',15);xlabel('fréquence (Hz)','FontSize',13);ylabel('amplitude','FontSize',13);
            subplot(3,3,6);
            stem(fr(1:floor(length(fr)/2)),s2(1:floor(length(s2)/2)),'r','Marker','none');
            title('spectre 2','FontSize',15);xlabel('fréquence (Hz)','FontSize',13);ylabel('amplitude','FontSize',13);
            subplot(3,3,5);
            stem(fr(1:floor(length(fr)/2)),sxy(1:floor(length(sxy)/2)),'r','Marker','none');
            title('cross spectrum','FontSize',15);xlabel('fréquence (Hz)','FontSize',13);ylabel('amplitude','FontSize',13);
            
            subplot(3,3,7);
            plot(f,Cxy,'r','Marker','diamond');
            title('cohérence','FontSize',15);xlabel('fréquence (Hz)','FontSize',13);ylabel('R²','FontSize',13);
            
            subplot(3,3,8);
            plot(t,ifft(sxy),'b');
            title('cumulant','FontSize',15);xlabel('temps(s)','FontSize',13);ylabel('R²','FontSize',13);
            
            subplot(3,3,9);
            plot(t,abs(phase(:,1)-phase(:,2)),'b');
%             title('phase','FontSize',15);xlabel('fréquence
%             (hz)','FontSize',13);ylabel('radian','FontSize',13);
            title('phase relative','FontSize',15);xlabel('time','FontSize',13);ylabel('radian','FontSize',13);
            
            
    end

%%
    function res = MPF(t,signal)
        % voir l'algorithme de A. Nordez : 
        % 'calculs_frequentiels_1fen.m'
        nbpts = length(t);
        ff=  fft(signal);
        DSP = ff.*conj(ff)/nbpts;
        fr = 1/(t(end)-t(1))*(0:nbpts-1)';
        ind = floor(nbpts/2)+1;
        somme = trapz(fr(1:ind+1),DSP(1:ind+1));
        DSP = DSP(:);fr = fr(:);
        somme1 = trapz(fr(1:ind+1),DSP(1:ind+1).*fr(1:ind+1)); 
        res = somme1/somme;
    end

%%                 Moments spectral d'ordre k
%   calcul 2*sum(fr^k*A(fr))
    function [moment_k] = moment_spectral(t,Y,k)
        N = length(t);
        fr = 1/(t(end)-t(1))*(0:N-1);
        s = (1/N)*abs(fft(Y));
        
        fr = fr(1:floor(N/2));
        s = s(1:floor(N/2));
        moment_k = sum((fr(:).^k).*s(:));
    end
%%                      envelloppe
% On va filtrer par un filtre butterworth ordre 4  fr_c = 2.03 Hz
% (voir Amarantini) 
    function [envlp]= envelloppe(fr_echant,X)
        %cd 'C:\Users\Turpin Nicolas\Documents\MATLAB\EMG';
        u = util();
        c = 2.03/fr_echant;
        envlp = u.filtre(2,2*1.247*c,'low',X);
    end

%%          fréquence médiane (sur signal entier)
% algorithme modifié de Nordez A (qui est biaisé car la somme se fait par
% intégration num et le cumulant par une somme classique)
    function [freq_mediane,irep] = mediane(t,data,p)
        if nargin <3
            p = 0.5;
        end
        % initialisation
        N= length(t);
        freq = 1/(t(end)-t(1))*(0:N-1);
        ff=fft(data,N);
        DSP=ff.*conj(ff)/N;
        somme=sum(DSP(1:(floor(N/2)+1)));
        DSP1=DSP./somme;
        DSP_cumul(1)=DSP1(1);
        for i=2:((N/2)+1)
            DSP_cumul(i)=DSP1(i)+DSP_cumul(i-1);
        end
        [xxx,irep]=min(abs(DSP_cumul-p));
        freq_mediane=freq(irep);
        
        if irep == 0
            error('erreur de calcul !');
        end
%         if nargout == 0
%             spectre(t,Y,type); hold 'on';
%             line([fr(index),fr(index)],[0,max(s)],'color','b');
%             text(fr(index),max(s)*0.5-min(s)*0.5,[denomination,num2str(freq_mediane),'hz']) ;
%         end
    end

%%       TRANSFORMATION DU SIGNAL (rms ; moyenne_mobile, iEMG, variance)
%%                  RMS
    function [rms] = RMS(s,T,lisse,ressampl)
         [s,nbre] = parTrois(s);
        %t = cputime;
           [nl,nc] = size(s);
           if nargin <3
               lisse = 0;% pour fenètres fixes (plus lissé)
               ressampl = 1;% option pour la normalisation sur x
                            % ressemplage ou moyennage
           end
           if nargin <4
               ressampl =1;
           end
        
           u = util();
           T = floor(T/2);
           s = s(:).^2;
           rms = zeros(length(s)-T,size(s,2));
           for i = 1:T
               rms = rms + s(i:end-T+i);
           end
           if lisse
             rms = u.normalisation(sqrt(rms(1:end)/(T)),length(s),ressampl);% <=> fenètre mobile
           else
             rms = u.normalisation(sqrt(rms(1:T:end)/(T)),length(s),ressampl);% <=> fenètre fixe
           end
           % reconstruire la matrice si c'en est une
           if min(nl,nc)~=1
               for i = 1:min(nl,nc)
                    E(:,i) = rms((i-1)*max(nl,nc)+1:i*max(nl,nc));
               end
               clear rms;rms=E;
           end
         %e = cputime-t;
         %disp(['CPU = ', num2str(e) ,' s']);
    end
%%                       moyenne mobile
    function res = moyenne_mobile(s,T)
        [s,nbre] = parTrois(s);
        
        poids = [];
        n= length(T);
        if n~= 1
            poids = T;
            T = n;
        end
        u = util();
        T = floor(T);
        N = size(s,1);
        if isempty(poids)
            poids= 1-abs(linspace(-1,1,T));
        end
        % x = linspece(-1,1,T);
        % poids = exp(-x.^2/2);
        y = zeros(N-T+1,size(s,2));
        for i = 1:T
            y = y + poids(i)*s(i:N-T+i,:);
        end
        y = y/sum(poids);
        
        % normalisation sur x
        x = linspace(T/2,N-T/2+1,size(y,1));
        for i = 1:size(y,2)
            res(:,i) = interp1(x,y(:,i),1:N,'splin');
        end
        res = res(nbre:end-nbre,:);
    end 
    function y = fast_moyenne_mobile(s,T)
        Thalf = floor(T/2); T = 2*Thalf + 1;
        s = amarant(s,Thalf);
        poids= 1-abs(linspace(-1,1,T));
        N = size(s,1);
        y = zeros(N,size(s,2));
        for i = 1:T
            y(Thalf+1:N-Thalf,:) = y(Thalf+1:N-Thalf,:) + poids(i)*s(i:N-T+i,:);
        end
        y = y(Thalf+1:end-Thalf,:)/sum(poids);
    end
%%                          moyenne mobile fenètre fixe
%     function yy = iEMG(s,T)
%         u = util();
%         yy = zeros(length(s)-T,1);
%         for i = 1:length(s)-T
%           yy(i) = trapz(abs(s(i:i+T)));
%         end
%         yy = u.normalisation(yy,length(s));
%     end 
    function res = iEMG(s,T)
        [s,nbre] = parTrois(abs(s));
        N =size(s,1);
        Thalf = floor(T/2); T = 2*Thalf + 1;
        y = 0.5*abs(s(1:end-T+1,:));
        for i = 2:T-1
            y = y + abs(s(i:end-T+i,:));
        end
        y= y+0.5*abs(s(T:end,:));
        % normalisation sur x
        x = linspace(Thalf+1,N-Thalf,size(y,1));
        for i = 1:size(y,2)
            res(:,i) = interp1(x,y(:,i),1:N,'splin');
        end
        res = res(nbre:end-nbre,:);
    end
    function y = fast_iEMG(s,T)
        Thalf = floor(T/2); T = 2*Thalf + 1;
        s = amarant(s,Thalf);
        y = 0.5*abs(s(1:end-T+1,:));
        for i = 2:T-1
            y = y + abs(s(i:end-T+i,:));
        end
        y= y+0.5*abs(s(T:end,:));
        %res = y(Thalf+1:end-Thalf);
    end
       
%%               Variance instantanée normalisée
% fonction utile pour les ONSET détection
    function res = var_emg(s,T)
        lorigine = size(s,1);
        [s,nbre] = parTrois(s); 
        
        L = size(s,1);
        S_carre = zeros(L-T+1,size(s,2));
        carre_S = zeros(L-T+1,size(s,2));
        for i = 1:T
            S_carre = S_carre + s(i:end-T+i,:).^2;% la somme des carrés
            carre_S = carre_S + s(i:end-T+i,:);   % on fait la somme qu'on mettra au carré
        end
        y = (S_carre-(carre_S/T).^2)/(T-1);
        % normalisation sur x
        x = linspace(T/2,L-T/2+1,size(y,1));
        for i = 1:size(y,2)
            res(:,i) = interp1(x,y(:,i),1:L,'splin');
        end
        res  = res(nbre:end-nbre,:);
       
    end
%% courbe de la médiane
    function res = median_emg(s,T)
        [s,nbre] = parTrois(s);
        
        u = util();
        T = floor(T);
        N = size(s,1);
        y = [];
        for i = 1:T
            y(:,:,i) = s(i:end-T+i,:);
        end
        y = median(y,3);
        % normalisation sur x
        x = linspace(T/2,N-T/2+1,size(y,1));
        for i = 1:size(y,2)
            res(:,i) = interp1(x,y(:,i),1:N,'splin');
        end
        res  = res(nbre:end-nbre,:);
    end

%%              calcul de la coactivation rms1.*rms2
    function y = coactivation(s1,s2,T)
        % sur RMS normalisé 
        s1 = iEMG(s1,T);%s1 = s1./max(s1);
        s2 = iEMG(s2,T);%s2 = s2./max(s2);
        %subplot(3,1,1);
        %plot([s1 s2]);
        y = s1(:).*s2(:);
        %subplot(3,1,2:3);
        %plot(y,'r');
    end


    function [y,nbre_pts] = parTrois(X)
        opt = 0.15;
        N = size(X,1);
        nbre_pts = floor(opt*N);
        origine1 = mean(X(1:floor(opt*N/4),:));% X(1)
        origine2 = mean(X(end-floor(opt*N/4):end,:));% X(end)
        y = [bsxfun(@plus,-flipud(X(1:nbre_pts,:)),2*origine1);...
             X(2:end-1,:);...
             bsxfun(@plus,-flipud(X(end-nbre_pts:end,:)),+2*origine2)];
    end
    function [y] = amarant(X,N)
        % procédure d'amarantni simplifiée
        y = [bsxfun(@plus,-flipud(X(2:N+1,:)),2*X(1,:));...
             X(1:end,:);...
             bsxfun(@plus,-flipud(X(end-N:end-1,:)),2*X(end,:))];
    end



        
        

        
    


end