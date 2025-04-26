function [Angles_GH, Angles_ST, Angles_HT] = filter_and_correct_angles(Angles_GH, Angles_ST, Angles_HT, fs, fc)
    % Unwrap pour limiter les sauts de cardan liés aux angles de Euler
    Angles_GH = unwrap(Angles_GH);
    Angles_ST = unwrap(Angles_ST);
    Angles_HT = unwrap(Angles_HT);
    
    % Filtrage passe-bas
    [b, a] = butter(2, fc / (fs/2), 'low');
    Angles_GH = filtfilt(b, a, Angles_GH);
    Angles_ST = filtfilt(b, a, Angles_ST);
    Angles_HT = filtfilt(b, a, Angles_HT);
    
    % Recentrage des angles pour éliminer un biais initial
    Angles_GH = center_angles(Angles_GH);
    Angles_ST = center_angles(Angles_ST);
    Angles_HT = center_angles(Angles_HT);
end