
function activation_summary = resume_cinematique(combined_mean_cycles, num_samples_per_cycle)
    activation_summary = struct();
    angle_labels = {'Plan élévation', 'Élévation', 'Rotation axiale'};
    articulations = {'GH', 'ST', 'HT'};
    cycle_time = linspace(0, 100, num_samples_per_cycle);

    for a = 1:length(articulations)
        joint = articulations{a};
        activation_summary.(joint) = struct();

        for c = 1:3
            angle_data = rad2deg(combined_mean_cycles.(joint)(:, c));

            [max_val, idx_max] = max(angle_data);
            max_time = cycle_time(idx_max);

            [min_val_post, idx_min_post] = min(angle_data(idx_max:end));
            idx_min_post = idx_max + idx_min_post - 1;
            return_time = cycle_time(min(idx_min_post, end));

            if idx_max > 5
                [min_val_pre, idx_min_pre] = min(angle_data(1:idx_max));
                time_min_pre = cycle_time(idx_min_pre);
            else
                min_val_pre = NaN;
                time_min_pre = NaN;
            end

            amp_total = max_val - min(angle_data);

            if ~isnan(time_min_pre) && (max_time - time_min_pre > 0)
                vitesse_aller = abs(max_val - min_val_pre) / (max_time - time_min_pre);
            else
                vitesse_aller = NaN;
            end

            delta_angle = abs(max_val - min_val_post);
            delta_time = abs(return_time - max_time);
            if delta_time > 0
                vitesse_retour = delta_angle / delta_time;
            else
                vitesse_retour = NaN;
            end

            activation_summary.(joint)(c).composante = angle_labels{c};
            activation_summary.(joint)(c).max_angle_deg = max_val;
            activation_summary.(joint)(c).time_max_pct = max_time;
            activation_summary.(joint)(c).return_time_pct = return_time;
            activation_summary.(joint)(c).amplitude_deg = amp_total;
            activation_summary.(joint)(c).vitesse_aller = vitesse_aller;
            activation_summary.(joint)(c).vitesse_retour = vitesse_retour;
        end
    end
end