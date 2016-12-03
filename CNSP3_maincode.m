function CNSP3_maincode(parts)
load('CN_Project3_2016.mat');
time_stim=linspace(0.001,20,20000);
if(parts==1 || parts==4)
    ACF=zeros(1,101);
    for T=0:100
        sum=0;
        for n=max(1,1-T):min(20000,20000-T)
            sum=sum+(Stimulus(n))*(Stimulus(n+T));
        end
        ACF(1+T) = sum/(20000-abs(T));
        
    end
    plot(-50:50,ACF);
    peak=max(ACF)
    sigmasq=var(Stimulus);
    error=abs((peak-sigmasq)/sigmasq)*100
end
if(parts==2 || parts==5)
    %PSTH
    MSR=zeros(4,20000);
    edges1=linspace(0,20,20001);
    for j=1:4
        N=zeros(1,20000);
        for i=1:50
            N=N+histcounts(All_Spike_Times{j,i},edges1);
        end
        MSR(j,:)=N./50;
    end
    
    figure
    subplot(2,2,1)
    plot(time_stim,MSR(1,:)*1000,'o');
    title('Neuron 1');
    subplot(2,2,2)
    plot(time_stim,MSR(2,:)*1000,'o');
    title('Neuron 2');
    subplot(2,2,3)
    plot(time_stim,MSR(3,:)*1000,'o');
    title('Neuron 3');
    subplot(2,2,4)
    plot(time_stim,MSR(4,:)*1000,'o');
    title('Neuron 4');
    
    MSR_last5sec=MSR(:,15001:20000);
end
if(parts==3)
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

if(parts==4 || parts==5)
    Stm=Stimulus(1:15000);
    sta=zeros(4,101);
    figure
    mean_rate=zeros(1,4);
    for j=1:4
        sum=zeros(1,101);
        spike_count=0;
        for i=1:50
            v=All_Spike_Times{j,i}<15;
            v=All_Spike_Times{j,i}(v);
            d=size(v);
            spike_count=spike_count+d(2);
            for T=0:100
                for l=1:d(2)
                    sum(T+1)=sum(T+1)+(Stm(round((v(l)*1000-T+1000*(v(l)*1000<T+1)))))*(v(l)*1000>T+1)/d(2);
                end
                
            end
            
        end
        mean_rate(j)=spike_count/750;
        sta(j,:)=sum./50;
        subplot(2,2,j)
        plot(0:100,sum./50);
        axis([0,100,-0.2,0.2]);
    end
    mean_rate
    ACFg=zeros(1,101);
    ACFg(1,1)=var(Stm);
    Qss=toeplitz(ACF);
    figure
    surf(eye(101)/Qss)
    
    size(Qss)
     figure
     for i=1:4
    H=inv(Qss)*transpose(sta(i,:))*mean_rate(i);
    subplot(2,2,i)
    plot(1:101,transpose(H));
    %axis([0,101,-3,3]);
     end
    
end

if(parts==5)
    convol=conv(sta(2,:),Stm);
    rate_est=convol(1,101:15100);
    figure
    plot(1:15000,rate_est);
    size(rate_est)
    figure
    plot(rate_est,MSR(2,1:15000)*1000,'o')
end

end