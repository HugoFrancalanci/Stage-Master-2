function methods = derivation
%%     DERIVATION
% derive 1 ou 2 fois, sur 1 ou plusieurs colonnes
% USE :
% f = derivation()  % crée la classe
% METHODES :
% [y] = vitesse(A,dt)       --> un vecteur colonne 1 fois
% [y] = acceleration(X,dt)  --> un vecteur colonne 2 fois
% [y] = deriv(X,dt)         --> plusieurs colonnes 1 fois
% [y] = deriv2(X,dt)        --> plusieurs colonnes 2 fois


methods = struct('acceleration',@acceleration,...
    'vitesse',@vitesse,...
    'deriv',@deriv,...
    'deriv2',@deriv2);


%%      dérive une collonne 2x
    function [y] = acceleration(X,dt)
        if size(X,1)==1
            X= X(:);
        end
        if nargin<2
            dt = 1;
        end
      y1 = [35 -104 114 -56 11;11 -20 6 4 -1]*[X(1,:) ;X(2,:); X(3,:); X(4,:); X(5,:)]./(12*dt^2);
      y2 = (-X(1:end-4,:)+16*X(2:end-3,:)-30*X(3:end-2,:) +16*X(4:end-1,:) -X(5:end,:))./(12*dt^2);
      y3 = [-1 4 6 -20 11;11 -56 114 -104 35]*[X(end-4,:); X(end-3,:); X(end-2,:); X(end-1,:); X(end,:)]./(12*dt^2);
      y = [y1;y2;y3];
    end

%%      dérive une collonne 1x
    function [y] = vitesse(X,dt) 
        if size(X,1)==1
            X= X(:);
        end
        if nargin<2
            dt = 1;
        end
       y1 = [-25 48 -36 16 -3;-3 -10 18 -6 1]*[X(1,:) ;X(2,:); X(3,:); X(4,:); X(5,:)]./(12*dt);
       y2 = (X(1:end-4,:)-8*X(2:end-3,:) + 8*X(4:end-1,:) -X(5:end,:))./(12*dt); 
       y3 = [ -1 6 -18 10 3;3 -16 36 -48 25]*[X(end-4,:); X(end-3,:); X(end-2,:); X(end-1,:); X(end,:)]./(12*dt);
       y = [y1;y2;y3];
    end
%%      derivation speciale en ajoutant des bords
    function [y] = deriv(X,dt) 
      if size(X,1)==1
            X= X(:);
      end
      if nargin<2
          dt = 1;
      end
      [~,nc] = size(X);
      for i = 1:nc
         [temp,N] = parTrois(X(:,i));
         temp = vitesse(temp,dt);
         y(:,i) =  temp(N:end-N+1);
      end
    end
%%      derivation speciale en ajoutant des bords
    function [y] = deriv2(X,dt)
      
      if size(X,1)==1
        X= X(:);
      end
      if nargin<2
          dt = 1;
      end
        [~,nc] = size(X);
      for i = 1:nc
         [temp,N] = parTrois(X(:,i));
         temp = acceleration(temp,dt);
         y(:,i) =  temp(N:end-N+1);
      end
    end


    function [y,nbre_pts] = parTrois(X)
        X= X(:);
        N = length(X);
        nbre_pts = max(floor(0.1*N),1);
        origine1 = X(1);
        origine2 = X(end);
        y = [-flipud(X(1:nbre_pts))+2*origine1;X(2:end-1);-flipud(X(end-nbre_pts+1:end))+2*origine2]';
    end

end