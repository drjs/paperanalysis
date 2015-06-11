function hasStatsTbx = checkForStatisticsToolbox()
    %CHECKFORSTATISTICSTOOLBOX Checks if the statistics toolbox is
    %installed. Returns true if present, false otherwise. 
    % This function is used for disabling functionality which will not work
    % without the statistics toolbox. This includes:
    % - Word clustering in Word Clouds. Statistics functions are used to compare different
    %   documents, this is how we measure when words tend to appear
    %   together or not. Without this function the word cloud will only
    %   have one cluster.
    % - Semantic Surface. The semantic surface visualisation relies heavily
    %   on statistical analysis techniques (mostly PCA) to measure the
    %   similarity  between documents. Without the statistics toolbox this
    %   will not work at all, so the feature is disabled.
    
    installedToolboxes = ver;
    installedToolboxes = {installedToolboxes.Name};
    statsTbxNames = {'Statistics and Machine Learning Toolbox', 'Statistics Toolbox'};
    hasStatsTbx = any(ismember(statsTbxNames, installedToolboxes));
    
end

