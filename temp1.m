
function CNSP3_maincode
load('CN_Project3_2016.mat');

time_stim=linspace(0.001,20,2000);

MSR=zeros(4,2000);
edges1=linspace(0,20,2001);
for j=1:4
    N=zeros(1,2000);
        for i=1:50
            N=N+histcounts(All_Spike_Times{j,i},edges1);
        end
        MSR(j,:)=N./50;
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



Stm=Stimulus(1:15000);
sta=zeros(4,101);
stac=zeros(4,101);

Qss = autocorr(Stm,100);
for j=1:4
    sum=zeros(1,101);
    for i=1:50
         v=All_Spike_Times{j,i}<15;
         v=All_Spike_Times{j,i}(v);
         d=size(v);         
        for T=0:100
            for l=1:d(2)
                sum(T+1)=sum(T+1)+(Stm(round((v(l)*1000-T+1000*(v(l)*1000<T+1)))))*(v(l)*1000>T+1)/d(2);
            end
        end
    end
    sta(j,:)=sum./50;
    figure(1)
    subplot(2,2,j)
    plot(0:100,sum./50);
    axis([0,100,-0.2,0.2]);
    
   
    stac(j,:)=sta(j,:)./Qss;
    figure(2)
    subplot(2,2,j)
    plot(0:100,stac(j,:));
    
end
convol=conv(stac(3,:),Stm);
rate_est=convol(1,101:15100);
figure
plot(1:15000,rate_est);
rate_est_avg=zeros(1,1500);
for i=1:1500
    
        rate_est_avg(i)=mean(rate_est((i-1)*10+1:(i)*10));
end


size(rate_est_avg)
figure
plot(rate_est_avg,MSR(3,1:1500)*1000,'o')

end