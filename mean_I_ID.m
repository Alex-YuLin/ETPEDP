%{
    目的:
        計算充電曲線 A+bexp(ct) 其中 A&B 參數
    輸入:
        Data: [ 時間 電流 ]
        StartTime: 初始取樣延遲時間
        SamplePeriod: 取樣間隔時間   
        minPeriod: ADC曲樣時間
        Tensuu: 取樣平均 取樣數
        RealValue:  未使用
    輸出:
        Error:  未使用(舊程式 有需要修改再修改)
        SampleValue:   取樣得到 [時間 電流]
        A1: 程式參數 B1: 程式參數 C: 程式參數  kk: 程式參數
%}
function[Error,SampleValue,A1,B1,C,kk]=mean_I_ID(Data, StartTime, SamplePeriod, minPeriod, Tensuu, RealValue)
    %PSPICE模擬出的總點數
    DataLength=size(Data);
    %取樣開始時間
    SampleTime=StartTime;
    %取樣點數
    DotNumber=Tensuu;

    
    index=1;
    for i=0:DotNumber/3
        for j=0:DotNumber/3-1
            SPdot(index)=StartTime+i*SamplePeriod/2+j*minPeriod;
            index=index+1;
        end
    end

    %找到取樣的點數在矩陣中的編號
    for i=1:DotNumber
        for j=1:DataLength(1)
            if Data(j,1)>=SPdot(i)
                t(i)=Data(j,1);
                I(i)=Data(j,2);
                
                
                break
            end
        end
    end
    
    
    SampleValue=[t(:),I(:)];
    
    
    t1=mean(t(1:DotNumber/3));
    t2=mean(t(DotNumber/3+1:2*DotNumber/3));
    t3=mean(t(2*DotNumber/3+1:3*DotNumber/3));
    I1=mean(I(1:DotNumber/3));
    I2=mean(I(DotNumber/3+1:2*DotNumber/3));
    I3=mean(I(2*DotNumber/3+1:3*DotNumber/3));
    
    kk=K_keisan([t1 t2 t3],[I1 I2 I3]);
    C=real(C_keisan([t1 t2 t3],[I1 I2 I3],SamplePeriod/2));
    
    
    
    %透過取樣點的編號找到相對應的電流值存進矩陣
    for i=1:Tensuu
        Y(i,1)=I(i);
        A(i,1)=1;
        A(i,2)=exp(C*t(i));
    end
   
    
%     
%     Y=[I1;I2;I3];
%     
%     A(1,1)=1;
%     A(1,2)=exp(C*t1);
%     A(2,1)=1;
%     A(2,2)=exp(C*t2);
%     A(3,1)=1;
%     A(3,2)=exp(C*t3);
  
    

    %最小方差法
    if C==0
        A1=I(1);
        B1=0;
    else
    hh=inv(A'*A)*A'*Y;
    ID_result=real(hh);
%
    A1=hh(1);
    B1=hh(2);
    end

%     keisan=A1+B1*exp(C*0.001);
    keisan=A1+B1;
    rironn=RealValue;
    Error=(keisan-rironn)/rironn*100;

end