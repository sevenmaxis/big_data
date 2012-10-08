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
    # { author1 => { term1 => count, term2 => count }, author2 => { ... }, ... }
    hash = Hash.new{ |h,k| h[k] = Hash.new(0) }
    
    update_status("Processing line: #{value}")

    authors = value.scan(/(?<=::)[^:].*?(?=::)/)
    terms = value.match(/.*:::(.*)/)[1].downcase.gsub(/\W|[0-9]|\ba\b|-/, ' ').split

    # delete stop words from list of terms
    terms -= $stop_words

    authors.each do |author| 
      terms.each do |term|       
        #increment_counter("Author #{author} processed",  "The term #{term} processed")
        hash[author][term] += 1
      end
    end

    # h_ means this variable has hash structure
    hash.each do |author, h_term|
      h_term.each do |term, count|
        emit( author, "#{term}:#{count}")
      end
    end
  end
  
  reduce do |author, h_terms|

    hash = Hash.new(0)

    h_terms.each do |h_term|
      term, count = h_term.split(':')
      hash[term] += count.to_i
    end

    hash.sort_by{ |_,count| -count }.each do |term, count|
      emit( author, "#{term}:#{count}")
    end
  end
end

