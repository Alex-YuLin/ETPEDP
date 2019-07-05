function[C]=C_keisan(t,I,SP)
if (I(1)-I(2))==0
    K=0;
else
    K=(I(1)-I(3))/(I(1)-I(2));
end
    C=real(log(K-1))/SP;
end