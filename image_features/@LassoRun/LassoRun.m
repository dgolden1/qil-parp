classdef LassoRun
  % Represents input, running, and output of a Lasso run, along with methods for
  % printing and plotting output
  %
  % Response can be continuous, binomial, or a struct array with the fields 'event' and 'time'
  % (Cox proportional hazards)
  
  % By Daniel Golden (dgolden1 at stanford dot edu) November 2012
  % $Id$

  properties
    b
    fitinfo
    ThisFeatureSet
    Y
    YName
    ncvfolds
    mcreps
    alpha
    ROC % receiver operating characteristic struct
    ElapsedSeconds
    YPositiveClassLabel
  end
  
  properties (Dependent, SetAccess = private)
    % Dependent properties with no "set" method
    MinError
    MinPlus1SEError
    NullError
    YBoolean
    AUC % Mean ROC AUC
    Sensitivity % Mean ROC sensitivity
    Specificity % Mean ROC specificity
    Type % Type of lasso run; One of 'gaussian', 'binomial' or 'cox'
  end
  
  methods
    function obj = LassoRun(feature_set, y, y_name, varargin)
      % LassoRun(feature_set, y, y_name, varargin)
      %
      % All parameters except for feature_set are optional, and can be determined
      % from feature_set
      %
      % Response is interpreted as survival (for Cox proportional hazards regression) if
      %  it is a struct with fields 'event' (true for survival events, false for
      %  censoring) and 'time' (time to event or censoring)
      % 
      % PARAMETERS
      % mcreps: number of monte-carlo repetitions of the lasso procedure
      % (default: 20)
      % alpha: value of alpha for lasso (1=lasso, 0=ridge, everything else is
      %  elastic net) (default: 1)
      % ncvfolds: number of cross-validation folds (default: 10)
      % y_positive_class_label: for binomial response, define the "positive" class label
      %  (default: determined automatically)
      % b_plot: make plots of output (default: true)
      % b_verbose: print a bunch of output (default: true)
      %
      % Remaining PARAMETERS are passed to LassoRun.Plot
      
      if nargin == 0
        return;
      end
      
      obj.ThisFeatureSet = feature_set;
      
      if exist('y', 'var') && ~isempty(y)
        obj.Y = y(:);
      elseif ~isempty(feature_set.Response)
        obj.Y = feature_set.Response(:);
      else
        error('No response supplied to constructor or within feature set');
      end
      
      % Parse input args; other arguments get passed to LassoRun.Plot
      p = inputParser;
      p.addParamValue('mcreps', 20);
      p.addParamValue('alpha', 1);
      p.addParamValue('ncvfolds', 10);
      p.addParamValue('y_positive_class_label', []);
      p.addParamValue('b_plot', true);
      p.addParamValue('b_verbose', true);
      [args_in, args_out] = arg_subset(varargin, p.Parameters);
      p.parse(args_in{:});
      
      % Assign remaining properties
      if isempty(p.Results.y_positive_class_label)
        obj.YPositiveClassLabel = DeterminePositiveClassLabel(obj);
      else
        obj.YPositiveClassLabel = p.Results.y_positive_class_label;
      end
      
      if exist('y_name', 'var') && ~isempty(y_name)
        obj.YName = y_name;
      elseif ~isempty(feature_set.ResponseName)
        obj.YName = feature_set.ResponseName;
      else
        obj.YName = obj.YPositiveClassLabel;
      end
      
      obj.ncvfolds = p.Results.ncvfolds;
      obj.alpha = p.Results.alpha;
      
      if obj.ncvfolds == length(obj.Y)
        % Leave-one-out cross-validation doesn't require multiple Monte Carlo
        % repetitions
        obj.mcreps = 1;
      else
        obj.mcreps = p.Results.mcreps;
      end
      
      % Predict, print and plot
      obj = Predict(obj);
      
      if p.Results.b_verbose
        PrintOutput(obj);
      end
      
      if p.Results.b_plot
        Plot(obj, args_out{:});
      end
    end
    
    function value = get.MinError(obj)
      if isfield(obj.fitinfo, 'Deviance')
        value = obj.fitinfo.Deviance(obj.fitinfo.IndexMinDeviance);
      elseif isfield(obj.fitinfo, 'MSE')
        value = obj.fitinfo.MSE(obj.fitinfo.IndexMinMSE);
      else
        value = [];
      end
    end
    
    function value = get.MinPlus1SEError(obj)
      if isfield(obj.fitinfo, 'Deviance')
        value = obj.fitinfo.Deviance(obj.fitinfo.Index1SE);
      elseif isfield(obj.fitinfo, 'MSE')
        value = obj.fitinfo.MSE(obj.fitinfo.Index1SE);
      else
        value = [];
      end
    end
    
    function value = get.NullError(obj)
      [~, max_lambda_idx] = max(obj.fitinfo.Lambda);
      if isfield(obj.fitinfo, 'Deviance')
        value = obj.fitinfo.Deviance(max_lambda_idx);
      elseif isfield(obj.fitinfo, 'MSE')
        value = obj.fitinfo.MSE(max_lambda_idx);
      else
        value = [];
      end
    end
    
    function value = get.YBoolean(obj)
      if isstruct(obj.Y)
        value = false;
        return;
      end
      
      Y_unique = unique(obj.Y);
      if iscellstr(obj.Y)
        % Convert Y from cellstr to logical
        if length(Y_unique) ~= 2
          error('Y must have exactly 2 unique values');
        end
        value = strcmp(obj.Y, obj.YPositiveClassLabel);
      elseif length(Y_unique) == 2
        value = logical(obj.Y);
      else
        % Continuous response
        value = [];
      end
    end
    
    function value = get.AUC(obj)
      if ~isempty(obj.ROC)
        value = mean(obj.ROC.AUC);
      else
        value = [];
      end
    end
    
    function value = get.Sensitivity(obj)
      if ~isempty(obj.ROC)
        value = mean(obj.ROC.opt_sensitivity);
      else
        value = [];
      end
    end
    
    function value = get.Specificity(obj)
      if ~isempty(obj.ROC)
        value = mean(obj.ROC.opt_specificity);
      else
        value = [];
      end
    end
    
    function value = get.Type(obj)
      if isstruct(obj.Y)
        % True if response is censored survival
        value = 'cox';
        return
      end
      
      Y_unique = unique(obj.Y);
      if length(Y_unique) == 2
        % Y has two categories
        value = 'binomial';
      elseif iscellstr(Y_unique)
        % Y is a cellstring and has more than two categories
        error('Unsupported number of string response categories: %d', length(Y_unique));
      else
        % Y is continuous
        value = 'gaussian';
      end
    end
  end
  
  methods (Static)
    MakeForestPlot(lasso_runs, run_names, h_fig)
  end
end
