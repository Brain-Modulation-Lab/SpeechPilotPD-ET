function [Result]=act_test(com,comb,time,f,fsel,tsel)
ch=size(com,4);
fq=dsearchn(f',fsel);
tq=dsearchn(time',tsel);
p=ones(ch,1);
zval=zeros(ch,1);
for i=1:ch
empch(i)=sum(reshape(abs(com(:,:,:,i)),[],1));    
end
for i=setdiff(1:ch,find(empch==0))
x=squeeze(mean(mean(abs(com(fq(1):fq(2),tq(1):tq(2),:,i)),1),2));
y=squeeze(mean(mean(abs(comb(fq(1):fq(2),:,:,i)),1),2)); 
[p(i),h,stats] = signrank(x,y);
zval(i)=stats.zval;
end
Result=[zval p];