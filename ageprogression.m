% function imwarpdemo(manIm,babyIm,grandpaIm,manPts,babyPts,grandpaPts)
function ageprogression()
%% Read in input
manIm = rgb2gray(imread('bruce03.jpg'));
manPts = csvread('manPts.csv');
babyIm = rgb2gray(imread('baby03.jpg'));
babyPts = csvread('babyPts.csv');
grandpaIm = rgb2gray(imread('grandpa02.jpg'));
grandpaPts = csvread('grandpaPts.csv');

%% Init
a = 1;
b = 1;
manMidIm = manIm;
babyMidIm = babyIm;
grandpaMidIm = grandpaIm;
outputIm = manIm;

f = figure('Visible','off','Position',[360,500,600,750]);


shapeTXT = uicontrol(f,'Style','text','String','Shape Blend',...
    'Position',[50,90,150,15]);
shapeEDT = uicontrol(f,'Style','edit','String',num2str(a),...
    'Position',[200,90,50,15]);
shapeBlend = uicontrol(f,'Style','slider',...
    'Max', 2,...
    'Min', 0,...
    'Value', a,...
    'SliderStep',[.01 .05],...
    'Position',[25,70,550,20],...
    'Callback',@(src,event)shapeBlend_cb(src,event));

colorTXT = uicontrol(f,'Style','text','String','Color Blend',...
    'Position',[50,40,150,15]);
colorEDT = uicontrol(f,'Style','edit','String',num2str(b),...
    'Position',[200,40,50,15]);
colorBlend = uicontrol(f,'Style','slider',...
    'Max', 2,...
    'Min', 0,...
    'Value', b,...
    'SliderStep',[.01 .05],...
    'Position',[25,20,550,20],...
    'Callback',@(src,event)colorBlend_cb(src,event));

babyAxes = axes('Position',[.05,.80,.16,.20]);
manAxes = axes('Position',[.05,.62,.16,.20]);
grandpaAxes = axes('Position',[.05,.44,.16,.20]);
babyMaskAxes =  axes('Position',[.80,.80,.16,.20]);
manMaskAxes =  axes('Position',[.80,.62,.16,.20]);
grandpaMaskAxes = axes('Position',[.80,.44,.16,.20]);
babyMidAxes =  axes('Position',[.05,.15,.24,.30]);
manMidAxes =  axes('Position',[.39,.15,.24,.30]);
grandpaMidAxes = axes('Position',[.72,.15,.24,.30]);
outputAxes =  axes('Position',[.25,.40,.52,.65]);



tri  = delaunay(manPts(:,1),manPts(:,2));
set(f,'CurrentAxes',manAxes); imshow(manIm);
set(f,'CurrentAxes',babyAxes); imshow(babyIm);
set(f,'CurrentAxes',grandpaAxes); imshow(grandpaIm);
set(f,'CurrentAxes',manMaskAxes); imshow(manIm);
hold on; triplot(tri,manPts(:,1),manPts(:,2));
set(f,'CurrentAxes',babyMaskAxes); imshow(babyIm);
hold on; triplot(tri,babyPts(:,1),babyPts(:,2));
set(f,'CurrentAxes',grandpaMaskAxes); imshow(grandpaIm);
hold on; triplot(tri,grandpaPts(:,1),grandpaPts(:,2));
set(f,'CurrentAxes',manMidAxes); imshow(manMidIm);
set(f,'CurrentAxes',babyMidAxes); imshow(babyMidIm);
set(f,'CurrentAxes',grandpaMidAxes); imshow(grandpaMidIm);
set(f,'CurrentAxes',outputAxes); imshow(outputIm);


% Assign the GUI a name to appear in the window title.
set(f,'Name','Age Progression - by Rich Nguyen');
% Move the GUI to the center of the screen.
movegui(f,'center');
% Make the GUI visible.
set(f,'Visible','on');

%% Apps Fucntions
    function shapeBlend_cb(src,event)
        a = get(src,'Value');
        set(shapeEDT,'String',num2str(a));
        changeShapeBlend();
    end

    function colorBlend_cb(src,event)
        b = get(src,'Value');
        set(colorEDT,'String',num2str(b));
        changeColorBlend();
    end


    function changeShapeBlend()
        if a < 1
            if (b > 1)
                b = .7;
                set(colorEDT,'String',num2str(b));
                set(colorBlend,'Value',b);
            end
            midPts  = a * manPts + (1-a) * babyPts;
            manMidIm = findMidIm(manIm,manPts,midPts);
            babyMidIm= findMidIm(babyIm,babyPts,midPts);
            set(f,'CurrentAxes',manMidAxes); imshow(manMidIm,[]);
            set(f,'CurrentAxes',babyMidAxes); imshow(babyMidIm,[]);
        else
            if (b < 1)
                b = 1.7;
                set(colorEDT,'String',num2str(b));
                set(colorBlend,'Value',b);
            end
            midPts  = (a-1) * grandpaPts + (2-a) * manPts;
            manMidIm = findMidIm(manIm,manPts,midPts);
            grandpaMidIm= findMidIm(grandpaIm,grandpaPts,midPts);
            set(f,'CurrentAxes',manMidAxes); imshow(manMidIm,[]);
            set(f,'CurrentAxes',grandpaMidAxes); imshow(grandpaMidIm,[]);
        end
        changeColorBlend();
    end

    function changeColorBlend()
        if b < 1
            outputIm = b * manMidIm + (1-b) * babyMidIm;
        else
            outputIm = (2-b) * manMidIm + (b-1) * grandpaMidIm;
        end
        set(f,'CurrentAxes',outputAxes); imshow(outputIm,[]);
    end

    function wrapedIm = findMidIm(manIm,manPts,midPts)
        % Morp man into the middle image
        [R C] = size(manIm);
        wrapedIm = zeros(R,C);
        % calculate displacements
        displaceC = manPts(:,1) - midPts(:,1);
        displaceR = manPts(:,2) - midPts(:,2);
        % interators
        Cx = 1:C;
        Rx = 1:R;

        % create mesh
        [Ci Ri] = meshgrid(Cx,Rx);

        % get grid data for interpolation
        displaceGridC = round(griddata(manPts(:,1), manPts(:,2), displaceC, Cx', Rx, 'linear'));
        displaceGridR = round(griddata(manPts(:,1), manPts(:,2), displaceR, Cx', Rx, 'linear'));

        % remove NaN from the grid
        displaceGridC(isnan(displaceGridC))= 0;
        displaceGridR(isnan(displaceGridR))= 0;

        % map each pixel
        newCi = Ci + displaceGridC;
        newRi = Ri + displaceGridR;

        % adjust so that all pixel locations are within the image
        newCi(newCi(:) < 1) = 1;
        newCi(newCi(:) > C) = C;
        newRi(newRi(:) < 1) = 1;
        newRi(newRi(:) > R) = R;

        % Wrap image
        for r = 1: R
            for c = 1: C
                wrapedIm(r,c) = manIm(newRi(r,c),newCi(r,c));
            end
        end

    end %function

end
