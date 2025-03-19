function [fig MEMOIRE xxx] = tracer_correlation_(x,y,option,col,monstyle,limx,limy,fig,indice_des_points,indice_du_muscle,type,group)
% fonction basique pour plotter des corrélations

 % IL FAUT QUE LES DONNEES SOIENT DANS LA FIGURE SET(gcf,'data',MEMOIRE)
 % pour pouvoir updater de cette  manière
% if isstruct(x)
%     % c'est un update avec
%     MEMOIRE = x;
%     % modifier l'indice
%     current = length(MEMOIRE)+1;% à terminer
%     
%     % les entrées suivantes sont x et y 
%     MEMOIRE(current).x(length(MEMOIRE(current-1).x)+1) = y;
%     MEMOIRE(current).y(length(MEMOIRE(current-1).y)+1) = option;
%     
%     affichage();
%     return;
% end 
if nargin <12
    group = ones(length(x),1);
    if nargin <11
        type = 'mag';
        if nargin<10
            indice_du_muscle = 1;
            if nargin<9
                indice_des_points = [];
                if nargin <8
                    fig  = [];
                    if nargin <7
                        limy = [min(y) max(y)];
                        if nargin <6
                            limx = [min(x) max(x)];
                             monstyle = 'o';
                             if nargin <4
                                 col = {'w' 'r' 'g' 'b' 'k'};
                                 if nargin <3
                                     option = 'ortho_r';
                                 end
                            end
                        end
                    end
                end
            end
        end
    end
end
if isempty(limx)
    limx =[min(x) max(x)];
end
if isempty(limy)
    limy = [min(y) max(y)];
end
if isempty(col)
    col = {'w' 'r' 'g' 'b' 'k'};
end
if ~iscell(col)
    col = {col};
end
if isempty(monstyle)
    monstyle = 'o';
end
if isempty(option)
    option = 'ortho_r';
end

% initial values
DELETEpt  = 0;
current = 1;
IND = ~isnan(x) & abs(x)~=Inf & ~isnan(y) & abs(y)~=Inf;
index = true(1,length(x));
x = x(IND);
y = y(IND);
group(~IND) = 0;
index(~IND) = 0;

DISPLAY_STATS = 0;
MEMOIRE(current).x  = x;
MEMOIRE(current).y  = y;
MEMOIRE(current).index  = index;
MEMOIRE(current).group  = group;

MEMOIRE(1).xlim = limx;
MEMOIRE(1).ylim = limy;
%====================================
% créer la figure et le menu spécial
fig_ = NaN;
if isempty(fig)
    fig = figure('WindowButtonDownFcn',  @f_current_pt,...
                  'name','Correlations');
else
    set(fig,'WindowButtonDownFcn',  @f_current_pt,...
                  'name','Correlations');
end    

menu_principal = uimenu(fig,'Label','Settings');
uimenu(menu_principal,'Label','Change Sign ','Callback',@change_sign);
uimenu(menu_principal,'Label','Set Origin ','Callback',@set_origin);

% enlever certaines fonctinonalités
delete(uigettool(fig,'Exploration.Brushing'))
delete(uigettool(fig,'DataManager.Linking'))
delete(findall(fig,'Tag','figDataManagerBrushTools'))
delete(findall(fig,'Tag','figBrush'))
delete(findall(fig,'Tag','figLinked'))   
       
       
% Load the Redo icon
icon = fullfile(matlabroot,'toolbox/matlab/icons/greenarrowicon.gif');
[cdata,map] = imread(icon);
% Convert white pixels into a transparent background
map(map(:,1) + map(:,2) + map(:,3) ==3) = NaN;
% Convert into 3D RGB-space
cdataRedo = ind2rgb(cdata,map);
cdataUndo = cdataRedo(:,16:-1:1,:);
% add the icon (and its mirror image = undo) to latest toolbar
uipushtool('cdata',cdataUndo, 'tooltip','undo',...
                  'ClickedCallback',@undo);
uipushtool('cdata',cdataRedo, 'tooltip','redo',...
                  'ClickedCallback',@redo);

% icone pour réinitialiser
icon = 'reinitialiser.gif';
[cdata,map] = imread(icon);
map(map(:,1) + map(:,2) + map(:,3) ==3) = NaN;
reinit = ind2rgb(cdata,map);
uipushtool('cdata',reinit, 'tooltip','reset',...
                  'ClickedCallback',@reInitialiser);
% icone pour déleter les points
icon = 'KILL.gif';
[cdata,map] = imread(icon);
map(map(:,1) + map(:,2) + map(:,3) ==3) = NaN;
reinit = ind2rgb(cdata,map);
uipushtool('cdata',reinit, 'tooltip','delete',...
                  'ClickedCallback',@delete_pt);
              
% un scroll bar pour choisir le type de régression
hToolbar = findall(gcf,'tag','FigureToolBar');
jToolbar = get(get(hToolbar,'JavaContainer'),'ComponentPeer');
if ~isempty(jToolbar)
    jCombo = javax.swing.JComboBox({'ls' 'robust' 'robustzero' 'ortho' 'ortho_r' 'quad' 'quad2' 'exp' 'exp2' 'power' 'power2' 'lambda'});
    set(jCombo, 'actionPerformedCallback', @selection_CallbackFcn);
    jToolbar(1).add(jCombo);% jToolbar(1).add(jCombo,1); pour le mettre en première position
    jToolbar(1).repaint;
    jToolbar(1).revalidate;
    set(jCombo,'SelectedItem',option);
end

% un get values pour mettre les valeurs dans le workspace
icon = 'Get_values.gif';
[cdata,map] = imread(icon);
map(map(:,1) + map(:,2) + map(:,3) ==3) = NaN;
reinit = ind2rgb(cdata,map);
uipushtool('cdata',reinit, 'tooltip','put the values in the Workspace',...
                  'ClickedCallback',@GET_VALUES);

function selection_CallbackFcn(hCombo,hEvent)
    option = get(hCombo,'SelectedItem');
    MEMOIRE(current).xlim = get(gca,'XLim');
    MEMOIRE(current).ylim = get(gca,'YLim');
    affichage();
end

% une icone pour afficher les stats
icon = 'information.gif';
[cdata,map] = imread(icon);
map(map(:,1) + map(:,2) + map(:,3) ==3) = NaN;
reinit = ind2rgb(cdata,map);
uipushtool('cdata',reinit, 'tooltip','display statistics',...
                  'ClickedCallback',@DISPLAY);
              
% si premier appel, créer les limites
ampx = max(x) - min(x);
ampy = max(y) - min(y);
if ~isfield(MEMOIRE(1),'xlim'), MEMOIRE(1).xlim = [min(x)-0.1*ampx max(x)+0.1*ampx];end %get(gca,'XLim');
if ~isfield(MEMOIRE(1),'ylim'), MEMOIRE(1).ylim = [min(y)-0.1*ampy max(y)+0.1*ampy];end % get(gca,'YLim')

% faire le premier affichage
try
affichage();
catch e
    warndlg('impossible d''effectuer la régression!')
    disp(e.message)
    return
end

% callbacks
    function affichage()
        LINEAR = 1;
        x = MEMOIRE(current).x;
        y = MEMOIRE(current).y;
        g = MEMOIRE(current).group(MEMOIRE(current).index);
        cla;
        x = x(:);y = y(:);
        hold 'on'
        if max(g)==1
            plot(x,y,monstyle,'markersize',12,'LineWidth',1.4,'color','k','MarkerFaceColor',col{1});
        else
            for i_g = 1:max(g)
                plot(x(g==i_g),y(i_g==g),monstyle,'markersize',12,'LineWidth',1.4,'color','k','MarkerFaceColor',col{i_g});
            end
        end

        % choix du type de régression
        switch option
            case 'ls'
                b  = regress(y,[ones(length(x),1) x]);
            case 'robust'
                [b stats] = robustfit(x,y);
            case 'robustzero'
                b(1) = 0;
                [b(2) stats] = robustfit(x,y,[],[],'off');
            case 'ortho'
                [b var_explained] = normal_regress(x,y);
            case 'ortho_r'
                [b var_explained] = normal_regress(x,y,1);
            otherwise
                LINEAR = 0;
        end

        xx = linspace(min(x)-0.1*(max(x)-min(x)),max(x)+0.1*(max(x)-min(x)),100);


        hold 'on';
        if LINEAR
            plot(xx,b(1)+b(2)*xx,':','linewidth',3,'color','k'); 
            eval(['f = @(x) ',num2str(b(1)),'+',num2str(b(2)),'*x;']);
        else
            b = [NaN NaN];
            switch option
                case 'exp'
                    [xxx f] = expregress(x,y,[],'exp');
                    plot(xx,f(xx),':','linewidth',3,'color','k'); 
               case 'exp2'
                    [xxx f] = expregress(x,y,[],'expMoinsUn');
                    plot(xx,f(xx),':','linewidth',3,'color','k');
                case 'quad'
                    [xxx f] = expregress(x,y,[],'quad');
                    plot(xx,f(xx),':','linewidth',3,'color','k'); 
                case 'quad2'
                    [xxx f] = expregress(x,y,[],'quad2');
                    plot(xx,f(xx),':','linewidth',3,'color','k'); 
                case 'power'
                    [xxx f] = expregress(x,y,[],'power');
                    plot(xx,f(xx),':','linewidth',3,'color','k'); 
                case 'power2'
                    [xxx f] = expregress(x,y,[],'power2');
                    plot(xx,f(xx),':','linewidth',3,'color','k'); 
                case 'lambda'
                    [xxx f] = expregress(x,y,[],'lambda');
                    plot(xx,f(xx),':','linewidth',3,'color','k'); 
            end
        end

        if DISPLAY_STATS
            if LINEAR
                try
                    text(mean(x),mean(y),sprintf('pseudo r= %1.3f \nx = %3.3f + %3.3f y',sqrt(var_explained),-b(1)/b(2),1/b(2)),'interpreter','none','fontsize',14)
                catch
                    text(mean(x),mean(y),sprintf('x = %3.1f + %3.2f',-b(1)/b(2),1/b(2)),'interpreter','none','fontsize',14)
                end
            else
                text(mean(x),mean(y),sprintf('f = %s',char(f)),'interpreter','none','fontsize',14)
            end
        end
        
        
        [RHO,PVAL] = corr(x,y,'type','Pearson');
        [RHO2,PVAL2] = corr(x,y,'type','Spearman') ;
        if strcmp(option,'robust')
            PVAL = stats.p(2);
        end
        if DISPLAY_STATS
            text(mean(x)+std(x),mean(y)+std(y),sprintf(['Pearson''s r=%1.3f (p=%1.3f) N=%u\n',...
                                                    ' Spearman''s r=%1.3f (p=%1.3f)\n',...
                                       'y = %3.2f x +  %3.2f'],RHO,PVAL,length(x),RHO2,PVAL2,b(2),b(1)),'interpreter','none','fontsize',14);
        end


       try 
        xlim(MEMOIRE(current).xlim);
        ylim(MEMOIRE(current).ylim);
       end
       hold 'off';
       if DISPLAY_STATS
            plotAltmanBland(x,y,f)
       else
           try
               close(fig_);
           end
       end
       figure(fig)
    end

    function delete_pt(source,eventdata)
        if strcmp(get(gcf,'Pointer'),'crosshair')
           set(gcf,'Pointer','arrow')
           DELETEpt = 0;
        else
           set(gcf,'Pointer','crosshair')
           DELETEpt = 1;
        end
    end

    function f_current_pt(source,eventdata)
       
        btype = get(fig,'SelectionType');
        if DELETEpt && isequal(btype,'normal')
           
           
            cp = get(gca,'CurrentPoint');
            cx = cp(1,1);
            cy = cp(1,2);
            xl = get(gca,'XLim');
            dx = diff(xl);
            yl = get(gca,'YLim');
            dy = diff(yl);

            if ~(cx>=xl(1) && cx<=xl(2) && cy>=yl(1) && cy<=yl(2)), return; end

            d = abs((x-cx)/dx) + abs((y-cy)/dy);
            [dmin,j] = min(d);
            if dmin<0.1 
               % effacer le point de la liste
               x(j) = [];y(j) = [];
               % mettre l'indice correspondant à zéro
               index = MEMOIRE(current).index;
               index(cumsum(index)==j) = 0;
               % updater la mémoire
               xlim(xl);ylim(yl);
               MEMOIRE(current+1).x = x;
               MEMOIRE(current+1).y = y;
               MEMOIRE(current+1).xlim = xl;
               MEMOIRE(current+1).ylim = yl;
               MEMOIRE(current+1).index = index;
               
               group = MEMOIRE(current).group;
               group(j) = 0;
               MEMOIRE(current+1).group = group;
               
               
               current = current +1;

               affichage();
            end          
        elseif isequal(btype,'alt')
               cp = get(gca,'CurrentPoint');
               cx = cp(1,1);
               cy = cp(1,2);
               xl = get(gca,'XLim');
               dx = diff(xl);
               yl = get(gca,'YLim');
               dy = diff(yl);

               if ~(cx>=xl(1) && cx<=xl(2) && cy>=yl(1) && cy<=yl(2)), return; end

               d = abs((x-cx)/dx) + abs((y-cy)/dy);
               [dmin,j] = min(d);
               index_temp = cumsum( MEMOIRE(current).index);
               index_temp(~MEMOIRE(current).index) = 0;
               if dmin<0.1
                   text(x(j),y(j),sprintf('Pt:%u',find(index_temp==j)),'fontsize',11,'color','r');
                   try
                       res = [];
                       res = evalin('base','res');
                       figure('position',[32    85   381   178]);
                       itemp = find(cumsum(indice_des_points)==find(index_temp==j),1,'first');
                       if strcmp(type,'mag')
                            plot(res.t,res.mag.muscle(indice_du_muscle).data(:,itemp),'k') 
                            ylim(max(max((abs(res.mag.muscle(indice_du_muscle).data(25:end,:)))))*[-1 1]);% remplacer (25:end,:) par (25:end,indice_des_points)
                            line([res.t(1) res.t(end)],[1 1]*res.mag.muscle(indice_du_muscle).amp(itemp)/2,'color','r');
                            line([res.t(1) res.t(end)],-[1 1]*res.mag.muscle(indice_du_muscle).amp(itemp)/2,'color','r'); 
                       elseif strcmp(type,'elec')
                            plot(res.t,res.elec.muscle(indice_du_muscle).data(:,itemp),'k')
                            ylim(max(max((abs(res.elec.muscle(indice_du_muscle).data(25:end,:)))))*[-1 1]);
                            line([res.t(1) res.t(end)],[1 1]*res.elec.muscle(indice_du_muscle).amp(itemp)/2,'color','r');
                            line([res.t(1) res.t(end)],-[1 1]*res.elec.muscle(indice_du_muscle).amp(itemp)/2,'color','r'); 
                       end
                       title(sprintf('point %u (over all = %u)',find(index_temp==j),itemp),'fontsize',12);                      
                       box off;
                       xlim([0 0.1]);
                   end
               end
               
        else
            return
        end
    end

    function redo(source, eventdata)
        if current + 1 <=length(MEMOIRE)
            current = current +1;
            affichage();
        end 
    end
    function undo(source, eventdata)
        if current - 1>0
            current = current -1;
            affichage();
        end
    end

    function reInitialiser(source,eventdata)
         current = 1;
         affichage();
    end

    function set_origin(source,eventdata)
        angle_initial = inputdlg('origin angle (°):','set origin');
        angle_initial = str2double(angle_initial);

        MEMOIRE(current+1).x = MEMOIRE(current).x + angle_initial;
        MEMOIRE(current+1).y = MEMOIRE(current).y;
        MEMOIRE(current+1).xlim = get(gca,'XLim') + angle_initial;
        MEMOIRE(current+1).ylim = get(gca,'YLim');

        current = current +1;
        affichage(); 
    end
    function change_sign(source,eventdata)
         MEMOIRE(current+1).x = MEMOIRE(current).x * (-1);
         MEMOIRE(current+1).y = MEMOIRE(current).y * (-1);
         yl = get(gca,'YLim');
         xl = get(gca,'XLim');
         MEMOIRE(current+1).ylim = -[yl(2) yl(1)];
         MEMOIRE(current+1).xlim = -[xl(2) xl(1)];
         
         current = current +1;
         affichage(); 
    end
    function GET_VALUES(source,eventdata)
        str = get(get(gca,'title'),'string');
        assignin('base',[str 'x'],MEMOIRE(current).x(:));
        assignin('base',[str 'y'],MEMOIRE(current).y(:));
        assignin('base',[str 'index'],MEMOIRE(current).index);
        disp(['CORRELATION GUI:',str,' x, y and index values assigned to the workspace']);
    end

    function plotAltmanBland(x,y,f)
        d = y-f(x);
        hh = ishandle(fig_);
        
        if isempty(hh)
            fig_ = figure('position',[942   112   381   178],'MenuBar','none');
        end
        if ~hh
            fig_ = figure('position',[942   112   381   178],'MenuBar','none');
        end
        figure(fig_)
        clf;
        subplot(6,2,[3 7 9 11]);
        plot(x,d,'ko','MarkerFaceColor','k');hold 'on';
        assignin('base','d',d);
        set(gca,'fontsize',8);
        abscisse = linspace(min(x)-0.25*abs(min(x)-max(x)),max(x)+0.25*abs(min(x)-max(x)),20);
        plot(abscisse,[ones(length(abscisse),1)*mean(d),ones(length(abscisse),1)*mean(d)+2*std(d),ones(length(abscisse),1)*mean(d)-2*std(d)],'-.k','linewidth',2);
        xlim([abscisse(1) abscisse(end)]);
        [hh pp] = ttest(d,0);% tests si les résidues sont différents de zéro
        try
            [h,p] = kstest(d);[h2 p2] = lillietest(d);
            if ~ (h&&h2)
                title(sprintf('normal p= %1.3f\n residual= %2.2f±%2.2f (p=%1.3f)',max(p,p2),mean(d),std(d),pp),'fontsize',7);
            else
                title(sprintf('not normal p= %1.3f\n residual= %2.2f±%2.2f (p=%1.3f)',max(p,p2),mean(d),std(d),pp),'fontsize',7);
            end
        end
        subplot(122);
        normplot(d)
        set(gca,'fontsize',8);
    end

    function DISPLAY(~,~)
        MEMOIRE(current).xlim = get(gca,'xlim');
        MEMOIRE(current).ylim = get(gca,'ylim');
        if DISPLAY_STATS
           DISPLAY_STATS = false;
        else
           DISPLAY_STATS =  true;
        end
        affichage();
    end
        
        
        


end