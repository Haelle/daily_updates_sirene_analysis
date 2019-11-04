Attempt to re-create SIRENE daily updates from INSEE API (https://api.insee.fr/) for october 2019.

There are a lot of manuals operations ; and it generates [result analysis](#bilans) to compare with stocks provided by INSEE.

Ruby & PostgreSQL are mandatory.

# 1. Setup & downloads
From [SIRENE page on data.gouv.fr](https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret/) download :

- Fichier StockEtablissement du 01 XXX 20XX
- Fichier StockUniteLegale du 01 XXX 20XX

and also for the next or previous month :

- Fichier StockEtablissement du 01 XXX+1 20XX
- Fichier StockUniteLegale du 01 XXX+1 20XX

Then store & extract them in `/stocks` directory named like this :
- StockEtablissement_previous.csv
- StockEtablissement_latest.csv
- StockUniteLegale_previous.csv
- StockUniteLegale_latest.csv

# 2. Fetch daily updates
run :
```bash
ruby fetch_daily_updates_to_csv.rb
```
it generates daily updates CSV files for each day from INSEE API for établissements and unités légales

# 3. Generate stocks from previous stock + all daily updates
It will create/drop a database so it should be run by a Postgres SUPERUSER.

In both `generate_stock_unites_legales.sql` and `generate_stock_etablissements.sql` :

1. in both files ; update `current_directory` (line 54/59) with your current directory (`pwd`)
2. if you run this script with a SUPERUSER then `stocks_generated` directory should allow everyone to write on it (`chmod 777 -R stocks_generated`)
3. run `psql -v scriptdir="$(pwd)/" -f generate_stock_unites_legales.sql`
4. run `psql -v scriptdir="$(pwd)/" -f generate_stock_etablissements.sql`
5. change back owner if needed ! (`sudo chown you:you -R stocks_generated`)

Previous month stocks + daily updates are generated in `/stocks_generated`.

# 4. Sort all stocks to compare them
run `sort_stocks.rb` : in order to easly compare stocks sort them

# 5. Compare stocks and generated an HTML report
run `compare_stocks.rb` : compare files and generate HTML differences

# Bilans

- quelques timeout sont arrivés lors de la récupération des daily updates (qui peuvent être du au rate limiting)
- les entreprises passant de 'diffusibles' à 'non-diffusibles' et vice et versa rend l'analyse complexe (+9000 entreprises en plus dans le stock généré)
