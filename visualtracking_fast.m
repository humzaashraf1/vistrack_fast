% Step 1: Run Timelapse_2color_nd2_multifile & save maskfiles
% Step 2: Visualize tracking accuracy with vistrack_fast

clearvars
addpath(genpath('./'));
path1 = '\'; %Scripts folder
path2 = '\'; %Functions folder within scripts
addpath(genpath('./'));
dirToProcessList = {
    '\'
    }; %Directories containing raw data
firstdirToProcess = dirToProcessList{1};
dirToExport ='\'; %Directory to export data to 
fileList = dir(fullfile(firstdirToProcess,'*.nd2'));
fileList = {fileList.name};
maskdir = '\';

% Run tracking code with a mask directory
file = x; %File of interest 
EF = y; %Number of movie frames
currFile = fullfile(firstdirToProcess,fileList{file});
Timelapse_2color_nd2_multifile(currFile,dirToExport,dirToProcessList,path1,path2,EF,maskdir);

% Run vistrack_fast
file = 'Z:\ManuscriptDataFinal\Figure4\20220821_HA Projects\COOLMOVIECODE\TwoColor\example\tracedata_r_c_s.mat'; %row, col, site
dir = maskdir;
vistrack_fast(dir,file)
