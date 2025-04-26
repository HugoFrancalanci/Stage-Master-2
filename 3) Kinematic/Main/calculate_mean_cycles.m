function [mean_cycles_GH, mean_cycles_ST, mean_cycles_HT] = calculate_mean_cycles(cycles_frames, num_cycles, Angles_GH, Angles_ST, Angles_HT, num_samples)
    % Initialisation des matrices pour stocker les cycles moyens
    mean_cycles_GH = zeros(num_samples, 3);
    mean_cycles_ST = zeros(num_samples, 3);
    mean_cycles_HT = zeros(num_samples, 3);
    
    % Interpolation et moyenne des cycles
    for c = 1:3 % Composantes (X, Y, Z)
        % Matrices pour stocker les cycles interpolés
        interp_cycles_GH = zeros(num_cycles, num_samples);
        interp_cycles_ST = zeros(num_cycles, num_samples);
        interp_cycles_HT = zeros(num_cycles, num_samples);
        
        for i = 1:num_cycles
            % Points de temps normalisés pour ce cycle
            cycle_time_norm = linspace(0, 100, length(cycles_frames{i}));
            
            % Points de temps pour l'interpolation
            interp_time = linspace(0, 100, num_samples);
            
            % Récupérer les angles pour ce cycle
            cycle_angles_GH = Angles_GH(cycles_frames{i}, c);
            cycle_angles_ST = Angles_ST(cycles_frames{i}, c);
            cycle_angles_HT = Angles_HT(cycles_frames{i}, c);
            
            % Interpolation des cycles à un nombre fixe d'échantillons
            interp_cycles_GH(i, :) = interp1(cycle_time_norm, cycle_angles_GH, interp_time, 'pchip');
            interp_cycles_ST(i, :) = interp1(cycle_time_norm, cycle_angles_ST, interp_time, 'pchip');
            interp_cycles_HT(i, :) = interp1(cycle_time_norm, cycle_angles_HT, interp_time, 'pchip');
        end
        
        % Calcul de la moyenne des cycles pour chaque composante
        mean_cycles_GH(:, c) = mean(interp_cycles_GH, 1)';
        mean_cycles_ST(:, c) = mean(interp_cycles_ST, 1)';
        mean_cycles_HT(:, c) = mean(interp_cycles_HT, 1)';
    end
end