clc
clear
close all

numOfPhotos=90;
imgRows=100;
imgCols=50;

X=zeros(numOfPhotos,(imgRows*imgCols)/100);




%%Resize Images
%  myresize(imgRows,imgCols);


%read train images
datasetIndex=0;    

for i=1:numOfPhotos/10
    for j=1:numOfPhotos/9           
        datasetIndex=datasetIndex+1;
    im=imread(['resized_train_numbers\' num2str(i) ' (' num2str(j) ').jpg']);
    im=im2bw(im,graythresh(im));    
    
    c=1;
    for g=1:imgRows/10
        for e=1:imgCols/10
            s=sum(sum(im((g*10-9:g*10),(e*10-9:e*10))));
            X(datasetIndex,c)=s;
            c=c+1;            
        end    
    end
    
    end
end
datasetNormalized=zeros(numOfPhotos,imgRows*imgCols/100);
%%Normalize dataset contents
minDataset=min(min(X));
maxDataset=max(max(X));
for i = 1:numOfPhotos
    for j=1:imgRows*imgCols/100
        datasetNormalized(i, j) = (X(i,j)-minDataset)/(maxDataset-minDataset);
    end
end
        



% 
%%Neural network part


% T=zeros(1,90);
% for  i=1:90
%     T(i)=ceil(i/10);
% end

T=zeros(9,90);
for j=1:90
    i=ceil(j/10);
    T(i,j)=1;
end

% net=newff(datasetNormalized',T,20);
net = newff(minmax(datasetNormalized'),[20 9],{'logsig' 'logsig'},'traingdx');

net.performFcn='sse';
net.trainParam.goal=0.01;
net.trainParam.show=20;
net.trainParam.epochs=100;
net.trainParam.mc=0.95;
% net.trainFcn='trainlm';
net.trainParam.min_grad=1e-12;
[net,tr]=train(net,datasetNormalized',T);




%Read input image for recognition
[name file]=uigetfile('*.jpg','Choose Plate Digit Image');
newImg=imread([file name]);
newImg=imresize(newImg,[imgRows imgCols]);
newImg=im2bw(newImg,graythresh(newImg));
figure,imshow(newImg);

m=zeros(1,imgRows*imgCols/100);
c=1;
for g=1:imgRows/10
        for e=1:imgCols/10
            s=sum(sum(newImg((g*10-9:g*10),(e*10-9:e*10))));
            m(c)=s;
            c=c+1;            
        end
end
%Normalize m contents

m_normalized=zeros(1,imgRows*imgCols/100);
for i=1:imgRows*imgCols/100    
        m_normalized(i)=(m(i)-min(m))/(max(m)-min(m));
end


[dummy,b]=max(sim(net,m_normalized'));
% b=round(sim(net,m_normalized'));
msgbox(['digit is: ' num2str(b)],'Digit recognized','help');
