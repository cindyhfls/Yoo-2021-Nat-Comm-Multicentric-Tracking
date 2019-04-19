function [grid,N] = map_2d(posX,posY,nbinsx,nbinsy)

% NPC_sz = 30; % for us, the NPC diameter is 30 pixels
% Xedges = quantile(posX,linspace(0,1,nbins+1));
% Yedges = quantile(posY,linspace(0,1,nbins+1));

[N,Xedges,Yedges,binX,binY] = histcounts2(posX,posY,[nbinsx nbinsy]);
% [N,~,~,binX,binY] = histcounts2(posX,posY,Xedges,Yedges);

if max(unique(binX))<nbinsx || max(unique(binY))<nbinsy
%     warning('Last bin is empty, consider reduce the number of bins');
elseif sum(N(:)==0)/numel(N)> 0.1
    warning('Many of the bins are empty, the grids might be redundant\n');
%     fprintf('Proportion empty = %1.4f \n',sum(N(:)==0)/numel(N))
    % report an error if proportion low count is <0.1
elseif sum(N(:)>0 & N(:)<50)/numel(N)>0.2
    warning('Many (%2.1f%%) low count bins\n',sum(N(:)>0 & N(:)<50)/numel(N)*100);
end
grid = dummyvar(sub2ind([nbinsx nbinsy], binX, binY));

if size(grid,2)<nbinsx*nbinsy
    grid(:,size(grid,2)+1:nbinsx*nbinsy) = 0;
end
    
% vect = [mean([Xedges(1:end-1);Xedges(2:end)]);...
%     mean([Yedges(1:end-1);Yedges(2:end)])];
% 
% figure;
% imagesc(N);
% colorbar;
end