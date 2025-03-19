function [W,H] = ranger(X,W,H)
     %fonction permettant de ranger les loadings et synergies
     % selon leurs variances
    [SCEt,SCEf,SCEe] = VAF(X,W,H,'methode',4);
    va = sort(SCEf,'descend');
    permutation = zeros(length(va),length(va));
    for i = 1:length(SCEf)
        permutation(i,find(SCEf==va(i)))=1;
    end
    W = W*permutation';
    H = permutation*H;
