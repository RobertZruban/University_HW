*1;
proc sql;
select firstname,surname,birthdate from dm1.doctor
where intck("year",birthdate,today(),"c")>60;
run;
*2;
proc sql;
select distinct specialization from dm1.doctor
where address LIKE "%Praha%";

run;
*3;
proc sql;
select sum(points) from dm1.doctor
where specialization="psychologist";

run;
*4;
proc sql;
select sum(points) from dm1.doctor
where specialization="practicioner" and intck("year",birthdate,today(),"c")>60 ;
run;
*5;
proc sql;
select specialization,avg(points) from dm1.doctor
group by specialization;
run;
*6;
proc sql;
select specialization,sum(points) as body from dm1.doctor
group by specialization
having body>500;
run;

*7;
proc sql;
select diagnosis from dm1.doctor d inner join dm1.visitation v on d.id=v.doctor
where surname="Asklepios";
run;
*8;
proc sql;
select visitdate from dm1.patient p inner join dm1.visitation v on p.id=v.patient
where surname="Zeleny" and firstname="Jan";
run;

*9;
proc sql;
select distinct firstname,surname 
from dm1.doctor d inner join dm1.visitation v on d.id=v.doctor;
run;
*10;
proc sql;
select p.firstname,p.surname from dm1.doctor d,dm1.visitation v,dm1.patient p
where d.id=v.doctor 
		and v.patient=p.id 
		and d.surname="Novak" and d.firstname="Jan";

run;
*10nefunguje;
proc sql;
select p.firstname,p.surname from (dm1.doctor d inner join dm1.visitation v on d.id=v.doctor) as z inner join dm1.patient p on p.id=z.patient
where d.surname="Novak" and d.firstname="Jan";
run;
*11;
proc sql;
select p.firstname,p.surname,p.birthdate from dm1.doctor d,dm1.visitation v,dm1.patient p
where d.id=v.doctor 
		and v.patient=p.id 
		and d.surname="Novak" and d.firstname="Jan"
		and intck("year",p.birthdate,today(),"c")<40;

run;
*12;
proc sql;
select count(*) from dm1.visitation v inner join dm1.patient p on v.patient=p.id
where p.firstname="Joe" and p.surname="Smith";
run;
*13;
proc sql;
select d.firstname,d.surname,count(*) as pocet from dm1.doctor d inner join dm1.visitation v
		on d.id=v.doctor
		group by d.firstname,d.surname
		having pocet>3;
run;
*14;
proc sql;
select d.firstname,d.surname from dm1.doctor d inner join dm1.visitation v
		on d.id=v.doctor
		where diagnosis="sleeplessness";
run;
*15;
proc sql;
select * from dm1.doctor d 
where intck("year",birthdate,today(),"c")=(select max(intck("year",birthdate,today(),"c")) from dm1.doctor);
run;
*16b;
proc sql;
select empid,firstname,lastname,city,state,dateofbirth
from dm1.staffmaster s natural inner join dm1.payrollmaster p
where month(dateofbirth)=2;
run;
*16a;
proc sql;
select empid,firstname,lastname,city,state from dm1.staffmaster 
where empid in (select empid from dm1.payrollmaster
where month(dateofbirth)=2);
run;
*17;
proc sql;
select * from
	(select jobcode,avg(salary) as prumer from dm1.payrollmaster
	group by jobcode)
	having prumer>(select avg(salary) from dm1.payrollmaster);

run;
*18a;
proc sql;
select empid,firstname,lastname,dateofbirth
from dm1.payrollmaster natural inner join dm1.staffmaster
where jobcode in("FA1","FA2")
and  year(dateofbirth)<(select max(year(dateofbirth))
						from dm1.payrollmaster
						where jobcode="FA3");

run;
*18b;
proc sql;
select empid,firstname,lastname,dateofbirth
from dm1.payrollmaster natural inner join dm1.staffmaster
where jobcode in("FA1","FA2")
and  year(dateofbirth)<(select min(year(dateofbirth))
						from dm1.payrollmaster
						where jobcode="FA3");
run;







