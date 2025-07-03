function [activation1, activation2] = extract_activations_helper(H, n_subjects)
    % Initialiser les matrices originales (1000 points, n_subjects sujets)
    activation1_raw = zeros(1000, n_subjects);
    activation2_raw = zeros(1000, n_subjects);
    
    for i = 1:n_subjects
        activation1_raw(:, i) = H(:, (i-1)*2 + 1);
        activation2_raw(:, i) = H(:, (i-1)*2 + 2);
    end
    
    % Interpolation sur 100 points
    x_old = linspace(0, 100, 1000);
    x_new = linspace(0, 100, 100);
    activation1 = zeros(100, n_subjects);
    activation2 = zeros(100, n_subjects);
    
    for i = 1:n_subjects
        activation1(:, i) = interp1(x_old, activation1_raw(:, i), x_new, 'spline');
        activation2(:, i) = interp1(x_old, activation2_raw(:, i), x_new, 'spline');
    end
end