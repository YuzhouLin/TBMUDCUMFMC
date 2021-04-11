function [Results] = between_subject_accuracy_LOSOCCA(feat, info)



class_list = unique(info{1}.class);
rep_list = unique(info{1}.rep);

for subject = 1:60
    % prep data
    [zfmat{subject}, MU{subject},  SIGMA{subject},     pca_map{subject}] = prep_subj_data(feat{subject},info{subject});
end

for candidate = 1:60
    for subject = 1:60
        if candidate == subject
            continue
        end
        [A, B, r, C, D] = canoncorr(pca_map{candidate}, pca_map{subject});
        ccafmat{subject} = zfmat{subject}(:,5:end) * A;
        ccafmat2{subject} = zfmat{candidate}(:,5:end) * B;
        
        figure()
        gscatter(ccafmat{subject}(:,1),ccafmat{subject}(:,2),zfmat{subject}(:,2))
        figure()
        gscatter(ccafmat2{subject}(:,1),ccafmat2{subject}(:,2),zfmat{candidate}(:,2))

        
    end
end









% % prep feature bank
% tr_data = [];
% for b = 1:length(feat_b)
%     b_feat = feat_b{b};
%     b_info = info_b{b};
%     [z_fmat_b, ~,  ~,     pca_map_b] = prep_subj_data(b_feat,b_info);
%     [cca_bc, cca_cb, beta, alpha1, alpha2] = km_kcca(pca_map_b,pca_map_c,'linear',[],0.01,'full')
%     %[cca_bc, cca_cb] = rCCA(pca_map_b, pca_map_c);
%     
%     %mapped
%     %m_data = z_fmat_b(:,5:end) * cca_bc * pinv(cca_cb);
%     %tr_data = [tr_data; ...
%     %    [ z_fmat_b(:,1:4), m_data]];
% end
% 







% prep novel data
% switch r here:
[z_fmat_n, MU, SIGMA, pca_map_n] = prep_subj_data(feat_n,info_n);




end
