function plot_EMG_from_C3D_analytic(subjects, muscles_R, muscles_L, analytic_labels, data_path)
    % Vérification des entrées
    if nargin < 5
        error('Tous les arguments requis doivent être fournis.');
    end
    
    nb_subjects = length(subjects);
    nb_muscles = length(muscles_R);
    nb_analytics = length(analytic_labels);
    
    for subj_idx = 1:nb_subjects
        for f_idx = 1:nb_analytics
            % Construction du nom du fichier
            fileName = fullfile(data_path, subjects{subj_idx}, ...
                sprintf('%s-PROTOCOL01-ANALYTIC%d-01.c3d', ...
                subjects{subj_idx}, f_idx));
            
            % Vérification de la présence du fichier 
            if ~exist(fileName, 'file')
                warning('Fichier non trouvé : %s', fileName);
                continue;
            end
            
            try
            % Extraction des données analogiques
                c3dH = btkReadAcquisition(fileName);
                analogs = btkGetAnalogs(c3dH);
            catch ME
                warning('Erreur de lecture du fichier %s : %s', fileName, ME.message);
                continue;
            end
            
            figure;
            sgtitle(sprintf('Sujet %s - %s', subjects{subj_idx}, analytic_labels{f_idx}));
            % Permet de normaliser les axes
            ax = gobjects(nb_muscles, 1); 
            
            for m = 1:nb_muscles
                ax(m) = subplot(ceil(nb_muscles/2), 2, m);
                hold on;
                
                % Affichage des données des muscles des deux épaules
                for side = 1:2
                    if side == 1
                        muscle_name = muscles_R{m};
                        color = 'b';
                    else
                        muscle_name = muscles_L{m};
                        color = 'r';
                    end
                    
                    if isfield(analogs, muscle_name)
                        signal = analogs.(muscle_name);
                        time_normalised = linspace(0, 1, length(signal));
                        plot(time_normalised, abs(signal), 'Color', color, 'LineWidth', 1.2);
                        title(muscle_name(2:end));
                        xlabel('Temps normalisé');
                        ylabel('EMG (V)');
                        grid on;
                    else
                        title(sprintf('%s (Données absentes)', muscle_name(2:end)));
                    end
                end
                hold off;
            end
            
            for k = 1:length(ax)
                ax(k).YAxis.Exponent = 0;
            end
            linkaxes(ax, 'y');
        end
    end
end
