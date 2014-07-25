require 'typhoeus'
require 'nokogiri'

class UIUCCheck
  @subject = 'CS'
  @course_num = '467'
  @term = '2014/fall'
  @base_url = 'http://courses.illinois.edu/cisapp/explorer/schedule/'
  @hydra = Typhoeus::Hydra.new(max_concurrency: 200)
  @crns = []

  def self.get_crns
    course_url = "#{@base_url}#{@term}/#{@subject}/#{@course_num}.xml"
    @hydra.queue(request = Typhoeus::Request.new(course_url))
    
    request.on_complete do |response|
      doc = Nokogiri::XML(response.response_body)
      
      # get crns
      doc.css('section').each do |section|
        @crns << section.attr('href')
      end
    end

    @hydra.run
  end

  def self.check_for_openings
    @crns.each do |crn|
      @hydra.queue(request = Typhoeus::Request.new(crn))

      request.on_complete do |response|
        doc = Nokogiri::XML(response.response_body)

        # print information
        status = doc.css('enrollmentStatus').children[0].text

        crn_name = crn[/[^\/]+$/].sub('.xml', '')

        puts "#{crn_name} - #{status}"
      end
    end

    @hydra.run
  end
end