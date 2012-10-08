# single letter words, such as "a" can be ignored; also hyphens can be ignored 
# (i.e. deleted). Lastly, periods, commas, etc. need to be ignored; 
# in other words, only alphabets and numbers can be part of a title term: 
# Thus, “program” and “program.” should both be counted as the term ‘program’, 
# and "map-reduce" should be taken as 'map reduce'. Note: You do not need to do 
# stemming, i.e. "algorithm" and "algorithms" can be treated as separate terms.

ignorable = [ 'a', '-', ',', '.']