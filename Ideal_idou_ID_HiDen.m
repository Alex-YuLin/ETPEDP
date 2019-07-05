% 閒置曲線ID %
%{
    目的: 電壓放電曲線 擷取點 並用__法求出AB 回歸曲線 
    輸入: 
        Data: 模擬 IT 數據
        StartTime:  擷取點起始延遲
        Td:  擷取點時間(x倍tau_v) Td
        Ts:  ASA_ADC擷取頻率
        times: 擷取點數
        Tp: 擷取點時間(x倍tau_c) Tp
        Density: 電子濃度 (未使用)
        Tensuu: 未知(未使用)
        pn: 輸入電壓
        noice:雜訊比
        LoadTable:查表(Load -5.0V ~ 1.0V stap為0.00001 )
        noice_circuit:充電 穩定店(加雜訊用)
    輸出:
        dot: 時間、電壓、電流
        A1: Y=A*exp(Bt) 式中 A
        B1: Y=A*exp(Bt) 式中 B
%}
% 閒置曲線ID %
function[AB_value,AA,BB]=Ideal_idou_ID_HiDen(Data ,StartTime ,Td_ori ,Ts ,times, Tp, Density, Tensuu, pn, noice, LoadTable, noice_circuit, para)
    %{
        Tp -> 下降取擷取點 = StartTime+Td + n * Tp
    %}
    Ar = 6;
    Beta1= 0;
    Beta2= 0;
    %攫取區域數量
    n=2;
    % Load -5.0V ~ 1.0V stap為0.00001 
    % 因為要使用單位 I-T 表 so直接input Guesss.IV data
    % load(LoadTable);
    Guess.IV=LoadTable;
    % 加入雜訊，雜訊大小是用最大電流的%數決定
        gosa=noice;
        Ireal_seco=noice_circuit;
        Length = length(Data(:,2));
        Data(:,2) = Data(:,2)+ rand(Length,1) * Ireal_seco * gosa/100-Ireal_seco*gosa/100/2;
        
        %計算個溫濃下的 Td 時間 越過非ID曲線
        [Td,~]=find_Td(Data, StartTime, Ts, Td_ori, LoadTable, noice, noice_circuit, pn);
       
        
        
    if pn>=0
        % 起始時間電流%
        [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),StartTime+Td);
        %用電流在IV取線上找到對應電壓% -> 最高電壓 
%         [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
        % OML公式 改二分逼近
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
            % 查表
%             [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
            %查表改二分逼近
             dot1(3) = binaryApproch(pn, dot1(2), para(1), para(2), Ar, Beta1, Beta2);
            ValHiDen(1,tamp)=dot1(1);
            ValHiDen(1,tamp+1)=dot1(2);
            ValHiDen(1,tamp+2)=dot1(3);
            
            
            for j=1:times-1
                % 由時間(自訂)找相對應電流(Data)
                [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),real(StartTime+Td+(i-1)*Tp+j*Ts));
                % 由電流(Data)找相對應電壓(ideal)
                %[~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
                %查表改二分逼近
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
        % 計算 V( T_d+nT_s+kT_p)= V( T_d)(exp(b T_s)^ n (exp(b T_p) ^ k 中的
        % exp(b T_s) 和 exp(b T_p)
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
%         %  A1*exp(B1*Td) = V_Td 推導出 A1 = exp(log(V_Td)/B1/Td)
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
        
        % 加入雜訊，雜訊大小是用最大電流的%數決定
        
        [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),StartTime+Td);
        %查表
%         [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
        %OML公式 改二分逼近
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
            %查表
%             [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
            % OML公式 改二分逼近
            dot1(3) = binaryApproch(pn, dot1(2), para(1), para(2), Ar, Beta1, Beta2);
            ValHiDen(1,tamp)=dot1(1);
            ValHiDen(1,tamp+1)=dot1(2);
            ValHiDen(1,tamp+2)=dot1(3);
            
            for j=1:times-1
                % 由時間(自訂)找相對應電流(Data)
                [dot1(1),dot1(2),~]=T_find_D(Data(:,1),Data(:,2),real(StartTime+Td+(i-1)*Tp+j*Ts));
                % 由電流(Data)找相對應電壓(ideal) 查表
%                 [~,dot1(3),~]=T_find_D(Guess.IV(:,1),Guess.IV(:,2),dot1(2));
                % OML公式改二分逼近
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

        % 計算 V( T_d+nT_s+kT_p)= V( T_d)(exp(b T_s)^ n (exp(b T_p) ^ k 中的
        % exp(b T_s) 和 exp(b T_p)
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
%         %  A1*exp(B1*Td) = V_Td 推導出 A1 = exp(log(V_Td)/B1/Td)
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










