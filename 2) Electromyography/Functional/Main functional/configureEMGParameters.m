function [fs, b, a, rms_window, num_points, time_normalized] = configureEMGParameters()
    % Configuration des paramètres EMG
    
    fs = 2000;
    [b, a] = butter(4, [15, 475] / (fs/2), 'bandpass');
    rms_window = round(0.250 * fs);
    num_points = 1000;
    time_normalized = linspace(0, 1, num_points);
end
