function CNSP3_maincode
load('CN_Project3_2016.mat');
time_stim=linspace(0.001,20,20000);
ACF=zeros(1,101);
for T=-50:50
    sum=0;
    for n=max(1,1-T):min(20000,20000-T)
        sum=sum+(Stimulus(n))*(Stimulus(n+T));
    end
    ACF(51+T) = sum/(20000-abs(T));
    
end
plot(-50:50,ACF);
peak=max(ACF)
sigmasq=var(Stimulus);
error=abs((peak-sigmasq)/sigmasq)*100


%PSTH
MSR=zeros(4,20000);
edges1=linspace(0,20,20001);
for j=1:4
    N=zeros(1,20000);
        for i=1:50
            N=N+histcounts(All_Spike_Times{j,i},edges1);
        end
        MSR(j,:)=MSR(j,:)+N./50;
end

        figure
        subplot(2,2,1)
        plot(time_stim,MSR(1,:)*1000);
        title('Neuron 1');
        subplot(2,2,2)
        plot(time_stim,MSR(2,:)*1000);
        title('Neuron 2');
        subplot(2,2,3)
        plot(time_stim,MSR(3,:)*1000);
        title('Neuron 3');
        subplot(2,2,4)
        plot(time_stim,MSR(4,:)*1000);
        title('Neuron 4');
        
MSR_last5sec=MSR(:,15001:20000);

%FANO FACTOR
bin_size=[10 20 50 100 200 500];
figure
linearity=zeros(6,4);

for k=1:6
    for j=1:4
        N=zeros(50,20000/bin_size(k));
        vary=zeros(1,50);
        avg_spk=zeros(1,50);
         for i=1:50
             N(i,:)=histcounts(All_Spike_Times{j,i},linspace(0,20,1+(20000/bin_size(k)))); 
             vary(i)=var(N(i,:));
             avg_spk(i)=mean(N(i,:));
         end
        subplot(2,2,j)
        plot(vary,avg_spk,'o')
        d=polyfit(vary,avg_spk,2);
        linearity(k,j)=d(2)/d(1);
    end
    figure
end
linearity

end