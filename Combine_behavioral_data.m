%This script combines the behavioral data from the CamCAN project,
%retrieved from different files. 

cd('/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM')

basedir = '/Volumes/STD-Donders-DCC-Geerligs/'
savedir = '/Volumes/STD-Donders-DCC-Geerligs/Michelle/VSTM/Extracted_data/';

%table with age, session IDs, gender
T=readtable([basedir  'Cambridge_data/MRI_data/cc700-scored/participant_data.csv']);
%The additional data from the Home interview contains the spot-the-word test
Homeint_add=load([basedir  'Cambridge_data/MRI_data/cc700-scored/HomeInterview/compiled/homeint_dataset_additional.mat']);
%The main data from the home interview contains information about education
Homeint=load([basedir  'Cambridge_data/MRI_data/cc700-scored/HomeInterview/compiled/homeint_dataset_homeint.mat']);
%This query from the CamCAN behavioral data contains the Cattell IQ scores
load([basedir 'Cambridge_data/behavioral/query_data_19_5_2017.mat'], 'DAT');
%This folder contains the VSTM behavioral data
VSTM_dir=[basedir 'Cambridge_data/MRI_data/cc280-scored/VSTM_fMRI_D/release001/data/'];
%This folder contains the Benton faces behavioral data
Benton_dir=[basedir 'Cambridge_data/MRI_data/cc700-scored/BentonFaces/release001/data/'];

%go through the VSTM subject list in the order of the directory to
%identify the correct subject order and note the matching values
files=dir([basedir 'Michelle/VSTM/aamod_firstlevel_contrasts_00001/CBU*']);
for i=length(files):-1:1
    
    CBUID(i)=str2num(files(i).name(4:end));
    [ind,y]=find(strcmp(T{:,7:11},files(i).name));
    CCID(i)=str2num(T.Observations{ind}(3:end));
    age(i)=T.age(ind);
    gender(i)=T.gender_code(ind);
    
    if isempty(T.cbuid280_sess1{ind}) && isempty(T.cbuid280_sess2{ind})
        CBUID2(i)=NaN;
        session1or2(i)=NaN;
    elseif isempty(T.cbuid280_sess2{ind})
        CBUID2(i)=str2num(T.cbuid280_sess1{ind}(4:end));
        session1or2(i)=1;
    else
        CBUID2(i)=str2num(T.cbuid280_sess2{ind}(4:end));
        session1or2(i)=2;
    end
        
    ind2=find(strcmp(Homeint.res.CCID,T.Observations{ind}));
    edu(i)=max(str2num(Homeint.res.v73{ind2}));
    stw(i)=Homeint_add.res.STW_total(ind2);
    
    ind3=find(strcmp(T.Observations{ind},DAT.SubCCIDc));
    Cattell(i)=DAT.table.Cattell.TotalScore(ind3); 
    if DAT.table.Cattell.DataFlag(ind)~=0
        Cattell(i)=NaN;
    end
    
    VSTMfile = dir([VSTM_dir T.Observations{ind} '/VSTM*scored.txt']);
    VSTM = [VSTM_dir T.Observations{ind} '/' VSTMfile(1).name];
    try
        C=textread(VSTM, '%f','delimiter', '\n','headerlines',1);
        mem_score(i,:)=C([2 7 13]);
        precision_score(i,:)=C([1 6 12]);
        mse_score(i,:)=C([5 11 17]);
    catch
        C=textread(VSTM, '%s','delimiter', '\n','headerlines',1);
        if strcmp(C{1}(1:3), 'NaN')
            %if the file contains NaNs these are all people with mean absolute devation of >30 degrees at load 1
            %these are 8 subjects in total
            mem_score(i,:)=NaN;
            precision_score(i,:)=NaN;
            mse_score(i,:)=NaN;
        end
    end
    
    Benton = [Benton_dir 'BentonFaces_' T.Observations{ind} '_scored.txt'];
    [RA, dat1, dat2, nscores, nexpected, subscore1, subscore2, totalscore, qcfail]=textread(Benton, '%s %s %s %f %f %f %f %f %f','delimiter', '\t','headerlines',1);
    if qcfail==0
        benton(i)=totalscore;
    else
        benton(i)=NaN;
    end
    
end

save([savedir 'subject_info.mat'], 'age','mem_score', 'precision_score',....
    'CBUID','CCID', 'edu', 'stw', 'Cattell', 'session1or2', 'CBUID2', 'benton', 'gender', 'mse_score')



