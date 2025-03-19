function mvc = calculateMVC(subjects, params)
    % Calcul du MVC basé sur la tâche analytique assignée
    
    nb_subjects = length(subjects);
    mvc = zeros(params.nb_muscles, 1);
    
    for subj_idx = 1:nb_subjects
        for m = 1:params.nb_muscles
            analytic_idx = params.assigned_analytics(m);
            
            fileName_analytic = sprintf('%s%s\\%s-%s-20240101-PROTOCOL01-ANALYTIC%d-.c3d', ...
                params.base_path, subjects{subj_idx}, subjects{subj_idx}, subjects{subj_idx}, analytic_idx);
            
            c3dH_analytic = btkReadAcquisition(fileName_analytic);
            analogs_analytic = btkGetAnalogs(c3dH_analytic);
            
            muscle_name = params.muscles{m};
            if isfield(analogs_analytic, muscle_name)
                signal = analogs_analytic.(muscle_name);
                signal_filtered = filtfilt(params.b, params.a, signal);
                signal_abs = abs(signal_filtered);
                emg_rms = sqrt(movmean(signal_abs.^2, params.rms_window));
                mvc(m) = mean(maxk(emg_rms, 5));
            end
        end
    end
end