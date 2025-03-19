function [vaf_m vaf_sd h PearsonR res_H] = bootstrapvaf(E,lc)

% initialisation
[n m]        = size(E);
SHORT        = false;
% taille des sous partie des données
if nargin <2
    lc = [];
end
if ~isempty(lc)
    SHORT  = true;
end
% nombre de resamplage          
NB_ITER      = 100; 
% if n>500
%     fprintf(['attention: n élevé (%u) le processus peut être long\n'...
%              'peut être ''downsampler'' la matrice initiale\n'],n);
% end
               
wb = waitbar(0,' bootstrapping...');
for i = 1:(m-1)
    temp   = [];
    H      = [];
    if i>2
        nbi = floor(NB_ITER/i);
    else
        nbi = NB_ITER;
    end
    for N = 1:nbi
        if SHORT    % resampling with replacement
            vec      = ceil(rand(n,1)*(n-1) + 1);
            vec      = vec(1:lc);
        else
            vec      = ceil(rand(n,1)*(n-1) + 1);
        end
        E_           = E(vec,:);
        W            = [];
        [W H]        = lee_seung(E_,i);
        res(i,N).H   = H; % keep record
        err          = E_ - W*H;
        temp(N)      = 1-sum(err(:).^2)/sum(E_(:).^2); 
        res(i,N).err = 1-sum(err.^2)./sum(E_.^2);
        waitbar(((NB_ITER-1)*i+N)/((m-1)*NB_ITER),wb,'bootstrapping..'); 
    end
    temp        = sort(temp);
    vaf_m(i)    = mean(temp);
    vaf_sd(i)   = std(temp);
end
vaf_m(m)    = 1;
vaf_sd(m)   = 0 ;

% compute mean SD for the weightings of H
waitbar(0,wb,' compute r-values...');
for i  = 1:m-1
    temp = [];
    temp_err = [];
    if i>2
        nbi = floor(NB_ITER/i);
    else
        nbi = NB_ITER;
    end        
    for j = 1:nbi
        temp(:,:,j) = res(i,j).H;
        temp_err(j,:) = res(i,j).err;
    end
    res_H(i) = {temp};
    % moyenne, écart type et confidence intervals
    h(i).mean = mean(temp,3);
    h(i).std  = std(temp,[],3);
    h(i).N    = size(temp,3); 
    h(i).inf  = h(i).mean - 1.96*h(i).std;
    h(i).sup  = h(i).mean + 1.96*h(i).std;
    h(i).circ_var = 1-norm2(mean(temp,3),2);
    h(i).circ_std = sqrt(2*(1-norm2(mean(temp,3),2)));
    
    h(i).mean_err = mean(temp_err);
    h(i).std_err  = std(temp_err);
    % compute the intra-group r -values
    for j = 1:size(temp,1)
        vecteurs = [];
        vecteurs(:,:) = temp(j,:,:);
        PearsonR(i).data(:,j) = offdiag(corr(vecteurs));
    end
    waitbar(i/m,wb,' compute r-values...');
end
        
    
% ind = find((vaf_m -1.96*vaf_sd)>0.9,1,'first');
% fprintf('# synergies based on bootstrapped VAF\n');
% fprintf('95%% conf. int. VAF > 90%% :\t%1.0f\n',ind);
    
% close waitbar
close(wb);
    
function M = offdiag(A)
% return all the off - diagonal elements

    [M_ N_] = size(A);
    idx = logical(triu((1-eye(M_,N_))));
    M = A(idx);
end
    
    
end