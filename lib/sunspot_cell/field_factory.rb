module SunspotCell
  module FieldFactory

    class Attachment < Sunspot::FieldFactory::Static

      alias :sunspot_populate_document :populate_document unless method_defined?(:sunspot_populate_document)
      def populate_document document, model, options = {}
        sunspot_populate_document document, model
      end

      def extract_value model, options = {}
        if options.has_key?(:value)
          options.delete(:value)
        else
          @data_extractor.value_for(model)
        end
      end
    end

  end
end
