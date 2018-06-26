module SunspotCell
  module FieldFactory

    class Attachment < Sunspot::FieldFactory::Static

      alias :sunspot_populate_document :populate_document unless method_defined?(:sunspot_populate_document)
      def populate_document document, model, options = {}
        sunspot_populate_document document, model
      end

    end

  end
end
