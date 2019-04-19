function [grid,vect,N,edges] = map_1d(var_1d,nbins)

[N,edges,bin] = histcounts(var_1d,nbins);

grid = dummyvar(bin);

if max(unique(bin))<nbins % if the last bin is empty
    warning('Last bin is empty, consider reduce the number of bins\n');
    grid = [grid,zeros(size(grid,1),1)]; % add zeros to last col
end

vect = mean([edges(1:end-1);edges(2:end)]); % center of bins


% figure;
% imagesc(N);
% colorbar;

end