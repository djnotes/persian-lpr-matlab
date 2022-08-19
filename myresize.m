function myresize(rows,cols)
fileName='train_numbers/';
outputFile='resized_train_numbers/';
for i=1:9
    for j=1:10
        I=imread(strcat(fileName,num2str(i),' (',num2str(j),').jpg'));
        I=imresize(I,[rows,cols]);
        imwrite(I,strcat(outputFile,num2str(i),' (',num2str(j),').jpg'));
    end
end
        
end