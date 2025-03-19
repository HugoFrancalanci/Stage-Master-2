%% Barzilai-Borwein gradient projection (GPSR-BB) algorithm
%
function [X] = nmf_gpsr_bb(A,Y,X,no_iter)
%
% [X] = nmf gpsr bb(A,Y,X,no iter) finds such matrix X that solves
% the equation AX = Y subject to nonnegativity constraints.
%
% INPUTS:
% A - systemmatrix of dimension [I by J]
% Y - matrix of observations [I by T]
% X - matrix of initial guess [J by T]
%no iter - maximum number of iterations
%
%OUTPUTS:
% X - matrix of estimated sources [J by T]
%
% #########################################################################
% Parameters
alpha_min = 1E-8; alpha_max = 1;
alpha = .1*ones(1,size(Y,2));
B = A'*A; Yt = A'*Y;
for k=1:no_iter
    G = B*X - Yt;
    delta = max(eps, X - repmat(alpha,size(G,1),1).*G) - X;
    deltaB = B*delta;
    lambda = max(0, min(1, -sum(delta.*G,1)./(sum(delta.*deltaB,1) + eps)));
    X = max(eps,X + delta.*repmat(lambda,size(delta,1),1));
    gamma = sum(delta.*deltaB,1) + eps;
    if gamma
        alpha = min(alpha_max, max(alpha_min, sum(delta.^2,1)./gamma ));
    else
        alpha = alpha_max;
    end
end