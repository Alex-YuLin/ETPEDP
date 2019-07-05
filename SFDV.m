function [Vout] = SFDV(VV,Vpl,Tar_I, Te, Ne, A, beta)
    Vt=abs(VV);
    Vb1=-Vt;Vb2=Vt;Vscan=VV; 
    Ib1=FDCurrent_2(A,beta,Vb1,Vpl,Te,Ne);
    Ib2=FDCurrent_2(A,beta,Vb2,Vpl,Te,Ne);
    if( Ib1>=Tar_I || Ib2<=Tar_I )
        Vout=0; msg='[error]: SFDV ¶W¹L¥ª¥k·¥­­'
        return;
    end
    Err=1;
    
    count=1;
    while (Err>1E-13)
        Vm=(Vb1+Vb2)/2;
        Im =FDCurrent_2(A,beta,Vm ,Vpl,Te,Ne);
        
        volta(count,1)=Vb1;volta(count,2)=Vb2;volta(count,3)=Vm;
        Curre(count,1)=Ib1;Curre(count,2)=Ib2;Curre(count,3)=Im;
        
        Diff1=Tar_I-Ib1;
        Diffm=Tar_I-Im;
        if (Diff1*Diffm<0 )
                Vb2=Vm;Ib2=Im; Vout=Vm;
        else
                Vb1=Vm;Ib1=Im; Vout=Vm;
            
        end
     
        Err = abs(Im-Tar_I); 
        
        count=count+1;
%         plot(1:length(volta(:,1)),volta(:,1),'--',1:length(volta(:,2)),volta(:,2),1:length(volta(:,1)),volta(:,3),':');

    end
end