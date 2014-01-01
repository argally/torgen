require 'fileutils'
require 'optparse'
require 'yaml'
require 'erb'
require 'csv'
require 'rubygems'

$tickers = { }
root = {:hostnames => $tickers}

def parse_yaml(file)
  YAML::load(File.read(file))
end

def csv_convert(csvfile)
  CSV.foreach($file, :headers => true, :header_converters => :symbol, :converters => :all) do |row|
  $tickers[row.fields[0]] = Hash[row.headers[1..-1].zip(row.fields[1..-1])]
  end
end

 # This hash will hold all of the options
 # parsed from the command-line by
 # OptionParser.

options = {}
options[:template] = :tor

 optparse = OptionParser.new do |o|
  o.on('-s', '--silo SILO', "E.g prod.dc1 or nprd.dc1") do |f|
    options[:silo] = f
  end
  o.on('-c', '--csv [CSV]', "CSV file conversion script for template generation") do |f|
    options[:csv] = f
  end
  o.on('-f', '--file FILE', "YAML file containing SW devices to template") do |f|
    options[:file] = f
  end
  o.on('-t', '--template [TEMPLATE]', [:tor, :tor_set, :mgmt_set, :mgmt, :vlan, :generic], "Template type using set or hierarcy Junos wnaset (tor, tor_set, mgmt_set, mgmt, vlan, generic) Default: tor") do |f|
    options[:template] = f
  end
  o.on('-h', '--help') do
    puts o
    exit
  end
end 

begin
  optparse.parse!
   mandatory = [:silo]                                    # Enforce the presence of
   missing = (mandatory.select{ |param| options[param].nil?})     # the -t and -f switches
  if not missing.empty?                                            #
    puts "Missing options: #{missing.join(', ')}"                  #
    puts optparse                                                  #
    exit                                                           #
  end
#end                                                             #
rescue OptionParser::InvalidOption, OptionParser::MissingArgument      #
  puts $!.to_s                                                           # Friendly output when parsing fails
  puts optparse                                                          #
  exit                                                                   #
end  

if (options[:csv])
 $file = (options[:csv])
 csv_convert(options[:csv])
 
 f = File.open("../yaml/#{options[:silo]}-capadd.yaml","w")
 puts "\t Generating YAML SW source file ../yaml/#{options[:silo]}-capadd.yaml"
 puts root.to_yaml
 f.puts root.to_yaml
 f.close
else
 siloinfo = parse_yaml("../site/#{options[:silo]}.wd.yaml")
 switchinfo = parse_yaml(options[:file])
 hostnames = switchinfo[:hostnames]
 template = ERB.new( File.read("../templates/#{options[:template]}.erb"), nil, '-')
  hostnames.each_key do |host|
   if File.exists?"../#{options[:silo]}" 
    File.open "../#{options[:silo]}/#{host}.#{siloinfo[:silo]}.wd.wnaset", "w" do |out| 
    puts "\t Generating ../#{options[:silo]}/#{host}.#{siloinfo[:silo]}.wd.wnaset"  
    out.puts template.result binding
    end
   else
    FileUtils.mkdir_p "../#{options[:silo]}"
    File.open "../#{options[:silo]}/#{host}.#{siloinfo[:silo]}.wd.wnaset", "w" do |out| 
    puts "\t Generating ../#{options[:silo]}/#{host}.#{siloinfo[:silo]}.wd.wnaset"  
    out.puts template.result binding
    end
   end      
end
end


