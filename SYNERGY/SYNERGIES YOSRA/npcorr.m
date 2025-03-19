function C = npcorr(X)
% non perturbed correlation
% utilise npcov pour la covariance
C = npcov(X);
d_ = diag(C);
C = C./sqrt(d_*d_');
