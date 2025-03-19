function [cov_ m_] = npcov(X)
% Non Perturbed Covariance
% robust estimation of the covariance matrix
maxiter = 20;%
Nl      = size(X,1);
if Nl<30
    percentage = 0.6;
elseif Nl<60
    percentage = 0.8;
else
    percentage = 0.95;
end

% first guesses
m_           = npmean(X);
cov_previous = covariance(X,ones(Nl,1));
%up = sqrt(chi2inv(0.975,size(X,2)));
for i = 1:maxiter
    
    % weightings caculation
    err   = sqrt(mahalanobis(X,m_));
    dev   = 2*1.4826*median(abs(err-median(err)));%  MAD
    w     = exp(-(err/dev).^2); % poids
        
    [lo, up] = confint(err,percentage);
    w(err<=up) = 1;
    %w = w/sum(w);
    
    % updated coariance matrix and mean
    cov_new      = covariance(X,w);
    m_           = sum(bsxfun(@times,X,w/sum(w)));
    
    % break rule = change in frobenius norm <1E-6
    if sum((cov_previous(:) - cov_new(:)).^2)<1E-6
        break
    end
    
    % updtate 
    cov_previous = cov_new;
            
end
cov_ = cov_new;

if i==maxiter
    fprintf('warning::npcov, maximum iteration reached\n');
end

    function d = mahalanobis(M,m_)
        % squared mahalanobis distance
        % previously d = diag(C*inv(cova)*C');
        C = bsxfun(@minus,M,m_);
        [Q R] = qr(C);
        ri = R'\C'; % see function mahal of matlab (more robust)
        d = sum(ri.*ri,1)'*(size(M,1)-1);              
    end
    function COV_ = covariance(M,p)
        % weigted covariance matrix
        m = sum(bsxfun(@times,M,p/sum(p)));% weighted mean
        C = bsxfun(@minus,M,m);% centered data
        %COV_ = size(M,1)*C'*diag(p)*C/(size(M,1)-1);
        COV_ = C'*diag(p)*C/(sum(p)-1);
    end
    function [Ll Ul] = confint(X,p_)
    % confidence interval of X: lower limit (Ll) and upper limit (Ul) at 
    % p_% (eg, p_ = 95%)
        if ~isempty(p_)
            if p_<0 || p_>1
                p_ = 0.95;
                warning(['wrong percentage value for confidence '...
                         'interval: 95% used instead']);
            end
        else
            p_ = 0.95;
        end
        lo = (1-p_)/2;
        up = lo + p_;
        % empirical distribution (=cdf)
        [f_ x_] = ecdf(X);
        
        %A Piecewise Linear Nonparametric CDF Estimate
        x2_ = linspace(x_(1),x_(end),3*length(x_));
        [xx ii] = unique(x_);
        F = interp1(xx,f_(ii),x2_,'linear','extrap');
        %CI definition
        Ll  = x2_(find(F >= lo,1,'first'));% inf conf lim
        Ul  = x2_(find(F <= up,1,'last')); % sup conf lim
    end

end

