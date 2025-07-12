% Main GUI File: image_analysis_gui.m

function image_analysis_gui()
    addpath("./methods")
    % Create Main Figure
    fig = uifigure('Name','Across Time and Space','Position',[100 100 1210 750]);
    % setup layout
    mainLayout = uigridlayout(fig, [2, 1]);
    mainLayout.RowHeight = {'1x', 30};
    mainLayout.ColumnWidth = {'1x'};

    % Menu
    menu = uimenu(fig,'Text','Select');
    uimenu(menu,'Text','Choose Folder','MenuSelectedFcn',@(src,event)chooseFolder(fig));

    % UI Components
    contentPanel = uipanel(mainLayout,'BorderType','none');
    contentPanel.Layout.Row = 1;
    contentPanel.Layout.Column = 1;

    % Left Panel for Folder Tree
    treePanel = uipanel(contentPanel,'Position',[10 10 250 680],'Title','Image Folder');
    tree = uitree(treePanel,'Position',[10 10 230 650], 'Multiselect', true);

    % Tab Group
    tabGroup = uitabgroup(contentPanel,'Position',[270 10 920 680]);
    tab1 = uitab(tabGroup,'Title','Highlights');
    tab2 = uitab(tabGroup,'Title','Difference Curtain');
    tab3 = uitab(tabGroup,'Title','Time Lapse');
    % tab flag
    tabGroup.SelectionChangedFcn = @(src, event)onTabChanged(src, event, fig);

    % Axes for each tab
    ax1 = uiaxes(tab1,'Position',[30 30 850 560],'Visible','off');
    ax1.XColor = 'none';  
    ax1.YColor = 'none';  
    axis(ax1, 'off');     
    ax2 = uiaxes(tab2,'Position',[30 30 850 560],'Visible','off');
    ax2.XColor = 'none';  
    ax2.YColor = 'none';  
    axis(ax2, 'off');     
    ax3 = uiaxes(tab3,'Position',[30 30 850 560],'Visible','off');
    ax3.XColor = 'none';  
    ax3.YColor = 'none';  
    axis(ax3, 'off'); 

    % Status bar
    statusPanel = uipanel(mainLayout);
    statusPanel.Layout.Row = 2;
    statusPanel.Layout.Column = 1;
    statusLabel = uilabel(statusPanel, ...
        'Text', 'Ready', ...
        'HorizontalAlignment', 'left', ...
        'Position', [10, 0, 1180, 20]);

    % Shared State
    appData.selectedFolder = fullfile(pwd,"datasets");
    appData.selectedImages = {};
    appData.imageCache = {};
    appData.ax1 = ax1;
    appData.ax2 = ax2;
    appData.ax3 = ax3;
    appData.alphaSliders = [];
    appData.sliderCurtain = [];
    appData.tab = tabGroup;
    appData.tree = tree;
    appData.activeTab = tab1;
    appData.statusLabel = statusLabel;

    guidata(fig, appData);

    % Initialize Tree
    initializeTree(fig);

    % Setup Tabs
    setupTab1(tab1, fig);
    setupTab2(tab2, fig);
    setupTab3(tab3, fig);

end

%% functions for file selection
function chooseFolder(fig)
    folder = uigetdir();
    if folder ~= 0
        appData = guidata(fig);
        appData.selectedFolder = folder;
        appData.selectedImages = {};
        appData.imageCache = {};
        guidata(fig, appData);
        initializeTree(fig);
    end
end

function initializeTree(fig)
    appData = guidata(fig);
    tree = appData.tree;
    delete(tree.Children);

    rootPath = appData.selectedFolder;
    rootNode = uitreenode(tree, 'Text', rootPath, 'NodeData', rootPath);
    buildTreeNodes(rootNode, rootPath);
    expand(rootNode);

    % expand sub folder
    for i = 1:length(rootNode.Children)
        childNode = rootNode.Children(i);
        childPath = childNode.NodeData;
        if isfolder(childPath)
            expand(childNode);
        end
    end

    tree.SelectionChangedFcn = @(src, event)onNodeSelected(src, event, fig);
end

function buildTreeNodes(parentNode, folderPath)
    files = dir(folderPath);
    files = files(~ismember({files.name}, {'.', '..'}));

    for i = 1:length(files)
        thisFile = files(i);
        fullPath = fullfile(folderPath, thisFile.name);

        if thisFile.isdir
            node = uitreenode(parentNode, 'Text', thisFile.name, 'NodeData', fullPath);
            buildTreeNodes(node, fullPath);
        else
            uitreenode(parentNode, 'Text', thisFile.name, 'NodeData', fullPath);
        end
    end
end

function isImg = isImage(filename)
    [~,~,ext] = fileparts(filename);
    isImg = any(strcmpi(ext,{'.jpg','.jpeg','.png','.bmp'}));
end

function onNodeSelected(src,event,fig)
    appData = guidata(fig);
    selectedNode = event.SelectedNodes;
    if isempty(selectedNode)
        return;
    end
    path = selectedNode.NodeData;
    if isfolder(path)
        files = dir(fullfile(path,'*.*'));
        files = files(~startsWith({files.name}, '.'));
        images = {};
        for i = 1:length(files)
            if isImage(files(i).name)
                images{end+1} = imread(fullfile(path, files(i).name));
            end
        end
        appData.selectedImages = images;
    else
        selected = event.SelectedNodes;
        if length(selected) >= 2 && appData.activeTab.Title ~= "Time Lapse"
            selected = selected(end-1:end);
        end
        appData.selectedImages = {};
        for i = 1:length(selected)
            node = selected(i);
            appData.selectedImages{end+1} = imread(node.NodeData);
        end
    end
    guidata(fig, appData);
end

%% functions for highlights
function setupTab1(tab, fig)
    % Match button
    matchBtn = uibutton(tab,'Text','Match','Position',[30 610 100 30],...
        'ButtonPushedFcn',@(btn,event)onMatchHighlights(fig));
   
    % Transparency sliders
    s1 = uislider(tab,'Position',[150 615 200 3],'Limits',[0 1],'Value',1);
    s2 = uislider(tab,'Position',[380 615 200 3],'Limits',[0 1],'Value',1);
    s3 = uislider(tab,'Position',[610 615 200 3],'Limits',[0 1],'Value',1);

    % Axes for image display
    ax = uiaxes(tab,'Position',[30 30 850 560]);
    ax.Visible = 'off';

    % Store references
    appData = guidata(fig);
    appData.imgAxes = ax;
    appData.alphaSliders = [s1 s2 s3];
    

    % setup ticks (transparent: 0-100%)
    s1.MajorTicks = [0 1];
    s1.MajorTickLabels = {'0', '100'};
    s2.MajorTicks = [0 1];
    s2.MajorTickLabels = {'0', '100'};
    s3.MajorTicks = [0 1];
    s3.MajorTickLabels = {'0', '100'};

     % setup slider name
    appData.slider_highlight_lbl = uilabel(tab, 'Text', 'Highlights', 'Position', [150 635 100 20]);
    appData.slider_img1_lbl = uilabel(tab, 'Text', 'Image 1:', 'Position', [380 635 100 20]);  % dynamic modification follows
    appData.slider_img2_lbl = uilabel(tab, 'Text', 'Image 2:', 'Position', [610 635 100 20]);  % dynamic modification follows

    guidata(fig, appData);

end

function onMatchHighlights(fig)
    appData = guidata(fig);

    if length(appData.selectedImages) ~= 2
        uialert(fig,'Please select exactly 2 images.','Selection Error');
        return;
    end

    imgs{1} = appData.selectedImages{1};
    imgs{2} = appData.selectedImages{2};

    % Call analysis method
    funcPath = './methods/two_image_analysis.m';
    if exist(funcPath,'file')
        logStatus(fig,"Matching starts.");
        [matched,imgcell,highlight] = two_image_analysis(imgs,fig);
        if ~matched
            uialert(fig,'Matching failed.','Error');
            return;
        end

        % dsp
        logStatus(fig,"Matching completed.");

        % Show blended image
        ax = appData.ax1;
        cla(ax);
        ax.Visible = 'on';

        % Store image data
        appData.imgHighlight = highlight;
        appData.img1 = imgcell{1};
        appData.img2 = imgcell{2};

        % Initial blend
        alpha1 = appData.alphaSliders(1).Value;
        alpha2 = appData.alphaSliders(2).Value;
        alpha3 = appData.alphaSliders(3).Value;
        blended = blendThreeImages(appData.imgHighlight, appData.img1, appData.img2, [alpha1, alpha2, alpha3]);
        h = imshow(blended, 'Parent', ax);
        appData.blendedImageHandle = h;

        % Setup slider callbacks
        for k = 1:3
            appData.alphaSliders(k).ValueChangedFcn = @(s,e)onSliderUpdateBlend(fig);
        end

        guidata(fig, appData);

        % dynamic update of slider name
        if isfield(appData, "tree") && isprop(appData.tree, "SelectedNodes")
            nodes = appData.tree.SelectedNodes;
            if length(nodes) >= 2
                name1 = getFileName(nodes(end-1).NodeData);
                name2 = getFileName(nodes(end).NodeData);
                appData.slider_img1_lbl.Text = "Image 1: " + name1;
                appData.slider_img2_lbl.Text = "Image 2: " + name2;
            end
        end
    else
        uialert(fig,'Method "two_image_analysis" not found.','Missing Method');
    end
end

function name = getFileName(fullPath)
    [~, name, ~] = fileparts(fullPath);
end

function onSliderUpdateBlend(fig)
    appData = guidata(fig);

    alpha1 = appData.alphaSliders(1).Value;
    alpha2 = appData.alphaSliders(2).Value;
    alpha3 = appData.alphaSliders(3).Value;

    blended = blendThreeImages(appData.imgHighlight, appData.img1, appData.img2, [alpha1, alpha2, alpha3]);

    if isvalid(appData.blendedImageHandle)
        appData.blendedImageHandle.CData = blended;
    end

    guidata(fig, appData);
end

function output = blendThreeImages(imgA, imgB, imgC, alphas)
    % Ensure size in same
    assert(isequal(size(imgA), size(imgB), size(imgC)), 'Images must be same size');

    % Convert to double
    A = im2double(imgA);
    B = im2double(imgB);
    C = im2double(imgC);

    % Normalize alpha weights
    if sum(alphas) == 0
        alphas = [1, 1, 1]; % avoid divide by zero
    end
    w = alphas / sum(alphas);

    % Weighted blending
    output = w(1)*A + w(2)*B + w(3)*C;

    % Convert back to uint8
    output = im2uint8(output);
end

%% functions for difference curtain
function setupTab2(tab, fig)
    % Match button
    matchBtn = uibutton(tab,'Text','Match','Position',[30 610 100 30],...
        'ButtonPushedFcn',@(btn,event)onMatchCurtain(fig));

    % Curtain slider
    slider = uislider(tab,'Position',[150 615 600 3],'Limits',[0 1],'Value',0.5);

    % Axes for image display 
    ax = uiaxes(tab,'Position',[30 30 850 560]);
    ax.Visible = 'off';

    % Store
    appData = guidata(fig);
    appData.imgAxes = ax;
    appData.sliderCurtain = slider;
    guidata(fig, appData);

    % setup sliders
    slider.MajorTicks = [0 1];
    slider.MajorTickLabels = {'Image 1', 'Image 2'};
end

function onMatchCurtain(fig)
    appData = guidata(fig);
    imgs = appData.selectedImages;
    if length(imgs) ~= 2
        uialert(fig,'Please select exactly 2 images.','Selection Error');
        return;
    end
    % Call analysis method
    if exist('./methods/two_image_analysis.m','file')
        logStatus(fig,"Matching starts.");
        [matched,imgcell,~] = two_image_analysis(imgs,fig);
        if ~matched
            uialert(fig,'Matching failed.','Error');
            return;
        end

        % dsp
        logStatus(fig,"Matching completed.");

        % Show curtain view
        ax = appData.ax2;
        cla(ax);
        ax.Visible = 'on';
        top = imgcell{2};
        bottom = imgcell{1};

        % Store images and handle
        imgSize = size(top);
        blendImage = image(ax,zeros(imgSize,'uint8'));

        % Slider interaction
        appData.sliderCurtain.ValueChangedFcn = @(s,e)updateCurtainView(blendImage,top,bottom,s.Value);
        updateCurtainView(blendImage,top,bottom,appData.sliderCurtain.Value);
    else
        uialert(fig,'Method "two_image_analysis" not found.','Missing Method');
    end

    % setup slider for tab2
    if isfield(appData, "tree") && isprop(appData.tree, "SelectedNodes")
        nodes = appData.tree.SelectedNodes;
        if length(nodes) >= 2
            name1 = getFileName(nodes(end-1).NodeData);
            name2 = getFileName(nodes(end).NodeData);
            appData.sliderCurtain.MajorTickLabels = [name1, name2];
        end
    end
end

function updateCurtainView(hImg, top, bottom, ratio)
    % Calculate blend region
    w = size(top,2);
    split = round(ratio * w);
    
    % Ensure split in bounds
    split = max(1, min(split, w-1));

    % Blend image
    leftPart  = bottom(:, 1:split, :);
    rightPart = top(:, split+1:end, :);

    % Create yellow line: size [height x 1 x 3]
    h = size(top, 1);
    yellowLine = uint8(zeros(h, 3, 3));
    yellowLine(:,:,1) = 255;  % Red
    yellowLine(:,:,2) = 255;  % Green

    % Concatenate
    composite = [leftPart, yellowLine, rightPart];
    hImg.CData = composite;
end

%% functions for time lapse
function setupTab3(tab, fig)
    % Match & Reset Buttons
    matchBtn = uibutton(tab,'Text','Match','Position',[30 610 100 30],...
        'ButtonPushedFcn',@(btn,event)onMatchTimelapse(fig));

    % Axes
    ax = uiaxes(tab,'Position',[30 70 850 520]);
    ax.Visible = 'off';
    ax.XColor = 'none';
    ax.YColor = 'none';
    axis(ax, 'off');

    % Scroll bar (slider)
    slider = uislider(tab, 'Position', [30 40 850 3], 'Limits', [1 2], 'Value', 1, 'MajorTicks', []);
    slider.ValueChangedFcn = @(s,e)onSliderChanged(fig, round(s.Value));

    % Frame label
    label = uilabel(tab, 'Position', [890 35 80 20], 'Text', '1 / 1');

    % Store
    appData = guidata(fig);
    appData.imgAxes = ax;
    appData.sliderTimeline = slider;
    appData.labelTimeline = label;
    appData.timelineImgs = {};
    appData.playIndex = 1;
    guidata(fig, appData);
end

function onMatchTimelapse(fig)
    appData = guidata(fig);
    imgs = appData.selectedImages;

    if length(imgs) < 2
        uialert(fig, 'Please select at least 2 images.', 'Selection Error');
        return;
    end

    if exist('./methods/multiple_image_analysis.m','file')
        logStatus(fig,"Matching starts.");
        resultImgs = multiple_image_analysis(imgs,fig);
        if isempty(resultImgs)
            uialert(fig,'No images matched.','No Result');
            return;
        end

        % dsp
        logStatus(fig,"Matching completed.");

        % store results and reset state
        appData.timelineImgs = resultImgs;
        appData.playIndex = 1;
        guidata(fig, appData);

        % setup slider
        slider = appData.sliderTimeline;
        slider.Limits = [1, length(resultImgs)];
        slider.MajorTicks = 1:length(resultImgs);
        slider.Value = 1;
        % get image name for ticks
        if isfield(appData, "tree") && isprop(appData.tree, "SelectedNodes")
            nodes = appData.tree.SelectedNodes;
            if length(nodes) >= 1
                names = getFileNameList(nodes);
                slider.MajorTickLabels = names; 
            end
        end

        % setup label
        label = appData.labelTimeline;
        label.Text = sprintf("1 / %d", length(resultImgs));

        % display in loop
        ax = appData.ax3;
        ax.Visible = 'on';

        while isvalid(fig) && strcmp(appData.activeTab.Title, "Time Lapse")
            appData = guidata(fig);  % refresh every time

            i = appData.playIndex;
            if i > length(appData.timelineImgs)
                i = 1;
            end

            imshow(appData.timelineImgs{i}, 'Parent', ax);
            appData.sliderTimeline.Value = i;
            appData.labelTimeline.Text = sprintf('%d / %d', i, length(appData.timelineImgs));

            % prepare next index
            appData.playIndex = mod(i, length(appData.timelineImgs)) + 1;

            guidata(fig, appData);  % update back

            pause(1.5);
        end
    else
        uialert(fig,'Method "multiple_image_analysis" not found.','Missing Method');
    end
end

function onSliderChanged(fig, index)
    appData = guidata(fig);
    if isempty(appData.timelineImgs)
        return;
    end
    ax = appData.ax3;
    ax.Visible = 'on';
    imshow(appData.timelineImgs{index}, 'Parent', ax);
    appData.sliderTimeline.Value = index;
    appData.labelTimeline.Text = sprintf('%d / %d', index, length(appData.timelineImgs));

    % update index to display next img
    appData.playIndex = index;
    guidata(fig, appData);
end

function onTabChanged(src, event, fig)
    appData = guidata(fig);
    currentTab = event.NewValue;  % this is a uitab object
    appData.activeTab = currentTab;  % store active tab handle
    guidata(fig, appData);
end

function names = getFileNameList(nodes)
    
    if isscalar(nodes) % no problem with least image selection number
        files = dir(fullfile(nodes.NodeData,'*.*'));
        files = files(~startsWith({files.name}, '.'));
        lists = cell(length(files));
        for i = 1:length(files)
            lists{i} = files(i).name;
        end
    else
        lists = cell(length(nodes));
        for i = 1:length(nodes)
            lists{i} = nodes(i).NodeData;
        end
    end

    names = strings(1, length(lists));
    for i = 1:length(lists)
        [~, name, ~] = fileparts(lists{i});
        names(i) = name;
    end
end

