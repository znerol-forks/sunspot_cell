module Sunspot

  class RichDocument < RSolr::Xml::Document
    def contains_attachment?
      @fields.each do |field|
        if field.name.to_s.include?("_attachment") && field.value.present?
          return true
        end
      end
      return false
    end

    def add(connection)
      params = {
        :wt => :ruby
      }

      data = nil
      id = ""
      file_name = ""

      @fields.each do |f|
        if f.name.to_s.include?("_attachment") and f.value.present?
          params['fmap.content'] = f.name
          if f.value.is_a?(Hash)
            params['stream.url']         = f.value[:file]
            params['stream.contentType'] = f.value[:type]
          else
            data = open(f.value).read rescue ""
          end
        else
          id = f.value if f.name.to_s == "id"
          file_name = f.value if f.name.to_s == "name_text"
          param_name = "literal.#{f.name.to_s}"
          puts({ param_name: param_name, value: f.value })
          params[param_name] = [] unless params.has_key?(param_name)
          params[param_name] << f.value
        end
        if f.attrs[:boost]
          params["boost.#{f.name.to_s}"] = f.attrs[:boost]
        end
      end

      connection.send_and_receive('update/extract',
        { :method => :post,
          :params => params,
          :data => data,
          :headers => {"Content-Type" => ""}
        })
    rescue
      puts "Could not index file #{id} (#{file_name})"
    end
  end
end
