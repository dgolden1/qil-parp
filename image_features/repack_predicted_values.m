function predictedValuesNew = repack_predicted_values(predictedValuesOld, cvparray)
% Initially, predictedValues is an NxM cell array of N cross validation
% repetitions (num partitions*num monte carlo repetitions) and M values of
% lambda
% 
% Repack predictedValues so that each row is a different monte carlo
% repetition and each column is a different lambda, and each cell is the
% predicted values for the response, in the original order
% 
% I verified this by calculating the deviance based on these values and
% checking that it's within 1% of the reported deviance

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id: repack_predicted_values.m 124 2012-12-11 23:43:40Z dgolden $

mcreps = length(cvparray);
num_partitions = cvparray{1}.NumTestSets;
num_lambda = size(predictedValuesOld, 2);

predictedValuesNew = cell(mcreps, num_lambda);
for kk = 1:length(cvparray)
  % For each monte carlo repetition...
  cvpkk = cvparray{kk};

  clear thisIndices;
  for jj = 1:cvpkk.NumTestSets
    % For each cross-validation test set, figure out what the original
    % patient indices were
    thisIndices{jj,1} = find(cvpkk.test(jj));
    % thisPredictedValues = predictedValuesOld{idx_into_orig};
  end
  
  idxThisMCRepIntoOrig = ((kk-1)*cvpkk.NumTestSets + 1):(kk*cvpkk.NumTestSets);
  thisIndicesCombined = cell2mat(thisIndices);
  [~, sortIdx] = sort(thisIndicesCombined);
  for ii = 1:num_lambda
    predictedValuesOrigForThisLambda = cell2mat(predictedValuesOld(idxThisMCRepIntoOrig,ii));
    predictedValuesNew{kk, ii} = predictedValuesOrigForThisLambda(sortIdx);
  end
end
