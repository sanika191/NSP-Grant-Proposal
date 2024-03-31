% oNum: orientation number. Choose between 0 to 8. Numbers 1-8 correspond
% to the orientation index. Orientation values are given by 0:22.5:157.5.
% If set to 0, all the trials from all the orientations are taken together. 

% refType: 'avg','bipolar','csd'. Returns the unipolar data for anything else.
% Output is returned in fieldtrip format

function [data,layout] = getDataTSLA(refType)

CL = {'Fp1'	'Fp2'	'F7'	'F3'	'Fz'	'F4'	'F8'	'FC5'	'FC1'	'FC2'	'FC6'	'T7'	'C3'	'Cz'	'C4'	'T8'	'TP9'	'CP5'	'CP1'	'CP2'	'CP6'	'TP10'	'P7'	'P3'	'Pz'	'P4'	'P8'	'PO9'	'O1'	'Oz'	'O2'	'PO10'	'AF7'	'AF3'	'AF4'	'AF8'	'F5'	'F1'	'F2'	'F6'	'FT9'	'FT7'	'FC3'	'FC4'	'FT8'	'FT10'	'C5'	'C1'	'C2'	'C6'	'TP7'	'CP3'	'CPz'	'CP4'	'TP8'	'P5'	'P1'	'P2'	'P6'	'PO7'	'PO3'	'POz'	'PO4'	'PO8'};

if ~exist('refType','var');         refType='';                         end

%%%%%%%%%%%%%%%%%%%%%%%%%%% Get saved data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = load('001MS_F1-200917-GAV_0002.mat');
eegData = x.eegData;
%%%%%%%%%%%%%%%%%%%%% Convert data in fieldtrip format %%%%%%%%%%%%%%%%%%%%
numTrials = size(eegData,2);

data.label = CL;
data.fsample = round(1/(x.timeVals(2)-x.timeVals(1)));

times=cell(1,numTrials);
trialWiseData=cell(1,numTrials);
for i=1:numTrials
    times{i}=x.timeVals;
    trialWiseData{i} = squeeze(eegData(:,i,:));
end

data.trial = trialWiseData;
data.time = times;

%%%%%%%%%%%%%%%%%%%%%%%%%% Get Layout File %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(refType,'bipolar')
    x=load('bipolarLayout.mat');
    layout = x.lay;
else
    [~, ftdir] = ft_version;
    x=load(fullfile(ftdir,'template','layout','acticap-64ch-standard2.mat'));
    layout = x.lay;
end

%%%%%%%%%%%%%%%%%%%%%%%%% Apply referencing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(refType,'avg')
    cfg=[];
    cfg.channel='all';
    cfg.reref = 'yes';
    cfg.refchannel='all';
    cfg.refmethod='avg';
    data=ft_preprocessing(cfg,data);
    
elseif strcmp(refType,'bipolar')
    cfg=[];
    cfg.channel='all';
    x=load('bipolarMontage.mat');
    cfg.montage=x.montage;
    data=ft_preprocessing(cfg,data);

elseif strcmp(refType,'csd')
    cfg=[];
    cfg.layout=layout;
    cfg.method='spline';
    data=ft_scalpcurrentdensity(cfg,data);
end
end