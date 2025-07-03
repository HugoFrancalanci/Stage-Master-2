% Fonction pour interpréter la taille d'effet
function interpretation = interpretCohenD(d)
    if d < 0.2
        interpretation = 'effet négligeable';
    elseif d < 0.5
        interpretation = 'effet faible';
    elseif d < 0.8
        interpretation = 'effet moyen';
    else
        interpretation = 'effet fort';
    end
end