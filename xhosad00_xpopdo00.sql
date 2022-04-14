--Adam Hos xhosad00 
--Dominik Pop xpopdo00

--drop tables
DROP TABLE Kradez;
DROP TABLE Prestupek;
DROP TABLE Policista;
DROP TABLE RidickeOpravneni;
DROP TABLE MelSPZ;
DROP TABLE HistorieSPZ;
DROP TABLE Motocykl;
DROP TABLE OsobniAutomobil;
DROP TABLE Autobus;
DROP TABLE NakladniAutomobil;
DROP TABLE Vozidlo;
DROP TABLE Majitel;
DROP TABLE Ridic;
DROP TABLE Osoba;

--drop sequences
DROP SEQUENCE S_ID_osoby;
DROP SEQUENCE S_ID_opravneni;
DROP SEQUENCE S_ID_prestupku;
DROP SEQUENCE S_ID_majitele;
DROP SEQUENCE S_ID_kradeze;

-- alter formats

ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD-MM-YYYY HH24:MI';
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';

--create sequences
CREATE SEQUENCE S_ID_osoby START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE S_ID_opravneni START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE S_ID_prestupku START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE S_ID_majitele START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE S_ID_kradeze START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

--create tables
CREATE TABLE Policista(
    sluzebni_c NUMERIC(7,0),
    jmeno VARCHAR(20),
    prijmeni VARCHAR(20),
    pozice VARCHAR(20),
    CONSTRAINT PK_sluzebni_c PRIMARY KEY (sluzebni_c)
);

CREATE TABLE Osoba(
    ID_osoby NUMBER DEFAULT S_ID_osoby.nextval,
    jmeno VARCHAR(20),
    prijmeni VARCHAR(20),
    datum_narozeni DATE,
    rodne_cislo VARCHAR(20), CONSTRAINT rodne_cislo_delka check (LENGTH(rodne_cislo) = 10), check (MOD(rodne_cislo,11) = 0) ,--TODO pridat DATE datum narozeni?
    CONSTRAINT PK_ID_osoby PRIMARY KEY (ID_osoby)
);

CREATE TABLE Ridic(
    ID_prukazu CHAR(10),
    zakaz_rizeni NUMBER(1) DEFAULT 0,
    trestneBody NUMERIC(2) DEFAULT 0,
    ID_osoby NUMBER CONSTRAINT ID_osoby_NN NOT NULL,
    CONSTRAINT PK_ID_prukazu PRIMARY KEY (ID_prukazu),
    CONSTRAINT FK_ID_osoby FOREIGN KEY (ID_osoby) REFERENCES Osoba 
);

CREATE TABLE RidickeOpravneni(
    ID_opravneni NUMBER DEFAULT S_ID_opravneni.nextval,
    zhotoveni DATE,
    popis CHAR(2),
    ID_prukazu CHAR(10),
    CONSTRAINT PK_ID_opravneni_opravneni PRIMARY KEY (ID_opravneni),
    CONSTRAINT FK_ID_prukazu_opravneni FOREIGN KEY (ID_prukazu) REFERENCES Ridic
);

CREATE TABLE Prestupek(
    ID_prestupku NUMBER DEFAULT S_ID_prestupku.nextval,
    nazev VARCHAR(50),
    popis VARCHAR(500),
    zhotoveni DATE,
    vyse NUMERIC(7,0),
    body NUMERIC(2),
    ID_prukazu CHAR(10), 
    sluzebni_c NUMERIC(7,0),
    CONSTRAINT PK_ID_prestupek PRIMARY KEY (ID_prestupku),
    CONSTRAINT FK_ID_prukazu_prestupek FOREIGN KEY (ID_prukazu) REFERENCES Ridic,
    CONSTRAINT FK_ID_sluzebni_c FOREIGN KEY (sluzebni_c) REFERENCES Policista
);

CREATE TABLE Majitel(
    ID_majitele NUMBER DEFAULT S_ID_majitele.nextval,
    ID_prukazu CHAR(10), --can be NULL
    ID_osoby NUMBER CONSTRAINT ID_majitele_NN NOT NULL,
    CONSTRAINT PK_ID_majitele PRIMARY KEY (ID_majitele),
    CONSTRAINT FK_ID_prukazu FOREIGN KEY (ID_prukazu) REFERENCES Ridic,
    CONSTRAINT FK_ID_osoby2 FOREIGN KEY (ID_osoby) REFERENCES Osoba
);

CREATE TABLE Vozidlo(
    VIN CHAR(17),
    znacka VARCHAR(20), 
    nazev VARCHAR(30),
    rok_vyroby NUMERIC(4),
    barva VARCHAR(20),
    objem_motoru NUMERIC(6,0), 
    SPZ char(8), 
    ID_majitele NUMBER,
    CONSTRAINT PK_VIN PRIMARY KEY (VIN),
    CONSTRAINT FK_ID_Majitel FOREIGN KEY (ID_majitele) REFERENCES Majitel
);

CREATE TABLE Kradez(
    ID_kradeze NUMBER DEFAULT S_ID_kradeze.nextval,
    zemne VARCHAR(15), 
    mesto VARCHAR(20), 
    ulice VARCHAR(50),
    datum_a_cas TIMESTAMP,
    VIN CHAR(17),
    sluzebni_c NUMERIC(7,0),
    CONSTRAINT PK_ID_kradeze PRIMARY KEY (ID_kradeze),
    CONSTRAINT FK_ID_VIN_kradez FOREIGN KEY (VIN) REFERENCES Vozidlo,
    CONSTRAINT FK_ID_sluzebni_c_kradez FOREIGN KEY (sluzebni_c) REFERENCES Policista
);

CREATE TABLE HistorieSPZ(
    SPZ CHAR(8),
    datum_zmeny DATE,
    CONSTRAINT PK_SPZ PRIMARY KEY (SPZ)
);

--vazba Vozidla a HistorieSPZ
CREATE TABLE MelSPZ( 
    VIN CHAR(17),
    SPZ CHAR(8),
    CONSTRAINT FK_VIN_melSPZ FOREIGN KEY (VIN) REFERENCES Vozidlo,
    CONSTRAINT FK_SPZ FOREIGN KEY (SPZ) REFERENCES HistorieSPZ
);

CREATE TABLE Motocykl(
    VIN CHAR(17),
    CONSTRAINT PK_VIN_motocykl PRIMARY KEY (VIN),
    CONSTRAINT FK_ID_VIN_motocykl FOREIGN KEY (VIN) REFERENCES Vozidlo
);

CREATE TABLE OsobniAutomobil(
    VIN CHAR(17),
    CONSTRAINT PK_VIN_osobniauto PRIMARY KEY (VIN),
    CONSTRAINT FK_ID_VIN_osobniauto FOREIGN KEY (VIN) REFERENCES Vozidlo
);

CREATE TABLE Autobus(
    VIN CHAR(17),
    mista_sezeni NUMERIC(3),
    mista_stani NUMERIC(3),
    CONSTRAINT PK_VIN_autobus PRIMARY KEY (VIN),
    CONSTRAINT FK_ID_VIN_autobus FOREIGN KEY (VIN) REFERENCES Vozidlo
 );

CREATE TABLE NakladniAutomobil(
    VIN CHAR(17),
    nosnost_kg NUMERIC(5),
    CONSTRAINT PK_VIN_nakladni PRIMARY KEY (VIN),
    CONSTRAINT FK_ID_VIN_nakladni FOREIGN KEY (VIN) REFERENCES Vozidlo
 );


--------SEEDING------
--Policista
INSERT INTO Policista(sluzebni_c, jmeno, prijmeni, pozice)
    VALUES (525320,'Ludovic', 'Cruchot','cetnik');
INSERT INTO Policista(sluzebni_c, jmeno, prijmeni, pozice)
    VALUES (525321,'Jean', 'Bonjour','porucik');
INSERT INTO Policista(sluzebni_c, jmeno, prijmeni, pozice)
    VALUES (525322,'James', 'Bond','porucik');

--Osoba
INSERT INTO Osoba(jmeno, prijmeni, datum_narozeni, rodne_cislo)
    VALUES ('Pepa','Novak', TO_DATE('17-12-2000', 'DD-MM-YY'), '0012175944');
INSERT INTO Osoba(jmeno, prijmeni, datum_narozeni, rodne_cislo)
    VALUES ('Jan','Pospisil', TO_DATE('01-08-1991', 'DD-MM-YY'), '9108014894');
INSERT INTO Osoba(jmeno, prijmeni, datum_narozeni, rodne_cislo)
    VALUES ('Dan','Kurtka', TO_DATE('11-02-1964', 'DD-MM-YY'), '6402112827');
INSERT INTO Osoba(jmeno, prijmeni, datum_narozeni, rodne_cislo)
    VALUES ('Alexnadr','Bonto', TO_DATE('13-08-1971', 'DD-MM-YY'), '7108137212');
INSERT INTO Osoba(jmeno, prijmeni, datum_narozeni, rodne_cislo)
    VALUES ('William','Shakespeare', TO_DATE('12-08-1965', 'DD-MM-YY'), '6508127032');
INSERT INTO Osoba(jmeno, prijmeni, datum_narozeni, rodne_cislo)
    VALUES ('David','Bartosik', TO_DATE('05-11-2005', 'DD-MM-YY'), '0511056062');

--Ridic
INSERT INTO Ridic(ID_prukazu, zakaz_rizeni, ID_osoby)
    VALUES ('EG123456', 0, 1);
INSERT INTO Ridic(ID_prukazu, zakaz_rizeni, ID_osoby)
    VALUES ('FF112346', 0, 3);
INSERT INTO Ridic(ID_prukazu, zakaz_rizeni, ID_osoby)
    VALUES ('EA843115', 0, 4);
INSERT INTO Ridic(ID_prukazu, zakaz_rizeni, ID_osoby)
    VALUES ('EB693227', 0, 6);
    
--RidickeOpravneni
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'AM', 'EG123456');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'B', 'EG123456');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'B1', 'EG123456');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('13-09-1994', 'DD-MM-YY'), 'B', 'FF112346');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('13-09-1994', 'DD-MM-YY'), 'B1', 'FF112346');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('03-04-2012', 'DD-MM-YY'), 'C', 'FF112346');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('03-04-2012', 'DD-MM-YY'), 'C1', 'FF112346');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('06-02-1964', 'DD-MM-YY'), 'B1', 'EA843115');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('06-02-1964', 'DD-MM-YY'), 'B', 'EA843115');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'A1', 'EG123456');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'A2', 'EG123456');
INSERT INTO RidickeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('15-07-2021', 'DD-MM-YY'), 'A1', 'EB693227');

--Majitel
INSERT INTO Majitel(ID_prukazu, ID_osoby)
    VALUES ('EG123456', 1);
INSERT INTO Majitel(ID_prukazu, ID_osoby)
    VALUES (null, 2);
INSERT INTO Majitel(ID_prukazu, ID_osoby)
    VALUES ('EA843115', 4);
INSERT INTO Majitel(ID_prukazu, ID_osoby)
    VALUES ('EB693227', 6);

--Vozidlo
INSERT INTO Vozidlo(VIN, znacka, nazev, rok_vyroby, barva, objem_motoru, SPZ, ID_majitele)
    VALUES ('YS3AL76L1R7002116', 'Alfa Romeo', 'Twin Spark', 1992, 'vinova', 2000, 'MUJDRAAK', 1);
INSERT INTO Vozidlo(VIN, znacka, nazev, rok_vyroby, barva, objem_motoru, SPZ, ID_majitele)
    VALUES ('JH4KA8172PC002873', 'Honda', 'Acura Legend', 1993, 'bila', 2500, '5B555555', 2);
INSERT INTO Vozidlo(VIN, znacka, nazev, rok_vyroby, barva, objem_motoru, SPZ, ID_majitele)
    VALUES ('4JGBB86E27A199749', 'Ford', 'Ford Escape', 2002, 'cerna', 3000, 'A5B46064', 3);
INSERT INTO Vozidlo(VIN, znacka, nazev, rok_vyroby, barva, objem_motoru, SPZ, ID_majitele)
    VALUES ('JYA2RRA01KA020333', 'Yamaha', 'ysr50', 1989, 'modra', 100, 'GR400253', 1);
INSERT INTO Vozidlo(VIN, znacka, nazev, rok_vyroby, barva, objem_motoru, SPZ, ID_majitele)
    VALUES ('WYB4RXA04KA050443', 'Honda', 'CBR-R 125', 2004, 'oranzova', 125, '6M820091', 4);

--OsobniAutomobil
INSERT INTO OsobniAutomobil(VIN)
    VALUES ('YS3AL76L1R7002116');
INSERT INTO OsobniAutomobil(VIN)
    VALUES ('JH4KA8172PC002873');
INSERT INTO OsobniAutomobil(VIN)
    VALUES ('4JGBB86E27A199749');

--Motocykl
INSERT INTO Motocykl(VIN)
    VALUES ('JYA2RRA01KA020333');
INSERT INTO Motocykl(VIN)
    VALUES ('WYB4RXA04KA050443');

--HistorieSPZ
INSERT INTO HistorieSPZ(SPZ, datum_zmeny)
    VALUES ('A1T94678', TO_DATE('01-01-2016', 'DD-MM-YYYY'));

--MelSPZ
INSERT INTO MelSPZ(VIN, SPZ)
    VALUES ('YS3AL76L1R7002116', 'A1T94678');

--Kradez
INSERT INTO  Kradez(zemne, mesto, ulice, datum_a_cas, VIN, sluzebni_c)
    VALUES ('CR', 'Janlovice', 'Janlovice 202', '10-04-1995 17:30', '4JGBB86E27A199749', 525320);
INSERT INTO  Kradez(zemne, mesto, ulice, datum_a_cas, VIN, sluzebni_c)
    VALUES ('CR', 'Praha', 'Neumannova 2', '10-08-2002 12:33', '4JGBB86E27A199749', 525321);


--PRESTUPEK---- hrani si s updatem
--dotaz pro ziskani poctu udelenych body za nejnovjejsi prestupek
--SELECT * FROM (SELECT body FROM Prestupek  WHERE ID_prukazu = 'EG123456' ORDER by zhotoveni DESC), pouzit nize
--1--
INSERT INTO Prestupek(nazev, popis, zhotoveni, vyse, body, ID_prukazu, sluzebni_c)
    VALUES ('Průjezd na cervenou', 'průjzd na červenou v městě St. Tropez na křižovatce na ulicích Námestní a Brumbalova', TO_DATE('10-04-1995', 'DD-MM-YYYY'), 4500, 3, 'EG123456', 525320);
    
UPDATE Ridic
SET trestneBody = trestneBody + (SELECT * FROM (SELECT body FROM Prestupek  WHERE ID_prukazu = 'EG123456' ORDER by zhotoveni DESC) WHERE rownum = 1)
WHERE ID_prukazu = 'EG123456';

UPDATE Ridic
SET zakaz_rizeni = 1
WHERE trestneBody >= 12;
--1--
--2
INSERT INTO Prestupek(nazev, popis, zhotoveni, vyse, body, ID_prukazu, sluzebni_c)
    VALUES ('Průjezd na cervenou a kolize', 'průjzd na červenou v městě St. Tropez na křižovatce na ulicích Gondrova a Frňákova, čelní náraz s SUV, ...', TO_DATE('10-04-2020', 'DD-MM-YYYY'), 4500, 5, 'EG123456', 525320);

UPDATE Ridic
SET trestneBody = trestneBody + (SELECT * FROM (SELECT body FROM Prestupek  WHERE ID_prukazu = 'EG123456' ORDER by zhotoveni DESC) WHERE rownum = 1)
WHERE ID_prukazu = 'EG123456';

UPDATE Ridic
SET zakaz_rizeni = 1
WHERE trestneBody >= 12;
--2--

--3--
INSERT INTO Prestupek(nazev, popis, zhotoveni, vyse, body, ID_prukazu, sluzebni_c)
    VALUES ('Prekroceni rychlosti', 'Prekroceni rychlosti v městě St. Tropez na křižovatce na ulicích Gondrova a Frňákova', TO_DATE('15-05-2021', 'DD-MM-YYYY'), 5000, 4, 'EG123456', 525321);

UPDATE Ridic
SET trestneBody = trestneBody + (SELECT * FROM (SELECT body FROM Prestupek  WHERE ID_prukazu = 'EG123456' ORDER by zhotoveni DESC) WHERE rownum = 1)
WHERE ID_prukazu = 'EG123456';

UPDATE Ridic
SET zakaz_rizeni = 1
WHERE trestneBody >= 12;
--3--
--PRESTUPEK----


---SELECTY---
--1--
-- Select vybere osoby narozene po roce 2004 majici ridicske opravneni a vlastnici motocykl.
SELECT ID_osoby, jmeno, prijmeni, znacka, nazev
FROM Osoba NATURAL JOIN Ridic NATURAL JOIN Majitel NATURAL JOIN Vozidlo NATURAL JOIN Motocykl
WHERE datum_narozeni > TO_DATE('31-12-2004', 'DD-MM-YYYY');

--1--

--2--
-- Vybere ridice, kteri maji zakaz rizeni a vlastni vic jak 1 ridicske opravneni
SELECT jmeno, prijmeni
FROM (SELECT jmeno, prijmeni, zakaz_rizeni, COUNT(*) pocet
    FROM Osoba NATURAL JOIN Ridic NATURAL JOIN RidickeOpravneni
    GROUP BY jmeno, prijmeni, zakaz_rizeni)
WHERE pocet > 1 AND zakaz_rizeni = 1;
--2--

--3--
-- Vybere Prestupky spachane ridicem Pepa Novak ze dne 10.4.2020
SELECT nazev 
FROM Prestupek NATURAL JOIN Ridic NATURAL JOIN Osoba
WHERE jmeno = 'Pepa' AND prijmeni = 'Novak' AND zhotoveni = TO_DATE('10-04-2020', 'DD-MM-YYYY');
--3--

--4--
-- Vybere Policisty, kteri zapsali prestupek dne 10.4.2020 ve vysi 4500 Kc
SELECT jmeno, prijmeni 
FROM Policista NATURAL JOIN Prestupek
WHERE zhotoveni = TO_DATE('10-04-2020', 'DD-MM-YYYY') AND vyse = 4500;
--4-- 

--5--
-- Zobrazi vozidla a jmena jejich majitelu
SELECT VIN, znacka, nazev, jmeno, prijmeni FROM Vozidlo NATURAL JOIN Majitel NATURAL JOIN Osoba;
--5--

--6--
-- Zobrazi sumu, kterou museli ridici zaplatit za vsechny sve prestupky
SELECT O.jmeno, O.prijmeni, SUM(P.vyse) celkem_presupky 
FROM Prestupek P, Ridic R, Osoba O
WHERE P.ID_prukazu = R.ID_prukazu AND R.ID_osoby = O.ID_osoby
GROUP BY O.jmeno, O.prijmeni;

--6--

--7--
-- Zobrazi ridice u kterych neexistuji prestupky
SELECT * FROM Osoba NATURAL JOIN (SELECT ID_osoby, COUNT(nazev) pocet_prestupku FROM Ridic NATURAL LEFT JOIN (SELECT * FROM Prestupek NATURAL JOIN Ridic) GROUP BY ID_osoby)
WHERE pocet_prestupku = 0;

--7--

--8--
-- Zobrazi majitele, kteri maji vozidlo od spolecnosti Honda nebo Yamaha
SELECT jmeno, prijmeni
FROM Vozidlo NATURAL JOIN Osoba NATURAL JOIN Majitel
WHERE znacka IN ('Honda', 'Yamaha');
--8--

--9--
-- Zobrazi informace o vozidlech, ktere byly ukradene a informace o jejich kradezi zapsal Ludovic Cruchot
SELECT VIN, znacka, nazev, rok_vyroby, barva, objem_motoru, SPZ
FROM Vozidlo V NATURAL JOIN Kradez K NATURAL JOIN Policista P
WHERE P.jmeno = 'Ludovic' AND P.prijmeni = 'Cruchot';
--9--

--10--
-- Zobrazi policisty, kteri nezapsali zadnou kradez
SELECT * 
FROM Policista P
WHERE NOT EXISTS (SELECT * FROM Kradez K WHERE P.sluzebni_c = K.sluzebni_c);
--10--

--11--
-- Zobrazi pocet prestupku pro vsechny ridice, serazene sestupne
SELECT ID_osoby, jmeno, prijmeni, COUNT(nazev) pocet_prestupku 
FROM Osoba NATURAL JOIN (SELECT * FROM Ridic NATURAL LEFT JOIN (SELECT * FROM Prestupek NATURAL JOIN Ridic)) 
GROUP BY ID_osoby, jmeno, prijmeni ORDER BY pocet_prestupku DESC;
--11--

--12--
-- Zobrazi vsechny presupky a policisty, kteri je zapsali
SELECT * 
FROM Prestupek NATURAL JOIN Policista;
--12--

-- 13 --
-- Zobrazi informace o vsech vozidlech ktere byly ukradeny
SELECT *
FROM Vozidlo
WHERE nazev IN (SELECT nazev FROM Vozidlo NATURAL JOIN Kradez);

-- 13 --
---SELECTY---