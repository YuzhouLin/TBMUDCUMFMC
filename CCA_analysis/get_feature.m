function [feat] = get_feature(data,channel,winsize,wininc,feat,feat_name)
%CHECK_FEATURE Summary of this function goes here
%   Detailed explanation goes here

    if contains(feat_name, 'EMG')
        channels = channel{1};
    else
        channels = channel{2};
    end
    
    if ~isfield(feat, feat_name)
        feat.(feat_name) = [];
    end
    
    f_fn = str2func(['get' lower(feat_name(4:end)) 'feat']);
    feat.(feat_name) = [feat.(feat_name); feval(f_fn, data(:,channels),winsize,wininc)];
end

