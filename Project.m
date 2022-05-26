clear all
close all
clc
%% Načítanie premenných
Tab = readtable('Final_Data.xlsx');
t = datetime(datenum(Tab.('T'),'yyyyQQ'),'ConvertFrom','datenum','Format','yyyyQQ');
y = Tab.('D_HDP');
ystar = Tab.('D_FHDP');
con = Tab.('C')/100000;
R = Tab.('PRIBOR');
Pi = Tab.('Pi');
FPi = Tab.('FPi');
RMK = Tab.('RSK');
EUR = Tab.('EURLIBOR');
Pistar = Tab.('Pistar');

%% Úprava premenných
c = detrend(con);
r = (log(R) - mean(log(R)))/100;
pi = log(Pi) - mean(log(Pi));
pif = log(FPi) - mean(log(FPi));
q = log(RMK) - mean(log(RMK));
rstar = (EUR - mean(EUR))/100;
pistar = (Pistar - mean(Pistar))/100;

%% Uloženie premenných do xlxs formátu
T_final = table(y,ystar,r,c,pi,pif,q,rstar,pistar);
writetable(T_final,'data_file.xlsx','Sheet',1);

%% Vykreslenie transformovaných premenných
nexttile
plot(t,y)
title('HDP (y)')

nexttile
plot(t,ystar)
title('Zahraničné HDP (ystar)')

nexttile
plot(t,c)
title('Spotreba (c)')

nexttile
plot(t,pi)
title('Inflácia (pi)')

nexttile
plot(t,pif)
title('Inflácia Importu (pif)')

nexttile
plot(t,pistar)
title('Zahraničná inflácia (pistar)')

nexttile
plot(t,r)
title('Domáca Úroková Miera (r)')

nexttile
plot(t,rstar)
title('Zahraničná Úroková Miera (rstar)')

nexttile
plot(t,q)
title('Reálny Smenný Kurz (q)')
%% Dynare časť
addpath('C:\dynare\4.5.7\matlab');
dynare Dynare_script.mod