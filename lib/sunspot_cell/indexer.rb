module SunspotCell
  module Indexer

    def self.included(base)
      base.class_eval do

        def add_documents documents
          documents_arr = Sunspot::Util.Array(documents)
          docs_attach = []
          docs_no_attach = []
          documents_arr.each do |document|
            if document.contains_attachment?
              docs_attach << document
            else
              docs_no_attach << document
            end
          end

          begin
            if !docs_no_attach.empty?
              @connection.add(docs_no_attach)
            end
            if !docs_attach.empty?
              Sunspot::Util.Array(docs_attach).each do |document|
                document.add(@connection)
              end
            end
          rescue Exception => e
            @batch = nil
            raise e
          end
        end

        def prepare_full_update model
          document = document_for_full_update(model)
          setup = setup_for_object(model)
          if boost = setup.document_boost_for(model)
            document.attrs[:boost] = boost
          end
          setup.all_field_factories.each do |field_factory|
            field_factory.populate_document(document, model)
          end
          document
        end

        def document_for_full_update(model)
          Sunspot::RichDocument.new(
            id: Sunspot::Adapters::InstanceAdapter.adapt(model).index_id,
            type: [model.class.name],
            # model: model,
          )
        end

        def document_for_atomic_update(clazz, id)
          if Adapters::InstanceAdapter.for(clazz)
            Sunspot::RichDocument.new(
              id: Sunspot::Adapters::InstanceAdapter.index_id_for(clazz.name, id),
              type: Util.superclasses_for(clazz).map(&:name)
            )
          end
        end

      end
    end
  end
end
