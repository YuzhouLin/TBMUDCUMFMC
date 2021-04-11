clear all
clc
% make a dictionary of the auxillary subjects
% see how src performs

featureset = 'EMGTD';

for subject_i = 1:60
    fset_i = load(['Prepped_Feature_Sets/' featureset '_S' num2str(subject_i) '.mat']);
    feat_i = fset_i.feat;
    info_i = fset_i.info;
    fields = fieldnames(feat_i);
    fmat = [];
    for f=1:length(fields)
        fmat = [fmat feat_i.(fields{f})];
    end

    %subjects_j = [1:(subject_i-1), (subject_i+1):60];
    subjects_j = 2:5;
    for subject_j = 1:length(subjects_j)
       subj_j{subject_j} = load(['Prepped_Feature_Sets/' featureset '_S' num2str(subjects_j(subject_j)) '.mat']);
    end
    [SRC_dict,labels] = SRC_make_dict(6, subj_j,0);
    
    [predictions,t] = SRC_predict(SRC_dict, fmat, 1e-5,step);
    
       
        
end