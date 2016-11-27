function CNSP3_maincode
load('CN_Project3_2016.mat');
%time_stim=linspace(0.001,20,20000);
ACF=zeros(1,101);
for T=-50:50
    sum=0;
    for n=max(1,1-T):min(20000,20000-T)
        sum=sum+(Stimulus(n))*(Stimulus(n+T));
    end
    ACF(51+T) = sum/(20000-abs(T));
    
end
plot(-50:50,ACF);
peak=max(ACF);
sigmasq=var(Stimulus);
error=abs((peak-sigmasq)/sigmasq)*100


%PSTH





end