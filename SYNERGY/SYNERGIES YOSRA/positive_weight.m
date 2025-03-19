function H = positive_weight(H)
% retoune la matrice "retourn�e" cad avec plus de poids positifs que
% n�gatifs

for i= 1:size(H,1)
    if sum(H(i,H(i,:)>0))/sum(-H(i,H(i,:)<0))<1
        H(i,:) = -H(i,:);
    end
end
H = H./repmat(norm2(H,2),1,size(H,2));