function [h p CI] = rcmp(R,r_ref,affichage,type)
% R - COMPARE
% comparaison d'une population de r (eg Pearson's r) à une référence r_ref
% La population de R-values (R) est Fischer Z transformée avant les tests
% Test uniquement si la référence est inférieure ou non aux valeurs dans R,
% Les R peuvent être les r-values intra (pour une même condition)
% et r_ref la correlation obtenue entre deux conditions différentes, si les
% synergies proviennent de la même population r_ref
% sera dans la variation intra de ces conditions

if nargin<4
    type = 'inf';
    if nargin<3
        affichage = 0;
    else
        affichage = 1;
    end
end
if ~strcmp(type,'sup') && ~strcmp(type,'inf')
    fprintf('attention type %s non reconnu (type = inf ou sup)\n',type);
end
FischerZ    = @(x) 0.5*log((1+x)./(1-x));% transformée en Z
invFischerZ = @(x) (exp(2*x)-1)./(exp(2*x)+1);% transformée inverse

R = R(:);
n = length(R);

% Z transformation
Z_r  = FischerZ(R);
ref         = FischerZ(r_ref);

if kstest(Z_r)
    % data not normally distributed
    % (U statistics)
    [ll ul x f] = confint(Z_r,0.9);% empirical distribution   
    SD          = f.*(1-f)/n;% variance
    Z           = (f - 0.5)./sqrt(SD);% test statistique
    switch type
        case 'inf'
             p_values    = 2*normcdf(Z,0,sqrt(n));
        case 'sup'
            p_values    = 2*(1-normcdf(Z,0,sqrt(n)));
    end
    p_values(p_values>1) = 1;
    [xxx ind]   = min(abs(x-ref));
    if isempty(ind)
        p = 1;
    else
        if ind+1>length(p_values)
            p = p_values(ind);
        else
            p = p_values(ind+1);
        end
    end
    if p<0.05
        h = 1;
    else
        h  = 0;
    end
    CI = invFischerZ([ll ul]);
  
    if affichage
        plot(x,[f(:) p_values(:)]);line([ll ll],[0 0.5]);line([ul ul],[0 0.5]);
        line([ref ref],[0 0.5],'color','r'); title(sprintf('p=%3.3f',p))
    end
else
    % data normally distributed
    d  = mean(Z_r) - ref;
    SD = std(Z_r);
    
    Z = d/(SD);
    if Z<0
        p = 2*normcdf(Z);
    else
        p = 2*(1-normcdf(Z));
    end
    if p<0.05
        h = 1;
    else
        h  = 0;
    end
    CI = invFischerZ([mean(Z_r) + norminv(0.025)*std(Z_r),...
             mean(Z_r) + norminv(0.975)*std(Z_r)]);  
    
%     if r_ref>CI(2)
%         h = 0;
%         p = 1;
%     end
    
end
end
