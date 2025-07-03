% Fonction pour interpréter la taille d'effet d de Cohen
function interpretation = interpretCohenD(d)
    d_abs = abs(d);
    if d_abs < 0.2
        interpretation = 'effet négligeable';
    elseif d_abs < 0.5
        interpretation = 'effet faible';
    elseif d_abs < 0.8
        interpretation = 'effet moyen';
    else
        interpretation = 'effet fort';
    end
end