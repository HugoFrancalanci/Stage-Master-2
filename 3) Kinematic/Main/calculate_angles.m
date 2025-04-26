function [Angles_GH, Angles_ST, Angles_HT] = calculate_angles(markers, nFrames, side)
    Angles_GH = zeros(nFrames, 3);
    Angles_ST = zeros(nFrames, 3);
    Angles_HT = zeros(nFrames, 3);

    normalize_vector = @(v) v / norm(v);

    for i = 1:nFrames
        try
            [Ot, Xt, Yt, Zt] = calculate_thorax_frame(markers, i, normalize_vector);
            [Os, Xs, Ys, Zs] = calculate_scapula_frame(markers, i, normalize_vector, side);
            [Oh, Xh, Yh, Zh] = calculate_humerus_frame(markers, i, normalize_vector, side);

            [R_HT, R_ST, R_GH] = calculate_rotation_matrices(Xt, Yt, Zt, Xs, Ys, Zs, Xh, Yh, Zh);

            Angles_HT(i,:) = squeeze(R2mobileYXY_array3(reshape(R_HT,3,3,1)));
            Angles_ST(i,:) = squeeze(R2mobileYXZ_array3(reshape(R_ST,3,3,1)));
            Angles_GH(i,:) = squeeze(R2mobileYXY_array3(reshape(R_GH,3,3,1)));

        catch
            if i > 1
                Angles_GH(i,:) = Angles_GH(i-1,:);
                Angles_ST(i,:) = Angles_ST(i-1,:);
                Angles_HT(i,:) = Angles_HT(i-1,:);
            else
                Angles_GH(i,:) = NaN(1,3);
                Angles_ST(i,:) = NaN(1,3);
                Angles_HT(i,:) = NaN(1,3);
            end
        end
    end
end
