function [Result]=act_test_hil(tr,base,time,tsel)
ch=size(tr,1);
tq=dsearchn(time',tsel);
for i=1:ch
empch(i)=sum(reshape(abs(tr{i}),[],1));    
end
for f=1:size(tr{1},1)
p=ones(ch,1);
zval=zeros(ch,1);

for i=setdiff(1:ch,find(empch==0))
x=squeeze(mean(abs(tr{i}(f,tq(1):tq(2),:)),2));
y=squeeze(mean(abs(base{i}(f,:,:)),2)); 
[p(i),h,stats] = signrank(x,y);
zval(i)=stats.zval;
end
Result(:,:,f)=[zval p];

end