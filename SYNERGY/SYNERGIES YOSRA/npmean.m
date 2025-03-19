function [M DEV]= npmean(DATA,dim)
% npmean (Non Perturbed Mean)
% c'est une moyenne robuste qui minimise l'influence des les outliers,
% mais qui suppose une valeur fixe corrompue par du bruit
% La moyenne obtenue est calculée en éliminant les éventuels NaN et +- Inf
% auteur : NA Turpin (2014)

[l c] = size(DATA);
if nargin<2
    dim=1;
    if l==1 || c==1
        DATA = DATA(:);
        l = length(DATA);
        c = 1;
    end
end

if ~isempty(DATA)
    if dim==1
        M = zeros(1,c);
        for ii = 1:c
           [m dev]   =  npmean_(DATA(:,ii));
           M(1,ii)   =  m;
           DEV(1,ii) =  dev;
        end
    elseif dim==2
           M = zeros(l,1);
        for ii = 1:l
           [m dev]  =  npmean_(DATA(ii,:));
           M(ii,1) = m;
           DEV(ii,1) = dev;
        end
    end
else
    M = [];
    DEV = [];
end


% algorithme npmean
    function [m dev] = npmean_(data_)
        data = data_(abs(data_)~=Inf & ~isnan(data_));
        if length(data)>1
            maxiter = 20;
            % estimation 1
            m_old   = median(data);
            for i = 1:maxiter
                % réduire l'influence des outiers
                err   = data-m_old;
                dev   = 2.985*1.4826*median(abs(err));% robust STD estimate
                poids = exp(-(err/dev).^2); 
                poids = poids/sum(poids);
                % estimation
                m     = sum(poids.*data);
                % test
                if abs(m-m_old)/m_old<1E-3
                    break;
                end
                % update
                m_old = m;
            end
        else
            m   = mean(data_);
            dev = std(data_);
        end
        dev   = 1.4826*median(abs(data-m));% MAD
    end

end
    
    