function CNSP3_maincode
load('CN_Project3_2016.mat');
time_stim=linspace(0.001,20,20000);
time_shifted=linspace(-19.999,20,40000);
stim_shifted=[zeros(1,20000),Stimulus];
plot(time_stim,Stimulus);

all_spike_rounded=cell(4,50);
window=time_stim;
for j=1:4
        for i=1:50
            all_spike_rounded{j,i}=(round((All_Spike_Times{j,i}).*1000))./1000;
            d=size(All_Spike_Times(j,i));
            v=all_spike_rounded(j,i);
            for k=1:20000
                for l=1
               
                
            end
        end
    
    end

end