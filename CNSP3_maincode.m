function CNSP3_maincode(parts,gauss)
load('CN_Project3_2016.mat');
time_stim=linspace(0,20,20000);
if(parts==1 || parts==4 || parts==5 || parts==6)
    ACF=zeros(1,101);
    for T=0:100
        sum=0;
        for n=max(1,1-T):min(20000,20000-T)
            sum=sum+(Stimulus(n))*(Stimulus(n+T));
        end
        ACF(1+T) = sum/(20000-abs(T));
        
    end
    
    figure
    plot(-50:50,ACF);
    peak=max(ACF);
    sigmasq=var(Stimulus);
    error=abs((peak-sigmasq)/sigmasq)*100;
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
if(parts==3 )
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

if(parts==4 || parts==5 || parts==6)
    Stm=Stimulus(1:15000);
    sta=zeros(4,101);
    figure
    mean_rate=zeros(1,4);
    for j=1:4
        [sta(j,:),mean_rate(j)]=STA_calc(Stm,All_Spike_Times,15,j);
        subplot(2,2,j)
        plot(0:100,sta(j,:));
        axis([0,100,-0.2,0.2]);
    end
    
    ACFg=zeros(1,101);
    ACFg(1,1)=var(Stm);
    H=zeros(4,101);
    figure
    if(gauss==0)
        CF=ACF;
    end
    if (gauss==1)
        CF=ACFg;
    end
    for i=1:4
        H(i,:)=Linear_filter(sta(i,:),CF,mean_rate(i));
        subplot(2,2,i)
        plot(1:101,H(i,:));
        %axis([0,101,-3,3]);
    end
    
end

MSR=zeros(4,100);
for j=1:4
    MSR(j,:)=MSR_calc(0,15,100,All_Spike_Times,j);
end


if(parts==5)
    rate_est_avg=zeros(4,100);
    for j=1:4
        rate_est_avg(j,:)=Yoft_calc(Stm,H(j,:),15000,100);
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
    figure
    for j=2:3
        rate_est_avg20(j-1,:)=Yoft_calc(Stm_20,H(j,:),5000,50);
        L=rate_est_avg20(j-1,:);
        G=sig_para(j-1,:);
        sigplot20=G(1)./(1+exp(G(2).*(G(3)-L)));
        pred_rate(j-1,:)=sigplot20;
        subplot(2,1,j-1);
        plot(linspace(15.1,20,50),sigplot20);
        MSR20(j-1,:)=MSR_calc(15,20,50,All_Spike_Times,j);
        hold on
        plot(linspace(15.1,20,50),MSR20(j-1,:) ,'r');
        hold off
        corrcoef(MSR20(j-1,:),sigplot20)
    end
end
if(parts==6)
    for j=2:3
        h=H(j,:);
        [sort_ind, sort_ind]=sort(abs(h));
        MSE=zeros(1,101);
        MSRl5=MSR_calc(15,20,50,All_Spike_Times,j);
        for k=1:101
            h(sort_ind(k))=0;
            y=Yoft_calc(Stimulus(1:15000),h,15000,100);
            G0=[9 3 2];
            [G,resnorm]=lsqcurvefit(@fsigmoid,G0,y,MSR(j,:));
            yl5=Yoft_calc(Stimulus(15001:20000),h,5000,50);
            pred_rate_l5=G(1)./(1+exp(G(2).*(G(3)-yl5)));
            R=corrcoef(pred_rate_l5,MSRl5);
            MSE(k)=(R(1,2)^2);
        end
        figure
        plot(MSE)
        [val, Ind]=max(MSE);
        if(gauss==0)
            [val, Ind]=max(MSE(1:10));
        end
        val
        Ind
        h=H(j,:);
        for k=1:Ind
            h(sort_ind(k))=0;
        end
        figure
        plot(h);
        yl5=Yoft_calc(Stimulus(15001:20000),h,5000,50);
        pred_rate_l5=G(1)./(1+exp(G(2).*(G(3)-yl5)));
        figure
        plot(linspace(15.1,20,50),pred_rate_l5);
        hold on
        plot(linspace(15.1,20,50),MSRl5);
        hold off
    end
end



if(parts==7)
    q=[0 0.001 0.01 0.1 1 10 100];
    MI=zeros(4,50,7);
    for k=1:4    %neuron number
        
        for l=1:50
            [Stim8x100,response]=Rand_stim_resp_gen();
            for cnt=1:7
                MI(k,l,cnt)=MI_calc(q(cnt),k,response);
            end
        end
        mean_MI=mean(MI(k,:,2:7));
        std=sqrt(var(MI(k,:,2:7)));
        x=[-3 -2 -1 0 1 2];
        figure
        errorbar(x,mean_MI,std);
    end
end
end
function [Stim8x100,response]=Rand_stim_resp_gen()
load('CN_Project3_2016.mat');
rand_stim=randperm(199,8);
rand_stim=sort(rand_stim);
Stim_start=rand_stim.*100;
%Stim_start=[1001,3001,5001,7001,9001,11001,13001,15001];
Stim8x100=zeros(8,100);
for i=1:8
    Stim8x100(i,:)=Stimulus(Stim_start(i):(Stim_start(i)+99));
end
response=cell(4,8,50);
for k=1:4
    for j=1:50
        for i=1:8
            v=All_Spike_Times{k,j};
            a=v>(Stim_start(i)/1000);
            b=v<(Stim_start(i)/1000 +0.1);
            v=a&b;
            response{k,i,j}=All_Spike_Times{k,j}(v);
        end
    end
end
end
function MI=MI_calc(q,k,response)
confusionmat=zeros(8,8); %8 row 8 col
edge=[1  51   101   151   201   251   301   351   400];


for row=1:8
    for res=1:50
        r_cur=response{k,row,res};
        distance=zeros(8,50);
        for i=1:8
            for j=1:50
                distance(i,j)=VP_dist(r_cur,response{k,i,j},q);
                distance(row,res)=50;
            end
        end
        distance=distance';
        Min_idx=find(distance==min(distance(:)));
        min_dist=histcounts(Min_idx',edge);
        min_dist_prob=min_dist/sum(min_dist)/50;
        confusionmat(row,:)=confusionmat(row,:)+min_dist_prob;
    end
end
norm_confmat=confusionmat./8;
sum_row=sum(norm_confmat,2);
sum_col=sum(norm_confmat);
MI=0;
for x=1:8
    for y=1:8
        MI=MI+norm_confmat(x,y)*log2(norm_confmat(x,y)/sum_row(y)/sum_col(x));
    end
end
end
function d=VP_dist(tli,tlj,cost)
nspi=length(tli);
nspj=length(tlj);

if cost==0
    d=abs(nspi-nspj);
    return
elseif cost==Inf
    d=nspi+nspj;
    return
end

scr=zeros(nspi+1,nspj+1);
scr(:,1)=(0:nspi)';
scr(1,:)=(0:nspj);
if nspi & nspj
    for i=2:nspi+1
        for j=2:nspj+1
            scr(i,j)=min([scr(i-1,j)+1 scr(i,j-1)+1 scr(i-1,j-1)+cost*abs(tli(i-1)-tlj(j-1))]);
        end
    end
end
d=scr(nspi+1,nspj+1);
end
function rate_est_avg=Yoft_calc(Stm,H,conv_size,est_len)
rate_est_avg=zeros(1,est_len);
convol=conv(H,Stm);
rate_est=convol(1,1:conv_size);
w=conv_size/est_len;
for i=1:est_len
    
    rate_est_avg(i)=mean(rate_est((i-1)*w+1:(i)*w));
end
end
function [sum,mean_rate]=STA_calc(Stm,spike_times,sec_to_use,j)
sum=zeros(1,101);
spike_count=0;
for i=1:50
    v=spike_times{j,i}<sec_to_use;
    v=spike_times{j,i}(v);
    d=size(v);
    spike_count=spike_count+d(2);
    for T=0:100
        for l=1:d(2)
            sum(T+1)=sum(T+1)+(Stm(round((v(l)*1000-T+1000*(v(l)*1000<T+1)))))*(v(l)*1000>T+1)/d(2);
        end
        
    end
    
end
mean_rate=spike_count/750;
sum=sum./50;
end
function H_t=Linear_filter(sta,ACF,mean_rate)
Qss=toeplitz(ACF);
H_t=transpose(inv(Qss)*transpose(sta)*mean_rate);
end
function N=MSR_calc(tstart,tend,div,spike_times,j)
edges1=linspace(tstart,tend,div+1);

N=zeros(1,div);
for i=1:50
    N=N+histcounts(spike_times{j,i},edges1);
end
N=N./50/((tend-tstart)/div);

end
function F=fsigmoid(G,L)
F=G(1)./(1+exp(G(2)*(G(3) - L)));
end