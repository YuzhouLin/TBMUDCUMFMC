% get accuracy for EMG feature sets

%% Objectives:
% Assessment of EMG and ACC baseline performance
% 1. Single Position – ACC (gesture) – Performance
% 2. Single Position – EMG (gesture) – Performance
% 3. Single Gesture – ACC (position) – Performance
% 4. Single Gesture – EMG (position) – Performance
% 5. Multiple Positions – ACC (gesture) – Performance
% 6. Multiple Positions – EMG (gesture) – Performance
% 7. Multiple Gestures - ACC (position) - Performance
% 8. Multiple Gestures - EMG (position) - Performance

clear variables
close all
clc



addpath([pwd '/Features']);


dataset = {'NinaPro7-A'};
feature_flag = {
    {'EMGMAV','EMGZC','EMGSSC','EMGWL'},...
    {'EMGFSD'},...
    {'EMGTDPSD'},...
    {'EMGMAVFD','EMGDASDV','EMGWAMP','EMGZC','EMGMFL','EMGSAMPEN','EMGTDPSD'}...
    };
fs = {'EMGTD','EMGFSD','EMGTDPSD','EMGLSF'};

classes = [13 14 10 9 6 32];% flexion, extension, pronation, supination, power grip, pinch grip
channels = 1:8;
num_reps = 6;
winsize = 200; % ms
wininc = 50;   % ms
t1 = tic;

for fsi = 1:length(fs)
    % EXTRACT FEATURES
    for subject = 1:60
        
        if subject < 41
            dataset = 'NinaPro2';
            s = subject;
        else
            dataset = 'NinaPro7';
            s = subject - 40;
        end
        if ~exist(['Prepped_Feature_Sets/' fs{fsi} '_S' num2str(subject) '.mat'],'file')
            disp(['F:' num2str(fsi) '/' num2str(length(fs)) '; S:' num2str(subject) '/60'])
            [feat, info] = extract_feature_new(s, classes, dataset, channels, feature_flag{fsi}, winsize, wininc);
            save(['Prepped_Feature_Sets/' fs{fsi} '_S' num2str(subject) '.mat'],'feat','info')
        end
    end
    % WITHIN SUBJECT ACURACY
    for subject = 1:60
        
        if ~exist(['Results_Within_Subject/' fs{fsi} '_S' num2str(subject) '.mat'],'file')
            disp(['F:' num2str(fsi) '/' num2str(length(fs)) '; S:' num2str(subject) '/60'])
            fset = load(['Prepped_Feature_Sets/' fs{fsi} '_S' num2str(subject) '.mat']);
            feat = fset.feat;
            info = fset.info;
            results = within_subject_accuracy(feat,info);
            save(['Results_Within_Subject/' fs{fsi} '_S' num2str(subject) '.mat'],'results');
        end
    end
    %    % BETWEEN SUBJECT ACCURACY - NO CCA
    for subject_i = 1:60
        for subject_j = 1:60
            fset_i = load(['Prepped_Feature_Sets/' fs{fsi} '_S' num2str(subject_i) '.mat']);
            feat_i = fset_i.feat;
            info_i = fset_i.info;
            if subject_i == subject_j
                continue
            end
            if ~exist(['Results_Between_Subject_No_CCA/' fs{fsi} '_S' num2str(subject_i) '_S' num2str(subject_j) '.mat'],'file')
                
                disp(['F:' num2str(fsi) '/' num2str(length(fs)) '; S:' num2str(subject_i) '/60; S:' num2str(subject_j) '/60'])
                fset_j = load(['Prepped_Feature_Sets/' fs{fsi} '_S' num2str(subject_j) '.mat']);
                feat_j = fset_j.feat;
                info_j = fset_j.info;
                results = between_subject_accuracy(feat_i, info_i, feat_j, info_j,{'NOCCA'});
                save(['Results_Between_Subject_No_CCA/' fs{fsi} '_S' num2str(subject_i) '_S' num2str(subject_j) '.mat'],'results');
            end
        end
    end
    %    % BETWEEN SUBJECT ACCURACY - WITH CCA
       for subject_i = 1:60
           for subject_j = 1:60
               fset_i = load(['Prepped_Feature_Sets/' fs{fsi} '_S' num2str(subject_i) '.mat']);
               feat_i = fset_i.feat;
               info_i = fset_i.info;
               if subject_i == subject_j
                   continue
               end
               for r = 1:(num_reps - 1) % r is the number of reps used to learn CCA projection
    
                    warning('off','all')
                   %if ~exist(['Results_Between_Subject_CCA/' fs{fsi} '_R' num2str(r) '_S' num2str(subject_i) '_S' num2str(subject_j) '.mat'],'file')
                       disp(['F:' num2str(fsi) '/' num2str(length(fs)) '; S:' num2str(subject_i) '/60; S:' num2str(subject_j) '/60'])
                       fset_j = load(['Prepped_Feature_Sets/' fs{fsi} '_S' num2str(subject_j) '.mat']);
                       feat_j = fset_j.feat;
                       info_j = fset_j.info;
    
                        results = between_subject_accuracy(feat_i, info_i, feat_j, info_j,{'CCA', r});
                        mysave(['Results_Between_Subject_CCA/' fs{fsi} '_R' num2str(r) '_S' num2str(subject_i) '_S' num2str(subject_j) '.mat'],results);
                   %end
               end
           end
       end
%     % BETWEEN SUBJECT ACCURACY - WITH LOSOCCA
%     for subject = 1:60 % novel user
%         feat_b = cell(58,1);
%         info_b = cell(58,1);
%         counter = 1;
%         subj = load(['Prepped_Feature_Sets/' fs{fsi} '_S' num2str(subject) '.mat']);
%         feat{subject} = subj.feat;
%         info{subject} = subj.info;
%     end
%         
%     between_subject_accuracy_LOSOCCA(feat, info);
%         %mysave(['Results_Between_Subject_LOSOCCA/' fs{fsi} '_R' num2str(r) '_S' num2str(subject_i) '.mat'],results);
            
end
