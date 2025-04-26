function config = get_configuration()
    % Configuration de base
    config = struct();

    % Définition des populations disponibles
    config.populations = struct();

    % Population 1 (asymptomatique)
    config.populations.Asymptomatic = struct();
    config.populations.Asymptomatic.Subjects = { ...
    'A1', 'A2', 'A3', 'A4', 'A5',...
    'A6', 'A7', 'A8', 'A9', 'A10',...
    'A11', 'A12', 'A13', 'A14', 'A15',...
    'A16', 'A17', 'A18', 'A19', 'A20',...
    'A21', 'A22', 'A23', 'A24', 'A25',...
    'A26', 'A27', 'A28', 'A29', 'A30',...
    'A31', 'A32', 'A33', 'A34', 'A35',...
    'A36', 'A37', 'A38', 'A39', 'A40',...
    'A41'};
    config.populations.Asymptomatic.base_path = 'C:\\Users\\Francalanci Hugo\\Documents\\MATLAB\\Stage Sainte-Justine\\HUG\\Sujets\\Asymptomatic';

    % Population 2 (pathologique - pré-opératoire)
    config.populations.Pre_operatoire = struct();
    config.populations.Pre_operatoire.Subjects = { ...
    'S1', 'S2', 'S3', 'S4', 'S5', ...
    'S6', 'S7', 'S8', 'S9', 'S10', ...
    'S11', 'S12', 'S13'};
    config.populations.Pre_operatoire.base_path = 'C:\\Users\\Francalanci Hugo\\Documents\\MATLAB\\Stage Sainte-Justine\\HUG\\Sujets\\Pre_operation';

    % Population 3 (pathologique - post-opératoire)
    config.populations.Post_operatoire = struct();
    config.populations.Post_operatoire.Subjects = { ...
    'S1', 'S2', 'S3', 'S4', 'S5', ...
    'S6', 'S7', 'S8', 'S9', 'S10', ...
    'S11', 'S12', 'S13'};
    config.populations.Post_operatoire.base_path = 'C:\\Users\\Francalanci Hugo\\Documents\\MATLAB\\Stage Sainte-Justine\\HUG\\Sujets\\Post_operation';

    % Option pour choisir de traiter un seul mouvement ou tous
    config.process_all_movements = true; % Mettre false pour ne traiter qu'un seul mouvement
    config.movement_choice = 4; % Utilisé seulement si process_all_movements = false (1-4)

    % Option pour inverser le mouvement fonctionnel 4
    config.invert_functional4_right = false; % false pour pre et post-opération
    config.invert_functional4_left = false;

    % Option pour sauvegarder les données pour chaque sujet
    config.save_individual_subject_files  = false; 

    % Définir les mouvements à traiter
    if config.process_all_movements
        config.movements_to_process = 1:4;
    else
        config.movements_to_process = config.movement_choice;
    end

    % Paramètres communs
    config.fs = 200; % Fréquence d'échantillonnage
    config.num_samples_per_cycle = 100; % Nombre d'échantillons pour normaliser les cycles
    config.cycle_threshold_pct = 40; % Seuil pour la détection des cycles
    config.min_cycle_duration = 0.5 * config.fs; % Durée minimale d'un cycle (0.5 seconde)
    config.min_cycle_amplitude = 50; % Amplitude minimale pour un cycle valide
    config.filter_cutoff = 6; % Fréquence de coupure pour le filtre passe-bas
    
    % Enregistrement des statistiques
    config.output_directory = 'C:\Users\Francalanci Hugo\Documents\MATLAB\Stage Sainte-Justine\HUG\Scripts\3) Kinematic';
    return;
end
