% This script extract the ROI data from relevant contrasts from the VSTM and
%determines which subjects and ROIs can be included in the analyses. 

clc; clear

% add SPM and the BCT toolbox to the path
addpath(genpath('/Volumes/STD-Donders-DCC-Geerligs/Cambridge_data/Toolboxes/SPM12/'))
addpath('/Volumes/STD-Donders-DCC-Geerligs/Cambridge_data/Toolboxes/2015_01_25 BCT/')

%directory where the results will be saved
savedir = '/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/Extracted_data/';
%load the behavioral data from all subjects
subdata= load([savedir 'subject_info.mat']);
%define the directory that contains the contrasts
condir =  '/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/aamod_firstlevel_contrasts_00001/';

%file for brain parcellation
roifile='/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/Craddock_ROIs_JNpaper_reordered.nii';

%number of files
numsub=length(subdata.CBUID);
numROI=748;

%Select a threshold to select a ROI associated with
thresholdT=1.96;

%contrasts to include
consin=[1:12];

%The contrast that will be used for the thresholding: maintenance 3-1
selcon=11;

%% extracting ROI data for all contrasts 
conmatrix=zeros(numsub,length(consin),numROI);
Tmatrix=zeros(numsub,numROI);
nvox=zeros(numsub,numROI);

parfor i=1:numsub
    disp(i)
    SR={};
    %get the contrast-values
    SR.no_svd = 1;SR.zero_rel_tol = 0.99;SR.zero_abs_tol = 1;SR.output_raw=1;
    SR.mask_space=0;
    for j=consin
        if j<10
            SR.Datafiles{1}{j}=[condir 'CBU' num2str(subdata.CBUID(i)) '/stats/con_000'  num2str(j) '.nii'];
        else
            SR.Datafiles{1}{j}=[condir 'CBU' num2str(subdata.CBUID(i)) '/stats/con_00'  num2str(j) '.nii'];
        end
    end
    SR.ROIfiles={roifile};
    ROI = roi_extract(SR);
    for r=1:numROI
        conmatrix(i,:,r)=nanmean(ROI(r).rawdata,2);
        nvox(i,r)=sum(~isnan(ROI(r).rawdata(1,:)));
    end

    %get the t-statistics
    SR={};
    %get the contrast-values
    SR.no_svd = 1;SR.zero_rel_tol = 0.99;SR.zero_abs_tol = 1;SR.output_raw=1;
    SR.mask_space=0;
    if selcon<10
        SR.Datafiles{1}{1}=[condir 'CBU' num2str(subdata.CBUID(i)) '/stats/spmT_000'  num2str(selcon) '.nii'];
    else
        SR.Datafiles{1}{1}=[condir 'CBU' num2str(subdata.CBUID(i)) '/stats/spmT_00'  num2str(selcon) '.nii'];
    end

    SR.ROIfiles={roifile};
    ROI = roi_extract(SR);
    Tmatrix(i,:)=[ROI(:).mean]; 
end
save([savedir 'data_con.mat'], 'conmatrix', 'Tmatrix', 'nvox')

% contrast 10 = encoding, contrast 12 = maintenance

%% Select ROIs to include
 
%subject 26 excluded due to poor data quality, the others excluded due to mean absolute devation of >30 degrees at load 1
exsub = [26; find(isnan(subdata.mem_score(:,1)))];
insub = setdiff(1:numsub, exsub);

%Base the thresholding on the contrast between load 3 and 1, do this
%seperate for negative and positive ROIs to keep it comparable to the
%initial analyses
ThresholdMatrix=Tmatrix;
ThresholdMatrix(ThresholdMatrix<thresholdT)=0;
ThresholdMatrix(ThresholdMatrix>=thresholdT)=1;

NThresholdMatrix=Tmatrix;
NThresholdMatrix(NThresholdMatrix>-thresholdT)=0;
NThresholdMatrix(NThresholdMatrix<=-thresholdT)=1;

%ROIs to include have at least 10 voxels that are covered and at least 10% of participants that show an above threshold response, we do this separate for ROIs with a positive or negative response
ROI2include_pos = intersect(find(sum(nvox(insub,:)>9,1)==length(insub)), find(mean(ThresholdMatrix(insub,:),1)>0.1));
ROI2include_neg = intersect(find(sum(nvox(insub,:)>9,1)==length(insub)), find(mean(NThresholdMatrix(insub,:),1)>0.1));
ROI2include = [ROI2include_pos ROI2include_neg];

%these ROIs did not show sufficient coverage
ROI2exclude_coverage = find(sum(nvox(insub,:)<10,1)>0);

%now get the values for these included subjects and included ROIs for
%the contrast of interest
cmatrix = squeeze(conmatrix(insub,selcon,ROI2include)); 
conmatrix=conmatrix(insub,:,ROI2include);
Tmatrix=Tmatrix(insub,ROI2include);
nvox=nvox(insub,ROI2include);

save([savedir 'extracted_data.mat'], 'exsub','insub', 'cmatrix', 'ROI2include', 'ROI2exclude_coverage', 'conmatrix', 'Tmatrix', 'nvox')

