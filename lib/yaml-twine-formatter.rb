require 'yaml'

module Twine
  module Formatters
    class Yaml < Abstract
      def format_name
        'yaml'
      end

      def extension
        '.yml'
      end

      def can_handle_directory?(path)
        false
      end

      def default_file_name
        'strings.yml'
      end

      def format_header(lang)
        "# YAML\n# Generated by Twine #{Twine::VERSION}\n# Language: #{lang}\n"
      end

      def format_sections(twine_file, lang)
        sections = get_key_value_table(twine_file.sections, lang)
        YAML.dump(sections)
      end
      
      def get_key_value_table(sections, lang)
        table = {}
        
        sections.each do |section|
          section.definitions.each do |definition|
          	next unless definition.translations.include? lang
            table["[[#{section.name}]].[#{definition.key}]"] = definition.translations[lang]
          end
        end
        
        table
      end
      
      def read(io, lang)
        entries = YAML.load(io)
        entries.each do |key, value|
          tokens = /\[\[(.*)?\]\]\.\[(.*)\]/.match(key)
          section = tokens[1]
          def_key = tokens[2]
          set_translation_in_section(section, def_key, lang, value)
        end
      end
      
      def set_translation_in_section(section, key, lang, value)
        value = value.gsub("\n", "\\n")

        if @twine_file.definitions_by_key.include?(key)
          definition = @twine_file.definitions_by_key[key]
          reference = @twine_file.definitions_by_key[definition.reference_key] if definition.reference_key
          
          ref_section = nil
          @twine_file.sections.each do |s|
            if s.definitions.find { |d| d.key == key }
              ref_section = s
              break
            end
          end
          
          if !ref_section or ref_section.name != section
            ref_section_name = (ref_section && ref_section.name) or ""
            Twine::stdout.puts "WARNING: '#{key}' in section [[#{section}]] found in different section [[#{ref_section_name}]]. Translation not written."
          elsif !reference or value != reference.translations[lang]
            definition.translations[lang] = value
          end
        elsif @options[:consume_all]
          Twine::stdout.puts "Adding new definition '#{key}' in section [[#{section}]] to twine file."
          current_section = @twine_file.sections.find { |s| s.name == section }
          unless current_section
            current_section = TwineSection.new(section)
            @twine_file.sections.insert(0, current_section)
          end
          current_definition = TwineDefinition.new(key)
          current_section.definitions << current_definition
          
          if @options[:tags] && @options[:tags].length > 0
            current_definition.tags = @options[:tags]            
          end
          
          @twine_file.definitions_by_key[key] = current_definition
          @twine_file.definitions_by_key[key].translations[lang] = value
        else
          Twine::stdout.puts "WARNING: '#{key}' not found in twine file."
        end

        if !@twine_file.language_codes.include?(lang)
          @twine_file.add_language_code(lang)
        end
      end
    end
  end
end

Twine::Formatters.formatters << Twine::Formatters::Yaml.new
