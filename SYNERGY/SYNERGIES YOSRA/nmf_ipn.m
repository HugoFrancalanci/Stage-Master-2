% Interior Point Newton (IPN) algorithm function
%
function [x] = nmf_ipn(A,y,x,no_iter)
%
% [x]=nmf ipn(A,y,x,no iter) finds such x that solves the equation Ax = y
% subject to nonnegativity constraints.
%
% INPUTS:
% A - systemmatrix of dimension [I by J]
% y - vector of observations [I by 1]
% x - vector of initial guess [J by 1]
%no iter - maximum number of iterations
%
%OUTPUTS:
% x - vector of estimated sources [J by 1]
%
% #########################################################################
% Parameters
s = 1.8; theta = 0.5; rho = .1; beta = 1;
H = A'*A; yt = A'*y; J = size(x,1);
%Main loop
for k=1:no_iter
    g = H*x - yt; d = ones(J,1); d(g >= 0) = x(g >= 0);
    ek = zeros(J,1); ek(g >=0 & g < x.^s) = g(g >=0 & g < x.^s);
    M = H + diag(ek./d);
    dg = d.*g;
    tau1 = (g'*dg)/(dg'*M*dg); tau_2vec = x./dg;
    tau2 = theta*min(tau_2vec(dg > 0));
    tau = tau1*ones(J,1); tau(x - tau1*dg <= 0) = tau2;
    w = 1./(d + ek); sk = sqrt(w.*d); pc = - tau.*dg;
    Z = repmat(sk,1,J).*M.*repmat(sk',J,1);
    rt = -g./sk;
    [pt,flag,relres,iter,resvec] = lsqr(Z,rt - g.*sk,1E-8);
    p = pt.*sk;
    phx = max(0, x + p) - x;
    ph = max(rho, 1 - norm(phx))*phx;
    Phi_pc = .5*pc'*M*pc + pc'*g; Phi_ph = .5*ph'*M*ph + ph'*g;
    red_p = Phi_ph/Phi_pc; dp = pc - ph;
    if red_p >= beta
        t = 0;
    else
        ax = .5*dp'*M*dp; bx = dp'*(M*ph + g);
        cx = Phi_ph - beta*Phi_pc;
        Deltas = sqrt(bx^2 - 4*ax*cx);
        t1 = .5*(-bx + Deltas)/ax; t2 = .5*(-bx - Deltas)/ax;
        t1s = t1 > 0 & t1 < 1; t2s = t2 > 0 & t2 < 1; t = min(t1, t2);
        if (t <= 0)
            if t1s
                t = t1s;
            else
                t = t2s;
            end
        end
    end
    sk = t*dp + ph;
    x = x + sk;
end % for k