
function [R_HT, R_ST, R_GH] = calculate_rotation_matrices(Xt, Yt, Zt, Xs, Ys, Zs, Xh, Yh, Zh)
    % Matrices de rotation par rapport au repère global
    Rt = [Xt', Yt', Zt'];
    Rs = [Xs', Ys', Zs'];
    Rh = [Xh', Yh', Zh'];
    
    % Correction orthonormalité (A^T=A = I)
    % Utilisation de "svd" pour garantir que les matrices R sont orthogonales
    [Ut,~,Vt] = svd(Rt); Rt = Ut * Vt';
    [Us,~,Vs] = svd(Rs); Rs = Us * Vs';
    [Uh,~,Vh] = svd(Rh); Rh = Uh * Vh';
    
    % Matrices de rotation relatives
    R_HT = Rt' * Rh;  % Humérus par rapport au thorax
    R_ST = Rt' * Rs;  % Scapula par rapport au thorax
    R_GH = Rs' * Rh;  % Humérus par rapport à la scapula
end