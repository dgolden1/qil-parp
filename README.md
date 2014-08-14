qil-parp
========

The repository contains code that can be used to reproduce results from the following journal paper:

Golden, D. I., Lipson, J. A., Telli, M. L., Ford, J. M., & Rubin, D. L. (2013). Dynamic contrast-enhanced MRI-based biomarkers of therapeutic response in triple-negative breast cancer. Journal of the American Medical Informatics Association. doi:10.1136/amiajnl-2012-001460

The paper is available online at [http://jamia.bmj.com/content/early/2013/06/25/amiajnl-2012-001460.abstract](http://jamia.bmj.com/content/early/2013/06/25/amiajnl-2012-001460.abstract)

The code was written primarily by Daniel Golden. You can contact him at "dgolden1", followed by gmail dot com.

To fully reproduce the results, you will also need the MRI data. We are actively seeking permission to release that data.

# Pharmacokinetic Modeling Code
Pharmacokinetic modeling code in the `parp/nicks_PK_code` directory was written primarily by Nick Hughes with some modifications by Daniel Golden.

# Example
An example to reproduce the results for GLCM pre-chemo features on predicting pCR:

    addpaths;
    db = LoadDB(PARPDB, '/path/to/pre_res_1.5_resized_maps');
    
    % These patients may be in the database, but they were not included in the run for the paper because the data were not available at that time
    exclude_patients = [112 113 114];
    
    lr = RunLassoModel(db, {'b_glcm', true}, 'rcb_pcr', 'exclude_patients', exclude_patients); 
