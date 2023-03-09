function writerObj = vistrack_fast(dir,file)
% Load in the tracedata file
load(file)
XPOS = tracedata(:,:,1);
YPOS = tracedata(:,:,2);

% Load in the maskdir that contains the segmentation from the movie
fileList = dir(fullfile(dir,'*.tif'));
fileList = {fileList.name};
fL = [];
for L = 1:length(fileList)
    fL_temp = fileList{L}(7:end);
    fL_temp = fL_temp(1:end-4);
    fL(1,L) = str2num(fL_temp);
end
current_order = fL;
[B,current_order] = sort(current_order);
fileList = fileList(:,current_order);

tic
% Generate linear pixel indices from the binary downsized images
pixidx = [];
centroids = [];
%stack = []; % Binary image stack rescaled
for L = 1:size(B,2)
    stack_temp = imread([dir,fileList{L}]);
    stack_temp = logical(stack_temp);
    
    test1 = []; test2 = [];
    IMprops = regionprops(stack_temp,'Centroid','PixelIdxList');
    IMprops1 = {IMprops.Centroid};
    IMprops2 = {IMprops.PixelIdxList};
    for M = 1:size(IMprops1,2)
        test1(M,:) = IMprops1{M};
    end
    test2 = IMprops2;
    centroids{L,1} = test1;
    pixidx{L,1} = test2;
    
    %stack_temp = imresize(stack_temp,0.5);
    %stack(:,:,L) = stack_temp;
end
elapsed_time1 = toc;
disp(['Linear index extraction completed in ', num2str(elapsed_time1), ' seconds.']);

% Assign cell ID from matching centroid
idx = [];
for N = 1:size(YPOS,2)
    index = [];
    for L = 1:size(YPOS,1)
        t = [XPOS(L,N),YPOS(L,N)];
        [x,y] = ismember(t,centroids{N,1});
        index = [index;y];
    end
    index = index(:,1);
    idx{N,1} = index;
end

% Matrix of pixelidxlist for nuclear segmentation
tic
temp_idx_frame_r = cell(size(YPOS,1),size(YPOS,2)); % Initialize large empty cell 
for N = 1:size(YPOS,2)
temp_idx = pixidx{N,1}'; 
temp_idx_frame = idx{N,1};
for L = 1:size(YPOS,1)
    try
    testray = temp_idx(temp_idx_frame(L)); testray = testray{1,1};
    temp_idx_frame_r{L,N} = testray; % Fill each cell with the linear indices from segmentation
    catch
    end
end
end
elapsed_time2 = toc;
disp(['Linear indices assigned and stored in ', num2str(elapsed_time2), ' seconds.']);

% Set the random number generator seed
rng(42);
% Generate 10 pseudo-random RGB colors using the jet colormap
n_colors = 20;
jet_colors = jet(n_colors);
colors = jet_colors(randperm(n_colors), :) * 255;

% Define the length of the array
n = length(XPOS); % Change n to the desired length of the array
% Generate a 1xn array of random integers between 1 and 10
random_values = randi([1, 10], [1, n])';

tic
writerObj = VideoWriter('CompletedStack1.avi'); % create a video object
fps = 30; % default FPS is 30
new_fps = fps / 2; % cut frame rate in half to slow down video
writerObj.FrameRate = new_fps;
open(writerObj);
for n = 1:size(temp_idx_frame_r,2)
    matrix2fill_R = uint8(ones(2044,2048)); % assume image size is 2044 x2048
    matrix2fill_G = uint8(ones(2044,2048));
    matrix2fill_B = uint8(ones(2044,2048));
for L = 1:size(temp_idx_frame_r,1)
    linear_indices = temp_idx_frame_r{L,n};
    RGBval = random_values(L); RGBval = colors(RGBval,:);
    [rows, cols] = ind2sub(size(matrix2fill_R), linear_indices); % convert linear indices to row-column indices
    matrix2fill_R(sub2ind(size(matrix2fill_R), rows, cols)) = RGBval(1); % set values at row-column indices to 1

    [rows, cols] = ind2sub(size(matrix2fill_G), linear_indices); % convert linear indices to row-column indices
    matrix2fill_G(sub2ind(size(matrix2fill_G), rows, cols)) = RGBval(2); % set values at row-column indices to 1

    [rows, cols] = ind2sub(size(matrix2fill_B), linear_indices); % convert linear indices to row-column indices
    matrix2fill_B(sub2ind(size(matrix2fill_B), rows, cols)) = RGBval(3); % set values at row-column indices to 1
end
    IMG = cat(3, matrix2fill_R, matrix2fill_G, matrix2fill_B);
    IMG = imresize(IMG,0.5); % downsize RGB image and write to video object in loop
    writeVideo(writerObj, IMG);
end
close(writerObj);
elapsed_time3 = toc;
disp(['Video write completed in ', num2str(elapsed_time3), ' seconds.']);
total_time = elapsed_time1 + elapsed_time2 + elapsed_time3;
fprintf('Total time taken: %f seconds\n', total_time);
