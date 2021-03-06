
function MI=temp1()
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