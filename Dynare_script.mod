/*
Variable Definition

y:domestic GDP, 
pi: overall inflation, 
pif: import inflation
pih:domestic inflation
r: nominal domestic interest rate, 
rstar: foreign real interest rate, 
pistar:foreign inflation,
ystar:foreign GDP, 
q: real exchange rate
a: productivity, 
theta: low of one price gap, 
c: consumption, 
mc: real marginal cost, 
s: term of trade

Shocks
eps_s:terms of trade
eps_q:real exhcange rate
eps_theta:law of one price
eps_pif:import inflation
eps_pih:domestic inflation (not included yet)
eps_r:domestic monetary policy
eps_a:productivity
eps_ystar:foreign consumption
eps_rstar:foreign interest rate
eps_pistar: foreign inflation

parameters
Fixed parameters
beta: discout factor

Estimated parameters
sigma: inverse elasticity of intertemporal substitution in consumption
psi: inverse of wage elasticity of labour supply
epsilon_H: elasticity of intratemporal substitution between home goods and foreign goods
epsilon_B: degree of openness
thetah: calvo price stickiness - domestic
thetaf: calvo price stickiness - foreign
omegaR: monetary policy-interest coefficient
omegaY: monetary policy-output coefficient
omegaPI: monetary policy-inflation coefficient
omegaQ1: monetary policy-exchange rate coefficient 
omegaQ2: monetart policy-change in exchange rate coefficient
rho_s:persistence coefficient of terms of trade
rho_q: persistence coefficient of real exhhange rate 
rho_pif:persistence coefficient of import inflation
rho_pih:persistence coefficient of domestic inflation
rho_r: persistence coefficient of domestcic monetary policy
rho_a: Persistence coefficient of productivity
rho_rstar: persistence coefficient of foreign monetary policy
rho_ystar: Persistence coefficient of foreign output
rho_pistar: persistence coefficient of forieng inflation
*/

//Here you specify endogenous variables
var 
c 
pi 
s 
q 
theta 
mc 
y 
pih 
pif 
r 
zs 
zq 
ztheta 
zpih 
zpif 
zr 
a 
ystar 
rstar 
pistar
;

//Here you specify exogenous variables
varexo 
eps_s 
eps_q 
eps_theta 
eps_pif 
eps_pih 
eps_r 
eps_a 
eps_ystar 
eps_rstar 
eps_pistar
;

//Here you specify the parameters of the model
parameters 
beta
sigma 
psi 
epsilon_B 
epsilon_H 
thetah 
thetaf 
omegaR 
omegaY 
omegaPI
omegaQ1
omegaQ2 
rho_s 
rho_q 
rho_theta 
rho_pif 
rho_pih 
rho_r 
rho_a 
rho_ystar 
rho_rstar 
rho_pistar 
lambdah 
lambdaf 
omegaS 
omegaTHETA
;

//Initial calibration before estimation
//parameters
beta          =   0.99; // OK
sigma         =   2.00; //OK    
psi           =   1.60; //OK (popripade 1.55)
epsilon_H     =   1.80;  //1.8 str33-34   https://is.muni.cz/auth/th/ni40z/Thesis_IS.pdf
epsilon_B     =   0.5;  //0.5 str 34"economy openness"  https://www.econstor.eu/bitstream/10419/120433/1/827021127.pdf
thetah        =   0.861;   // 0.861 str 13 https://www.econstor.eu/bitstream/10419/120433/1/827021127.pdf
thetaf        =   0.902;   // 0.902  str 13  https://www.econstor.eu/bitstream/10419/120433/1/827021127.pdf
omegaR        =   0.50;    //OK str 47 https://is.muni.cz/auth/th/th0in/DP_Klapalova.pdf
omegaY        =   0.20; // 0.2 str 47 https://is.muni.cz/auth/th/th0in/DP_Klapalova.pdf
omegaPI       =   1.70; // 1.7 str 47 https://is.muni.cz/auth/th/th0in/DP_Klapalova.pdf
omegaQ1       =   0.25; // Toto by mohlo byt Ok, neviem sa k tomu vyjadrit
omegaQ2       =   0.25; // Toto by mohlo byt Ok, tneviem sa k tomu vyjadrit

//Autocorrelation parameters all to 0.5, implies a stationary moderate shock
rho_s         =   0.50;
rho_q         =   0.50; 
rho_theta     =   0.50;
rho_pif       =   0.50;
rho_pih       =   0.50;
rho_r         =   0.50;   
rho_a         =   0.50;
rho_ystar     =   0.50;    
rho_rstar     =   0.50;
rho_pistar    =   0.50; 

//Variance of shocks
sig=1.00; 

//other parameters
lambdah = (1-beta*thetah)*(1-thetah)/thetah;     
lambdaf = (1-beta*thetaf)*(1-thetaf)/thetaf; 
omegaS = 1+ epsilon_B*(2-epsilon_B)*(sigma*epsilon_H -1);
omegaTHETA = 1+ epsilon_B*(sigma*epsilon_H -1);


model(linear);

c      = c(+1)-(1/sigma)*(r - pi(+1));                                                                        // EULER 

pi = (1-epsilon_B)*pih + epsilon_B*pif;                                                                       // OVERALL INFLATION   

s  =  s(-1)+pif - pih + zs;                                                                                   // TOT  

q(+1) -q = rstar - pistar(+1) - (r-pi(+1)) + zq;                                                              // UIP

theta  = -q - (1-epsilon_B)*s +ztheta;                                                                        // LOP GAP   

mc = sigma*c + psi*y + epsilon_B*s - (1+psi)*a;                                                               // FIRM'S MARGINAL COST

y      = (1-epsilon_B)*c + epsilon_B*ystar + (2-epsilon_B)*epsilon_B*epsilon_H*s + epsilon_B*epsilon_H*theta; // GOODS MARKET CLEARING

pih    = beta*pih(+1) + lambdah*mc + zpih;                                                                    // DOMESTIC INFLATION  

pif    = beta*pif(+1) + lambdaf*theta + zpif;                                                                 // IMPORT INFLATION  

//r      = omegaR*r(-1)+(1-omegaR)*(omegaPI*pi(+1)+omegaY*(y-y(-1))) + zr;                                    //MP(1)

//r    = omegaR*r(-1)+(1-omegaR)*(omegaPI*pi(+1)+omegaY*(y-y(-1))-omegaQ1*q)+ zr;                             //MP(2)

r    = omegaR*r(-1)+(1-omegaR)*(omegaPI*pi(+1)+omegaY*(y-y(-1))-omegaQ1*q+omegaQ2*(q-q(-1)))+ zr;             //MP(3)

zs     = rho_s*zs(-1) + eps_s;                                                                                //AR(1) process for shock to terms of trade

zq     = rho_q*zq(-1) + eps_q;                                                                                //AR(1) process for shock to real exchange rate

ztheta = rho_theta*ztheta(-1) + eps_theta;                                                                    //AR(1) process for shock to law of one price gap

zpih   = rho_pif*zpih(-1) + eps_pih;                                                                          //AR(1) process for shock to domestic inflation

zpif   = rho_pif*zpif(-1) + eps_pif;                                                                          //AR(1) process for shock to import inflation

zr     = rho_r*zr(-1) + eps_r;                                                                                //AR(1) process for shock to domestic monetary policy

a      = rho_a*a(-1) + eps_a;                                                                                 //AR(1) process for shock to productivity

ystar  = rho_ystar*ystar(-1) + eps_ystar;                                                                     //AR(1) process for shock to foreign output

rstar  = rho_rstar*rstar(-1) + eps_rstar;                                                                     //AR(1) process for shock to foreign interest

pistar = rho_pistar*pistar(-1) + eps_pistar;                                                                  //AR(1) process for shock to foreign inflation

end;

steady;

shocks;
var eps_s       =sig^2;
var eps_q       =sig^2;
var eps_theta   =sig^2;
var eps_pih     =sig^2;
var eps_pif     =sig^2;
var eps_r       =sig^2;
var eps_a       =sig^2;
var eps_ystar   =sig^2;
var eps_rstar   =sig^2;
var eps_pistar  =sig^2;
end;


//Specify priors for Bayesian Estimation
//Here you specify priors for the parameters 

estimated_params;

// Priors for Housholds
//beta, beta_pdf, 0.99, 0.02;
sigma, gamma_pdf, 2.0, 0.25;  
psi, gamma_pdf, 1.5, 0.3;   
epsilon_H, gamma_pdf, 2, 0.1;  //toto som zmenil
//epsilon_B, //beta distrib(predtym bola gama distrib), toto som zmenil 0.5, 0.025, Kludne by to vsak mohlo zostat zakomentovane a byt Fix. parameter

//Priors for Firms
thetah, beta_pdf, 0.5, 0.25;
thetaf, beta_pdf, 0.5, 0.25;

//Priors for Monetary policy
omegaR, beta_pdf, 0.7, 0.20; 
omegaY, gamma_pdf, 0.2, 0.1; // toto som zmenil
omegaPI, gamma_pdf, 1.5, 0.25;
omegaQ1, gamma_pdf, 0.25, 0.1;
omegaQ2, gamma_pdf, 0.25, 0.1;

//Priors for Autocorrelation parameters
rho_s, beta_pdf,  0.5, 0.1;
rho_q, beta_pdf,  0.5, 0.1;
rho_theta, beta_pdf,  0.5, 0.1;
rho_pif, beta_pdf,  0.5, 0.1;
rho_pih, beta_pdf,  0.5, 0.1;
rho_r, beta_pdf, 0.5, 0.1;
rho_a, beta_pdf,  0.5, 0.1;
rho_ystar, beta_pdf, 0.5, 0.1;
rho_rstar, beta_pdf, 0.5, 0.1;
rho_pistar, beta_pdf,  0.5, 0.1;

//Priors for White noise shocks
stderr eps_s, inv_gamma_pdf, 2, inf;
stderr eps_q, inv_gamma_pdf, 2, inf;
stderr eps_theta, inv_gamma_pdf, 2, inf;
stderr eps_pih, inv_gamma_pdf, 2, inf; 
stderr eps_pif, inv_gamma_pdf, 2, inf;
stderr eps_r, inv_gamma_pdf, 2, inf;
stderr eps_a, inv_gamma_pdf, 2, inf;
stderr eps_ystar, inv_gamma_pdf, 2, inf; 
stderr eps_rstar, inv_gamma_pdf, 2, inf; 
stderr eps_pistar, inv_gamma_pdf, 2, inf;
end;

//specify observed variables
varobs y c r pi pif q pistar rstar ystar;

//This is the command used to enable Bayesian Estimation

estimation(order=1, 
datafile=data_file,
mode_compute=6,
bayesian_irf,
irf=40, 
//mode_file=,
mh_replic=1000000,
//load_mh_file,
mode_check,
mh_nblocks=5,
mh_drop=0.5,
mh_jscale=0.4) y c r rstar pi pif pih q s pistar ystar rstar;
