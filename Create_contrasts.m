%% Contrast estimation
% The first level model was already estimated in the CamCAN pipelines. Here,
% we create the contrasts for each load and task phase. This data has not
% been moved to Michelle's space since it does not need to change. 

clc; clear

addpath('/Volumes/STD-Donders-DCC-Geerligs/Michelle/')
addpath(genpath('/Volumes/STD-Donders-DCC-Geerligs/Cambridge_data/Toolboxes/SPM12/'))
condir =  '/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/aamod_firstlevel_contrasts_00001/';

%find all subjects (each subject has a directory)
files=dir([condir 'CBU*']);
numfiles=length(files);

%% create new contrasts
%note that all contrasts are created to make it easier to investigate the
%other effects

matlabbatch={};
for i=1:numfiles
    CBUID = files(i).name;

    matlabbatch{1}.spm.stats.con.spmmat = {[condir CBUID '/stats/SPM.mat']};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'encoding load1';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'repl';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'maintenance load1';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'repl';
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'response load1';
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';
    
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'encoding load2';
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'repl';
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'maintenance load2';
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 1 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'repl';
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'response load2';
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0 1 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'repl';
    
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'encoding load3';
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 0 1 0 0];
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'repl';
    matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'maintenance load3';
    matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 0 0 0 1 0];
    matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'repl';
    matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'response load3';
    matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 0 0 0 0 1];
    matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'repl';

    matlabbatch{1}.spm.stats.con.consess{10}.tcon.name = 'encoding load3-1';
    matlabbatch{1}.spm.stats.con.consess{10}.tcon.weights = [-1 0 0 0 0 0 1 0 0];
    matlabbatch{1}.spm.stats.con.consess{10}.tcon.sessrep = 'repl';
    matlabbatch{1}.spm.stats.con.consess{11}.tcon.name = 'maintenance load3-1';
    matlabbatch{1}.spm.stats.con.consess{11}.tcon.weights = [0 -1 0 0 0 0 0 1 0];
    matlabbatch{1}.spm.stats.con.consess{11}.tcon.sessrep = 'repl';
    matlabbatch{1}.spm.stats.con.consess{12}.tcon.name = 'response load3-1';
    matlabbatch{1}.spm.stats.con.consess{12}.tcon.weights = [0 0 -1 0 0 0 0 0 1];
    matlabbatch{1}.spm.stats.con.consess{12}.tcon.sessrep = 'repl';

    %this deletes old contrasts
    matlabbatch{1}.spm.stats.con.delete = 1;

    spm_jobman('initcfg')
    spm_jobman('run', matlabbatch)
    
end


