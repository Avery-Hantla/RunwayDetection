clear
clc
edgeDetection


function edgeDetection  
   % Gets image from the input folder    
   inputImages = dir(['Input']);
   cd Input/
   fileName = inputImages(3).name;
   I = imread(fileName);
   cd ../
   % Processes image and applys filters
   rotI = imrotate(I,0,'crop');
   I = (0.2989 * double(I(:,:,1)) + 0.5870 * double(I(:,:,2)) + 0.1140 * double(I(:,:,3)))/255;
   BW = edge(I,'canny');

   [H,theta,rho] = hough(BW);
   P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
   lines = houghlines(BW,theta,rho,P,'FillGap',25,'MinLength',1);
   figure, imshow(rotI), hold on
    
   points = zeros(4,2);
   lineTable = zeros(2,2);
   for k = 1:length(lines)
     xy = [lines(k).point1; lines(k).point2];
     % Finds lines that are vertical
     if abs((xy(1,2)-xy(2,2))) >= 40
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
         % Plot beginnings and ends of lines
         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
         % Puts the points that are plotted in an array
         points(2,:) = xy(1,:);
         points(1,:) = xy(2,:);
         lineEquation = lineFind(I,points);
         % Puts the slope and y-int into an array 
         if lineTable(1,1) == 0 
            lineTable(1,1) = lineEquation(1);
            lineTable(1,2) = lineEquation(2);
         else
            lineTable(2,1) = lineEquation(1);
            lineTable(2,2) = lineEquation(2);
         end
     end
   end
   % Makes a table of the two lines slope and y-int and outputs them to a
   % .txt file
   Table = table(lineTable(:,2),lineTable(:,1),'VariableNames',{'Slope','Y-Intercept'});
   cd Output/
   writetable(Table, 'Runway_Lines.txt')
   exportgraphics(gca, fileName);
   cd ../
end

function lineEquation = lineFind(I,points)
    % Finds the equations of the lines
    [x,~] = size(I);
    xCords = [points(1,1),points(2,1)];
    yCords = [x-(points(1,2)),x-(points(2,2))];
    lineEquation = [[1; 1]  xCords(:)]\yCords(:);
end