function [markers, nFrames, time] = read_c3d_file(fichier, fs)
    % Lecture du fichier C3D
    c3dH = btkReadAcquisition(fichier);
    
    % Extraction des marqueurs
    markers = btkGetMarkers(c3dH);
    
    % Détermination du nombre de frames
    nFrames = btkGetLastFrame(c3dH);
    
    % Calcul du vecteur temps
    time = (0:nFrames-1) / fs;
end
