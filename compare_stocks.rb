require 'diffy'
require 'pry'
require 'whirly'
require 'paint'

# Diffy fails to compare the full file (memory issue)
# and it also make comparison painful with bigger reports
# so the files are truncated to:
@size = 2_000_000

def compare(filename, generated_file, origina_file)
  diff =  Diffy::Diff.new(
    origina_file,
    generated_file,
    source: 'files',
    include_plus_and_minus_in_html: true,
    ignore_crlf: true
  )

  File.write(filename, diff.to_s(:html))

  append_css(filename)
  remove_unchanged(filename)
end

def append_css(filename)
  File.open(filename, 'a') do |f|
    f.write '<style>'
    f.write Diffy::CSS
    f.write '.unchanged {display:none !important;}'
    f.write '</style>'
  end
end

def remove_unchanged(filename)
  `sed -i '/class="unchanged"/d' #{filename}`
end

def shorten_file(full, shortened)
  `head #{full} -n #{@size} > #{shortened}`
end

# perform
Whirly.configure spinner: "dots"

# compare Unites Legales
generated_unites_legales_full = './stocks_generated/UnitesLegales_sorted.csv'
generated_unites_legales_shortened = './tmp/unite_generated_short.csv'

original_unites_legales_full = './stocks/StockUniteLegale_latest.csv'
original_unites_legales_shortened = './tmp/unite_original_short.csv'

Whirly.start do
  Whirly.status = 'Shorten stocks: UnitesLegales'
  shorten_file(generated_unites_legales_full, generated_unites_legales_shortened)
  shorten_file(original_unites_legales_full,  original_unites_legales_shortened)
end

Whirly.start do
  Whirly.status = 'Compare stocks UnitesLegales'
  filename_unites_legales = './reports/report_unites_legales.html'
  compare(
    filename_unites_legales,
    generated_unites_legales_shortened,
    original_unites_legales_shortened
  )
end

# compare Etablissements
generated_etablissements_full = './stocks_generated/Etablissements_sorted.csv'
generated_etablissements_shortened = './tmp/etab_generated_short.csv'

original_etablissements_full = './stocks/StockEtablissement_latest.csv'
original_etablissements_shortened = './tmp/etab_original_short.csv'

Whirly.start do
  Whirly.status = 'Shorten stocks: Etablissements'
  shorten_file(generated_etablissements_full, generated_etablissements_shortened)
  shorten_file(original_etablissements_full, original_etablissements_shortened)
end

Whirly.start do
  Whirly.status = 'Compare stocks Etablissements'
  filename_etablissements = './reports/report_etablissements.html'
  compare(
    filename_etablissements,
    generated_etablissements_shortened,
    original_etablissements_shortened
  )
end
