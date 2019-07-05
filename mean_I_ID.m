%{
    �ت�:
        �p��R�q���u A+bexp(ct) �䤤 A&B �Ѽ�
    ��J:
        Data: [ �ɶ� �q�y ]
        StartTime: ��l���˩���ɶ�
        SamplePeriod: ���˶��j�ɶ�   
        minPeriod: ADC���ˮɶ�
        Tensuu: ���˥��� ���˼�
        RealValue:  ���ϥ�
    ��X:
        Error:  ���ϥ�(�µ{�� ���ݭn�ק�A�ק�)
        SampleValue:   ���˱o�� [�ɶ� �q�y]
        A1: �{���Ѽ� B1: �{���Ѽ� C: �{���Ѽ�  kk: �{���Ѽ�
%}
function[Error,SampleValue,A1,B1,C,kk]=mean_I_ID(Data, StartTime, SamplePeriod, minPeriod, Tensuu, RealValue)
    %PSPICE�����X���`�I��
    DataLength=size(Data);
    %���˶}�l�ɶ�
    SampleTime=StartTime;
    %�����I��
    DotNumber=Tensuu;

    
    index=1;
    for i=0:DotNumber/3
        for j=0:DotNumber/3-1
            SPdot(index)=StartTime+i*SamplePeriod/2+j*minPeriod;
            index=index+1;
        end
    end

    %�����˪��I�Ʀb�x�}�����s��
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
    
    
    
    %�z�L�����I���s�����۹������q�y�Ȧs�i�x�}
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
  
    

    %�̤p��t�k
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