\cd :scriptdir;
\qecho 'Using scriptdir:' :scriptdir
CREATE DATABASE tmp_insee_daily_update;
\c tmp_insee_daily_update;

DROP TABLE unites_legales;
CREATE TABLE unites_legales
(
  siren VARCHAR(50) PRIMARY KEY,
  statutDiffusionUniteLegale VARCHAR(50),
  unitePurgeeUniteLegale VARCHAR(50),
  dateCreationUniteLegale VARCHAR(50),
  sigleUniteLegale VARCHAR(50),
  sexeUniteLegale VARCHAR(50),
  prenom1UniteLegale VARCHAR(50),
  prenom2UniteLegale VARCHAR(50),
  prenom3UniteLegale VARCHAR(50),
  prenom4UniteLegale VARCHAR(50),
  prenomUsuelUniteLegale VARCHAR(50),
  pseudonymeUniteLegale VARCHAR(100),
  identifiantAssociationUniteLegale VARCHAR(50),
  trancheEffectifsUniteLegale VARCHAR(50),
  anneeEffectifsUniteLegale VARCHAR(50),
  dateDernierTraitementUniteLegale VARCHAR(50),
  nombrePeriodesUniteLegale VARCHAR(50),
  categorieEntreprise VARCHAR(50),
  anneeCategorieEntreprise VARCHAR(50),
  dateDebut VARCHAR(50),
  etatAdministratifUniteLegale VARCHAR(50),
  nomUniteLegale VARCHAR(100),
  nomUsageUniteLegale VARCHAR(100),
  denominationUniteLegale VARCHAR(200),
  denominationUsuelle1UniteLegale VARCHAR(200),
  denominationUsuelle2UniteLegale VARCHAR(200),
  denominationUsuelle3UniteLegale VARCHAR(200),
  categorieJuridiqueUniteLegale VARCHAR(50),
  activitePrincipaleUniteLegale VARCHAR(50),
  nomenclatureActivitePrincipaleUniteLegale VARCHAR(50),
  nicSiegeUniteLegale VARCHAR(50),
  economieSocialeSolidaireUniteLegale VARCHAR(50),
  caractereEmployeurUniteLegale VARCHAR(50)
);

\qecho 'Starting stock import...'
\COPY unites_legales FROM 'stocks/StockUniteLegale_previous.csv' DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE tmp_daily_update AS SELECT * FROM unites_legales LIMIT 0;

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
      filename := CONCAT(current_directory, 'daily_updates/unites_legales/2019-10-', current_day, '.csv');

      statement := CONCAT('COPY tmp_daily_update FROM ''', filename, ''' DELIMITER '','' CSV HEADER');
      EXECUTE statement;

      import_result := (SELECT COUNT(*) FROM tmp_daily_update);

      INSERT INTO unites_legales
      SELECT *
      FROM tmp_daily_update
      ON CONFLICT (siren)
      DO UPDATE
      SET (siren, statutDiffusionUniteLegale, unitePurgeeUniteLegale, dateCreationUniteLegale, sigleUniteLegale, sexeUniteLegale, prenom1UniteLegale, prenom2UniteLegale, prenom3UniteLegale, prenom4UniteLegale, prenomUsuelUniteLegale, pseudonymeUniteLegale, identifiantAssociationUniteLegale, trancheEffectifsUniteLegale, anneeEffectifsUniteLegale, dateDernierTraitementUniteLegale, nombrePeriodesUniteLegale, categorieEntreprise, anneeCategorieEntreprise, dateDebut, etatAdministratifUniteLegale, nomUniteLegale, nomUsageUniteLegale, denominationUniteLegale, denominationUsuelle1UniteLegale, denominationUsuelle2UniteLegale, denominationUsuelle3UniteLegale, categorieJuridiqueUniteLegale, activitePrincipaleUniteLegale, nomenclatureActivitePrincipaleUniteLegale, nicSiegeUniteLegale, economieSocialeSolidaireUniteLegale, caractereEmployeurUniteLegale)
        = (EXCLUDED.siren, EXCLUDED.statutDiffusionUniteLegale, EXCLUDED.unitePurgeeUniteLegale, EXCLUDED.dateCreationUniteLegale, EXCLUDED.sigleUniteLegale, EXCLUDED.sexeUniteLegale, EXCLUDED.prenom1UniteLegale, EXCLUDED.prenom2UniteLegale, EXCLUDED.prenom3UniteLegale, EXCLUDED.prenom4UniteLegale, EXCLUDED.prenomUsuelUniteLegale, EXCLUDED.pseudonymeUniteLegale, EXCLUDED.identifiantAssociationUniteLegale, EXCLUDED.trancheEffectifsUniteLegale, EXCLUDED.anneeEffectifsUniteLegale, EXCLUDED.dateDernierTraitementUniteLegale, EXCLUDED.nombrePeriodesUniteLegale, EXCLUDED.categorieEntreprise, EXCLUDED.anneeCategorieEntreprise, EXCLUDED.dateDebut, EXCLUDED.etatAdministratifUniteLegale, EXCLUDED.nomUniteLegale, EXCLUDED.nomUsageUniteLegale, EXCLUDED.denominationUniteLegale, EXCLUDED.denominationUsuelle1UniteLegale, EXCLUDED.denominationUsuelle2UniteLegale, EXCLUDED.denominationUsuelle3UniteLegale, EXCLUDED.categorieJuridiqueUniteLegale, EXCLUDED.activitePrincipaleUniteLegale, EXCLUDED.nomenclatureActivitePrincipaleUniteLegale, EXCLUDED.nicSiegeUniteLegale, EXCLUDED.economieSocialeSolidaireUniteLegale, EXCLUDED.caractereEmployeurUniteLegale);

      RAISE NOTICE 'Day % imported (% rows)', counter, import_result;
      TRUNCATE TABLE tmp_daily_update;
      counter := counter + 1;
  END LOOP;
END $$;

\qecho 'Starting export...'
\COPY unites_legales TO 'stocks_generated/UnitesLegales.csv' DELIMITER ',' CSV HEADER;

\c template1;
DROP DATABASE tmp_insee_daily_update;
