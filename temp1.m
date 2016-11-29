function CNSP3_maincode
load('CN_Project3_2016.mat');
Stm=Stimulus(1:15000);
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
    subplot(2,2,j)
    plot(0:100,sum./50);
    axis([0,100,-0.2,0.2]);
end
end
