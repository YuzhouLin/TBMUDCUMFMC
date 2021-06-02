figure()

fs = 'EMGTD';

for s1 = 1:60
    results = load(['Results_Within_Subject\' fs '_S' num2str(s1) '.mat']);
    fn = fieldnames(results);
    if strcmp(fn, 'results')
        within_acc(s1) = mean(results.results.Gesture.LDA);
    else
        within_acc(s1) = mean(results.Gesture.LDA);
    end
end

between_acc = zeros(60,60);
for s1 = 1:60
    for s2 = 1:60
        if s1 == s2
            continue
        end
        results = load([Results_Between_Subject_No_CCA\' fs '_S' num2str(s1) '_S' num2str(s2) '.mat']);
        fn = fieldnames(results);
        if strcmp(fn, 'results')
            between_acc(s1,s2) = mean(results.results.Gesture.LDA);
        else
            between_acc(s1,s2) = mean(results.Gesture.LDA);
        end
    end
end
between_acc = sum(between_acc,2) ./ sum(between_acc~=0,2);


acc_cca = zeros(60,5);
for r = 1:5
    acc_cca_r = zeros(60,60);
    for s1 = 1:60
        for s2 = 1:60
            if s1 == s2
                continue
            end
            results = load([Results_Between_Subject_CCA\' fs '_R' num2str(r) '_S' num2str(s1) '_S' num2str(s2) '.mat']);
            fn = fieldnames(results);
            if strcmp(fn, 'results')
            acc_cca_r(s1,s2) = mean(results.results.Gesture.LDA);
            else
                acc_cca_r(s1,s2) = mean(results.Gesture.LDA);
            end

        end
    end
    acc_cca(:,r) = sum(acc_cca_r,2) ./ sum(acc_cca_r ~=0,2);
end

all_accs = [within_acc', between_acc, acc_cca];

boxplot(all_accs,{'Within','Between','CCA-R1','CCA-R2','CCA-R3','CCA-R4','CCA-R5'})

