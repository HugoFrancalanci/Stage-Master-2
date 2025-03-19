function M = offdiag(A)
% return all the off - diagonal elements

[M N] = size(A);
idx = logical(triu((1-eye(M,N))));
M = X(idx);