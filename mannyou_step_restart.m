% 萬用生成脈波程式 %
% 軟體瘦身版---適用PSpice模擬 %
%{
    多組脈衝生成
%}

clear;
clc;
%close all;

%步階的總時間長度
length=1;
%步階的開始時間點
start=1.0;
%步階的結束時間點
over=3.5;
%步階的大小

%  amplitude=-5;
 amplitude=-4;
%時間解析度
resolution=0.0005;
%時間常數  tau_C / tau_V = 500
time_constant=0.1674/500;
% time_constant=0.001;

% tau_2=0.3134;


% time_constant=0.000001;
%高解析度區域大小
high_res=time_constant*50;

% 脈衝時間
starttime=0.2;
charge=80e-3;
discharge=40e-3;
ScanPulze=[-5 -2 0.3];


t=0:resolution:length;
a=size(t);
flag=0;

x=1;

Y(x,1)=0;
Y(x,2)=0;
x=x+1;
start=starttime; over=starttime+charge;amplitude=ScanPulze(1);
Y(x,1)=start;
Y(x,2)=0;
x=x+1;
for i=1:a(2)
    if t(i)>start && t(i)<=start+high_res
        Y(x,1)=t(i);
        Y(x,2)=amplitude*(1-exp(-(t(i)-start)/time_constant));
        x=x+1;
    end
end
Y(x,1)=over;
Y(x,2)=amplitude;
x=x+1;
for i=1:a(2)
    if t(i)>over && t(i)<=over+high_res
        Y(x,1)=t(i);
        Y(x,2)=amplitude*(exp(-(t(i)-over)/time_constant));
        x=x+1;
    end
end

start=starttime+charge+discharge; over=starttime+charge*2+discharge;amplitude=ScanPulze(2);
Y(x,1)=start;
Y(x,2)=0;
x=x+1;
for i=1:a(2)
    if t(i)>start && t(i)<=start+high_res
        Y(x,1)=t(i);
        Y(x,2)=amplitude*(1-exp(-(t(i)-start)/time_constant));
        x=x+1;
    end
end
Y(x,1)=over;
Y(x,2)=amplitude;
x=x+1;
for i=1:a(2)
    if t(i)>over && t(i)<=over+high_res
        Y(x,1)=t(i);
        Y(x,2)=amplitude*(exp(-(t(i)-over)/time_constant));
        x=x+1;
    end
end

start=starttime+charge*2+discharge*2; over=starttime+charge*3+discharge*2;amplitude=ScanPulze(3);
Y(x,1)=start;
Y(x,2)=0;
x=x+1;
for i=1:a(2)
    if t(i)>start && t(i)<=start+high_res
        Y(x,1)=t(i);
        Y(x,2)=amplitude*(1-exp(-(t(i)-start)/time_constant));
        x=x+1;
    end
end
Y(x,1)=over;
Y(x,2)=amplitude;
x=x+1;
for i=1:a(2)
    if t(i)>over && t(i)<=over+high_res
        Y(x,1)=t(i);
        Y(x,2)=amplitude*(exp(-(t(i)-over)/time_constant));
        x=x+1;
    end
end





if length~=over
    Y(x,1)=length;
    Y(x,2)=0;
end






% for i=1:a(2)
%     Y(i,1)=t(i);
%     if t(i)>start && t(i)<=over
%         Y(i,2)=amplitude*(1-exp(-(t(i)-start)/time_constant));
%     elseif t(i)>over
%         Y(i,2)=amplitude*(exp(-(t(i)-over)/time_constant));
%     else
%         Y(i,2)=0;
%     end
% end




plot(Y(:,1),Y(:,2))
 csvwrite('C:\Users\q8529\Documents\NCU_LAB\07_EDPETP_handover\ProDes\Matlab\tsource2.csv',Y)
