function edge = edge_detector(img)
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

    edge = zeros(size(I));
    for ii = 1:size(I,1)
        edge(ii,:) = evalfis(edgeFIS,[(Ix(ii,:));(Iy(ii,:))]');
    end
end
