% Fonction auxiliaire pour les conditions
function result = iif(condition, trueValue, falseValue)
    if condition
        result = trueValue;
    else
        result = falseValue;
    end
end