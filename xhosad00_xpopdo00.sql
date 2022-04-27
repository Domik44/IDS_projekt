--Adam Hos xhosad00
--Dominik Pop xpopdo00

--drop tables
DROP TABLE Kradez;
DROP TABLE Prestupek;
DROP TABLE Policista;
DROP TABLE RidicskeOpravneni;
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
DROP SEQUENCE policista_id_seq;

-- alter formats

ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD-MM-YYYY HH24:MI';
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';

SET SERVEROUTPUT ON;

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

CREATE TABLE RidicskeOpravneni(
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


-------- 4) PROCEDURY --------
-- Procedura vypise na vystup jmeno, prijmeni a vek vsech ridicu mladsich 18 let
CREATE OR REPLACE PROCEDURE vekPod18
AS
    vek NUMERIC;
    CURSOR curs_ridici IS SELECT jmeno, prijmeni, datum_narozeni FROM Osoba O, Ridic R WHERE O.ID_osoby = R.ID_osoby;
    radek curs_ridici%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Procedura vypise ridice mladsi 18 let:');
    IF curs_ridici %ISOPEN THEN
        CLOSE curs_ridici;
    END IF;
    OPEN curs_ridici;
    
    LOOP
        FETCH curs_ridici INTO radek;
        EXIT WHEN curs_ridici%NOTFOUND;
        vek := (sysdate - radek.datum_narozeni) / 365;
        IF vek < 18 THEN
            DBMS_OUTPUT.PUT_LINE(radek.jmeno || ' ' || radek.prijmeni || ' ' || vek);
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
        WHEN others THEN
         DBMS_OUTPUT.PUT_LINE('Error pri procedure vekPod18!');
END;
/

-- Procedura vypocita procentualni zastoupeni jednotlivych typu vozidel (automobil, motocykl, autobus, nakladni automobil)
CREATE OR REPLACE PROCEDURE zastoupeni_vozidel
AS
    pocet_celkem NUMBER;
    pocet_typ NUMBER;
    procenta_typ NUMBER;
    CURSOR curs_auto IS SELECT * FROM OsobniAutomobil;
    CURSOR curs_motocykl IS SELECT * FROM Motocykl;
    CURSOR curs_autobus IS SELECT * FROM Autobus;
    CURSOR curs_nakladak IS SELECT * FROM NakladniAutomobil;
    CURSOR curs_vozidla IS SELECT * FROM Vozidlo;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Procedura vypise procentualni zastoupeni typu vozidel v databazi:');
    pocet_celkem := 0;
    FOR radek IN curs_vozidla LOOP
        pocet_celkem := pocet_celkem + 1;
    END LOOP;
    
    pocet_typ := 0;
    FOR radek IN curs_auto LOOP
        pocet_typ := pocet_typ + 1;
    END LOOP;
    procenta_typ := round((pocet_typ/pocet_celkem)*100);
    DBMS_OUTPUT.PUT_LINE('Zastoupeni osobnich automobilu: ' || procenta_typ || '%');
    
    pocet_typ := 0;
    FOR radek IN curs_motocykl LOOP
        pocet_typ := pocet_typ + 1;
    END LOOP;
    procenta_typ := round((pocet_typ/pocet_celkem)*100);
    DBMS_OUTPUT.PUT_LINE('Zastoupeni motocyklu: ' || procenta_typ || '%');
    
    pocet_typ := 0;
    FOR radek IN curs_autobus LOOP
        pocet_typ := pocet_typ + 1;
    END LOOP;
    procenta_typ := round((pocet_typ/pocet_celkem)*100);
    DBMS_OUTPUT.PUT_LINE('Zastoupeni autobusu: ' || procenta_typ || '%');
    
    pocet_typ := 0;
    FOR radek IN curs_nakladak LOOP
        pocet_typ := pocet_typ + 1;
    END LOOP;
    procenta_typ := round((pocet_typ/pocet_celkem)*100);
    DBMS_OUTPUT.PUT_LINE('Zastoupeni nakladnich automobilu: ' || procenta_typ || '%');
    
END;
/
-------- 4) PROCEDURY --------

-------- 4) TRIGGERY --------
-- Trigger, ktery prirazuje sluzebni cisla od urcite hodnoty (420000)
CREATE SEQUENCE policista_id_seq
    START WITH 420000
    INCREMENT BY 1;
CREATE OR REPLACE TRIGGER policista_id
    BEFORE INSERT ON Policista
    FOR EACH ROW
    BEGIN
        :NEW.sluzebni_c := policista_id_seq.nextval;
    END;
/

-- DEMONSTRACE TRIGGERU pro sluzebni cisla
INSERT INTO Policista(jmeno, prijmeni, pozice)
    VALUES ('Ludovic', 'Cruchot','cetnik');
INSERT INTO Policista(jmeno, prijmeni, pozice)
    VALUES ('Jean', 'Bonjour','porucik');
INSERT INTO Policista(jmeno, prijmeni, pozice)
    VALUES ('James', 'Bond','porucik');
SELECT * FROM Policista;

-- Trigger, ktery po vymene SPZ prida starou do historie
CREATE OR REPLACE TRIGGER update_historie_SPZ
    AFTER UPDATE ON Vozidlo
    FOR EACH ROW
    BEGIN
        IF :OLD.SPZ != :NEW.SPZ THEN
            INSERT INTO HistorieSPZ (SPZ, datum_zmeny) VALUES (:OLD.SPZ, sysdate);
        END IF;
    END;
/

-- Trigger, ktery po pridani prestupku aktualizuje trestne body ridice a pripadne i prida zakaz rizeni
CREATE OR REPLACE TRIGGER update_trestne_body
    AFTER INSERT ON Prestupek
    FOR EACH ROW
    BEGIN
        UPDATE Ridic SET trestneBody = trestneBody + :NEW.body WHERE ID_prukazu = :NEW.ID_prukazu; 
        UPDATE Ridic SET zakaz_rizeni = 1 WHERE ID_prukazu = :NEW.ID_prukazu;
    END;
/

-------- TRIGGERY --------

-------- 2) SEEDING --------
-- Policista
-- Presunuto nahoru do TRIGGERU

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
    
--RidicskeOpravneni
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'AM', 'EG123456');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'B', 'EG123456');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'B1', 'EG123456');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('13-09-1994', 'DD-MM-YY'), 'B', 'FF112346');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('13-09-1994', 'DD-MM-YY'), 'B1', 'FF112346');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('03-04-2012', 'DD-MM-YY'), 'C', 'FF112346');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('03-04-2012', 'DD-MM-YY'), 'C1', 'FF112346');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('06-02-1964', 'DD-MM-YY'), 'B1', 'EA843115');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('06-02-1964', 'DD-MM-YY'), 'B', 'EA843115');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'A1', 'EG123456');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
    VALUES (TO_DATE('05-02-2005', 'DD-MM-YY'), 'A2', 'EG123456');
INSERT INTO RidicskeOpravneni(zhotoveni, popis, ID_prukazu)
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
    VALUES ('CR', 'Janlovice', 'Janlovice 202', '10-04-1995 17:30', '4JGBB86E27A199749', 420000);
INSERT INTO  Kradez(zemne, mesto, ulice, datum_a_cas, VIN, sluzebni_c)
    VALUES ('CR', 'Praha', 'Neumannova 2', '10-08-2002 12:33', '4JGBB86E27A199749', 420001);


---- PRESTUPEK ---- 
-- DEMONSTRACE TRIGGERU
INSERT INTO Prestupek(nazev, popis, zhotoveni, vyse, body, ID_prukazu, sluzebni_c)
    VALUES ('Průjezd na cervenou', 'průjzd na červenou v městě St. Tropez na křižovatce na ulicích Námestní a Brumbalova', TO_DATE('10-04-1995', 'DD-MM-YYYY'), 4500, 3, 'EG123456', 420000);
INSERT INTO Prestupek(nazev, popis, zhotoveni, vyse, body, ID_prukazu, sluzebni_c)
    VALUES ('Průjezd na cervenou a kolize', 'průjzd na červenou v městě St. Tropez na křižovatce na ulicích Gondrova a Frňákova, čelní náraz s SUV, ...', TO_DATE('10-04-2020', 'DD-MM-YYYY'), 4500, 5, 'EG123456', 420000);
INSERT INTO Prestupek(nazev, popis, zhotoveni, vyse, body, ID_prukazu, sluzebni_c)
    VALUES ('Prekroceni rychlosti', 'Prekroceni rychlosti v městě St. Tropez na křižovatce na ulicích Gondrova a Frňákova', TO_DATE('15-05-2021', 'DD-MM-YYYY'), 5000, 4, 'EG123456', 420001);
---- PRESTUPEK ----
-------- 2) SEEDING --------

-------- 3) SELECTY --------
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
    FROM Osoba NATURAL JOIN Ridic NATURAL JOIN RidicskeOpravneni
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
SELECT id_osoby ID_OSOBY,
pocet_prestupku POCET_PRESTUPKU FROM Osoba NATURAL JOIN (SELECT ID_osoby, COUNT(nazev) pocet_prestupku FROM Ridic NATURAL LEFT JOIN (SELECT * FROM Prestupek NATURAL JOIN Ridic) GROUP BY ID_osoby)
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
-------- SELECTY --------

-------- 4) PRISTUPOVA PRAVA --------
-- TODO -> EXECUTE pro procedury
GRANT ALL ON Policista TO xhosad00;
GRANT ALL ON Osoba TO xhosad00;
GRANT ALL ON Ridic TO xhosad00;
GRANT ALL ON RidicskeOpravneni TO xhosad00;
GRANT ALL ON Prestupek TO xhosad00;
GRANT ALL ON Majitel TO xhosad00;
GRANT ALL ON Vozidlo TO xhosad00;
GRANT ALL ON Kradez TO xhosad00;
GRANT ALL ON HistorieSPZ TO xhosad00;
GRANT ALL ON MelSPZ TO xhosad00;
GRANT ALL ON Motocykl TO xhosad00;
GRANT ALL ON OsobniAutomobil TO xhosad00;
GRANT ALL ON Autobus TO xhosad00;
GRANT ALL ON NakladniAutomobil TO xhosad00;

GRANT EXECUTE ON vekPod18 TO xhosad00;
GRANT EXECUTE ON zastoupeni_vozidel TO xhosad00;
-------- PRISTUPOVA PRAVA --------

-------- 4) EXPLAIN PLAN --------

EXPLAIN PLAN FOR
    SELECT O.jmeno, O.prijmeni, SUM(P.vyse) celkem_presupky 
    FROM Prestupek P, Ridic R, Osoba O
    WHERE P.ID_prukazu = R.ID_prukazu AND R.ID_osoby = O.ID_osoby
    GROUP BY O.jmeno, O.prijmeni;
SELECT * FROM TABLE(DBMS_XPLAN.display);


CREATE INDEX index_ridic ON Ridic (ID_prukazu, ID_osoby);
CREATE INDEX index_prestupek ON Prestupek (ID_prukazu, Vyse);
CREATE INDEX index_osoba ON Osoba (ID_osoby, jmeno, prijmeni);

EXPLAIN PLAN FOR
    SELECT O.jmeno, O.prijmeni, SUM(P.vyse) celkem_presupky 
    FROM Prestupek P, Ridic R, Osoba O
    WHERE P.ID_prukazu = R.ID_prukazu AND R.ID_osoby = O.ID_osoby
    GROUP BY O.jmeno, O.prijmeni;
SELECT * FROM TABLE(DBMS_XPLAN.display);

DROP INDEX index_ridic;
DROP INDEX index_prestupek;
DROP INDEX index_osoba;
-------- EXPLAIN PLAN --------

-------- 4) POHLEDY --------
DROP MATERIALIZED VIEW ridici_view;

CREATE MATERIALIZED VIEW ridici_view
CACHE
BUILD IMMEDIATE 
REFRESH ON COMMIT
AS
SELECT *
FROM xpopdo00.Ridic;


SELECT * FROM ridici_view;

INSERT INTO Ridic(ID_prukazu, zakaz_rizeni, ID_osoby)
    VALUES ('EB693248', 0, 5);

COMMIT;
    
SELECT * FROM ridici_view;
-------- POHLEDY --------

-------- 4) VOLANI PROCEDUR --------
BEGIN
    vekPod18;
    zastoupeni_vozidel;
END;
/
-------- VOLANI PROCEDUR --------

-------- 4) DEMONSTRACE TRIGGERU --------
UPDATE Vozidlo SET SPZ = '7B755577' WHERE VIN = 'JH4KA8172PC002873';
SELECT * FROM HistorieSPZ;

-- inserty viz.: PRESTUPKY, radek: 400
SELECT * FROM Ridic;
-------- DEMONSTRACE TRIGGERU --------