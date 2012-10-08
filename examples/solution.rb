require "rubygems"
require "mandy"

module Enumerable
  alias_method :ewo, :each_with_object
end

Mandy.job "Word Count" do
  map_tasks 5
  reduce_tasks 3
  
  map do |line|
    
    line.gsub(/\W|[0-9]/, '').downcase.split.ewo(Hash.new(0)) do |word, dict|
      dict[word] += 1
    end.each do |word, count| 
      emit(word, count) 
    end.tap do |words|
      increment_counter("No, of words processed", words.size)
    end
  end
  
  reduce(Mandy::Reducers::SumReducer)
end