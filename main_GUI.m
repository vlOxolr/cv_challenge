% Main GUI File: image_analysis_gui.m

function image_analysis_gui()
    % Create Main Figure
    fig = uifigure('Name','Image Analysis GUI','Position',[100 100 1200 700]);

    %% Menu
    menu = uimenu(fig,'Text','Select');
    uimenu(menu,'Text','Choose Folder','MenuSelectedFcn',@(src,event)chooseFolder(fig));

    %% UI Components
    % Left Panel for Folder Tree
    treePanel = uipanel(fig,'Position',[10 10 250 680],'Title','Image Folder');
    tree = uitree(treePanel,'Position',[10 10 230 650]);

    % Tab Group
    tabGroup = uitabgroup(fig,'Position',[270 10 920 680]);
    tab1 = uitab(tabGroup,'Title','Highlights');
    tab2 = uitab(tabGroup,'Title','Image Difference Curtain');
    tab3 = uitab(tabGroup,'Title','Time Lapse');

    % Shared State
    appData.selectedFolder = './dataset/givenDataset/';
    appData.selectedImages = {};
    appData.imageCache = {};
    appData.imgAxes = []; % for tab1 and tab2 image display
    appData.alphaSliders = []; % for tab1 sliders
    appData.sliderCurtain = []; % for tab2 curtain
    appData.tab = tabGroup;
    appData.tree = tree;
    guidata(fig, appData);

    % Initialize Tree
    updateTree(fig);

    % Setup Tabs
    setupTab1(tab1, fig);
    setupTab2(tab2, fig);
    setupTab3(tab3, fig);
end

function chooseFolder(fig)
    folder = uigetdir('./dataset/givenDataset/');
    if folder ~= 0
        appData = guidata(fig);
        appData.selectedFolder = folder;
        appData.selectedImages = {};
        appData.imageCache = {};
        guidata(fig, appData);
        updateTree(fig);
    end
end

function updateTree(fig)
    appData = guidata(fig);
    tree = appData.tree;
    delete(tree.Children);
    folderPath = appData.selectedFolder;
    rootNode = uitreenode(tree,'Text',folderPath,'NodeData',folderPath);
    buildTree(rootNode, folderPath);
    tree.NodeSelectedFcn = @(src,event)onNodeSelected(src,event,fig);
end

function buildTree(parentNode, folderPath)
    contents = dir(folderPath);
    for i = 1:length(contents)
        item = contents(i);
        if item.isdir && ~startsWith(item.name,'.')
            nodePath = fullfile(folderPath, item.name);
            node = uitreenode(parentNode,'Text',item.name,'NodeData',nodePath);
            node.NodeClickedFcn = @(src,event)onNodeSelected(src,event,gcf);
            buildTree(node, nodePath);
        elseif isImage(item.name)
            filePath = fullfile(folderPath, item.name);
            leafNode = uitreenode(parentNode,'Text',item.name,'NodeData',filePath);
            leafNode.NodeClickedFcn = @(src,event)onNodeSelected(src,event,gcf);
        end
    end
end

function flag = isImage(filename)
    [~,~,ext] = fileparts(filename);
    flag = any(strcmpi(ext,{'.jpg','.png','.jpeg','.bmp'}));
end

function onNodeSelected(src,event,fig)
    appData = guidata(fig);
    path = event.SelectedNodes.NodeData;
    if isfolder(path)
        % Select all images in folder (for time lapse)
        files = dir(fullfile(path,'*.*'));
        images = {};
        for i = 1:length(files)
            if isImage(files(i).name)
                images{end+1} = fullfile(path,files(i).name);
            end
        end
        appData.selectedImages = images;
    else
        % Select image for highlights or curtain
        selected = appData.selectedImages;
        if any(strcmp(path, selected))
            return;
        end
        if length(selected) >= 2
            selected = selected(2:end);
        end
        selected{end+1} = path;
        appData.selectedImages = selected;
    end
    guidata(fig, appData);
end



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
    guidata(fig, appData);
end

function onMatchHighlights(fig)
    appData = guidata(fig);
    imgs = appData.selectedImages;
    if length(imgs) ~= 2
        uialert(fig,'Please select exactly 2 images.','Selection Error');
        return;
    end
    % Call analysis method
    funcPath = './methods/two_image_analysis.m';
    if exist(funcPath,'file')
        [matched,imgcell,highlight] = two_image_analysis(imgs);
        if ~matched
            uialert(fig,'Matching failed.','Error');
            return;
        end
        % Show images stacked
        ax = appData.imgAxes;
        cla(ax);
        hold(ax,'on');
        h1 = imshow(highlight,'Parent',ax);
        h2 = imshow(imgcell{1},'Parent',ax);
        h3 = imshow(imgcell{2},'Parent',ax);
        ax.Visible = 'on';

        % Set Alpha control
        sliders = appData.alphaSliders;
        h1.AlphaData = sliders(1).Value;
        h2.AlphaData = sliders(2).Value;
        h3.AlphaData = sliders(3).Value;

        sliders(1).ValueChangedFcn = @(s,e)set(h1,'AlphaData',s.Value);
        sliders(2).ValueChangedFcn = @(s,e)set(h2,'AlphaData',s.Value);
        sliders(3).ValueChangedFcn = @(s,e)set(h3,'AlphaData',s.Value);
    else
        uialert(fig,'Method "two_image_analysis" not found.','Missing Method');
    end
end


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
        [matched,imgcell,~] = two_image_analysis(imgs);
        if ~matched
            uialert(fig,'Matching failed.','Error');
            return;
        end
        % Show curtain view
        ax = appData.imgAxes;
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
end

function updateCurtainView(hImg, top, bottom, ratio)
    % Calculate blend region
    w = size(top,2);
    split = round(ratio * w);
    composite = [bottom(:,1:split,:), top(:,split+1:end,:)];
    hImg.CData = composite;
end


function setupTab3(tab, fig)
    % Match & Reset Buttons
    matchBtn = uibutton(tab,'Text','Match','Position',[30 610 100 30],...
        'ButtonPushedFcn',@(btn,event)onMatchTimelapse(fig));
    resetBtn = uibutton(tab,'Text','Reset','Position',[150 610 100 30],...
        'ButtonPushedFcn',@(btn,event)onResetTimelapse(fig));

    % Axes
    ax = uiaxes(tab,'Position',[30 30 850 560]);
    ax.Visible = 'off';

    % Store
    appData = guidata(fig);
    appData.imgAxes = ax;
    guidata(fig, appData);
end

function onResetTimelapse(fig)
    appData = guidata(fig);
    appData.selectedImages = {};
    guidata(fig, appData);
end

function onMatchTimelapse(fig)
    appData = guidata(fig);
    imgs = appData.selectedImages;
    if isempty(imgs)
        uialert(fig,'Please select images or folder first.','Selection Error');
        return;
    end
    % Call batch match function
    if exist('./methods/multiple_image_analysis.m','file')
        resultImgs = multiple_image_analysis(imgs);
        if isempty(resultImgs)
            uialert(fig,'No images matched.','No Result');
            return;
        end
        % Play slide show
        ax = appData.imgAxes;
        ax.Visible = 'on';
        for i = 1:length(resultImgs)
            imshow(resultImgs{i},'Parent',ax);
            pause(1.5);
        end
    else
        uialert(fig,'Method "multiple_image_analysis" not found.','Missing Method');
    end
end