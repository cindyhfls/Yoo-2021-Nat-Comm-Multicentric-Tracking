function iN_hist_map = map_spkhistory(psth,ext_psth,k,offset)
    
st_idx = 2; % starting from either the first timepoint or the second timepoint
% this is to match the behaviour vector length because Michael wanted to
% exclude the first behaviour recording frame for there were no velocity/direction.
shift_bins = 30+1; % ext_psth{1}(:,t+31)= psth{1}(:,t); % this is determined by using 0.5s extended ITI
n_hist_bins = k; % I want k = 10 bins history (t-10):(t-1)

n_neuron = size(psth{1},1);
n_trial = length(psth);
iN_hist_map = cell(n_trial,n_neuron);

for iTr = 1:length(psth)
    all_indices		= st_idx:size(psth{iTr},2); % Note) Change according to variable names
    if offset~=0
        central_cut = all_indices(1+abs(offset):end-abs(offset));
    else
        central_cut = all_indices;
    end
    org_len = size(psth{iTr},2)-st_idx+1;
    hist_map = NaN(org_len-2*abs(offset),n_hist_bins);
    for iN = 1:n_neuron
        for i = 1:org_len-2*abs(offset)
            t = central_cut(i);
            hist_map(i,1:n_hist_bins) = ext_psth{iTr}(iN,[(t-n_hist_bins):(t-1)]+shift_bins);
        end
        iN_hist_map{iTr,iN} = hist_map;
    end
end
end

