function edges = edge_detection(original_imgs,varargin)

    % set optional variable
    p = inputParser;
    addParameter(p,'visualizeMatchedPoint',false);
    parse(p,varargin{:});
    visualizeMatchedPoint = p.Results.visualizeMatchedPoint;

    % check if original_img contains exactly 2 images
    if size(original_imgs,2) ~= 2
        error('Input must contain exactly 2 images.');
    end

    % store image
    img1 = original_imgs{1};
    img2 = original_imgs{2};
    
    [img1,img2] = preprocessing(img1,img2);
    if visualizeMatchedPoint
        showImg(img1,img2,"preprocessing result");
    end

    edg1 = detect_for_single_img(img1);
    edg2 = detect_for_single_img(img2);

    edges{1} = edg1;
    edges{2} = edg2;

end


function edg = detect_for_single_img(img)
    edg = trial2(img);

end

function edg = trial1(img)

    I = im2double(img);

    Gx = [-1 1];
    Gy = Gx';
    Ix = conv2(I,Gx,'same');
    Iy = conv2(I,Gy,'same');

    edgeFIS = mamfis('Name','edgeDetection');

    edgeFIS = addInput(edgeFIS,[-1 1],'Name','Ix');
    edgeFIS = addInput(edgeFIS,[-1 1],'Name','Iy');

    sx = 0.1;
    sy = 0.1;
    edgeFIS = addMF(edgeFIS,'Ix','gaussmf',[sx 0],'Name','zero');
    edgeFIS = addMF(edgeFIS,'Iy','gaussmf',[sy 0],'Name','zero');

    edgeFIS = addOutput(edgeFIS,[0 1],'Name','Iout');

    wa = 0.1;
    wb = 1;
    wc = 1;
    ba = 0;
    bb = 0;
    bc = 0.7;
    edgeFIS = addMF(edgeFIS,'Iout','trimf',[wa wb wc],'Name','white');
    edgeFIS = addMF(edgeFIS,'Iout','trimf',[ba bb bc],'Name','black');

    r1 = "If Ix is zero and Iy is zero then Iout is white";
    r2 = "If Ix is not zero or Iy is not zero then Iout is black";
    edgeFIS = addRule(edgeFIS,[r1 r2]);
    edgeFIS.Rules

    edg = zeros(size(I));
    for ii = 1:size(I,1)
        edg(ii,:) = evalfis(edgeFIS,[(Ix(ii,:));(Iy(ii,:))]');
    end
end

function edg = trial2(img)
    edg = edge(img, 'Canny', [0.1 0.3], 3);
    edg = bwmorph(edg, 'clean');
    edg = bwareaopen(edg, 100);

end