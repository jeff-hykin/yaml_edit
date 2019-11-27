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
        class Document
            def to_s
                output = "[Document]".green() +" implicit: #{self.implicit.inspect}, implicit_end: #{self.implicit_end.inspect}, version: #{self.version.inspect}, directives: #{self.tag_directives.inspect}\n".blue
                for each in self.children
                    if each.respond_to?(:to_s)
                        output += indent(each.to_s)+"\n"
                    else
                        output += indent(each.inspect)+"\n"
                    end
                end
                return output
            end
        end
        
        class Mapping
            def to_s
                output = "[Mapping]".green() + " anchor: #{self.anchor.inspect}, tag: #{self.tag.inspect}, implicit:#{self.implicit.inspect}, style: #{self.style.inspect}\n".blue
                is_key = true
                for each in self.children
                    if is_key
                        output += indent("\n[key]".light_black) + "\n"
                    else
                        output += indent("[value]".light_black) + "\n"
                    end
                    is_key = ! is_key
                    
                    if each.respond_to?(:to_s)
                        output += indent(indent(each.to_s))+"\n"
                    else
                        output += indent(indent(each.inspect))+"\n"
                    end
                end
                return output
            end
        end
        
        class Sequence
            def to_s
                output = "[Sequence]".green() +" anchor: #{self.anchor.inspect}, tag: #{self.tag.inspect}, implicit:#{self.implicit.inspect}, style: #{self.style.inspect}\n".blue
                for each in self.children
                    if each.respond_to?(:to_s)
                        output += indent(each.to_s)+"\n"
                    else
                        output += indent(each.inspect)+"\n"
                    end
                end
                return output
            end
        end
        
        class Scalar
            def to_s
                output = "[Scalar]".green() +" anchor: #{self.anchor.inspect}, tag: #{self.tag.inspect}, plain:#{self.plain.inspect}, style: #{self.style.inspect}, quoted: #{self.quoted.inspect}\n".blue
                output += indent("value: #{self.value.inspect.yellow}")
            end
        end
    end
end


require 'yaml'
a = YAML.parse(<<-HEREDOC)
list1:
    - 1
    - 2
    - 3
list2: [1,2,3]
HEREDOC


puts a 