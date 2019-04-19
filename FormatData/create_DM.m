if exist('DM','var')
    fs = fieldnames(DM);
    for i = 1:length(fs)
        eval([fs{i} '= DM.' fs{i} ';']); % opposite approach if data loaded directly
    end
    hist_map = DM.spkhist;
    concatpsth = DM.spiketrain;
%     NPC_grid = DM.NPC;
else
% state the number of bins to use for recorded variables
n_dir_bins = 12;
n_speed_bins = 12 ;
n_pos_bins = 10;%15 
n_dist_bins = 12;
n_angle_bins = 12;
% n_acc_edges = [-Inf,-0.01,0.01,Inf]; % deceleration, zero, acceleration
% n_angular_acc_edges = [-pi,-pi/180,pi/180,pi]; % angle turn within 1 deg VS large angle turn
% n_reward_edges = [-Inf;unique(reward_exp)+0.001];
% n_acc_bins = length(n_acc_edges)-1;
% n_angular_acc_bins = length(n_angular_acc_edges)-1;
% n_reward_bins = length(n_reward_edges)-1;
end

try
%%% Self
% compute speed matrix
self_spd_grid = map_1d(self_vel,n_speed_bins);
self_dir_grid = map_1d(self_dir,n_dir_bins);
% compute position matrix
self_pos_grid = map_2d(self_posx,self_posy,n_pos_bins,n_pos_bins);
% compute acceleration matrix
% self_acc_grid = map_1d_by_edge(self_acc,n_acc_edges);
% self_angular_acc_grid = map_1d_by_edge(abs(self_angular_acc),n_angular_acc_edges);
% save the inputs in a structure
DM.self_vel = self_vel;
DM.self_dir = self_dir;
DM.self_posx = self_posx;
DM.self_posy = self_posy;
% DM.self_acc = self_acc;
% DM.self_angular_acc = self_angular_acc;
catch
end

try
%%% Prey
prey_spd_grid = map_1d(prey_vel,n_speed_bins);
prey_dir_grid = map_1d(prey_dir,n_dir_bins);
prey_pos_grid = map_2d(prey_posx,prey_posy,n_pos_bins,n_pos_bins);
DM.prey_vel = prey_vel;
DM.prey_dir = prey_dir;
DM.prey_posx = prey_posx;
DM.prey_posy = prey_posy;
catch
end

% n_NPC_params = size(NPC_grid,2);% number of unique NPCs

dist_grid = map_1d(dist_fromPrey,n_dist_bins);
angle_grid = map_1d(angle_toPrey,n_angle_bins);
% reward_grid = map_1d_by_edge(reward_exp,n_reward_edges);

DM.dist_fromPrey = dist_fromPrey;
DM.angle_toPrey = angle_toPrey;
% DM.reward_exp = reward_exp;
DM.spkhist = hist_map;
% DM.NPC = NPC_grid;
DM.spiketrain = concatpsth;

DM.n_dir_bins = n_dir_bins;
DM.n_speed_bins = n_speed_bins;
DM.n_pos_bins = n_pos_bins;
% DM.n_acc_edges = n_acc_edges;
% DM.n_angular_acc_edges = n_angular_acc_edges;
DM.n_spkhist_params = n_spkhist_params;
% DM.n_NPC_params = n_NPC_params;
DM.n_dist_bins = n_dist_bins;
DM.n_angle_bins = n_angle_bins;
% DM.n_reward_edges = n_reward_edges;

n_neuron = size( concatpsth, 2 ); %total number of neurons
n_coupling_params = n_neuron-1; % all other neurons
DM.n_coupling_params = n_coupling_params;

%%%%%%% IMPORTANT  START
% This is the only part you need to edit, the rest of the code is automated given what is inputed%%%%
% define the number of parameters for each variable (Highly flexible part)
% Actually the grids part need to be changed in fit_ln_topdown.m or
% fit_ln_bottomup.m
numParams = [n_pos_bins.^2,n_dir_bins,n_speed_bins,...
    n_pos_bins.^2,n_dir_bins,n_speed_bins,n_dist_bins,n_angle_bins]; % this is used in the model code for parsing input parameters into correct sizes

% what each of the parameter mean for human understanding only
vars_explained = {'Pos','Dir','Vel','PreyPos','PreyDir','PreyVel','Dist','Angle'};

% type of parameter, determine what the regularization calculation is
typeParams = {'2d','1dcirc','1d','2d','1dcirc','1d','1d','1dcirc'};

% regularization (roughness penalty for 2d and 1d, lasso for 0d
%     reg_weights = zeros(length(numParams),1); % default is no regularization (roughness penalty)
reg_weights= [1e1; 1e1; 1e1; 1e1; 1e1; 1e1; 1e1; 1e1];

%%%%%%% IMPORTANT  END