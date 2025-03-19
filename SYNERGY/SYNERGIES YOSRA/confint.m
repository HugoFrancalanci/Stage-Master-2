function [Ll Ul x2_ F] = confint(X,p_,option)
% confidence interval of X: lower limit (Ll) and upper limit (Ul) at 
% p_% (eg, p_ = 95%)
    if nargin <3
        option  = 1;
        if nargin <2
            p_ = 0.95;
        end
    end
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
    % % empirical distribution (=cdf)
    % [f_ x_] = ecdf(X);
    x_ = sort(X);
    K_ = length(x_);
    if option
        for kk =1:length(x_)
            f_(kk) = sum(x_<x_(kk))/K_;
        end
    else
        for kk =1:length(x_)
           f_(kk) = sum( x_ < x_(kk) + 0.5*(x_ == x_(kk)))/K_;
        end
    end

    %A Piecewise Linear Nonparametric CDF Estimate
    x2_ = linspace(x_(1),x_(end),3*length(x_));
    [xx ii] = unique(x_);
    F = interp1(xx,f_(ii),x2_,'linear','extrap');
    %CI definition
    Ll  = x2_(find(F >= lo,1,'first'));% inf conf lim
    Ul  = x2_(find(F <= up,1,'last')); % sup conf lim
end
