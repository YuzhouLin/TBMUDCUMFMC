clear variables;
clc;
close all;

addpath(['Features'])
addpath(['Features/required_fn'])
addpath(['MatlabScript'])
addpath(genpath([pwd '\LSCCA']))

Participant_dir = 'Dataset/Amputee_dataset';

features_fn = dir('Features/*.m');
features_fn = {features_fn(:).name};
features_fn = cellfun(@(i) i(1:end-2), features_fn,'UniformOutput', false);
features_list = cellfun(@(i) i(4:end-4), features_fn, 'UniformOutput',false);
features_list = {'mav','zc','ssc','wl'};
%features_list = {'ar'};
%features_list = {'tdpsd'};
%features_list = {'ls','msr','wamp','mfl'};
%features_list = {'zc','rms','iemg','dasdv','var'};
class_list = 0:9;

% Gather data
% filters -
%   Butterworth (4, 20-495)
remove_class = [6,7,9];

tr_data = getdataset(Participant_dir, 'amputee', 'train', 1000, 1:10, class_list);
te_data = getdataset(Participant_dir, 'amputee', 'test', 1000, 1:10, class_list);

winsize = 151;
wininc  = 50;

disp('-----------------------------------------')
disp('           Feature Computation           ')
disp('-----------------------------------------')
t1 = tic;
%for f = 1:length(features_list)
    
    
    %if ~exist(['Features/extracted_amputee/tr_' features_list{f} '.mat'],'file')
   %     disp(['F(' num2str(f) '/' num2str(length(features_list)) '): ' features_list{f}])
   %     tr_features = getfeature(tr_data,features_fn{f},winsize,wininc);
   %     mysave(['Features/extracted_amputee/tr_' features_list{f} '.mat'],tr_features)
   %else
   %     tr_features = load(['Features/extracted_amputee/tr_' features_list{f} '.mat'],'feature');
   %     tr_features = tr_features.feature;
   %end
    
   % if ~exist(['Features/extracted_amputee/te_' features_list{f} '.mat'],'file')
   %     te_features = getfeature(te_data,features_fn{f},winsize,wininc);
   %     mysave(['Features/extracted_amputee/te_' features_list{f} '.mat'],te_features)
   % else
   %     te_features = load(['Features/extracted_amputee/te_' features_list{f} '.mat'],'feature');
   %     te_features = te_features.feature;
   % end
    
    %toc(t1)
%end
%toc(t1);
% within subject accuracy - individual features

disp('-----------------------------------------')
disp('Within Subject Accuracy - Single Features')
disp('-----------------------------------------')
skip_features = [10];
for f = 1:length(features_list)
    if any(f == skip_features)
        continue
    end
    if ~exist(['Features/results_amputee/' features_list{f} '_ws_acc.mat'],'file')
        tr_features = load(['Features/extracted_amputee/tr_' features_list{f} '.mat'],'feature');
        tr_features = tr_features.feature;

        te_features = load(['Features/extracted_amputee/te_' features_list{f} '.mat'],'feature');
        te_features = te_features.feature;
        
        tr_features = tr_features(~ismember(tr_features(:,2),remove_class),:);
        te_features = te_features(~ismember(te_features(:,2),remove_class),:);

        participants = unique(tr_features(:,1));
        te_reps = unique(te_features(:,3));
        for p = 1:length(participants)

            tr_p = tr_features(tr_features(:,1) == participants(p),:);
            te_p = te_features(te_features(:,1) == participants(p),:);

            LDA_mdl = fitcdiscr(tr_p(:,4:end), tr_p(:,2));
            class_list = unique(te_p(:,2));
            for r = 1:length(te_reps)
                te_r = te_p(te_p(:,3) == te_reps(r),:);
                predictions = predict(LDA_mdl, te_r(:,4:end));

                ws_acc(p,r) = sum(predictions == te_r(:,2))/length(te_r);

                for c1 = 1:length(class_list)
                    c1_ids = te_r(:,2) == class_list(c1);
                    for c2 = 1:length(class_list)
                        ws_cmat{p,r}(c1,c2) = sum(predictions(c1_ids) == class_list(c2))/sum(c1_ids);
                    end
                end

            end

        end
        disp(['F(' num2str(f) '/' num2str(length(features_list)) ') ' features_list{f} ': ' num2str(mean(mean(ws_acc)))])
        save(['Features/results_amputee/' features_list{f} '_ws_acc.mat'],'ws_acc');
        save(['Features/results_amputee/' features_list{f} '_ws_cmat.mat'],'ws_cmat');
    end
end



% within subject accuracy - individual features

disp('-----------------------------------------')
disp('Between Subject Accuracy - Single Features')
disp('-----------------------------------------')
skip_features = [10];
for f = 1:length(features_list)
    if any(f == skip_features)
        continue
    end
    if ~exist(['Features/results_amputee/' features_list{f} '_bs_acc.mat'],'file')
        tr_features = load(['Features/extracted_amputee/tr_' features_list{f} '.mat'],'feature');
        tr_features = tr_features.feature;

        te_features = load(['Features/extracted_amputee/te_' features_list{f} '.mat'],'feature');
        te_features = te_features.feature;
        
        tr_features = tr_features(~ismember(tr_features(:,2),remove_class),:);
        te_features = te_features(~ismember(te_features(:,2),remove_class),:);

        participants = unique(tr_features(:,1));
        te_reps = unique(te_features(:,3));
        for p1 = 1:length(participants)

            tr_p = tr_features(tr_features(:,1) == participants(p1),:);

            LDA_mdl = fitcdiscr(tr_p(:,4:end), tr_p(:,2));
            for p2 = 1:length(participants)
                
                te_p = te_features(te_features(:,1) == participants(p2),:);
                class_list = unique(te_p(:,2));
                for r = 1:length(te_reps)
                    te_r = te_p(te_p(:,3) == te_reps(r),:);
                    predictions = predict(LDA_mdl, te_r(:,4:end));

                    bs_acc(p1,p2,r) = sum(predictions == te_r(:,2))/length(te_r);

                    for c1 = 1:length(class_list)
                        c1_ids = te_r(:,2) == class_list(c1);
                        for c2 = 1:length(class_list)
                            bs_cmat{p1,p2,r}(c1,c2) = sum(predictions(c1_ids) == class_list(c2))/sum(c1_ids);
                        end
                    end

                end
            end

        end
        disp(['F(' num2str(f) '/' num2str(length(features_list)) ') ' features_list{f} ': ' num2str(mean(mean(mean(bs_acc))))])
        save(['Features/results_amputee/' features_list{f} '_bs_acc.mat'],'bs_acc');
        save(['Features/results_amputee/' features_list{f} '_bs_cmat.mat'],'bs_cmat');
    end
end

featuresets = {'TD','TDAR','TDPSD','LSF4','LSF9'};
featuresets_components = {...
    {'mav','zc','ssc','wl'},...
    {'mav','zc','ssc','wl','ar'},...
    {'tdpsd'},...
    {'ls','mfl','msr','wamp'},...
    {'ls','mfl','msr','wamp','zc','rms','iemg','dasdv','var'}...
    };

% disp('-----------------------------------------')
% disp('  Within Subject Accuracy - Featuresets  ')
% disp('-----------------------------------------')
% for f = 1:length(featuresets)
%     if ~exist(['Features/results_amputee/' featuresets{f} '_ws_acc.mat'],'file')
%         
%         for fi = 1:length(featuresets_components{f})
%            if fi == 1
%                tr_features = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
%                tr_features = tr_features.feature;
%                te_features = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
%                te_features = te_features.feature;
%            else
%                tmp = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
%                tmp = tmp.feature;
%                tr_features = [tr_features, tmp(:,4:end)];
%                
%                tmp = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
%                tmp = tmp.feature;
%                te_features = [te_features, tmp(:,4:end)];
%            end
%             
%         end
%         
%         tr_features = tr_features(~ismember(tr_features(:,2),remove_class),:);
%         te_features = te_features(~ismember(te_features(:,2),remove_class),:);
%         
%         participants = unique(tr_features(:,1));
%         te_reps = unique(te_features(:,3));
%         for p = 1:length(participants)
% 
%             tr_p = tr_features(tr_features(:,1) == participants(p),:);
%             te_p = te_features(te_features(:,1) == participants(p),:);
% 
%             LDA_mdl = fitcdiscr(tr_p(:,4:end), tr_p(:,2));
%             class_list = unique(te_p(:,2));
%             for r = 1:length(te_reps)
%                 te_r = te_p(te_p(:,3) == te_reps(r),:);
%                 predictions = predict(LDA_mdl, te_r(:,4:end));
% 
%                 ws_acc(p,r) = sum(predictions == te_r(:,2))/length(te_r);
% 
%                 for c1 = 1:length(class_list)
%                     c1_ids = te_r(:,2) == class_list(c1);
%                     for c2 = 1:length(class_list)
%                         ws_cmat{p,r}(c1,c2) = sum(predictions(c1_ids) == class_list(c2))/sum(c1_ids);
%                     end
%                 end
% 
%             end
% 
%         end
%         disp(['F(' num2str(f) '/' num2str(length(featuresets)) ') ' featuresets{f} ': ' num2str(mean(mean(ws_acc)))])
%         save(['Features/results_amputee/' featuresets{f} '_ws_acc.mat'],'ws_acc');
%         save(['Features/results_amputee/' featuresets{f} '_ws_cmat.mat'],'ws_cmat');
%     end
%     
% end





disp('-----------------------------------------')
disp('Single Repetition Accuracy - Featuresets ')
disp('-----------------------------------------')
for f = 1:length(featuresets)
    if ~exist(['Features/results_amputee/' featuresets{f} '_sr_acc.mat'],'file')
        
        for fi = 1:length(featuresets_components{f})
           if fi == 1
               tr_features = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
               tr_features = tr_features.feature;
               te_features = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
               te_features = te_features.feature;
           else
               tmp = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
               tmp = tmp.feature;
               tr_features = [tr_features, tmp(:,4:end)];
               
               tmp = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
               tmp = tmp.feature;
               te_features = [te_features, tmp(:,4:end)];
           end
            
        end
        
        tr_features = tr_features(~ismember(tr_features(:,2),remove_class),:);
        te_features = te_features(~ismember(te_features(:,2),remove_class),:);
        
        participants = unique(tr_features(:,1));
        te_reps = unique(te_features(:,3));
        tr_reps = te_reps(1);
        te_reps = te_reps(2:end);
        for p = 1:length(participants)

            %tr_p = tr_features(tr_features(:,1) == participants(p),:);
            tr_p = te_features(te_features(:,1) == participants(p),:);
            tr_p = tr_p(tr_p(:,3) == tr_reps,:);
            te_p = te_features(te_features(:,1) == participants(p),:);

            LDA_mdl = fitcdiscr(tr_p(:,4:end), tr_p(:,2),'discrimtype','pseudolinear');
            class_list = unique(te_p(:,2));
            for r = 1:length(te_reps)
                te_r = te_p(te_p(:,3) == te_reps(r),:);
                predictions = predict(LDA_mdl, te_r(:,4:end));

                sr_acc(p,r) = sum(predictions == te_r(:,2))/length(te_r);

                for c1 = 1:length(class_list)
                    c1_ids = te_r(:,2) == class_list(c1);
                    for c2 = 1:length(class_list)
                        sr_cmat{p,r}(c1,c2) = sum(predictions(c1_ids) == class_list(c2))/sum(c1_ids);
                    end
                end

            end

        end
        disp(['F(' num2str(f) '/' num2str(length(featuresets)) ') ' featuresets{f} ': ' num2str(mean(mean(sr_acc)))])
        save(['Features/results_amputee/' featuresets{f} '_sr_acc.mat'],'sr_acc');
        save(['Features/results_amputee/' featuresets{f} '_sr_cmat.mat'],'sr_cmat');
    end
    
end







% 
% disp('-----------------------------------------')
% disp('  Between Subject Accuracy - Featuresets ')
% disp('-----------------------------------------')
% for f = 1:length(featuresets)
%     if ~exist(['Features/results_amputee/' featuresets{f} '_bs_acc.mat'],'file')
%         
%         for fi = 1:length(featuresets_components{f})
%            if fi == 1
%                tr_features = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
%                tr_features = tr_features.feature;
%                te_features = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
%                te_features = te_features.feature;
%            else
%                tmp = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
%                tmp = tmp.feature;
%                tr_features = [tr_features, tmp(:,4:end)];
%                
%                tmp = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
%                tmp = tmp.feature;
%                te_features = [te_features, tmp(:,4:end)];
%            end
%             
%         end
%         
%         tr_features = tr_features(~ismember(tr_features(:,2),remove_class),:);
%         te_features = te_features(~ismember(te_features(:,2),remove_class),:);
%         
%         participants = unique(tr_features(:,1));
%         te_reps = unique(te_features(:,3));
%         for p1 = 1:length(participants)
% 
%             tr_p = tr_features(tr_features(:,1) == participants(p1),:);
% 
%             LDA_mdl = fitcdiscr(tr_p(:,4:end), tr_p(:,2));
%             for p2 = 1:length(participants)
%                 
%                 te_p = te_features(te_features(:,1) == participants(p2),:);
%                 class_list = unique(te_p(:,2));
%                 for r = 1:length(te_reps)
%                     te_r = te_p(te_p(:,3) == te_reps(r),:);
%                     predictions = predict(LDA_mdl, te_r(:,4:end));
% 
%                     bs_acc(p1,p2,r) = sum(predictions == te_r(:,2))/length(te_r);
% 
%                     for c1 = 1:length(class_list)
%                         c1_ids = te_r(:,2) == class_list(c1);
%                         for c2 = 1:length(class_list)
%                             bs_cmat{p1,p2,r}(c1,c2) = sum(predictions(c1_ids) == class_list(c2))/sum(c1_ids);
%                         end
%                     end
% 
%                 end
%             end
% 
%         end
%         disp(['F(' num2str(f) '/' num2str(length(featuresets)) ') ' featuresets{f} ': ' num2str(mean(mean(mean(bs_acc))))])
%         save(['Features/results_amputee/' featuresets{f} '_bs_acc.mat'],'bs_acc');
%         save(['Features/results_amputee/' featuresets{f} '_bs_cmat.mat'],'bs_cmat');
%     end
% end







disp('-----------------------------------------')
disp('      Between Subject Accuracy - CCA     ')
disp('-----------------------------------------')

options.RegType = 2;
options.RegX = 0.04;
options.PrjX = 1;
options.PrjY = 1;

remove_class = [6,7,9];
for f = 1:length(featuresets)
    if ~exist(['Features/results_amputee/' featuresets{f} '_lscca_acc.mat'],'file')
        
        for fi = 1:length(featuresets_components{f})
           if fi == 1
               tr_features = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
               tr_features = tr_features.feature;
               te_features = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
               te_features = te_features.feature;
           else
               tmp = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
               tmp = tmp.feature;
               tr_features = [tr_features, tmp(:,4:end)];
               
               tmp = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
               tmp = tmp.feature;
               te_features = [te_features, tmp(:,4:end)];
           end
            
        end
        
        tr_features = tr_features(~ismember(tr_features(:,2),remove_class),:);
        te_features = te_features(~ismember(te_features(:,2),remove_class),:);
        
        participants = unique(tr_features(:,1));
        
        for p1 = 1:length(participants)
            t1=tic;
            % expert user
            ex_p = tr_features(tr_features(:,1) == participants(p1),:);
            [Y,PS] = mapstd(ex_p(:,4:end)',0,1);
            ex_p(:,4:end) = Y';
            
            
            for p2 = 1:length(participants)
                % p2 is the target user
                ta_p = te_features(te_features(:,1) == participants(p2),:);
                % the first rep is used to learn mapping
                ta_map = ta_p(ismember(ta_p(:,3),[0,1]),:);
                % other reps are used to test accuracy
                ta_p = ta_p(~ismember(ta_p(:,3),[0,1]),:);
                % make sure we have same number of samples
                [ex_p_equal,ta_map] = get_equal_data(ex_p, ta_map);
                % normalize the mapping data
                [Y,PS] = mapstd(ta_map(:,4:end)',0,1);
                ta_map(:,4:end) = Y';
                % apply normalization to ta_p (test data)
                Y1 = mapstd('apply',ta_p(:,4:end)',PS);
                ta_p(:,4:end) = Y1';
                % apply CCA to learn mapping
                [W_x] = LS_CCA(ta_map(:,4:end)',ex_p_equal(:,4:end)',options);
                % apply mapping onto the test data (ta_p)
                ta_p = [ta_p(:,1:3) (W_x'*ta_p(:,4:end)')'];
                
                ta_reps = unique(ta_p(:,3));
                % initialize blank training data
                train_data = [];
                for p3 = 1:length(participants)
                    % training users
                    if p2 == p3
                        continue
                    end
                    tr_p = tr_features(tr_features(:,1) == participants(p3),:);
                    [Y,PS] = mapstd(tr_p(:,4:end)',0,1);
                    tr_p(:,4:end) = Y';
                    [ex_p_equal,tr_p] = get_equal_data(ex_p,tr_p);
                    
                    [W_x] = LS_CCA(tr_p(:,4:end)',ex_p_equal(:,4:end)',options);
                    train_data = [train_data;...
                        [tr_p(:,1:3) (W_x'*tr_p(:,4:end)')']   ];
                end
                
                
                
                
                
                LDA_mdl = fitcdiscr(train_data(:,4:end), train_data(:,2));
                
                for r = 1:length(ta_reps)
                    ta_r = ta_p(ta_p(:,3) == ta_reps(r),:);
                    
                    
                    predictions = predict(LDA_mdl, ta_r(:,4:end));

                    bs_acc(p1,p2,r) = sum(predictions == ta_r(:,2))/length(ta_r);

                    for c1 = 1:length(class_list)
                        c1_ids = ta_r(:,2) == class_list(c1);
                        for c2 = 1:length(class_list)
                            bs_cmat{p1,p2,r}(c1,c2) = sum(predictions(c1_ids) == class_list(c2))/sum(c1_ids);
                        end
                    end

                end
            end
        toc(t1)
        end
        disp(['F(' num2str(f) '/' num2str(length(featuresets)) ') ' featuresets{f} ': ' num2str(mean(mean(mean(bs_acc)))) ' ' num2str(std(mean(mean(bs_acc))))])
        save(['Features/results_amputee/' featuresets{f} '_lscca_acc.mat'],'bs_acc');
        save(['Features/results_amputee/' featuresets{f} '_lscca_cmat.mat'],'bs_cmat');
    end
end





















disp('-----------------------------------------')
disp('              Khushaba Style             ')
disp('-----------------------------------------')

options.RegType = 2;
options.RegX = 0.04;
options.PrjX = 1;
options.PrjY = 1;

remove_class = [6,7,9];
for f = 3%:length(featuresets)
    %if ~exist(['Features/results_amputee/' featuresets{f} '_lscca_acc.mat'],'file')
        
        for fi = 1:length(featuresets_components{f})
           if fi == 1
               tr_features = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
               tr_features = tr_features.feature;
               te_features = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
               te_features = te_features.feature;
               
               ee_features = load(['Features/extracted_intact/tr_' featuresets_components{f}{fi} '.mat'],'feature');
               ee_features = ee_features.feature;
           else
               tmp = load(['Features/extracted_amputee/tr_' featuresets_components{f}{fi} '.mat'],'feature');
               tmp = tmp.feature;
               tr_features = [tr_features, tmp(:,4:end)];
               
               tmp = load(['Features/extracted_amputee/te_' featuresets_components{f}{fi} '.mat'],'feature');
               tmp = tmp.feature;
               te_features = [te_features, tmp(:,4:end)];
               
               tmp = load(['Features/extracted_intact/tr_' featuresets_components{f}{fi} '.mat'],'feature');
               tmp = tmp.feature;
               ee_features = [ee_features, tmp(:,4:end)];
           end
            
        end
        
        tr_features = tr_features(~ismember(tr_features(:,2),remove_class),:);
        te_features = te_features(~ismember(te_features(:,2),remove_class),:);
        
        ee_features = ee_features(~ismember(ee_features(:,2),remove_class),:);
        
        participants = unique(tr_features(:,1));
        iparticipants = unique(ee_features(:,1));
        
        for p1 = 1:length(iparticipants)
            t1=tic;
            % expert user
            ex_p = ee_features(ee_features(:,1) == iparticipants(p1),:);
            [Y,PS] = mapstd(ex_p(:,4:end)',0,1);
            ex_p(:,4:end) = Y';
            
            
            for p2 = 1:length(participants)
                % p2 is the target user
                ta_p = te_features(te_features(:,1) == participants(p2),:);
                % the first rep is used to learn mapping
                ta_map = ta_p(ismember(ta_p(:,3),[0,1]),:);
                % other reps are used to test accuracy
                ta_p = ta_p(~ismember(ta_p(:,3),[0,1]),:);
                % make sure we have same number of samples
                [ex_p_equal,ta_map] = get_equal_data(ex_p, ta_map);
                % normalize the mapping data
                [Y,PS] = mapstd(ta_map(:,4:end)',0,1);
                ta_map(:,4:end) = Y';
                % apply normalization to ta_p (test data)
                Y1 = mapstd('apply',ta_p(:,4:end)',PS);
                ta_p(:,4:end) = Y1';
                % apply CCA to learn mapping
                [W_x] = LS_CCA(ta_map(:,4:end)',ex_p_equal(:,4:end)',options);
                % apply mapping onto the test data (ta_p)
                ta_p = [ta_p(:,1:3) (W_x'*ta_p(:,4:end)')'];
                
                ta_reps = unique(ta_p(:,3));
                % initialize blank training data
                train_data = [];
                for p3 = 1:length(participants)
                    % training users
                    if p2 == p3
                        continue
                    end
                    tr_p = tr_features(tr_features(:,1) == participants(p3),:);
                    [Y,PS] = mapstd(tr_p(:,4:end)',0,1);
                    tr_p(:,4:end) = Y';
                    [ex_p_equal,tr_p] = get_equal_data(ex_p,tr_p);
                    
                    [W_x] = LS_CCA(tr_p(:,4:end)',ex_p_equal(:,4:end)',options);
                    train_data = [train_data;...
                        [tr_p(:,1:3) (W_x'*tr_p(:,4:end)')']   ];
                end
                
                
                
                
                
                LDA_mdl = fitcdiscr(train_data(:,4:end), train_data(:,2));
                
                for r = 1:length(ta_reps)
                    ta_r = ta_p(ta_p(:,3) == ta_reps(r),:);
                    
                    
                    predictions = predict(LDA_mdl, ta_r(:,4:end));

                    bs_acc(p1,p2,r) = sum(predictions == ta_r(:,2))/length(ta_r);

                    for c1 = 1:length(class_list)
                        c1_ids = ta_r(:,2) == class_list(c1);
                        for c2 = 1:length(class_list)
                            bs_cmat{p1,p2,r}(c1,c2) = sum(predictions(c1_ids) == class_list(c2))/sum(c1_ids);
                        end
                    end

                end
            end
        %toc(t1)
        end
        
        disp(['F(' num2str(f) '/' num2str(length(featuresets)) ') ' featuresets{f} ': ' num2str(mean(mean(mean(bs_acc)))) ' ' num2str(std(mean(mean(bs_acc))))])
        %save(['Features/results_amputee/' featuresets{f} '_lscca_acc.mat'],'bs_acc');
        %save(['Features/results_amputee/' featuresets{f} '_lscca_cmat.mat'],'bs_cmat');
    %end
end

