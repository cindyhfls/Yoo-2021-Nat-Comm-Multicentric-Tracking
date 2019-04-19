% This function formats the data into inputs to generate design matrix
function [concat_psth, self_posx, self_posy, self_vel, self_dir,prey_posx,prey_posy,prey_vel,prey_dir,dist_fromPrey,angle_toPrey,trial_exclusion_idx,artifact_idx] = format_data_new( psth,vars,varargin)
% default options
offset = 0;
cut = false;
assignopts(who,varargin);

fprintf('Formating data.. this might take a few seconds\n\n');

% Trial length
n_tr =  length( psth );

% Subject Dynamics
subj_dynamics = cell(length(vars),1);
subj_dynamics_str = {'posx','posy','vel','dir'};

% Prey (pursuited) Dynamics
prey_dynamics = cell(length(vars),1);
prey_dynamics_str = {'posx','posy','vel','dir'};
switched = false(n_tr ,1);

time_res_frame = cell(length(vars),1);% Time (seconds) in each frame

dist_fromPrey =cell(length(vars),1);
angle_toPrey = cell(length(vars),1);

% function to calculate distance for two vector coordinates
cal_dist = @(x,y) sqrt(sum(x.^2+y.^2,2)); 
%% For each trial
for iTr = 1: n_tr 
    % if not starting from the first frame of the trial (second instead)
    psth{iTr} = psth{iTr}(:,2:end);
    
    %%% time resolution
    time_res_frame{iTr} = vars{iTr}.time_res(2:end);
        
    %%% Prey switch
    % which prey is pursuited (for unswitched trials only
    if vars{iTr}.numPrey > 1
        pursuit_idx = detect_unswitch(vars{iTr}.self_pos{1}, vars{iTr}.prey_pos);
    else
        pursuit_idx = 1;
    end
     
    %%% Subject dynamics (avatar)
    % posx, posy
    subj_dynamics{iTr}(:,1) = vars{iTr}.self_pos{1}(2:end,1); % Pos start from the second time bin to match up vector length
    subj_dynamics{iTr}(:,2) = vars{iTr}.self_pos{1}(2:end,2);
    % speed
    subj_dynamics{iTr}(:,3) = cal_dist(diff(vars{iTr}.self_pos{1}(:,1)),diff(vars{iTr}.self_pos{1} (:,2)));
    % direction (angular velocity)
    subj_dynamics{iTr}(:,4) =  wrapTo2Pi( atan2( diff( vars{iTr}.self_pos{1}(:, 2)),  diff( vars{iTr}.self_pos{1}(:, 1)) ) );
    
    %%% Prey dynamics
    if pursuit_idx == 1 || pursuit_idx == 2 % only when pursuit_idx is a valid number (i.e. non-switch)
        prey_dynamics{iTr}(:,1) = vars{iTr}.prey_pos{pursuit_idx}(2:end,1); % Pos start from the second time bin to match up vector length
        prey_dynamics{iTr}(:,2) = vars{iTr}.prey_pos{pursuit_idx}(2:end,2);
        % speed
        prey_dynamics{iTr}(:,3) = cal_dist(diff(vars{iTr}.prey_pos{pursuit_idx}(:,1)),diff(vars{iTr}.prey_pos{pursuit_idx} (:,2)));
        % direction(angular velocity)
        prey_dynamics{iTr}(:,4) =  wrapTo2Pi( atan2( diff( vars{iTr}.prey_pos{pursuit_idx}(:, 2)),  diff( vars{iTr}.prey_pos{pursuit_idx}(:, 1)) ) );
    else
        prey_dynamics{iTr} = NaN(size(subj_dynamics{iTr}));
    end
     

    if cut % producing data for timeshift
       all_indices	= 1:length(time_res_frame{iTr}); % Note) Change according to variable names
       central_cut = all_indices(1+50:end-50); % hardcode to get the same spike for any time shift cut the first 50 frames and last 50 frames from trial
       psth{iTr} = psth{iTr}(:,central_cut); % psth is always the central part
       time_res_frame{iTr} = time_res_frame{iTr}(1,central_cut);
       subj_dynamics{iTr} = subj_dynamics{iTr}(central_cut+offset,:);
       prey_dynamics{iTr} = prey_dynamics{iTr}(central_cut+offset,:);
    end
    
    %%% angle and distance from prey (ego-centric)
    dist_fromPrey{iTr} = NaN(length(time_res_frame{iTr}),1);
    angle_toPrey{iTr} = NaN(length(time_res_frame{iTr}),1);
    
    if isnan(pursuit_idx)
        switched(iTr) = true;
    else
        dist_fromPrey{iTr} = cal_dist(subj_dynamics{iTr}(:,1) - prey_dynamics{iTr}(:,1),subj_dynamics{iTr}(:,2)- prey_dynamics{iTr}(:,2));
        temp = prey_dynamics{iTr}(:,1:2) - subj_dynamics{iTr}(:,1:2);
        angle_toPrey{iTr} = wrapTo2Pi(atan2(temp(:,2),temp(:,1)));
    end
    
end

%%%% Trial-level exclusion
% reward = arrayfun(@(i)vars{i}.reward,1:length(vars));
% numPredator = arrayfun(@(i)vars{i}.numNPCs-vars{i}.numPrey,1:length(vars));
% cond(:,1) = reward == 0 & numPredator == 0; %% remove time-out
subj_trajectory = cellfun(@(i)i.self_pos,vars);
[~,cond(:,1)] = exclude_n_att(subj_trajectory);%% remove time-out in a different way
cond(:,2) = switched;%% remove switch trials % you can add as many as you want
% conditions here
trial_exclusion_idx = any(cond,2); % 2nd dimension, if any of the conditions are satisfied


subj_dynamics(trial_exclusion_idx,:)= [];
prey_dynamics(trial_exclusion_idx,:) = [];
time_res_frame(trial_exclusion_idx) = [];
psth(trial_exclusion_idx) = [];
dist_fromPrey(trial_exclusion_idx) = [];
angle_toPrey(trial_exclusion_idx) = [];
vars(trial_exclusion_idx) = [];

%%%% Now concatenate everything into vectors
concat_psth = [psth{:}]';
time_res_frame = horzcat(time_res_frame{:})';
dist_fromPrey = vertcat(dist_fromPrey{:});
angle_toPrey = vertcat(angle_toPrey{:});


temp = vertcat(subj_dynamics{:});
self_posx = temp(:,1);
self_posy = temp(:,2);
self_vel = temp(:,3);
self_dir = temp(:,4);

temp = vertcat(prey_dynamics{:});
prey_posx = temp(:,1);
prey_posy = temp(:,2);
prey_vel = temp(:,3);
prey_dir = temp(:,4);

%%%% Frame-level exclusion:
% remove data points when the screen refreshment rate is weird (>0.17 or
% <0.16, these might cause bias towards lower ranges)
% cond2 (:,1) = time_res_frame>0.017 | time_res_frame<0.016;
% cond2(:,1) = false(length(time_res_frame),1); % update July 2, 2018 no longer remove artifact points
cond2(:,1) = self_vel==0 | prey_vel ==0;
artifact_idx = any(cond2,2); % you can add more conditions such as zero acceleration etc.
% Hypothesis: Maps are clearer when animal is stable/static etc.?

concat_psth(artifact_idx,:) = [];
self_posx(artifact_idx)	= [];
self_posy(artifact_idx) = [];
self_dir(artifact_idx)	= [];
self_vel(artifact_idx)	= [];
prey_posx(artifact_idx)	= [];
prey_posy(artifact_idx) = [];
prey_dir(artifact_idx)	= [];
prey_vel(artifact_idx)	= [];
dist_fromPrey(artifact_idx) = [];
angle_toPrey(artifact_idx) = [];
time_res_frame(artifact_idx) = [];

fprintf(' Input data formatted. Removed %i artifact time points.\nTotal number of trials = %i, total number of neurons = %i,\ntotal number of time frames %i\n\n', ...
    sum(artifact_idx),size(psth,1),size(concat_psth,2), size(concat_psth,1));

end