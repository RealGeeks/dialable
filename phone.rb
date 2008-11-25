
require "pp"

module Phone
  class NANP
    ##
    # Raised if something other than a valid NANP is supplied
    class InvalidNANPError < StandardError
    end
    
    module ServiceCodes # ERC, Easily Recognizable Codes
      ERC = {
        211	=> "Community Information and Referral Services",
        311	=> "Non-Emergency Police and Other Governmental Services",
        411	=> "Local Directory Assistance",
        511 => "Traffic and Transportation Information (US); Provision of Weather and Traveller Information Services (Canada)",
        611	=> "Repair Service",
        711	=> "Telecommunications Relay Service (TRS)",
        811	=> "Access to One Call Services to Protect Pipeline and Utilities from Excavation Damage (US); Non-Urgent Health Teletriage Services (Canada)",
        911	=> "Emergency"
      }
    end
    
    module Patterns
      List = [
        /^\D*1?\D*([2-9]\d\d)\D*(\d{3})\D*(\d{4})\D*[ex]+\D*(\d{1,5})\D*$/i,
        /^\D*1?\D*([2-9]\d\d)[ $\\\.-]*(\d{3})[ $\\\.-]*(\d{4})[ $\\\.\*-]*(\d{1,5})\D*$/i,
        /^\D*1?\D*([2-9]\d\d)\D*(\d{3})\D*(\d{4})\D*$/,
        /^(\D*)(\d{3})\D*(\d{4})\D*$/,
        /^\D*([2-9]11)\D*$/,
        /^\D*1?\D*([2-9]\d\d)\D*(\d{3})\D*(\d{4})\D.*/
        ]
    end
    
    attr_writer :areacode
    attr_writer :prefix
    attr_writer :line
    attr_writer :extension
    
    def initialize(parts={})
      self.areacode  = parts[:areacode]  ? parts[:areacode]  : nil
      self.prefix    = parts[:prefix]    ? parts[:prefix]    : nil
      self.line      = parts[:line]      ? parts[:line]      : nil
      self.extension = parts[:extension] ? parts[:extension] : nil
    end
  
    def self.parse(number)
      Patterns::List.each do |pat|
        return Phone::NANP.new(:areacode => $1, :prefix => $2, :line => $3, :extension => $4) if number =~ pat
      end
      
      raise InvalidNANPError, "Not a valid NANP Phone Number."
    end

    def erc?
      return ServiceCodes::ERC[@areacode].nil?
    end
  
    def to_s
      rtn = "#{@prefix}-#{@line}"
      rtn = "#{@areacode}-#{rtn}" if @areacode
      rtn = "#{rtn} x#{@extension}" if @extension
      rtn
    end

    def to_digits
      rtn = "#{@prefix}#{@line}"
      rtn = "#{@areacode}#{rtn}" if @areacode
      rtn = "#{rtn} x#{@extension}" if @extension
      rtn
    end

    def to_dialable
      rtn = "#{@prefix}#{@line}"
      rtn = "#{@areacode}#{rtn}" if @areacode
      rtn
    end
  
    def to_hash
      return {
        :areacode => @areacode,
        :prefix => @prefix,
        :line => @line,
        :extension => @extension
      }
    end
  end  
end