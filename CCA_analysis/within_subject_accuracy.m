function [Results] = within_subject_accuracy(feat,info)

% perform leave one rep out gesture classification within position
f_mat = [];

fields = fieldnames(feat);

for f = 1:length(fields)
    f_mat = [f_mat feat.(fields{f})];
end

class_list = unique(info.class);
rep_list = unique(info.rep);

f_mat = [info.subject info.class info.position info.rep f_mat];
f_mat = real(f_mat);

for r = 1:length(rep_list)
    
    s_tr = f_mat(f_mat(:,4) ~= rep_list(r),:);
    [s_tr_data, MU, SIGMA] = zscore(s_tr(:,5:end));
    s_tr = [s_tr(:,1:4) s_tr_data];
    
    s_te = f_mat(f_mat(:,4) == rep_list(r),:);
    s_te_data = (s_te(:,5:end)-MU)./SIGMA;
    s_te = [s_te(:,1:4) s_te_data];
    
    LDAMdl = fitcdiscr(s_tr(:,5:end), s_tr(:,2),'discrimtype','pseudolinear');
    predictions = predict(LDAMdl, s_te(:,5:end));
    Results.Gesture.LDA(r) = sum(predictions == s_te(:,2))/length(s_te(:,2));
    
    for c = 1:length(class_list)
        true_c = (s_te(:,2) == class_list(c));% rows are true class
        for cc = 1:length(class_list)
            Results.Gesture.LDAConf{r}(c,cc) = sum(predictions(true_c) == class_list(cc));
        end
    end
    
    QDAMdl = fitcdiscr(s_tr(:,5:end), s_tr(:,2),'discrimtype','pseudoquadratic');
    predictions = predict(QDAMdl, s_te(:,5:end));
    Results.Gesture.QDA(r) = sum(predictions == s_te(:,2))/length(s_te(:,2));
    
    for c = 1:length(class_list)
        true_c = (s_te(:,2) == class_list(c));% rows are true class
        for cc = 1:length(class_list)
            Results.Gesture.QDAConf{r}(c,cc) = sum(predictions(true_c) == class_list(cc));
        end
    end
    
    kNNMdl = fitcknn(s_tr(:,5:end), s_tr(:,2),'NumNeighbors',5);
    predictions = predict(kNNMdl, s_te(:,5:end));
    Results.Gesture.kNN(r) = sum(predictions ==  s_te(:,2))/length(s_te(:,2));
    
    for c = 1:length(class_list)
        true_c = (s_te(:,2) == class_list(c));% rows are true class
        for cc = 1:length(class_list)
            Results.Gesture.kNNConf{r}(c,cc) = sum(predictions(true_c) == class_list(cc));
        end
    end
    
    RFMdl = TreeBagger(5,s_tr(:,5:end),s_tr(:,2));
    predictions = predict(RFMdl, s_te(:,5:end));% these are output as characters
    predictions = str2double(predictions);
    Results.Gesture.RF(r) = sum(predictions == s_te(:,2))/length(s_te(:,2));
    
    for c = 1:length(class_list)
        true_c = (s_te(:,2) == class_list(c));% rows are true class
        for cc = 1:length(class_list)
            Results.Gesture.RFConf{r}(c,cc) = sum(predictions(true_c) == class_list(cc));
        end
    end
    
end




end