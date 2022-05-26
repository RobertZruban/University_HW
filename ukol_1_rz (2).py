# -*- coding: utf-8 -*-
"""
Created on Tue Oct 27 15:14:34 2020

@author: roboz
"""

import numpy as np
import random as rd
import matplotlib.pyplot as plt
S = input("Kolko krat chces aby sa hra odohrala:")
PociatocneVyhry_Bob = input("Kolko vyhier ma na zaciatku Bob: ")
PociatocneVyhry_Alica = input("Kolko vyhier ma na zaciatku Alica: ")
Celkove_vyhry = input("Kolko chces celkovo vyhier: ")
dlzka_vektora = Celkove_vyhry*2
Alica_total = 0
Bob_total = 0
Hra_ktora_neskoncila_pomerom = 0
x_p = 0
 
for hra in range(int(S)):
    s = np.random.uniform(0, 1, int(dlzka_vektora) )
    p = np.random.uniform(0, 1)
    Alica_win = 0
    Bob_win = 0

    if sum(s[0:int(PociatocneVyhry_Alica)+int(PociatocneVyhry_Bob )] < p) == int(PociatocneVyhry_Alica) :
        for x in s[int(PociatocneVyhry_Alica)+int(PociatocneVyhry_Bob):int(dlzka_vektora)]:
          
            if x < p:
                Alica_win = Alica_win + 1
                if Alica_win == int(Celkove_vyhry)-int(PociatocneVyhry_Alica):
                    Alica_total = Alica_total + 1
                    break
 
            elif x > p:
                Bob_win = Bob_win + 1
                if Bob_win == int(Celkove_vyhry)-int(PociatocneVyhry_Bob):
                    Bob_total = Bob_total + 1
                    break
            elif x == p:
                x_p = x_p + 1
                print("Jackpot!!!!!!!!")
          
    else:
        Hra_ktora_neskoncila_pomerom = Hra_ktora_neskoncila_pomerom + 1

relative_wins_Bob = (Bob_total / (Alica_total + Bob_total))
relative_wins_Alica = (Alica_total/ (Alica_total + Bob_total))
print("Pocet hier ktore neskoncili danym pomerom: ", Hra_ktora_neskoncila_pomerom)
print("Priemerna Bobova vyhra pri pociatocnom stave",int(PociatocneVyhry_Alica), "[Alica]", ":", int(PociatocneVyhry_Bob ), "[Bob]", " je ", round(relative_wins_Bob*100,2), " %")
print("Priemerna Alicina vyhra pri pociatocnom stave" , int(PociatocneVyhry_Alica),"[Alica]", ":", int(PociatocneVyhry_Bob ),"[Bob]",  " je ", round(relative_wins_Alica*100,2), " %")
print("Alica spolu vyhrala", Alica_total, "krat", "\nBob spolu vyhral", Bob_total , "krat")
print("Ferovy podil sanci Alica:Bob pro rozdeleni vyhry za daneho stavu je ", round(relative_wins_Alica/relative_wins_Bob,3))
print("Relativni zastoupeni poctu daneho stavu  na celkovom pocte simulacii", round((Alica_total+Bob_total)/int(S),3))
## PLOT
x = 1
plot1 = plt.subplot(1,2,1)
plt.grid(True)
plt.scatter(x,relative_wins_Bob, marker = "o", label = " Pravdepodobnost Boba", linewidths=3, edgecolors="r")
plot1.set_xlabel("Hrac Bob")
plot1.set_ylim([0,1])
plot1.set_ylabel("Relativna pravdepodobnost ")
plot2 = plt.subplot(1,2,2)
plot2.set_xlabel("Hrac Alica")
plot2.set_ylabel("Relativna pravdepodobnost ")
plot2.set_ylim([0,1])
plt.scatter(x,relative_wins_Alica, marker = "*", label = " Pravdepodobnost Alice", linewidths=3, edgecolors="b")
plt.tight_layout()
plt.grid(True)