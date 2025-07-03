function centered_angles = center_angles(angles)
    centered_angles = angles;
    for i = 1:3
        centered_angles(:,i) = angles(:,i) - mean(angles(1:10,i));
    end
end