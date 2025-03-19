function [W H] = ICA(A,n)
[weight,sphere,vaf,bias,signs,lrates,W] = runica(bsxfun(@rdivide,A,mean(A))','verbose','off','pca',n);
[H W]= positive_weight( pinv(weight*sphere)',W');
tr = pinv(W);
H = tr*W*H;


% SET THE OPTIONS
options = optimset('LargeScale','off');
options = optimset(options,'Display','off','GradObj','off');


q = ones(1,n);

% OPTIMISATION
ff = @(p) myfun(p);
qopt = fminunc(ff,q,options);


W = W*diag(qopt);

    function cout = myfun(p)
       cout = norm(W*diag(p)*H - A);
    end
end