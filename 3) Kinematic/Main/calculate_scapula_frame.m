function [Os, Xs, Ys, Zs] = calculate_scapula_frame(markers, i, normalize_vector, side)
    RSAA = markers.([side 'SAA'])(i,:);
    RSRS = markers.([side 'SRS'])(i,:);
    RSIA = markers.([side 'SIA'])(i,:);

    Os = RSAA;

    % Cadre harmonisé pour les deux côtés : même orientation de croisement
    Zs = normalize_vector(RSAA - RSRS);
    Xs = normalize_vector(cross(RSIA - RSAA, RSRS - RSAA)); % même ordre
    Ys = normalize_vector(cross(Xs, Zs));
end
