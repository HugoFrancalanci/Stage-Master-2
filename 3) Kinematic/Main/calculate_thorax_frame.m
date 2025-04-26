function [Ot, Xt, Yt, Zt] = calculate_thorax_frame(markers, i, normalize_vector)
    SJN = markers.SJN(i,:); 
    CV7 = markers.CV7(i,:);
    TV8 = markers.TV8(i,:); 
    SXS = markers.SXS(i,:);
    
    Ot = SJN;
    Yt = normalize_vector(mean([SXS; TV8]) - mean([SJN; CV7]));
    Zt = normalize_vector(cross(SJN - CV7, mean([SXS; TV8]) - SJN));
    Xt = normalize_vector(cross(Yt, Zt));
end