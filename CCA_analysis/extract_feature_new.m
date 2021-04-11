function [feat, info] = extract_feature_new(subject, classes, dataset, channels, feature_flag, winsize, wininc)

feat = [];
info = [];

switch(dataset)
    case 'NinaPro7'
        dataset_dir = '[EMG-ACC] NinaPro7';
    case 'NinaPro2'
        dataset_dir = '[EMG-ACC] NinaPro2';
end

files = [];
for s = 1:length(subject)
    for c = 1:length(classes)
        files = [files ; dir(['D:\[EMG-ACC] Project\' dataset_dir '\S' num2str(subject(s)) '\S' num2str(subject(s)) '_C' num2str(classes(c)) '_*'])];
    end
end


for f = 1:length(files)
    
    file_parts = split(files(f).name,'_');
    subj = str2double(file_parts{1}(2:end));
    class = str2double(file_parts{2}(2:end));
    position = str2double(file_parts{3}(2:end));
    rep = str2double(file_parts{4}(2:end));
    
    if rep == 0
        continue
    end
    
    data = csvread([files(f).folder '/' files(f).name]);
    
    data = resample(data(:,channels),1,2); % 2kHz to 1kHz (same as DL)
    
    
    % fextraction here
    for fe = 1:length(feature_flag)
        feat = get_feature_new(data,winsize,wininc,feat,feature_flag{fe});
    end
    
    numWindow = floor((size(data,1) - winsize)/wininc)+1;
    if ~isfield(info, 'class')
        info.class = [];
        info.subject = [];
        info.position = [];
        info.rep = [];
    end
    info.class    = [info.class;    ones(numWindow,1)*class];
    info.subject  = [info.subject;  ones(numWindow,1)*subj];
    info.position = [info.position; ones(numWindow,1)*position];
    info.rep      = [info.rep;      ones(numWindow,1)*rep];


end



end