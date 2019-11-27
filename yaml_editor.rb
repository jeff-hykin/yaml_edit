require 'atk_toolbox'

def indent (string , indentation="    ")
    if indentation.is_a? Numeric
        indentation = ' '*indentation
    end
    string.gsub( /^/, indentation)
end
def unindent (string , indentation="    ")
    if indentation.is_a? Numeric
        indentation = ' '*indentation
    end
    string.gsub( /^#{indentation}/, '')
end

class YAML_EDITOR
    
end

module Psych
    module Nodes
        module Common
            def style_to_s
                style_enums = [ :BLOCK, :FLOW, :ANY, :DOUBLE_QUOTED, :FOLDED, :LITERAL, :PLAIN, :SINGLE_QUOTED, ]
                for each_enum in style_enums
                    if self.class.const_defined?(each_enum)
                        if self.style == self.class.const_get(each_enum)
                            return each_enum
                        end
                    end
                end
                return self.style
            end
        end
        
        class Document
            def to_s
                self.inspect
            end
            def inspect
                output = "[Document]".green() +" implicit: #{self.implicit.inspect}, implicit_end: #{self.implicit_end.inspect}, version: #{self.version.inspect}, directives: #{self.tag_directives.inspect}\n".blue
                for each in self.children
                    output += indent(each.inspect)+"\n"
                end
                return output
            end
            def content
                return self.children[0]
            end
            def to_yaml
                new_stream = Psych::Nodes::Stream.new
                new_stream.children << self
                return new_stream.to_yaml
            end
        end
        
        class Mapping
            include Common
            def inspect
                output = "[Mapping]".green() + " anchor: #{self.anchor.inspect}, tag: #{self.tag.inspect}, implicit: #{self.implicit.inspect}, style: #{self.style_to_s}\n".blue
                is_key = true
                for each in self.children
                    if is_key
                        output += indent("\n[key]".light_black) + "\n"
                    else
                        output += indent("[value]".light_black) + "\n"
                    end
                    is_key = ! is_key
                    
                    output += indent(indent(each.inspect))+"\n"
                end
                return output
            end
            
            def [](key)
                is_value = true
                index = -1
                for each in self.children.reverse
                    index += 1
                    if not is_value
                        if each == key || (each.respond_to?(:value) && each.value == key)
                            # return the value of the key (which is the prev value)
                            return self.children[index-1]
                        end
                    end
                    is_value = ! is_value
                end
                return nil
            end
        end
        
        class Sequence
            include Common
            def inspect
                output = "[Sequence]".green() +" anchor: #{self.anchor.inspect}, tag: #{self.tag.inspect}, implicit: #{self.implicit.inspect}, style: #{self.style_to_s}\n".blue
                for each in self.children
                    output += indent(each.inspect)+"\n"
                end
                return output
            end
            
            def [](key)
                return self.children[key]
            end
        end
        
        class Scalar
            include Common
            def inspect
                output = "[Scalar]".green() +" anchor: #{self.anchor.inspect}, tag: #{self.tag.inspect}, plain:#{self.plain.inspect}, style: #{self.style_to_s}, quoted: #{self.quoted.inspect}\n".blue
                output += indent("value: #{self.value.inspect.yellow}")
            end
        end
        
        class Alias
            def inspect
                output = "[Alias]\n".green()
                output += indent("anchor: #{self.anchor.inspect.yellow}")
            end
        end
    end
end


require 'yaml'
doc = YAML.parse(<<-HEREDOC)
thing1: &ref hi
list1:
    - 1
    - 2
    - 3
    - *ref
# hello
list2: [1,2,3]
HEREDOC

Scalar   = Psych::Nodes::Scalar
Sequence = Psych::Nodes::Sequence


p doc.content["list1"]
# actual_data.children[1]
# seq.children    << scalar
# seq    = Psych::Nodes::Sequence.new
scalar = Scalar.new('foo')


# puts doc.to_yaml