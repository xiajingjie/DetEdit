%% itr_SumPPICIBin

clearvars
close all

%% Parameters defined by user
filePrefix = 'SOCAL'; % File name to match. 
% File prefix should include deployment, site, (disk is optional). 
% Example: 
% File name 'GofMX_DT01_disk01-08_TPWS2.mat' 
%                    -> filePrefix = 'GofMX_DT01'
% or                 -> filePrefix ='GOM_DT_09' (for files names with GOM)
sp = 'Zc'; % your species code
itnum = '2'; % which iteration you are looking for
srate = 200; % sample rate
tpwsPath = 'G:\SOCAL_BW\Detections\SOCAL_A2\TPWS'; %directory of TPWS files
tfName = 'G:\Harp_TF'; % Directory ...
% with .tf files (directory containing folders with different series ...
effortXls = 'H:\Pm_Effort.xls'; % specify excel file with effort times
% !!! if not effort times: run groupID_noEffortTimes
refTime = '2010-04-01'; %reference time format 'yyyy-MM-dd'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% define subfolder that fit specified iteration
if itnum > 1
   for id = 2: str2num(itnum) % iternate id times according to itnum
       subfolder = ['TPWS',num2str(id)];
       tpwsPath = (fullfile(tpwsPath,subfolder));
   end
end

%% Find all TPWS files that fit your specifications (does not look in subdirectories)
% Concatenate parts of file name
if isempty(sp)
    detfn = [filePrefix,'.*','TPWS',itnum,'.mat'];
else
    detfn = [filePrefix,'.*',sp,'.*TPWS',itnum,'.mat'];
end
% Get a list of all the files in the start directory
fileList = cellstr(ls(tpwsPath));
% Find the file name that matches the filePrefix
fileMatchIdx = find(~cellfun(@isempty,regexp(fileList,detfn))>0);
if isempty(fileMatchIdx)
    % if no matches, throw error
    error('No files matching filePrefix found!')
end

%% Get effort times matching prefix file
allEfforts = readtable(effortXls);
% site = strsplit(filePrefix,'_');
site = filePrefix;
effTable = allEfforts(ismember(allEfforts.Sites,site),:);
% effTable = allEfforts(ismember(allEfforts.Deployments,site(2)),:);

% make Variable Names consistent
startVar = find(~cellfun(@isempty,regexp(effTable.Properties.VariableNames,'Start.*Effort'))>0,1,'first');
endVar = find(~cellfun(@isempty,regexp(effTable.Properties.VariableNames,'End.*Effort'))>0,1,'first');
effTable.Properties.VariableNames{startVar} = 'Start';
effTable.Properties.VariableNames{endVar} = 'End';

Start = datetime(x2mdate(effTable.Start),'ConvertFrom','datenum');
End = datetime(x2mdate(effTable.End),'ConvertFrom','datenum');

effort = timetable(Start,End);

%% Concatenate all detections from the same site and create the plots
concatFiles = fileList(fileMatchIdx);

SumPPICIBin('filePrefix',filePrefix,'concatFiles', concatFiles,'sp', sp,...
    'sdir', tpwsPath,'effort',effort,'referenceTime',refTime);


disp('Done processing')