function [Angles_HT, time] = extract_HT_angles(subject, movement_choice, data_path)
    % Chemins et configuration
    chemin_dossier = fullfile(data_path, subject);

    % Noms de fichiers
    file_names = {
        sprintf('%s-PROTOCOL01-FUNCTIONAL1-01.c3d', subject), ...
        sprintf('%s-PROTOCOL01-FUNCTIONAL2-01.c3d', subject), ...
        sprintf('%s-PROTOCOL01-FUNCTIONAL3-01.c3d', subject), ...
        sprintf('%s-PROTOCOL01-FUNCTIONAL4-01.c3d', subject)
    };
    
    % Sélection du fichier
    fichier = fullfile(chemin_dossier, file_names{movement_choice});
    
    % Lecture du fichier C3D
    c3dH = btkReadAcquisition(fichier);
    
    % Extraction des marqueurs
    markers = btkGetMarkers(c3dH);
    nFrames = btkGetLastFrame(c3dH);
    fs = 200;
    time = (0:nFrames-1) / fs;
    
    % Initialisation des matrices pour stocker les angles
    Angles_HT = zeros(nFrames, 3);
    normalize_vector = @(v) v / norm(v);
    
    % Extraction des angles d'Euler
    for i = 1:nFrames
        % Repère du thorax
        SJN = markers.SJN(i,:); CV7 = markers.CV7(i,:);
        TV8 = markers.TV8(i,:); SXS = markers.SXS(i,:);
        Ot = SJN;
        Yt = normalize_vector(mean([SXS; TV8]) - mean([SJN; CV7]));
        Zt = normalize_vector(cross(SJN - CV7, mean([SXS; TV8]) - SJN));
        Xt = normalize_vector(cross(Yt, Zt));
        
        % Repère de l'humérus
        RGH = markers.RSCT(i,:); RHME = markers.RHME(i,:); RHLE = markers.RHLE(i,:);
        Rmid_HLE_HME = mean([RHLE; RHME]);
        Oh = RGH;
        Yh = normalize_vector(RGH - Rmid_HLE_HME);
        Xh = normalize_vector(cross(RGH - RHLE, RGH - RHME));
        Zh = normalize_vector(cross(Yh, Xh));
        
        % Matrices de rotation
        Rt = [Xt', Yt', Zt'];
        Rh = [Xh', Yh', Zh'];
        
        % Correction orthonormalité
        [Ut,~,Vt] = svd(Rt); Rt = Ut * Vt';
        [Uh,~,Vh] = svd(Rh); Rh = Uh * Vh';
        
        % Rotation Huméro-Thoracique
        R_HT = Rt' * Rh;
        
        % Extraction des angles d'Euler
        Angles_HT(i,:) = squeeze(R2mobileYXY_array3(reshape(R_HT,3,3,1)));
    end
    
    % Filtrage et correction
    Angles_HT = unwrap(Angles_HT);
    fc = 6;
    [b, a] = butter(2, fc / (fs/2), 'low');
    Angles_HT = filtfilt(b, a, Angles_HT);
    
    % Recentrage des angles
    for j = 1:3
        Angles_HT(:,j) = Angles_HT(:,j) - mean(Angles_HT(1:10,j));
    end
end