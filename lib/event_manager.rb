require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'


#Método de formatação do cep para jeito certo
def clean_cep(cep)
  cep.to_s.rjust(5,'0')[0..4]
end



#Método de acesso a API que faz a validação do cep e mostra os representantes
def legislators_by_cep(cep)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  #aqui estamos puxando o CEP/ZIPCODE e o estado
  begin
    civic_info.representative_info_by_address(
      address: cep,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
    #caso dê erro:
  rescue
    'Search your representatives'
  end
end


def thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_letter_#{id}.html"

  File.open(filename, 'w') do |f|
    f.puts form_letter
  end
end


puts "Event Manager Initialized!"

#Lendo a o padrão de página
template_letter = File.read('form_letter.erb')

#apropriando arquivo erb
erb_template = ERB.new template_letter

#abrindo o Arquivo CSV, headers = cabeçalho, convertendo para símbolos
contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)

#percorrendo cada linha do arquivo CSV
contents.each do |linha|
  id = linha[0]
  name = linha[:first_name]
  cep = clean_cep(linha[:zipcode])

  legislators = legislators_by_cep(cep)

  form_letter = erb_template.result(binding)

  thank_you_letter(id, form_letter)
end
