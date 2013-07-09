require 'RMagick'
require 'base64'

module ShardBroker
  class Captcha
    include Magick
    attr_reader :code, :data

    BASE_OPTIONS = {
      :colors => {
        :background => '#FFFFFF',
        :font => '#D35400'
      },
      :dimensions => {
        :height => 64,
        :width => 220
      },
      :wave => {
        :wavelength => (40..70),
        :amplitude => 3
      },
      :implode => 0.2,
      :letters => {
        :baseline => 42,
        :count => 6,
        :ignore => ['a','e','i','o','u','l','j','q','v'],
        :points => 64,
        :width => 34
      },
      :ttf => File.expand_path("#{File.dirname(__FILE__)}/../../assets/captcha.ttf"),
    }

    def generate!
      o = BASE_OPTIONS
      generate_code(o)
      canvas = Magick::Image.new(o[:dimensions][:width], o[:dimensions][:height])
      canvas.background_color = o[:colors][:background]
    
      text           = Magick::Draw.new
      text.font      = File.expand_path o[:ttf]
      text.pointsize = o[:letters][:points]

      cur = 0
      @code.each do |c|
        text.annotate(canvas, o[:letters][:width], o[:letters][:points], cur, o[:letters][:baseline], c) {
          self.fill = o[:colors][:font]
        }
        cur += o[:letters][:width]
      end
      
      w       = o[:wave][:wavelength]
      canvas  = canvas.wave(o[:wave][:amplitude], rand(w.last - w.first) + w.first)
      canvas  = canvas.implode(o[:implode])
      
      @code   = @code.join("")
      @data   = canvas.to_blob { self.format = "JPEG" }
      canvas.destroy!
    end
    
    def data64
      Base64.encode64(self.data).gsub(/\n/, '')
    end

    def dataUrl
      "data:image/jpeg;base64,"+data64
    end

    private

    def generate_code(o)
      chars = ('a'..'z').to_a - o[:letters][:ignore]
      chars += (0..9).to_a.map(&:to_s)
      chars.flatten!
      @code = []
      1.upto(o[:letters][:count]) do
        @code << chars[rand(chars.length)]
      end
    end
  end
end