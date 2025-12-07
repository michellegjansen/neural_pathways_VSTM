%This script identifies the modules based on modularity maximization and
%then computes the average brain activity per module. 

clc; clear

% add SPM and the BCT toolbox to the path
addpath(genpath('/Volumes/Wrkgrp/STD-Donders-DCC-Geerligs/Cambridge_data/Toolboxes/SPM12/'))
addpath('/Volumes/STD-Donders-DCC-Geerligs/Cambridge_data/Toolboxes/2015_01_25 BCT/')
addpath('/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/Code')
addpath('/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/Extracted_data/')

basedir = '/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/';
savedir = '/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/Extracted_data/';
plotdir = '/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/Figures/';

%load the behavioral data 
subdata= load([savedir 'subject_info.mat']);

%file for brain parcellation
roifile='/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/Craddock_ROIs_JNpaper_reordered.nii';

load([savedir 'extracted_data.mat'], 'exsub','insub', 'cmatrix', 'ROI2include', 'ROI2exclude_coverage', 'conmatrix', 'Tmatrix', 'nvox')

%compare to old networks
load('/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/networks.mat', 'networks')
old_networks=networks(ROI2include);


%% finding modules/partitions of brain regions (MODULARITY MAXIMIZATION)
% uses this toolbox:https://sites.google.com/site/bctnet/ 
%this is the correlation matrix that we will use to identify the modules
cmat=corrcoef(cmatrix);
%read the ROI file so we can plot things back on the brain
roidata = spm_read_vols(spm_vol(roifile));

%for 500 repetitions, estimate the functional networks 
gamma=1:0.05:1.5; %Resolution elements (range for the size of communities)
%rep=500;
rep=10 %to test

%initialization of result matrices, we keep the modules assignment for each
%gamma, as well as a measure of robustness and the similarity to aprior
%networks
fin_partition=zeros(length(gamma),length(cmat)); 
final_sim = zeros(length(gamma),1);
simold = zeros(length(gamma),1);

for n=1:length(gamma)
    g=gamma(n); %here we are trying different resolution elements
    
    %initialization of the variables for the intermediate solutions
    partition=zeros(length(cmat),rep);
    ran_partition=zeros(length(cmat),rep);
    
    parfor r=1:rep %The partition is performed 100 times for each resolution element 
        [M05,Q05]=community_louvain(cmat,g,[],'negative_asym');
        partition(:,r)=M05;
        ran_partition(:,r)=M05(randperm(length(M05)));
    end
    
    %How similar are the commnunity affiliation vectors to each other across repetitions (robustness)
    sim=zeros(rep);
    parfor i = 1:rep
        for j=1:rep
            sim(i,j)=AMI(partition(:,i), partition(:,j));
        end
    end
     
    final_sim(n)=mean(sim(:));
    
    %compute the agreement matrix over all repetitions of the partitioning
    D=agreement(partition)./rep;%average the values of all the agreement matrices
    
    % the threshold that is used for the agreement matrix is based on permuted labels
    DR=agreement(ran_partition)./rep; %ran_partition= permuted version
    
    %find a consensus partitioning
    mod = consensus_und(D,mean(DR(:)),rep, g); %Thresholding the agreement matrix (get rid of the smallest values, setting them to 0)
    
    simold(n)=AMI(old_networks(old_networks>0), mod(old_networks>0));  

    %Build a new agreement matrix until it gets to a partion that is stable     
    fin_partition(n,:)=mod; %(mod output similar(interpretation) as the M0 output)
    
    %%plot networks on the brain
    network_img = zeros(size(roidata));
    plotvals=zeros(max(roidata(:)),1);
    plotvals([ROI2include ROI2include_neg])=mod;
    for i=1:max(roidata(:))
        %network_img(roidata==i)=plotvals(i);
    end
    hdr = spm_vol(roifile);
    hdr.fname = [plotdir 'networksg' num2str(g) '_posneg.nii'];
    spm_write_vol(hdr, network_img)  
end


%% 
% Select the partition that is most similar to the apriori networks, remove
% the small networks (<15 nodes) and plot the result on the brain

[val,optimum]=max(simold);

all_community=fin_partition(optimum,:);
big_community_15=all_community;
count15=0;
for i=unique(all_community)
    nummod(i)=sum(all_community==i);
    if nummod(i)<15
        big_community_15(all_community==i)=0;
    else
        count15=count15+1;
        big_community_15(all_community==i)=count15;
    end
end

%this is the final modules assignment that will be used in the paper
final_community=big_community_15;

num_excluded_rois = sum(final_community ==0);

%save the image of the selected partition
network_img = zeros(size(roidata));
plotvals=zeros(max(roidata(:)),1);
plotvals(ROI2include)=final_community;
for i=1:max(roidata(:))
    network_img(roidata==i)=plotvals(i);
end
hdr = spm_vol(roifile);
hdr.fname = [plotdir 'networks_bigmod15_g125.nii'];
spm_write_vol(hdr, network_img)

%% Compute the average brain activity per module

meanROIs=mean(cmatrix,2);

%average per network
subjAverage_network=zeros(length(insub),max(final_community));
%average per network after regressing out the mean across all ROIs
res_subjAverage_network=zeros(length(insub),max(final_community));
for nNetworks=1:max(final_community)
    subjAverage_network(:,nNetworks)=mean((cmatrix(:,find(final_community==nNetworks))),2); 
    [B,BINT,R] = regress(subjAverage_network(:,nNetworks),[ones(size(meanROIs)) meanROIs]);
    res_subjAverage_network(:,nNetworks)=R+mean(subjAverage_network(:,nNetworks));
end

save([savedir 'module_data.mat'], 'final_community','insub', 'fin_partition', 'gamma', 'final_sim', 'subjAverage_network', 'res_subjAverage_network', 'meanROIs')

%% Correlations between brain networks

max(max(corr(subjAverage_network).*triu(ones(7),1)))
min(min(corr(subjAverage_network)))

%% Compare to apriori networks
% compare the full assignments and compare 
% each module to the functional networks identified in previous paper

final_community=fin_partition((find(gamma==1.2)),:);
load([basedir 'networks.mat'])
old_networks=networks(ROI2include);
AMI(old_networks(old_networks>0), final_community(old_networks>0))

for i=1:7
    for j=1:16
        overlap(i,j)=sum((old_networks==j).*(final_community==i)')./sum(final_community==i);
    end
end


%% plot the correlation matrix
cmat=corr(cmatrix);
[mod,order]=sort(final_community);
boundaries=[0 find(diff(mod)>0)+0.5 length(cmatrix)];

plot_imagesc_boundaries([plotdir 'cmat_ordered.pdf'], cmat(order,order), boundaries, [-1 1])


figure; scatter(cmatrix(:,order(1)), cmatrix(:,order(50))); lsline;
set(gca, 'Xtick', -0.5:0.5:1, 'Ytick', -0.5:0.5:1.5)
xlabel('Brain activity region x')
ylabel('Brain activity region y')
print(gcf, '-dpdf', [plotdir 'scatter_modules.pdf'])

