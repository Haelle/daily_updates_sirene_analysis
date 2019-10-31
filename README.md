Attempt to re-create SIRENE daily updates from INSEE API (https://api.insee.fr/)
And result analysis to compare with provided stocks

0. download the 4 stocks from data.gouv.fr for 2 months (2 stocks per month Etablissements/Unites Legales)
1. run `fetch_daily_updates_to_csv.rb` : generates daily updates CSV files for each day from INSEE API
2. run `generate_stock_from_daily_updates.rb` : generate stocks from previous stock + all daily updates
3. run `sort_stocks.rb` : in order to easly compare stocks sort them
4. run `compare_stocks.rb` : compare files and generate HTML differences
