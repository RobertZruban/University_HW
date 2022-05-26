
clear
close all
clc
%% Pridani cesty k podpurnym funkcim v adresari Support
% adresar pro vlastni funkce (pokud nejsou ve stejnem adresari jako skript)
 addpath('.\Support')

%% Na�?tení datového souboru
%% Seria vstupnych inputov na nastavanie obdobia
% dlzka_obdobia = input("Zadajte pocet dni sledovaneho obdobia");
ticker_symbol = input("Zadajte ticker symbol akcie bez uvodzoviek(napr: SPYD-Jan-YYYY bez uvodu) " ,'s');
startovaci_datum = input("Zadajte zaciatok sledovaneho obdobia vo formate Doviek (napr: 01-Jan-2015)  " , 's');
koniec_datumu = input("Zadajte koniec sledovaneho Obdobia DD-MM-YYYY bez uvodzoviek (napr: 30-Dec-2020) ", 's');
pocet_dni = input("Zadajte pocet dni od ktoreho chcete nastavit predikciu (musi byt mensi ako celkovy pocet dni medzi zaciatkom a koncom obdobia) ");
data = getMarketDataViaYahoo(ticker_symbol,startovaci_datum,koniec_datumu,'1d');

%% transformacia dat na vynosy v ln
model = data{1:pocet_dni,"Close"};
model2 = data{2:pocet_dni+1,"Close"};
y = log(model2)-log(model);
y23 = data{1:height(data)-1, "Close"};
y22 =data{2:height(data), "Close"};
predikcia = length(pocet_dni:length(log(y22)-log(y23)));


%% Nastaveni apriornich hyperparametru a Gibbsova vzorkovace
% Apriornimi hyperparametry
%return~N(mu,sigma) h=1/sigma^2
% p(mu)~N(mu_0, V_0)
% p(h)~G(h_0,nu_0)
 mu_0 = [0.5];
 V_0 = diag([0.1^2]);
 nu_0 = 2;
 s2_0 = 0.03^2;
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
len_sim=length(data{:,1})-pocet_dni; %pro kolik budoucich dni bude simulace provedena
sim_return=zeros([len_sim,num_sim]);
for k= 1:num_sim
    Mu=mu(:,k);
    Sigma=sigma(:,k);
    sim_return(:,k)= normrnd(Mu,Sigma,[len_sim,1]);
end

log_price=log(data{:,'Close'});
log_price_sim=zeros([pocet_dni+len_sim,num_sim]);
log_price_sim(1:pocet_dni,:)=NaN([pocet_dni,num_sim]);
for j=1:num_sim
    log_price_sim(pocet_dni+1:length(log_price_sim(:,1)),j)=log_price(pocet_dni)+cumsum(sim_return(:,j));
end



drift=zeros([pocet_dni+len_sim,1]);
drift(1:pocet_dni)=NaN([pocet_dni,1]);
for i=1:len_sim
    drift(pocet_dni+i,1)=log_price(pocet_dni)+i*mean_mu_1;
end

unlog_drift = exp(drift);
unlog_price = exp(log_price);
unlog_simul = log_price_sim;
unlog_simul = exp(unlog_simul);

VAR_mat = unlog_simul(pocet_dni+1:length(y23)+1,1:num_sim);
RISK = [];
PROFIT = [];

for z = 1:predikcia
  RISK(z) = quantile(VAR_mat(z,1:num_sim),0.05);
  PROFIT(z) = quantile(VAR_mat(z,1:num_sim),0.95);
end

%Graficke zobrazeni
date=datenum(data{:,"Date"});
date2 = date(pocet_dni+1:length(y23)+1);
figure
p=plot(date,unlog_price);
datetick('x', 'mmm yyyy', 'keepticks')
xlim([min(date) max(date)])
hold on
ps=plot(date,unlog_simul,'r');
for x=1:num_sim
    ps(x).Color(4)=0.01;
end
varplot = plot(date2, RISK, 'g');
profitplot = plot(date2, PROFIT, 'g');
trend=plot(date,unlog_drift, '--k');
hold off