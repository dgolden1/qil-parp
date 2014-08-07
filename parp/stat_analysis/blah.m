clear;
load ~/temp/blah1.mat

Y_bino = strcmp(Y, Y{1});

dev = nan(size(fitinfo.predictedValues));
for kk = 1:numel(dev)
  dev(kk) = sum(devFun(fitinfo.predictedValues{kk}, Y_bino));
end
