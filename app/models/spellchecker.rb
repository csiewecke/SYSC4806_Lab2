require 'set'

class Spellchecker

  attr_accessor :dictionary
  ALPHABET = 'abcdefghijklmnopqrstuvwxyz'

  #constructor.
  #text_file_name is the path to a local file with text to train the model (find actual words and their #frequency)
  #verbose is a flag to show traces of what's going on (useful for large files)
  def initialize(text_file_name)
    #read file text_file_name
    dictionaryString = ''
    File.open(text_file_name, 'r') do |f|
      dictionaryString += f.each_line.to_a.join ' '
    end
    #extract words from string (file contents) using method 'words' below.
    
    #put in dictionary with their frequency (calling train! method)
    train!(words(dictionaryString))
  end
  
  #returns an array of words in the text.
  def words (text)
    return text.downcase.scan(/[a-z]+/) #find all matches of this simple regular expression
  end

  #train model (create dictionary)
  def train!(word_list)
    #create @dictionary, an attribute of type Hash mapping words to their count in the text {word => count}. Default count should be 0 (argument of Hash constructor).
    self.dictionary = Hash.new(0)
    word_list.each{|a| @dictionary[a] += 1}
  end

  #lookup frequency of a word, a simple lookup in the @dictionary Hash
  def lookup(word)
    self.dictionary[word]
  end
  
  #generate all correction candidates at an edit distance of 1 from the input word.
  def edits1(word)
    
    deletes = []
    #all strings obtained by deleting a letter (each letter)
    i = 0
    while i < word.length do #deletes
      deletes.push(word[0...i] + word [i+1..-1])
      i += 1
    end
    
    transposes = []
    #all strings obtained by switching two consecutive letters
    i = 0
    while i < word.length-1  do #transposes
      string = word.split('')
      string[i], string[i+1] = string[i+1], string[i]
      transposes.push(string.join(''))
      i += 1
    end
    
    inserts = []
    # all strings obtained by inserting letters (all possible letters in all possible positions)
    i = 0
    while i < word.length + 1 do #inserts
      ALPHABET.split('').each do |letter|
        inserts.push(word[0...i] + letter + word[i..-1])
      end
    i+= 1
    end

    replaces = []
    #all strings obtained by replacing letters (all possible letters in all possible positions)
    i = 0
    while i < word.length do #replaces
      ALPHABET.split("").each do |letter|
        replaces.push(word[0...i] + letter + word[i+1..-1])
      end
      i+= 1
    end

    return (deletes + transposes + replaces + inserts).to_set.to_a #eliminate duplicates, then convert back to array
  end
  

  # find known (in dictionary) distance-2 edits of target word.
  def known_edits2 (word)
    # get every possible distance - 2 edit of the input word. Return those that are in the dictionary.
    edits2Array = []
    edits1Array = edits1(word)
    edits1Array.each {|edits1Word| edits2Array += edits1(edits1Word)}
    known(edits2Array)
  end

  #return subset of the input words (argument is an array) that are known by this dictionary
  def known(words)
    return words.find_all {|word| dictionary.key?(word) } #find all words for which condition is true,
                                    #you need to figure out this condition
    
  end


  # if word is known, then
  # returns [word], 
  # else if there are valid distance-1 replacements, 
  # returns distance-1 replacements sorted by descending frequency in the model
  # else if there are valid distance-2 replacements,
  # returns distance-2 replacements sorted by descending frequency in the model
  # else returns nil
  def correct(word)
    distance1 = known(edits1(word))
    distance1 = distance1.sort_by{|value| @dictionary[value]}.reverse
    distance2 = known_edits2(word)
    distance2 = distance2.sort_by{|value| (@dictionary[value])}.reverse.uniq  
    if (dictionary.key?(word))
      return [word]
    elsif (distance1.any?)
      return distance1
    elsif (distance2.any?)
      return distance2
    else
      return nil
    end
  end
    
  
end

