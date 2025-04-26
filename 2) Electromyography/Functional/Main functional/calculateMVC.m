function [mvc_R, mvc_L] = calculateMVC(subjects, muscles_R, muscles_L, assigned_analytics, b, a, rms_window, nb_subjects, nb_muscles, base_path)
    % Calcul du MVC basé sur la tâche analytique assignée pour chaque côté

    mvc_R = zeros(nb_muscles, nb_subjects);
    mvc_L = zeros(nb_muscles, nb_subjects);

    %% TRAITEMENT SOUS-TÂCHE ANALYTIC
    for subj_idx = 1:nb_subjects
        for m = 1:nb_muscles
            analytic_idx = assigned_analytics(m);

            % Traitement du côté droit
            muscle_name_R = muscles_R{m};
            fileName_analytic = sprintf('%s\\%s\\%s-PROTOCOL01-ANALYTIC%d-01.c3d', ...
                                        base_path, subjects{subj_idx}, subjects{subj_idx}, analytic_idx);

            if exist(fileName_analytic, 'file')
                c3dH_analytic = btkReadAcquisition(fileName_analytic);
                analogs_analytic = btkGetAnalogs(c3dH_analytic);

                if isfield(analogs_analytic, muscle_name_R)
                    signal = analogs_analytic.(muscle_name_R);
                    signal_filtered = filtfilt(b, a, signal);
                    emg_rms = sqrt(movmean(abs(signal_filtered).^2, rms_window));
                    % Utilisation de mean(maxk()) pour calculer le MVC
                    mvc_R(m, subj_idx) = mean(maxk(emg_rms, 5));
                end
            else
                warning('Fichier introuvable : %s', fileName_analytic);
            end

            % Traitement du côté gauche
            muscle_name_L = muscles_L{m};

            if exist(fileName_analytic, 'file') && isfield(analogs_analytic, muscle_name_L)
                signal = analogs_analytic.(muscle_name_L);
                signal_filtered = filtfilt(b, a, signal);
                emg_rms = sqrt(movmean(abs(signal_filtered).^2, rms_window));
                % Utilisation de mean(maxk()) pour calculer le MVC
                mvc_L(m, subj_idx) = mean(maxk(emg_rms, 5));
            end
        end
    end
end