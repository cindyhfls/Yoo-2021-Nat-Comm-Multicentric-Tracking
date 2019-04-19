function [grid] = NPC_map(vars,time_res_frame)

temp = arrayfun(@(iTr)vars{iTr}.valNPCs,1:length(vars),'UniformOutput',false);
vals = unique(cell2mat(temp));  % all possible values

n_prey_category = sum(vals<1); % should be 5
if any(vals>1)
    n_predator_category = sum(vals>1); % Kirk
    vals = [fliplr(vals(vals>1)),vals(vals<1)]; % from worst predator to best prey
else
    n_predator_category = 1; % Hobbs
end

n_params = n_prey_category + n_predator_category;

trial_length = [0,arrayfun(@(iTr)length(time_res_frame{iTr}),1:length(vars))];% start from the second time frame so -1
trial_idx = cumsum(trial_length);

grid = NaN(sum(trial_length),n_params);

for iTr = 1:length(vars)
    if n_predator_category == 1
        % which prey(s) were on the screen (2 to last cols)
        grid(trial_idx(iTr)+1:trial_idx(iTr+1),2:end) = repmat(sum(vals == vars{iTr}.valNPCs',1),trial_idx(iTr+1)-trial_idx(iTr),1); % sum along rows always
        grid(trial_idx(iTr)+1:trial_idx(iTr+1),1) = vars{iTr}.numNPCs-vars{iTr}.numPrey;
        % if a predator was on the screen (1st col)
        % N.B. organized in this way because there is a linear trend for
        % attractiveness with the predator being least attractive, and is more
        % convenient if rough penalty is applied in fitting
    else
        grid(trial_idx(iTr)+1:trial_idx(iTr+1),1:end) = repmat(sum(vals == vars{iTr}.valNPCs',1),trial_idx(iTr+1)-trial_idx(iTr),1); % sum along rows always
    end
        
end

end
