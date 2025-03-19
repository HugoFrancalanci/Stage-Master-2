function RES= filtre(DATA,type,range,fr)
% data -raw EMG;
% type = 'bandstop' ou 'bandpass'
% range = les fréquences à enlever ou garder [fr1 fr2;fr1bis fr2bis;...]
% fr - sampling frequency  (Hz)


RES = zeros(size(DATA,1),size(DATA,2));
for col = 1:size(DATA,2)
    RES(:,col) = filter(DATA(:,col),type,range,fr);
end
    
    
    
    
    function res= filter(data,type,range,fr)
        % récursion en cas de bandes multiples
        if size(range,1)>1
            data = filter(data,type,range(2:end,:),fr);
        end


        % initialisation
        n=size(data,1);
        res=data;
        T=n/fr; % observation time
        range = range*2;

        % calcul des bornes
        n1=floor(range(1,1)*T/2);
        if n1<1
            n1 = 0;
        elseif n1>n/2
            n1 = floor(n/2);
        end
        if size(range,2)>1
            n2 = floor(range(1,2)*T/2);
            if n2>n/2
                n2 = floor(n/2);
            end
        else
            n2 = n1+1;
        end
        if(n2-n1<0)
           msgbox('pas de filtrage effectué par la fonction "filtre": le range doit être croissant');
           return;
        end;

        % FFT
        z=fft(data);

        % élimination/conservation des zones non voulues
        switch type
            case 'bandstop'
                % compute the filtered signal
                z([n1+1:n2+1 n-n2+1:n-n1])=0;
                res=real(ifft(z));
            case 'bandpass'
                z1=z(n1+1:n2+1);
                z2=z(n-n2+1:n-n1);
                re=zeros(size(z));
                re(n1+1:n2+1)=z1;
                re(n-n2+1:n-n1)=z2;
                res=real(ifft(re,n));
            otherwise
                error('type non reconnu');

        end
    end

end