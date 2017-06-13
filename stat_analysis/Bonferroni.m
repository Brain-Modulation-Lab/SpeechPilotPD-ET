function [critical_z]=Bonferroni(x)
num_compar=size(x,1)*size(x,2)*size(x,3);
new_alpha=1-((1-0.05)^(1/num_compar));
critical_z=norminv(1-(new_alpha/2));
end