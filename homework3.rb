# normally just requiring mandy through gems is fine.
# we try and load a local version first in this example so that our specs don't use gem files.
if ENV['MANDY_PATH']
  require ENV['MANDY_PATH']
else
  require "rubygems"
  require "mandy"
end

require "./stopwords"

Mandy.local_input = File.join(File.dirname(__FILE__), 'input.txt')

# a job can consist of a map block, a reduce block or both along with some configuration options.
# this job counts words in the input document.
Mandy.job "Author-term maping" do
  map_tasks 5
  reduce_tasks 3
  
  map do |value|
    
    update_status("Processing line: #{value}")

    authors = value.scan(/(?<=::)[^:].*?(?=::)/)
    # find terms in a string
    terms = value.scan(/(?!.*:).+/).downcase.gsub(/\W|[0-9]|\ba\b|-/, ' ').split
    # delete stop words
    terms -= $stop_words

    # hash = { author1 => { term1 => count, term2 => count }, author2 => {...}, ...}
    # h_* means that this variable has hash structure
    authors.each_with_object(Hash.new{|h,k|h[k]=Hash.new(0)}) do |author, hash| 

      terms.each { |term| hash[author][term] += 1 }

    end.each do |author, h_terms|

      h_terms.each { |term, count| emit( author, "#{term}:#{count}") }

    end
  end
  
  reduce do |author, h_terms|

    h_terms.each_with_object(Hash.new(0)) do |h_term, hash|

      term, count = h_term.split(':')
      hash[term] += count.to_i

    end.sort_by{ |_,count| -count }.each do |term, count|

      emit( author, "#{term}:#{count}")

    end
  end
end

