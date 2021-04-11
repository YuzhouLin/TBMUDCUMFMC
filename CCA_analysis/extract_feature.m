function [feat, info] = extract_feature(subject, classes, dataset, filter_flag, feature_flag, winsize, wininc)

feat = [];
info = [];

switch(dataset)
    case 'Fougner'
        FS = 1000;
        channel = {1:8, 9:14};
	dataset_dir = '[EMG-ACC] SCHEME Effect of Static Position (Fougner)';
    case 'NinaPro7'
        FS = 2000;
        channel = {1:12, 13:48};
	dataset_dir = '[EMG] Ninapro7';
end

winsize = winsize*FS/1000;
wininc = wininc*FS/1000;

for fi = 1:length(filter_flag)
   filter = split(filter_flag{fi},'_');
   if ~exist('b','var')
       b = {};
       a = {};
   end
   switch filter{2}
       case 'NOTCH'
           [b0,a0] = iirnotch(str2double(filter{3})/(FS/2),str2double(filter{3})/(FS/2)/40);
           b{end+1} = b0;
           a{end+1} = a0;
       case 'HIGH'
           [b0,a0] = butter(3,str2double(filter{3})/(FS/2),'high');
           b{end+1} = b0;
           a{end+1} = a0;
       case 'LOW'
           [b0,a0] = butter(3, str2double(filter{3})/(FS/2),'low');
           b{end+1} = b0;
           a{end+1} = a0;
       case 'BANDPASS'
           [b0,a0] = butter(6, [str2double(filter{3})/(FS/2)    str2double(filter{4})/(FS/2)],'bandpass');
           b{end+1} = b0;
           a{end+1} = a0;
       case 'G'
           b{end+1} = 'g';
           a{end+1} = 'g';
   end
end

files = [];
for s = 1:length(subject)
    for c = 1:length(classes)
        files = [files ; dir(['C:\Users\ecampbe2\Desktop\[ACC] Datasets\' dataset_dir '\S' num2str(subject(s)) '\S' num2str(subject(s)) '_C' num2str(classes(c)) '_*'])];
    end
end


for f = 1:length(files)
    
    data = csvread([files(f).folder '/' files(f).name]);
    
    file_parts = split(files(f).name,'_');
    subj = str2double(file_parts{1}(2:end));
    class = str2double(file_parts{2}(2:end));
    position = str2double(file_parts{3}(2:end));
    rep = str2double(file_parts{4}(2:end));

    % filtering stuff here
    for fi = 1:length(b)
        filter = split(filter_flag{fi},'_');
        if strcmp(filter{1},'EMG')
            channels = channel{1};
        else
            channels = channel{2};
        end
        if isnumeric(b{fi})
            data(:,channels) = filtfilt(b{fi}, a{fi}, data(:,channels));
        else
            data(:,channels) = (data(:,channels) - 1.65)/0.8;% convert to g
        end
            
    end
    
    % fextraction here
    for fe = 1:length(feature_flag)
        feat = get_feature(data,channel,winsize,wininc,feat,feature_flag{fe});
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