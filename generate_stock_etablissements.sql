\cd :scriptdir;
\qecho 'Using scriptdir:' :scriptdir
CREATE DATABASE tmp_insee_daily_update;
\c tmp_insee_daily_update;

DROP TABLE etablissements;
CREATE TABLE etablissements
(
  siren VARCHAR(50),
  nic VARCHAR(50),
  siret VARCHAR(50) PRIMARY KEY,
  statutDiffusionEtablissement VARCHAR(50),
  dateCreationEtablissement VARCHAR(50),
  trancheEffectifsEtablissement VARCHAR(50),
  anneeEffectifsEtablissement VARCHAR(50),
  activitePrincipaleRegistreMetiersEtablissement VARCHAR(50),
  dateDernierTraitementEtablissement VARCHAR(50),
  etablissementSiege VARCHAR(50),
  nombrePeriodesEtablissement VARCHAR(50),
  complementAdresseEtablissement VARCHAR(50),
  numeroVoieEtablissement VARCHAR(50),
  indiceRepetitionEtablissement VARCHAR(50),
  typeVoieEtablissement VARCHAR(50),
  libelleVoieEtablissement VARCHAR(50),
  codePostalEtablissement VARCHAR(50),
  libelleCommuneEtablissement VARCHAR(50),
  libelleCommuneEtrangerEtablissement VARCHAR(50),
  distributionSpecialeEtablissement VARCHAR(50),
  codeCommuneEtablissement VARCHAR(50),
  codeCedexEtablissement VARCHAR(50),
  libelleCedexEtablissement VARCHAR(50),
  codePaysEtrangerEtablissement VARCHAR(50),
  libellePaysEtrangerEtablissement VARCHAR(50),
  complementAdresse2Etablissement VARCHAR(50),
  numeroVoie2Etablissement VARCHAR(50),
  indiceRepetition2Etablissement VARCHAR(50),
  typeVoie2Etablissement VARCHAR(50),
  libelleVoie2Etablissement VARCHAR(50),
  codePostal2Etablissement VARCHAR(50),
  libelleCommune2Etablissement VARCHAR(50),
  libelleCommuneEtranger2Etablissement VARCHAR(50),
  distributionSpeciale2Etablissement VARCHAR(50),
  codeCommune2Etablissement VARCHAR(50),
  codeCedex2Etablissement VARCHAR(50),
  libelleCedex2Etablissement VARCHAR(50),
  codePaysEtranger2Etablissement VARCHAR(50),
  libellePaysEtranger2Etablissement VARCHAR(50),
  dateDebut VARCHAR(50),
  etatAdministratifEtablissement VARCHAR(50),
  enseigne1Etablissement VARCHAR(50),
  enseigne2Etablissement VARCHAR(50),
  enseigne3Etablissement VARCHAR(50),
  denominationUsuelleEtablissement VARCHAR(200),
  activitePrincipaleEtablissement VARCHAR(50),
  nomenclatureActivitePrincipaleEtablissement VARCHAR(50),
  caractereEmployeurEtablissement VARCHAR(50)
);

\qecho 'Starting stock import...'
\COPY etablissements FROM 'stocks/StockEtablissement_previous.csv' DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE tmp_daily_update AS SELECT * FROM etablissements LIMIT 0;

DO $$
  DECLARE counter INTEGER := 1;
  DECLARE current_day VARCHAR(3);
  DECLARE filename VARCHAR(200);
  DECLARE statement TEXT;
  DECLARE current_directory VARCHAR(100) := '/path/to/your/directory/';
  DECLARE import_result INTEGER;

  BEGIN
    WHILE counter <= 31 LOOP
      RAISE NOTICE 'Importing day %', counter;

      current_day := CONCAT('0', counter);
      current_day := SUBSTRING(current_day, LENGTH(current_day)-1, 2);
      filename := CONCAT(current_directory, 'daily_updates/etablissements/2019-10-', current_day, '.csv');

      statement := CONCAT('COPY tmp_daily_update FROM ''', filename, ''' DELIMITER '','' CSV HEADER');
      EXECUTE statement;

      import_result := (SELECT COUNT(*) FROM tmp_daily_update);

      INSERT INTO etablissements
      SELECT *
      FROM tmp_daily_update
      ON CONFLICT (siret)
      DO UPDATE
      SET (siren, nic, siret, statutDiffusionEtablissement, dateCreationEtablissement, trancheEffectifsEtablissement, anneeEffectifsEtablissement, activitePrincipaleRegistreMetiersEtablissement, dateDernierTraitementEtablissement, etablissementSiege, nombrePeriodesEtablissement, complementAdresseEtablissement, numeroVoieEtablissement, indiceRepetitionEtablissement, typeVoieEtablissement, libelleVoieEtablissement, codePostalEtablissement, libelleCommuneEtablissement, libelleCommuneEtrangerEtablissement, distributionSpecialeEtablissement, codeCommuneEtablissement, codeCedexEtablissement, libelleCedexEtablissement, codePaysEtrangerEtablissement, libellePaysEtrangerEtablissement, complementAdresse2Etablissement, numeroVoie2Etablissement, indiceRepetition2Etablissement, typeVoie2Etablissement, libelleVoie2Etablissement, codePostal2Etablissement, libelleCommune2Etablissement, libelleCommuneEtranger2Etablissement, distributionSpeciale2Etablissement, codeCommune2Etablissement, codeCedex2Etablissement, libelleCedex2Etablissement, codePaysEtranger2Etablissement, libellePaysEtranger2Etablissement, dateDebut, etatAdministratifEtablissement, enseigne1Etablissement, enseigne2Etablissement, enseigne3Etablissement, denominationUsuelleEtablissement, activitePrincipaleEtablissement, nomenclatureActivitePrincipaleEtablissement, caractereEmployeurEtablissement)
      = (EXCLUDED.siren, EXCLUDED.nic, EXCLUDED.siret, EXCLUDED.statutDiffusionEtablissement, EXCLUDED.dateCreationEtablissement, EXCLUDED.trancheEffectifsEtablissement, EXCLUDED.anneeEffectifsEtablissement, EXCLUDED.activitePrincipaleRegistreMetiersEtablissement, EXCLUDED.dateDernierTraitementEtablissement, EXCLUDED.etablissementSiege, EXCLUDED.nombrePeriodesEtablissement, EXCLUDED.complementAdresseEtablissement, EXCLUDED.numeroVoieEtablissement, EXCLUDED.indiceRepetitionEtablissement, EXCLUDED.typeVoieEtablissement, EXCLUDED.libelleVoieEtablissement, EXCLUDED.codePostalEtablissement, EXCLUDED.libelleCommuneEtablissement, EXCLUDED.libelleCommuneEtrangerEtablissement, EXCLUDED.distributionSpecialeEtablissement, EXCLUDED.codeCommuneEtablissement, EXCLUDED.codeCedexEtablissement, EXCLUDED.libelleCedexEtablissement, EXCLUDED.codePaysEtrangerEtablissement, EXCLUDED.libellePaysEtrangerEtablissement, EXCLUDED.complementAdresse2Etablissement, EXCLUDED.numeroVoie2Etablissement, EXCLUDED.indiceRepetition2Etablissement, EXCLUDED.typeVoie2Etablissement, EXCLUDED.libelleVoie2Etablissement, EXCLUDED.codePostal2Etablissement, EXCLUDED.libelleCommune2Etablissement, EXCLUDED.libelleCommuneEtranger2Etablissement, EXCLUDED.distributionSpeciale2Etablissement, EXCLUDED.codeCommune2Etablissement, EXCLUDED.codeCedex2Etablissement, EXCLUDED.libelleCedex2Etablissement, EXCLUDED.codePaysEtranger2Etablissement, EXCLUDED.libellePaysEtranger2Etablissement, EXCLUDED.dateDebut, EXCLUDED.etatAdministratifEtablissement, EXCLUDED.enseigne1Etablissement, EXCLUDED.enseigne2Etablissement, EXCLUDED.enseigne3Etablissement, EXCLUDED.denominationUsuelleEtablissement, EXCLUDED.activitePrincipaleEtablissement, EXCLUDED.nomenclatureActivitePrincipaleEtablissement, EXCLUDED.caractereEmployeurEtablissement);

      RAISE NOTICE 'Day % imported (% rows)', counter, import_result;
      TRUNCATE TABLE tmp_daily_update;
      counter := counter + 1;
  END LOOP;
END $$;

\qecho 'Starting export...'
\COPY etablissements TO 'stocks_generated/Etablissements.csv' DELIMITER ',' CSV HEADER;

\c template1;
DROP DATABASE tmp_insee_daily_update;
