# A small helper class to assist with the generation of audio files for submission within the demo.
# Uses a cache of 16-bit little-endian audio files representing digits 0 through 9 to build the phrases.
class AudioHelper
  
  AUDIO_FILE_PATH = "Speech/"
  AUDIO_FILE_EXTENSION = ".wav"
  
  @cache
  
  # We want to pre-load all the digit audio files to speed things up
  def initialize
    @cache = {}
    # ('0'..'9').each do |c|
    #   @cache[c] = open(File.join(AUDIO_FILE_PATH, c + AUDIO_FILE_EXTENSION), "rb") { |io| io.read }
    # end
  end

  # Helper function to concatenate digit-level audio files into an n-digit speech sample representing the supplied prompt
  def generate_speech_from_prompt prompt
    puts "inside prompt"
    puts prompt
    output = []
    prompt.each_char do |c|
      output << @cache[c]
    end
    return output.join
  end
  
end