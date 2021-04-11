function [Results] = between_subject_accuracy(feat_i, info_i, feat_j, info_j, intervention)

% perform leave one rep out gesture classification within position
f_mat_i = [];
f_mat_j = [];

fields = fieldnames(feat_i);

for f = 1:length(fields)
    f_mat_i = [f_mat_i feat_i.(fields{f})];
    f_mat_j = [f_mat_j feat_j.(fields{f})];
end

class_list = unique(info_i.class);
rep_list = unique(info_i.rep);

f_mat_i = [info_i.subject info_i.class info_i.position info_i.rep f_mat_i];
f_mat_i = real(f_mat_i);

f_mat_j = [info_j.subject info_j.class info_j.position info_j.rep f_mat_j];
f_mat_j = real(f_mat_j);


s_tr = f_mat_i;
[s_tr_data, MU, SIGMA] = zscore(s_tr(:,5:end));
s_tr = [s_tr(:,1:4) s_tr_data];

s_te = f_mat_j;
s_te_data = (s_te(:,5:end)-MU)./SIGMA;
s_te = [s_te(:,1:4) s_te_data];

switch intervention{1}
    case 'NOCCA'
        LDAMdl = fitcdiscr(s_tr(:,5:end), s_tr(:,2),'discrimtype','pseudolinear');
        predictions = predict(LDAMdl, s_te(:,5:end));
        Results.Gesture.LDA = sum(predictions == s_te(:,2))/length(s_te(:,2));
        
        for c = 1:length(class_list)
            true_c = (s_te(:,2) == class_list(c));% rows are true class
            for cc = 1:length(class_list)
                Results.Gesture.LDAConf(c,cc) = sum(predictions(true_c) == class_list(cc));
            end
        end
        
        QDAMdl = fitcdiscr(s_tr(:,5:end), s_tr(:,2),'discrimtype','pseudoquadratic');
        predictions = predict(QDAMdl, s_te(:,5:end));
        Results.Gesture.QDA = sum(predictions == s_te(:,2))/length(s_te(:,2));
        
        for c = 1:length(class_list)
            true_c = (s_te(:,2) == class_list(c));% rows are true class
            for cc = 1:length(class_list)
                Results.Gesture.QDAConf(c,cc) = sum(predictions(true_c) == class_list(cc));
            end
        end
        
        kNNMdl = fitcknn(s_tr(:,5:end), s_tr(:,2),'NumNeighbors',5);
        predictions = predict(kNNMdl, s_te(:,5:end));
        Results.Gesture.kNN = sum(predictions ==  s_te(:,2))/length(s_te(:,2));
        
        for c = 1:length(class_list)
            true_c = (s_te(:,2) == class_list(c));% rows are true class
            for cc = 1:length(class_list)
                Results.Gesture.kNNConf(c,cc) = sum(predictions(true_c) == class_list(cc));
            end
        end
        
        RFMdl = TreeBagger(5,s_tr(:,5:end),s_tr(:,2));
        predictions = predict(RFMdl, s_te(:,5:end));% these are output as characters
        predictions = str2double(predictions);
        Results.Gesture.RF = sum(predictions == s_te(:,2))/length(s_te(:,2));
        
        for c = 1:length(class_list)
            true_c = (s_te(:,2) == class_list(c));% rows are true class
            for cc = 1:length(class_list)
                Results.Gesture.RFConf(c,cc) = sum(predictions(true_c) == class_list(cc));
            end
        end
        
    case 'CCA'
        reps_used = intervention{2};
        rep_combs = nchoosek(1:6, reps_used); % each row is a combination
        
        
        for r = 1:length(rep_combs)
            %target subject mapping data
            if size(rep_combs,2) == 1
                ts_tr = s_te( s_te(:,4)== rep_combs(r), :);
                ts_te = s_te( s_te(:,4)~= rep_combs(r), :);
            else
                ts_tr = s_te( ismember(s_te(:,4),rep_combs(r,:)), :);
                ts_te = s_te( ~ismember(s_te(:,4),rep_combs(r,:)), :);
            end
            % cannonical correlation requires that the dataset has the same
            % number of samples (paired test). Lets try running it on the
            % PCA mappings of each dataset.
            % FIRST: zscore the data
            [z_ss_tr, MU_ss, SIGMA_ss] = zscore(s_tr(:,5:end));
            [z_ts_tr, MU_ts, SIGMA_ts] = zscore(ts_tr(:,5:end));%(ts_tr(:,5:end) - MU)./ SIGMA;
            % SECOND: get pca coefs for both dataset
            [ss_coeff,~,~,~,explained,~] = pca(z_ss_tr);
            explained = cumsum(explained);
            num_pc = length(explained);%find(explained > 90,1);
            [ts_coeff] = pca(z_ts_tr);
            % THIRD: perform CCA with the two mapping rules
            [cca_ss_m, cca_ts_m, ~, ~, ~] = canoncorr(ss_coeff(:,1:num_pc), ts_coeff(:,1:num_pc));

            % This variable has the transformed training data
            
            cca_s_tr = [[s_tr(:,1:4),  z_ss_tr(:,1:num_pc) * cca_ss_m];...
                        [ts_tr(:,1:4), z_ts_tr(:,1:num_pc) * cca_ts_m]];
            % Train the models
            LDAMdl = fitcdiscr(cca_s_tr(:,5:end), cca_s_tr(:,2),'discrimtype','pseudolinear');
            QDAMdl = fitcdiscr(cca_s_tr(:,5:end), cca_s_tr(:,2),'discrimtype','pseudoquadratic');
            kNNMdl = fitcknn(cca_s_tr(:,5:end), cca_s_tr(:,2),'NumNeighbors',5);
            RFMdl = TreeBagger(5,cca_s_tr(:,5:end),cca_s_tr(:,2));
            
            % This variable has the transformed testing data
            z_ts_te = (ts_te(:,5:end)-MU_ts)./SIGMA_ts;
            cca_s_te = [ts_te(:,1:4), z_ts_te(:,1:num_pc) * cca_ts_m];
            
            % Get results for all classifiers
            % LDA
            predictions = predict(LDAMdl, cca_s_te(:,5:end));
            Results.Gesture.LDA(r) = sum(predictions == cca_s_te(:,2))/length(cca_s_te(:,2));
            for c = 1:length(class_list)
                true_c = (cca_s_te(:,2) == class_list(c));% rows are true class
                for cc = 1:length(class_list)
                    Results.Gesture.LDAConf{r}(c,cc) = sum(predictions(true_c) == class_list(cc));
                end
            end
            % QDA
            predictions = predict(QDAMdl, cca_s_te(:,5:end));
            Results.Gesture.QDA(r) = sum(predictions == cca_s_te(:,2))/length(cca_s_te(:,2));
            for c = 1:length(class_list)
                true_c = (cca_s_te(:,2) == class_list(c));% rows are true class
                for cc = 1:length(class_list)
                    Results.Gesture.QDAConf{r}(c,cc) = sum(predictions(true_c) == class_list(cc));
                end
            end
            %kNN
            predictions = predict(kNNMdl, cca_s_te(:,5:end));
            Results.Gesture.kNN(r) = sum(predictions == cca_s_te(:,2))/length(cca_s_te(:,2));
            for c = 1:length(class_list)
                true_c = (cca_s_te(:,2) == class_list(c));% rows are true class
                for cc = 1:length(class_list)
                    Results.Gesture.kNNConf{r}(c,cc) = sum(predictions(true_c) == class_list(cc));
                end
            end
            %RF
            predictions = predict(RFMdl, cca_s_te(:,5:end));% these are output as characters
            predictions = str2double(predictions);
            Results.Gesture.RF(r) = sum(predictions == cca_s_te(:,2))/length(cca_s_te(:,2));

            for c = 1:length(class_list)
                true_c = (cca_s_te(:,2) == class_list(c));% rows are true class
                for cc = 1:length(class_list)
                    Results.Gesture.RFConf{r}(c,cc) = sum(predictions(true_c) == class_list(cc));
                end
            end
            
        end
        
end


end
