function [center peak SD] = COA(f,longeur_cycle)
% Center Of Activity - (+ SDD of activity)
% paramètre de position et d'étendue des patterns (méthode circulaire)

if nargin >1
    u = util();
    f = u.pattern_moyen(f,longeur_cycle);
end
    
theta = linspace(0,2*pi(),size(f,1))';% angle
p = bsxfun(@rdivide,f,sum(f));% probability

% moment  trigonométrique d'ordre 1
% ----------------
theta1 = angle( sum( bsxfun(@times,exp(1i*theta),p)));
theta1(theta1<0) = 2*pi()+theta1(theta1<0);
center = theta1(:)'/(2*pi());% en pourcentage de cycle

% moment trigonométrique d'ordre 2 centré
% ----------------
for k= 1:size(f,2)
    theta2(k) = angle( sum( exp(1i*2*(theta - theta1(k))).*p(:,k)));
end
SD = sqrt(abs(theta2))/(2*pi());

% peak of activity
% ----------------
[xx peak] = max(f);
peak = peak/length(f);

end