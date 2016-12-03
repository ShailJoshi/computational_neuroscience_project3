function CNSP3_maincode(parts)
load('CN_Project3_2016.mat');
time_stim=linspace(0,20,20000);
if(parts==1 || parts==4 || parts==5)
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
if(parts==2)
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
    ACFg=zeros(1,101);
    ACFg(1,1)=var(Stm);
    Qss=toeplitz(ACFg);
    figure
    surf(eye(101)/Qss)
    
    size(Qss)
    figure
    H=zeros(4,101);
    for i=1:4
        H(i,:)=transpose(inv(Qss)*transpose(sta(i,:))*mean_rate(i));
        subplot(2,2,i)
        plot(1:101,H(i,:));
        %axis([0,101,-3,3]);
    end
    
end

 
if(parts==5)
    MSR=zeros(4,100);
    edges1=linspace(0,15,101);
    for j=1:4
        N=zeros(1,100);
        for i=1:50
            N=N+histcounts(All_Spike_Times{j,i},edges1);
        end
        MSR(j,:)=N./50/0.15;
    end
    rate_est_avg=zeros(4,100);
    for j=1:4
        
        convol=conv(H(j,:),Stm);
        rate_est=convol(1,1:15000);
        for i=1:100
            
            rate_est_avg(j,i)=mean(rate_est((i-1)*150+1:(i)*150));
        end 
        subplot(2,2,j)
        plot(rate_est_avg(j,:),MSR(j,:),'o')
    end
    figure
    xsig=linspace(-8,8,100);
    sig_para=zeros(2,3);
    for j=2:3
    G0=[9 3 2];
    L=rate_est_avg(j,:);
    [G,resnorm]=lsqcurvefit(@fsigmoid,G0,L,MSR(j,:));
    sig_para(j-1,:)=transpose(G);
    sigplot=G(1)./(1+exp(G(2).*(G(3)-xsig)));
    subplot(1,2,j-1)
     plot(L,MSR(j,:),'o')
     hold on
     plot(xsig,sigplot);
     hold off
    end
    
    %prediction
    Stm_20=Stimulus(15001:20000);
    rate_est_avg20=zeros(2,50);
    pred_rate=zeros(2,50);
      MSR20=zeros(2,50);
    edges20=linspace(15,20,51);
    figure
    for j=2:3
        convol=conv(H(j,:),Stm_20);
        rate_est20=convol(1,1:5000);
        for i=1:50
            rate_est_avg20(j-1,i)=mean(rate_est20((i-1)*100+1:(i)*100));
        end 
    L=rate_est_avg20(j-1,:);
    G=sig_para(j-1,:);
    sigplot20=G(1)./(1+exp(G(2).*(G(3)-L)));
    pred_rate(j-1,:)=sigplot20;
    subplot(2,1,j-1);
    plot(linspace(15.1,20,50),sigplot20);
    
        N=zeros(1,50);
        for i=1:50
            N=N+histcounts(All_Spike_Times{j,i},edges20);
        end
        MSR20(j-1,:)=N./50/0.1;
   
    
    hold on
    plot(linspace(15.1,20,50),MSR20(j-1,:) ,'r');
    hold off
    end
    MSE=zeros(1,2);
    for j=1:2
    for i=1:50
        MSE(j)=MSE(j)+((MSR20(j,i)-pred_rate(j,i))^2)/50;
    end
    end
    disp(MSE);
    
end
end
function F=fsigmoid(G,L) 
        F=G(1)./(1+exp(G(2)*(G(3) - L)));
        end