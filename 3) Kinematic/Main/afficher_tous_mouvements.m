function afficher_tous_mouvements(combined_mean_cycles, combined_std_cycles, combined_CI_cycles, num_samples_per_cycle) 
    cycle_time_norm = linspace(0, 100, num_samples_per_cycle);
    articulations = {'GH', 'ST', 'HT'};
    couleurs = {'r', 'g', 'b'};
    titres = {{'Plan élévation', 'Élévation', 'Rotation axiale'},
              {'Protraction/Rétraction', 'Rotation médiale/latérale', 'Inclinaison'},
              {'Plan élévation global', 'Élévation globale', 'Rotation axiale globale'}};

    for a = 1:3
        figure;
        sgtitle(sprintf('Cycle moyen global - %s - Tous mouvements confondus', articulations{a}));

        for c = 1:3
            subplot(3,1,c);
            plot(cycle_time_norm, rad2deg(combined_mean_cycles.(articulations{a})(:,c)), couleurs{c}, 'LineWidth', 2);
            hold on;
            fill([cycle_time_norm, fliplr(cycle_time_norm)], ...
                [rad2deg(combined_mean_cycles.(articulations{a})(:,c) + combined_std_cycles.(articulations{a})(:,c))', ...
                 fliplr(rad2deg(combined_mean_cycles.(articulations{a})(:,c) - combined_std_cycles.(articulations{a})(:,c))')], ...
                couleurs{c}, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
            plot(cycle_time_norm, rad2deg(combined_CI_cycles.([articulations{a} '_upper'])(:,c)), 'k--', 'LineWidth', 1);
            plot(cycle_time_norm, rad2deg(combined_CI_cycles.([articulations{a} '_lower'])(:,c)), 'k--', 'LineWidth', 1);
            ylabel([titres{a}{c} ' (°)']);
            if c == 3
                xlabel('% du cycle');
            end
            title(['Composante ' num2str(c)]);
            grid on;
            if c == 1
                legend('Moyenne', 'Écart type', 'IC 95%', 'Location', 'best');
            end
        end
    end
end
