% ���m���uID %
%{
    �ت�: �q����q���u �^���I �å�__�k�D�XAB �^�k���u 
    ��J: 
        Data: ���� IT �ƾ�
        StartTime:  �^���I�_�l����
        Td:  �^���I�ɶ�(x��tau_v) Td
        Ts:  ASA_ADC�^���W�v
        times: �^���I��
        Tp: �^���I�ɶ�(x��tau_c) Tp
        Density: �q�l�@�� (���ϥ�)
        Tensuu: ����(���ϥ�)
        pn: ��J�q��
        noice:���T��
        LoadTable:�d��(Load -5.0V ~ 1.0V stap��0.00001 )
        noice_circuit:�R�q í�w��(�[���T��)
    ��X:
        dot: �ɶ��B�q���B�q�y
        A1: Y=A*exp(Bt) ���� A
        B1: Y=A*exp(Bt) ���� B
%}
% ���m���uID %
function[AB_value,AA,BB]=Ideal_idou_ID_HiDen(Data ,StartTime ,Td_ori ,Ts ,times, Tp, Density, Tensuu, pn, noice, LoadTable, noice_circuit, para)
    %{
        Tp -> �U�����^���I = StartTime+Td + n * Tp
    %}
    Ar = 6;
    Beta1= 0;
    Beta2= 0;
    %�̨��ϰ�ƶq
    n=2;
    % Load -5.0V ~ 1.0V stap��0.00001 
    % �]���n�ϥγ�� I-T �� so����input Guesss.IV data
    % load(LoadTable);
    Guess.IV=LoadTable;
    % �[�J���T�A���T�j�p�O�γ̤j�q�y��%�ƨM�w
        gosa=noice;
        Ireal_seco=noice_circuit;
        Length = length(Data(:,2));
        Data(:,2) = Data(:,2)+ rand(Length,1) * Ireal_seco * gosa/100-Ireal_seco*gosa/100/2;
        
        %�p��ӷſ@�U�� Td �ɶ� �V�L�DID���u
        [Td,~]=find_Td(Data, StartTime, Ts, Td_ori, LoadTable, noice, noice_circuit, pn);
       
        
        
    if pn>=0
        % �_�l�ɶ��q�y%
        [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),StartTime+Td);
        %�ιq�y�bIV���u�W�������q��% -> �̰��q�� 
%         [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
        % OML���� ��G���G��
           dot1(3) = binaryApproch(pn, dot1(2), para(1), para(2), Ar, Beta1, Beta2);
        %
        dot(1,1)=dot1(1);
        dot(1,2)=dot1(2);
        dot(1,3)=dot1(3); 
        
        tamp=1;
        for i=1:n
            if(i>1)
                tamp=tamp+4;
            end
            
            [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),StartTime+Td+(i-1)*Tp);
            % �d��
%             [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
            %�d���G���G��
             dot1(3) = binaryApproch(pn, dot1(2), para(1), para(2), Ar, Beta1, Beta2);
            ValHiDen(1,tamp)=dot1(1);
            ValHiDen(1,tamp+1)=dot1(2);
            ValHiDen(1,tamp+2)=dot1(3);
            
            
            for j=1:times-1
                % �Ѯɶ�(�ۭq)��۹����q�y(Data)
                [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),real(StartTime+Td+(i-1)*Tp+j*Ts));
                % �ѹq�y(Data)��۹����q��(ideal)
                %[~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
                %�d���G���G��
                 dot1(3) = binaryApproch(pn, dot1(2), para(1), para(2), Ar, Beta1, Beta2);
                ValHiDen(j+1,tamp)=dot1(1);
                ValHiDen(j+1,tamp+1)=dot1(2);
                ValHiDen(j+1,tamp+2)=dot1(3);
            end
        end
        
        A3=ValHiDen(:,3);
        Y7=ValHiDen(:,7);
        B1 = log(inv(A3'*A3)*A3'*Y7)/Tp;
        
        BB=B1;
        % �p�� V( T_d+nT_s+kT_p)= V( T_d)(exp(b T_s)^ n (exp(b T_p) ^ k ����
        % exp(b T_s) �M exp(b T_p)
        count=1;
        for k=1:n
            ValHiDen_Exp_bTp(k) = exp(B1*Tp)^(k-1);
            for m=1:times
               ValHiDen_Exp_bTs(m) = exp(B1*Ts)^(m-1);
               ArrayExp(count)= ValHiDen_Exp_bTs(m)*ValHiDen_Exp_bTp(k);
               count=count+1;
            end
        end
        
        A4=ArrayExp';
        Y8=[ValHiDen(:,1:3);ValHiDen(:,5:7)];
        V_Td = inv(A4'*A4)*A4'*Y8(:,3);
%         V_Td =  data_sum(2)*sum(ArrayExp(:)) / ( sum(ArrayExp(:))^2 );
%         %  A1*exp(B1*Td) = V_Td ���ɥX A1 = exp(log(V_Td)/B1/Td)
         A1 = exp(log(V_Td)-B1*Td);
         A1=real(A1);
         AA=A1;
         
%         t=0.001:0.001:2.5;
%         plot(t,AA*exp(BB*t));
        hold on;
        AB_value(1)=AA;
        AB_value(2)=BB;
%         plot(ValHiDen(:,1)-3.5,ValHiDen(:,3),'rx');plot(ValHiDen(:,5)-3.5,ValHiDen(:,7),'rx');
    end
    if pn<=0
        
        % �[�J���T�A���T�j�p�O�γ̤j�q�y��%�ƨM�w
        
        [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),StartTime+Td);
        %�d��
%         [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
        %OML���� ��G���G��
        dot1(3) = binaryApproch(pn, dot1(2), para(1), para(2), Ar, Beta1, Beta2);
        dot(1,1)=dot1(1);
        dot(1,2)=dot1(2);
        dot(1,3)=dot1(3);

         tamp=1;
         for i=1:n
            if(i>1)
                tamp=tamp+4;
            end
            
            [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),StartTime+Td+(i-1)*Tp);
            %�d��
%             [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
            % OML���� ��G���G��
            dot1(3) = binaryApproch(pn, dot1(2), para(1), para(2), Ar, Beta1, Beta2);
            ValHiDen(1,tamp)=dot1(1);
            ValHiDen(1,tamp+1)=dot1(2);
            ValHiDen(1,tamp+2)=dot1(3);
            
            for j=1:times-1
                % �Ѯɶ�(�ۭq)��۹����q�y(Data)
                [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),real(StartTime+Td+(i-1)*Tp+j*Ts));
                % �ѹq�y(Data)��۹����q��(ideal) �d��
%                 [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
                % OML������G���G��
                dot1(3) = binaryApproch(pn, dot1(2), para(1), para(2), Ar, Beta1, Beta2);
                ValHiDen(j+1,tamp)=dot1(1);
                ValHiDen(j+1,tamp+1)=dot1(2);
                ValHiDen(j+1,tamp+2)=dot1(3);
            
            end
         end
        A3=ValHiDen(:,3);
        Y7=ValHiDen(:,7);
        B1 = log(inv(A3'*A3)*A3'*Y7)/Tp;
         B5= B1;
         BB=B5;

        % �p�� V( T_d+nT_s+kT_p)= V( T_d)(exp(b T_s)^ n (exp(b T_p) ^ k ����
        % exp(b T_s) �M exp(b T_p)
        count=1;
        for k=1:n
            ValHiDen_Exp_bTp(k) = exp(B5*Tp)^(k-1);
            for m=1:times
               ValHiDen_Exp_bTs(m) = exp(B5*Ts)^(m-1);
               ArrayExp(count)= ValHiDen_Exp_bTs(m)*ValHiDen_Exp_bTp(k);
               count=count+1;
            end
        end
        
        A4=ArrayExp';
        Y8=[ValHiDen(:,1:3);ValHiDen(:,5:7)];
        V_Td = inv(A4'*A4)*A4'*Y8(:,3);
%         V_Td =  data_sum(2)*sum(ArrayExp(:)) / ( sum(ArrayExp(:))^2 );
%         %  A1*exp(B1*Td) = V_Td ���ɥX A1 = exp(log(V_Td)/B1/Td)
         A1 = exp(log(V_Td)-B5*Td);
         A5=real(A1);
    
        AA=A5;
        t=0.001:0.001:2.5;
%         plot(t,AA*exp(BB*t));
        hold on;
        
        AB_value(1)=AA;
        AB_value(2)=BB;
     end
    
        
        
end










