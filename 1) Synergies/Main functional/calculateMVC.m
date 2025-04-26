function mvc = calculateMVC(data_path, subjects, muscles, assigned_analytics, b, a, rms_window)
% Calcule des MVC
    nb_subjects = length(subjects);
    nb_muscles = length(muscles);
    
    % Initialisation des MVC des tâches analytiques
    mvc = zeros(nb_muscles, 1);
    
    % Calcul du MVC basé sur la tâche analytique assignée
    for subj_idx = 1:nb_subjects
        for m = 1:nb_muscles
            analytic_idx = assigned_analytics(m);
            
            fileName_analytic = sprintf('%s\\%s\\%s-PROTOCOL01-ANALYTIC%d-01.c3d', ...
                                data_path, subjects{subj_idx}, subjects{subj_idx}, analytic_idx);
 
            c3dH_analytic = btkReadAcquisition(fileName_analytic);
            analogs_analytic = btkGetAnalogs(c3dH_analytic);
            
            muscle_name = muscles{m};
            if isfield(analogs_analytic, muscle_name)
                signal = analogs_analytic.(muscle_name);
                signal_filtered = filtfilt(b, a, signal);
                signal_abs = abs(abs(signal_filtered));
                emg_rms = sqrt(movmean(signal_abs.^2, rms_window));
                mvc(m) = mean(maxk(emg_rms, 5));
            end
        end
    end
end