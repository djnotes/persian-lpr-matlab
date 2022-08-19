clc
clear
close all



%%
%Open Image
 [name file] = uigetfile('*.jpg', 'Select an image');

fileName=[file name];
I = imread(fileName);
outDir=name(1:end-4); %remove .jpg extension
mkdir(outDir);%create directory to save extracted digits
figure, imshow(I);
%%

%Gray Image
Ig = rgb2gray(I);
figure,
subplot(1,2,1), imshow(Ig);

%Enhancement
Ih = histeq(Ig);
subplot(1,2,2), imshow(Ih);

figure,
subplot(1,2,1), imhist(Ig);
subplot(1,2,2), imhist(Ih);

%Edge Detection
Ie = edge(Ih, 'canny',graythresh(I));
figure, 
subplot(1,2,1), imshow(Ie);

%Dilation
Id = imdilate(Ie, strel('diamond', 1));
subplot(1,2,2), imshow(Id);



%Fill
If = imfill(Id,'holes');
figure, imshow(If);

%Find Plate
[lab, n] = bwlabel(If);

regions = regionprops(lab, 'all');
regionsCount = size(regions, 1) ;
imgArea=size(I,1)*size(I,2);%plate_1.jpg area=786,432

for partWidth = 1:regionsCount
    region = regions(partWidth);
    RectangleOfChoice = region.BoundingBox;
    PlateExtent = region.Extent;
    
    PlateStartX = fix(RectangleOfChoice(1));
    PlateStartY = fix(RectangleOfChoice(2));
    PlateWidth  = fix(RectangleOfChoice(3));
    PlateHeight = fix(RectangleOfChoice(4));
%     %%Remove upper and lower borders  
%     PlateStartY=PlateStartY+.08*PlateHeight;
%     PlateHeight=.9*PlateHeight;
%     RectangleOfChoice(2)=PlateStartY+.08*PlateHeight;
%     RectangleOfChoice(4)=.9*PlateHeight;
    Horizontal_len=size(I,2);
    Vertical_len=size(I,1);    
    plateArea=PlateWidth*PlateHeight;%outPlate.jpg area=65,383
    if PlateWidth >= PlateHeight*3 && PlateExtent >= .7 &&imgArea*.01<plateArea && plateArea<imgArea*.10 &&  Horizontal_len*.25<=PlateStartX && PlateStartX<=Horizontal_len*.6  && Vertical_len*.2<=PlateStartY && PlateStartY<=Vertical_len*.8 
        im2 = imcrop(I, RectangleOfChoice);        
        figure, imshow(im2);    
        break;
    end
end

gr_im2=rgb2gray(im2);
hq_im2=histeq(gr_im2);
plateBW=im2bw(gr_im2,graythresh(hq_im2));
figure,imshow(plateBW);
% hq_plateBW=im2bw(histeq(gr_im2),graythresh(im2));
% figure,
% 
% subplot(3,2,1),imshow(gr_im2);
% subplot(3,2,2),imhist(gr_im2);
% hq_gr_im2=histeq(gr_im2);
% subplot(3,2,3),imshow(hq_gr_im2);
% subplot(3,2,4),imhist(hq_gr_im2);
colPixels=sum(~plateBW);
% subplot(3,2,5),bar(colPixels);
% hq_colPixels=sum(~hq_plateBW);
% subplot(3,2,6),bar(hq_colPixels);



%begin plate processing to segregate digits
 medianColumn=median(colPixels);%median
plateIndex=1;
partsFound=0;
charsFound=0; %these are valid digits we want
%%constants for separating characters
X_RATIO=.611;
Y_RATIO=.4;

while plateIndex<=PlateWidth
    
    if colPixels(plateIndex)<=X_RATIO*medianColumn
		while plateIndex<=PlateWidth && colPixels(plateIndex)<=X_RATIO*medianColumn 			         
            plateIndex=plateIndex+1; %go forward to the starting point of character            
        end
            
        partWidth=0;
        digitStartX=plateIndex;
        while plateIndex<=PlateWidth && colPixels(plateIndex)>X_RATIO*medianColumn 
            partWidth=partWidth+1;            
            plateIndex=plateIndex+1;
        end
        if .03*PlateWidth<=partWidth % && partWidth <=.11*PlateWidth            
            partsFound=partsFound+1;
        end
        if  .03*PlateWidth<=partWidth && partWidth <=.11*PlateWidth && partsFound~=1 && partsFound~=4 %check if it is not flag and it is not the non-digit char (3rd character)			            
            charsFound=charsFound+1;
            cropArea=[digitStartX 0 partWidth PlateHeight];        
            imDigit=imcrop(im2,cropArea);                    
%             figure,imshow(imDigit);
             
                %Now Process every extracted digit vertically to crop extra
                %borders              
                
             
            imDigitBW=im2bw(imDigit,graythresh(imDigit));%black-white imDigit for vertical processing
%             figure,imshow(imDigitBW);
            rowPixels=sum(~imDigitBW,2);                       
            median_rowPixels=median(rowPixels);
            vertIndex=1;
            while vertIndex<=PlateHeight
                if rowPixels(vertIndex)<=Y_RATIO*median_rowPixels
                    while vertIndex<=PlateHeight && rowPixels(vertIndex)<=Y_RATIO*median_rowPixels
                        vertIndex=vertIndex+1;%go down until you reach the character
                    end
                     digitStartY=vertIndex;
                     partHeight=0;
                    while vertIndex<=PlateHeight && rowPixels(vertIndex)>Y_RATIO*median_rowPixels %tally part height
                        partHeight=partHeight+1;
                        vertIndex=vertIndex+1;
                    end
                    if partHeight>=.3*PlateHeight                                
                        cropArea=[digitStartX digitStartY partWidth partHeight];
                        vertDigit=imcrop(im2,cropArea);
                        figure,imshow(vertDigit);                        
						 imwrite(vertDigit,strcat(outDir,'\',num2str(charsFound),'.jpg')); %save the digit
                    end

                    continue;
                end
                vertIndex=vertIndex+1;
           end
      
        end
        continue;
    end
    plateIndex=plateIndex+1;
end



