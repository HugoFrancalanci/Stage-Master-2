function [Angles_GH, Angles_ST, Angles_HT] = invert_movement(Angles_GH, Angles_ST, Angles_HT)
    % Inverser les angles
    Angles_GH = -Angles_GH;
    Angles_ST = -Angles_ST;
    Angles_HT = -Angles_HT;
end
