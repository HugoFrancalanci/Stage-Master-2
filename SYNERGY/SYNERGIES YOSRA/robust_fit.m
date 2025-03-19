function b = robust_fit(x,y,y0)
% robut regression via an iterated weighted least square
% the algorithm optimise the covariance matrix used to define the
% regression coefficients (see reference)
% reference:
% Ricardo Maronna (2005) Principal Components and Orthogonal Regression
% Based on Robust Scales, Technometrics, 47:3, 264-273, DOI:
% 10.1198/004017005000000166

if nargin<3
    y0 = [];
end

% 
maxiter = 50;
x= x(:);y = y(:);

% première estimation
b = [0 0];
COVxy = cov(x,y);
VARx  = var(x);
xc    = mean(x);
b(2) = COVxy(1,2)/VARx;
if isempty(y0)
    b(1) = mean(y) - b(2)*xc;
else
    b(1) = y0;
end
    
%
old_ = b;
for i = 1:maxiter

    % calcul des résidus    
    err = y - b(1) - b(2)*x;
    dev   = 2.985*1.4826*median(abs(err));% tuning cte * MAD
    w = exp(-(err/dev).^2); % poids = welch method
    w = w/sum(w);
    
    % moyennes "optimales'
    xc = sum(w.*x);
    yc = sum(w.*y);

    % variance/covariance 'optimales'
    COVxy = (x-xc)'*diag(w)*(y-yc);
    VARx  = (x-xc)'*diag(w)*(x-xc);
    
    if isempty(y0)
        b(2) = COVxy/VARx;
        b(1) = yc - b(2)*xc; 
    else
        b(1) = y0;
        b(2) = (COVxy - y0*xc + xc*yc)/(VARx+xc^2);
    end
    % criterion = no more variation in the estimates of the coefficients
    new_ = b;
    if  max(abs(old_-new_)./abs(old_))<1E-12
        break; 
    end
    old_ = new_;
end

if i==maxiter
    fprintf('warning::robust_fit, maximum iteration reached\n');
end
    
end
