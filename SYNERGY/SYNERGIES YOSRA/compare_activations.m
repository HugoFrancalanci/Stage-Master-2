function compare_activations(E1,E2,longueur_cycle)


for s = 1:17 %[3 6 7 11 13 14 15]       
    for i = 1:N
        temp = [SYNseat(i).data(:,:,s)' SYNstand(i).data(:,:,s)'];
        shuffled  =  reshape(temp(randperm(length(temp(:)))),size(temp,1),size(temp,2));
        
        scalar_product_matrix = Z( nancorr(temp,[],'sp') );
        corr_matrix           = Z( nancorr(temp) );
        
        sprand_matrix         = Z( nancorr(shuffled,[],'sp') );
        corrrand_matrix       = Z( nancorr(shuffled) );
        
        
        %EXTRAIRE LES R
        SP_intra_seat(s,i)  = nanmean(scalar_product_matrix(I_seated));
        SP_intra_stand(s,i) = nanmean(scalar_product_matrix(I_stand));
        SP_inter(s,i)       = nanmean(scalar_product_matrix(I_INTER));
        
        SP_r(s,i)   = mean(sprand_matrix(logical(triu(ones(12,12)) - eye(12))));     
        
    end
end

end