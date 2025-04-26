function [Oh, Xh, Yh, Zh] = calculate_humerus_frame(markers, i, normalize_vector, side)
    RGH = markers.([side 'SCT'])(i,:);
    RHME = markers.([side 'HME'])(i,:);
    RHLE = markers.([side 'HLE'])(i,:);

    Rmid_HLE_HME = mean([RHLE; RHME]);
    Oh = RGH;

    % Cadre harmonisé pour les deux côtés : même orientation de croisement
    Yh = normalize_vector(RGH - Rmid_HLE_HME);
    Xh = normalize_vector(cross(RGH - RHLE, RGH - RHME)); % même ordre pour tous
    Zh = normalize_vector(cross(Yh, Xh));
end

