#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
#  usn.rb
#
#  Author: Ryosuke KUTSUNA <ryosuke@deer-n-horse.jp>
#
require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'tmpdir'
require 'tempfile'

class USN
  def initialize(num)
    @usnbase = "http://www.ubuntu.com/usn"
    @cvebase = "http://web.nvd.nist.gov/view/vuln/detail?vulnId="
    @lpbase = "https://launchpad.net/ubuntu/"

    unless num then
      puts "USN num not exist."
      exit 1
    else
      @usn_num = num
    end

    @tmpfile = Tempfile.new('usn')
    getUSNHtml()
    parseUSN()
    @tmpfile.close
    @tmpfile.unlink
  end

  def getTitle
    return @usn_title
  end

  def getURL
    return "#{@usnbase}/usn-#{@usn_num}/"
  end

  def getDate
    return @usn_date
  end

  def getSummary
    return @usn_summary
  end

  def getDetails
    return @usn_details
  end

  def getReferences
    return @usn_references
  end

  def getReferencesWithURL
    text0 = @usn_references.gsub!(/(CVE-[0-9]+-[0-9]+)/, "<a href=\"#{@cvebase}" + '\1' + "\">" + '\1' + "</a>")
    return text0
  end

  def getUSNTargets
    return @usn_targets
  end

  private
  # get USN Announce HTML
  def getUSNHtml() 
    dlusn = "#{@usnbase}/usn-#{@usn_num}/"
    begin
      open(dlusn) do |s|
          @tmpfile.print(s.read)
      end
    rescue => e
      p e.message
      print "Not found: #{dlusn}\n"
      exit 1
    end
  end
  
  # parse USN Announce HTML
  def parseUSN()
    doc = Nokogiri::HTML(open(@tmpfile))
    @usn_date = doc.xpath('//p/em')[0].text

    @usn_summary = ''
    @usn_details = ''
    @usn_references = ''
    @usn_targets = ''

    tag_h3 = Array.new()
    doc.xpath('//h3').each do |c|
      tag_h3 << c
    end
    @usn_title = tag_h3[0].text

    tag_p = Array.new()
    doc.xpath('//p').each do |c|
      tag_p << c
    end
    i = 0;
    detailf = false
    tag_p.each do |p|
      if i == 2
        @usn_summary = p.text
      end
      if i == 3
        detailf = true
      end
      if p.text =~ /^To update your system/ || p.text =~ /^ The problem can be corrected/
        detailf = false
      end
      if detailf
        @usn_details.concat("\n\n" + p.text)
      end
      if p.to_s =~ /^[\s,\t]*<a href=/
        unless p.text =~ /^To update your system/ 
          @usn_references.concat(p.text.gsub(/[\n\s]/, ''))
        end
      end
      i += 1
    end

    @usn_targets = Array.new()
    doc.xpath('//ul/li').each do |c|
      if c.text =~ /^Ubuntu [0-9.]+/
        @usn_targets << c.text
      end
    end
  end
end

### main ###
if __FILE__ == $0
  usn = USN.new("1849-1")
  print "Title      : #{usn.getTitle}\n"
  print "Date       : #{usn.getDate}\n"
  print "Summary    : #{usn.getSummary}\n"
  print "Details    : #{usn.getDetails}\n"
  print "References : #{usn.getReferences}\n"
  print "References(a) : #{usn.getReferencesWithURL}\n"
end

# EOF
