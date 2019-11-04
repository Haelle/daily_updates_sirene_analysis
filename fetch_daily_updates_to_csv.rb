require 'date'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'csv'
require 'pry'

# parameters ; it will generate csv files 'from' to 'to'
from = Date.parse '2019/10/1'
to   = Date.parse '2019/11/1' # excluded

# constants
NB_MAX = 1_000
@base_url = 'https://api.insee.fr/entreprises/sirene/V3/'
@token = File.read('.token').delete("\n")
@time_format = '%Y-%m-%dT%H:%H:%S' # "2019-06-01T00:00:00"

# headers are exacted from the stock file to make sure generated one's have the same headers
@csv_header_unite_legale = %i(siren statutDiffusionUniteLegale unitePurgeeUniteLegale dateCreationUniteLegale sigleUniteLegale sexeUniteLegale prenom1UniteLegale prenom2UniteLegale prenom3UniteLegale prenom4UniteLegale prenomUsuelUniteLegale pseudonymeUniteLegale identifiantAssociationUniteLegale trancheEffectifsUniteLegale anneeEffectifsUniteLegale dateDernierTraitementUniteLegale nombrePeriodesUniteLegale categorieEntreprise anneeCategorieEntreprise dateDebut etatAdministratifUniteLegale nomUniteLegale nomUsageUniteLegale denominationUniteLegale denominationUsuelle1UniteLegale denominationUsuelle2UniteLegale denominationUsuelle3UniteLegale categorieJuridiqueUniteLegale activitePrincipaleUniteLegale nomenclatureActivitePrincipaleUniteLegale nicSiegeUniteLegale economieSocialeSolidaireUniteLegale caractereEmployeurUniteLegale)
@csv_header_etablissement = %i(siren nic siret statutDiffusionEtablissement dateCreationEtablissement trancheEffectifsEtablissement anneeEffectifsEtablissement activitePrincipaleRegistreMetiersEtablissement dateDernierTraitementEtablissement etablissementSiege nombrePeriodesEtablissement complementAdresseEtablissement numeroVoieEtablissement indiceRepetitionEtablissement typeVoieEtablissement libelleVoieEtablissement codePostalEtablissement libelleCommuneEtablissement libelleCommuneEtrangerEtablissement distributionSpecialeEtablissement codeCommuneEtablissement codeCedexEtablissement libelleCedexEtablissement codePaysEtrangerEtablissement libellePaysEtrangerEtablissement complementAdresse2Etablissement numeroVoie2Etablissement indiceRepetition2Etablissement typeVoie2Etablissement libelleVoie2Etablissement codePostal2Etablissement libelleCommune2Etablissement libelleCommuneEtranger2Etablissement distributionSpeciale2Etablissement codeCommune2Etablissement codeCedex2Etablissement libelleCedex2Etablissement codePaysEtranger2Etablissement libellePaysEtranger2Etablissement dateDebut etatAdministratifEtablissement enseigne1Etablissement enseigne2Etablissement enseigne3Etablissement denominationUsuelleEtablissement activitePrincipaleEtablissement nomenclatureActivitePrincipaleEtablissement caractereEmployeurEtablissement)

def build_url(route:, query_hash:)
  url = URI(@base_url + route.to_s)
  query = URI.encode_www_form query_hash
  url.query = query
  url
end

def perform_query(route:, query_hash:)
  url_with_cursor = build_url(route: route, query_hash: query_hash)

  http = Net::HTTP.new(url_with_cursor.host, url_with_cursor.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url_with_cursor)
  request['authorization'] = "Bearer #{@token}"

  response = http.request(request)
  body = JSON.parse response.read_body, symbolize_names: true
  header = body[:header]

  [header, body]
end

def end_reached?(header)
  header[:curseur] == header[:curseurSuivant]
end

def fetch_one_day(current_day:, route:, filter_name:)
  # init loop
  count = 0
  today = current_day.strftime @time_format
  tomorrow = current_day.next_day.strftime @time_format
  query_hash = { nombre: NB_MAX, curseur: '*', q: '' }

  puts "Day: #{today}"
  loop do
    # update query params
    query_hash[:q] = "#{filter_name}:[#{today} TO #{tomorrow}]"

    # perform for today
    header, body = perform_query(route: route, query_hash: query_hash)

    # log progress
    count += header[:nombre]
    puts "#{(count.to_f / header[:total]*100).round(2)} (#{count}/#{header[:total]})"

    # save values
    yield body

    break if end_reached?(header)

    # update for next loop
    query_hash[:curseur] = header[:curseurSuivant]
  end

  puts "#{today} Finished"
end

def fetch_unites_legales(current_day:)
  filename = "daily_updates/unites_legales/#{current_day}.csv"

  if File.exist?(filename)
    puts "Ignoring #{current_day} for Unites Legales"
    return
  else
    puts "Starting #{current_day} for Unites Legales"
  end

  File.open(filename, 'w') { |f| f.puts @csv_header_unite_legale.to_csv }

  params = {
    current_day: current_day,
    route: :siren,
    filter_name: 'dateDernierTraitementUniteLegale'
  }

  fetch_one_day(params) do |body|
    File.open(filename, 'a') do |f|
      body[:unitesLegales].each do |elt|
        last_period = elt[:periodesUniteLegale].first
        elt.delete(:periodesUniteLegale)
        elt.merge!(last_period)

        csv_data = @csv_header_unite_legale.map { |h| elt[h] }.to_csv
        f.puts csv_data
      end
    end
  end
end

def fetch_etablissements(current_day:)
  filename = "daily_updates/etablissements/#{current_day}.csv"

  if File.exist?(filename)
    puts "Ignoring #{current_day} for Etablissements"
    return
  else
    puts "Starting #{current_day} for Etablissements"
  end

  File.open(filename, 'w') { |f| f.puts @csv_header_etablissement.to_csv }

  params = {
    current_day: current_day,
    route: :siret,
    filter_name: 'dateDernierTraitementEtablissement'
  }

  fetch_one_day(params) do |body|
    File.open(filename, 'a') do |f|
      body[:etablissements].each do |elt|
        last_period = elt[:periodesEtablissement].first
        elt.delete(:periodesEtablissement)
        elt.merge!(last_period)

        adresse = elt[:adresseEtablissement]
        elt.delete(:adresseEtablissement)
        elt.merge!(adresse)

        adresse2 = elt[:adresse2Etablissement]
        elt.delete(:adresse2Etablissement)
        elt.merge!(adresse2)

        csv_data = @csv_header_etablissement.map { |h| elt[h] }.to_csv
        f.puts csv_data
      end
    end
  end
end

# perform
day = from
loop do
  fetch_unites_legales(current_day: day)
  fetch_etablissements(current_day: day)
  day = day.next_day
  break if day == to
end
