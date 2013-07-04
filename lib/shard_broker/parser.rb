module ShardBroker
  module Parser

    def prepare_parser
      @formatter        = ShardBroker.env == :development ? REXML::Formatters::Transitive.new : REXML::Formatters::Default.new
      @parser           = REXML::Parsers::SAX2Parser.new('')
      @current_node     = nil
      @xml_stream_start = false

      @parser.listen(:start_element) do |uri, localname, qname, attributes|
        node = nil
        if qname == ProtocolTags::SESSION_TAG
          node = nil
        elsif qname == ShardBroker::Action::TAG
          node = ShardBroker::Action.new
        elsif qname == ShardBroker::Response::TAG
          node = ShardBroker::Response.new
        else
          node = ShardBroker::Node.new(qname)
        end

        if node
          node.add_attributes(attributes)
          @current_node = @current_node.nil? ? node : @current_node.add_element(node)
        end
      end

      @parser.listen(:end_element) do |uri, localname, qname|
        if qname == ProtocolTags::SESSION_TAG
          ShardBroker.logger.info "Recived session finish tag"
          close
        elsif !@current_node.nil? 
          if @current_node.parent.nil?
            if @current_node.haveValidId?
              runStateWith(@current_node)
            else
              write_error(ShardBroker::Status::NO_ID_ATTRIBUTE)
            end
            @current_node = nil
          else
            @current_node = @current_node.parent
          end
        else
          write_error(ShardBroker::Status::PARSER_ERROR)
          close
        end
      end

      @parser.listen(:characters) do |text|
        if @current_node
          rtx = REXML::Text.new(text.to_s, @current_node.whitespace, nil, true)
          @current_node.add(rtx)
        end
      end

      @parser.listen(:cdata) do |text|
        @current_node.add(REXML::CData.new(text)) if @current_node
      end
    end

    def read(content)
      @parser.source.buffer << content
      begin
        @parser.parse
      rescue REXML::ParseException => e
        write_error ShardBroker::Status::PARSER_ERROR, e
      rescue Encoding::CompatibilityError => e
        write_error ShardBroker::Status::PARSER_ERROR, e
      end
    end

    def write(content)
      out = ""
      if content.kind_of?(REXML::Element)
        @formatter.write(content, out)
      else
        out = content
      end
      if ShardBroker.env == :development
        out.each_line do |line|
          ShardBroker.logger.debug line.gsub("\n", "").green 
        end
      end
      self.send_data(out)
    end

  end
end