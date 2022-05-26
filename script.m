clear
close all
clc
%% Pridani cesty k podpurnym funkcim v adresari Support
% adresar pro vlastni funkce (pokud nejsou ve stejnem adresari jako skript)
 addpath('.\Support')

%% Načtení datového souboru
file=readtable('SP500.xlsx');
y=file{1:1257,'xReturn'};
%% Nastaveni apriornich hyperparametru a Gibbsova vzorkovace
% Apriornimi hyperparametry
%return~N(mu,sigma) h=1/sigma^2
% p(mu)~N(mu_0, V_0)
% p(h)~G(h_0,nu_0)
 mu_0 = [0.005];
 V_0 = diag([0.1^2]);
 nu_0 = 5;
 s2_0 = 0.1^2;
 h_0 = 1/s2_0;
 
% Definice modelu
 y = y;
 X = [ones(size(y))];
% Nastaveni Gibbsova vzorkovace
 S = 100000+1;   %celkovy pocet generovanych vzorku + pocatecni hodnota
 S_0 = 40000+1; %pocet vyhozenych vzorku
 S_1 = S-S_0;   %pocet ponechanych vzorku

 mu = zeros(length(mu_0),S);    %vzorky pro mu
 h = zeros(1,S);                    %vzorky pro h
  
% nastaveni pocatecnich hodnot
 mu(:,1) = mu_0;
 h(1,1) = h_0;
 %% Gibbsuv vzorkovac
for s=2:S
 %1. blok Gibbsova vzorkovace
 %podminena hustota p(mu|h,y)~N(mu_1,V_1)
  V_1 = inv(inv(V_0)+h(1,s-1)*(X'*X)); %(4.4) dle Koop (2003)
  mu_1 = V_1*(inv(V_0)*mu_0+h(1,s-1)*(X'*y)); %(4.5) dle Koop (2003)
  
  mu(:,s) = mu_1+norm_rnd(V_1); %(4.7) dle Koop (2003)
  
 
  
 %2. blok Gibbsova vzorkovace
 %podminena hustota p(h|mu,y)~G(h_1,nu_1)
  nu_1 = length(y)+nu_0;            %(4.9)
  h_1 = (1/nu_1*((y-X*mu(:,s))'*(y-X*mu(:,s))+nu_0*1/h_0))^-1; %(4.10)
 
  h(1,s) = gamm_rnd_Koop(h_1,nu_1,1); %(4.8)
  
end

%% Posteriorni analyza
% vyhozeni prvnich S_0 vzorku
 mu(:,1:S_0) = [];
 h(:,1:S_0) = [];
 sigma=sqrt(h.^-1);
% graficke zobrazeni konvergence
 k = 100;   %delka kroku
 figure
 subplot(2,3,1)
 plot(mu(1:k:end));
 title('mu')
 
 subplot(2,3,2)
 plot(h(1:k:end));
 title('h')

 subplot(2,3,3)
 plot(sigma(1:k:end));
 title('sigma')
 
 subplot(2,3,4)
 histogram(mu,50);
 title('mu')
 
 subplot(2,3,5)
 histogram(h,50);
 title('h')
 
 subplot(2,3,6)
 histogram(sigma,50);
 title('sigma')
 
% Gewekova konvergencni diagnostika
 CD_mu = Geweke(mu');
 CD_h = Geweke(h');
 CD_sigma= Geweke(sigma');
 
%% Prezentace vysledku
%apriorni str. hodnoty a sm. odchylky
%mu_0, h_0 - apriorni stredni hodnoty
 std_mu_0 = sqrt(V_0); %apriornich sm. odchylka pro mu
 std_h_0 = sqrt(2*h_0^2/nu_0); %apriorni sm. odchylka pro h

%posteriorni str. hodnoty a sm. odchylky
 mean_mu_1 = mean(mu,2); %sloupcovy vektor radkovych prumeru
 mean_h_1 = mean(h); %str. hodnota h
 mean_sigma_1=sqrt(mean_h_1^-1);
 std_mu_1 = sqrt(mean(mu.^2,2)-mean_mu_1.^2);  
 std_h_1 = sqrt(mean(h.^2)-mean_h_1.^2);
 std_sigma_1=sqrt(mean(sigma.^2)-mean_sigma_1.^2);
 

%Vystup na obrazovku
 fprintf('Parametr      prior m.   prior std.  post m.     post std.   Geweke CD\n')
 fprintf('=========================================================================================\n')
 fprintf('mu             %6.4f \t %6.4f \t %6.4f \t %6.4f \t %6.4f \t\n',mu_0,std_mu_0,mean_mu_1,std_mu_1,CD_mu.CD(1)) 
 fprintf('h              %6.4f \t       %6.4f \t %6.4f \t %6.4f \t\n',h_0,mean_h_1,std_h_1,CD_h.CD(1)) 
 fprintf('sigma          %6.4f \t            %6.4f \t     %6.4f \t %6.4f \t\n',sqrt(s2_0),mean_sigma_1,std_sigma_1,CD_sigma.CD(1)) 


%% Simulace budoucich vynosu a ceny SP500
%return~N(mu,sigma)
%Za pomoci vzorku z aposteriorniho rozdeleni nasimulujeme budouci vynosy a
%z nich pote vyvoj ceny(vyjadrene v logaritmu)
num_sim=1000;
len_sim=length(file{:,1})-1257; %pro kolik budoucich dni bude simulace provedena
sim_return=zeros([len_sim,num_sim]);
for k= 1:num_sim
    Mu=mu(:,k);
    Sigma=sigma(:,k);
    sim_return(:,k)= normrnd(Mu,Sigma,[len_sim,1]);
end

log_price=log(file{:,'Close'});
log_price_sim=zeros([1257+len_sim,num_sim]);
log_price_sim(1:1257,:)=NaN([1257,num_sim]);
for j=1:num_sim
    log_price_sim(1258:length(log_price_sim(:,1)),j)=log_price(1257)+cumsum(sim_return(:,j));
end

%Graficke zobrazeni
date=datenum(file{:,1});
figure
p=plot(date,log_price);
datetick('x', 'mmm yyyy', 'keepticks')
xlim([737400 738200])
hold on
ps=plot(date,log_price_sim,'r');
for x=1:num_sim
    ps(x).Color(4)=0.01;
end
hold off