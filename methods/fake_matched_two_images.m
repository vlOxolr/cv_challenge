function [matched,imgs,highlights] = matched_two_images(original_imgs)
% input:
% original_imgs: list which contains two original images
% output:
% matched: determine if 2 img matched or not (bool)
% imgs: list which contains two corrected images
% highlights: img of difference highlights
    matched = true;
    imgs = orignal_imgs;

    [height, width, ~] = size(original_imgs(1));

    % set white background
    output_image = uint8(255 * ones(height, width, 3));
    
    % compute triangle position
    centerX = width / 2;
    centerY = height / 2;
    side_length = min(height, width) / 3;
    theta = pi/2;
    x = centerX + side_length * cos([theta, theta + 2*pi/3, theta + 4*pi/3]);
    y = centerY - side_length * sin([theta, theta + 2*pi/3, theta + 4*pi/3]);
    
    % triangle mask
    mask = poly2mask(x, y, height, width);
    
    % get RGB channel
    R = output_image(:,:,1);
    G = output_image(:,:,2);
    B = output_image(:,:,3);
    
    % yellow mask
    R(mask) = 255;
    G(mask) = 255;
    B(mask) = 0;
    
    % merge channel
    output_image(:,:,1) = R;
    output_image(:,:,2) = G;
    output_image(:,:,3) = B;

    highlights = output_image;
end