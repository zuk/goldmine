require 'brokers/base'

module Brokers
  class ScotiaITrade < Base
    def to_s
      "Scotia iTrade"
    end
  
    def login!
      read_credentials!(:scotiaitrade)
      
      # login_p = @mech.get('https://swww.scotiaitrade.com/login.shtml')
      # login_f = login_p.form_with(:name => 'myForm')
      # login_f.USER = @credentials[:username]
      # login_f.PASSWORD = @credentials[:password]
      # login_f.submit
      
      @mech.post('https://swww.scotiaitrade.com/NASApp/doLogin', {
                   'USER' => @credentials[:username],
                   'PASSWORD' => @credentials[:password],
                   'target' => '/cgi-bin/cwRedirection.cgi',
                   'countrylangselect' => 'us_english',
                   'OP_TARGET' => 6
                 })
      @mech.get('https://swww.scotiaitrade.com/login_redirect.shtml')
      @mech.get('https://swww.scotiaitrade.com/NASApp/LoginCtx/TpLoginServlet?status=REDIRECT')
      @mech.get('https://swww.scotiaitrade.com/NASApp/MarketTabCtx/MarketTabServlet')
    end
  
    def logout!
      @mech.get('https://swww.scotiaitrade.com/NASApp/doLogout')
    end
  
    def get_positions
      positions = []
    
      @credentials[:accounts].each do |account|
        pos_html = Nokogiri::HTML(fetch_positions(account))
        
        fetch_time = now_string
        
        pos = {}
        pos[:type] = :cash
        pos[:currency] = :CAD
        pos[:account] = account
        pos[:broker] = to_s
        pos[:value] = as_f(pos_html.xpath('//td/b[contains(text(),"Trade Cash")]/../../following-sibling::tr/td/font').first.text)
        pos[:time] = fetch_time
        positions << pos
        
        pos_html.xpath('//tr[@valign="MIDDLE"]').select{|tr| td = (tr > 'td').size == 6}[1..-1].each do |tr|
          cells = tr > 'td'
      
          pos = {}
          pos[:type] = :stock
          ticker_a = (cells[0].search('a')).first
          
          ticker_data = /'EQ','([A-Z]+)','([A-Z]+)'/.match(ticker_a[:href])
          ticker = ticker_data[1]
          if ticker_data[2] == 'CDN'
            # FIXME: need a better way to figure out whether the ticker is for TSX or Venture Exchange
            if ticker == 'GWG'
              ticker << '.VN'
            else
              ticker << '.TO'
            end
          end

          pos[:ticker] = ticker
          pos[:qty] = as_i((cells[1] > 'font').first.text)
          pos[:book] = as_f((cells[2] > 'font').first.text)
          pos[:cost] = pos[:book] / pos[:qty].to_f
          pos[:price] = as_f((cells[3] > 'font').first.text)
          pos[:value] = as_f(cells[4].text)
          pl_cell = (cells[5] > 'font').first.text.split('/')
          
          pos[:profit_loss] = as_f(pl_cell[0])
          pos[:profit_loss_perc] = as_f(pl_cell[1])
          
          pos[:currency] = ticker_data[2] == 'CDN' ? :CAD : :USD
          pos[:account] = account
          pos[:broker] = to_s
          pos[:time] = fetch_time
      
          positions << pos
        end
      end
    
      positions
    end
  
    private  
    def fetch_positions(account)
      uri = URI.parse('https://swww.scotiaitrade.com/')
      
      cookies = [
        ['accountnum', '59015373'],
        ['accounttype', 'RRSP'],
        ['accountcurr', 'CAD'],
        ['accountalias', ''],
        ['brok_account_cookie_list', "489810 - 57045977 Cash CAD.489810 - 57510728 Cash Optimizer CAD.489810 - 59015373 RRSP CAD."],
        ['stepid', 5],
        ['account_cookie_status', 'ok'],
        ['__utma', '226969375.21766444.1282830225.1282830225.1282836097.2'],
        ['__utmb', '226969375'],
        ['__utmz', '226969375.1282837901.1.1.utmccn=(direct)|utmcsr=(direct)|utmcmd=(none)'],
        ['__utmc', '226969375']
        #['SOSTATUS']
      ]
      
      cookies.each do |key,val|
        cookie = Mechanize::Cookie.new(key, val)
        cookie.domain = 'swww.scotiaitrade.com'
        cookie.path = '/'
        @mech.cookie_jar.add(uri, cookie)
      end
      
      html = @mech.post('https://swww.scotiaitrade.com/NASApp/AccountBalancesCtx/AccountBalancesServlet?show=AccountHoldings&actionType=Link', {
              'selecteaccount' => account,
              'linkList' => 1
            }).body
      
      answer_challenge(html)
            
      html = @mech.post('https://swww.scotiaitrade.com/NASApp/AccountBalancesCtx/AccountBalancesServlet?show=AccountHoldings&actionType=Link', {
              'selecteaccount' => account,
              'linkList' => 1
            }).body
      html
    end
    
    def answer_challenge(challenge_html)
      challenge = Nokogiri::HTML(challenge_html)
      q = challenge.xpath('//b[text()="Question 1"]/../following-sibling::td/label').first
      
      puts "CHALLENGE: #{q.text.to_s.inspect}"
      if @credentials[:challenges] && @credentials[:challenges][q.text.to_s]
        answer = (@credentials[:challenges] && @credentials[:challenges][q.text.to_s]).strip
        puts answer
      else
        answer = gets.strip
      end
      
      return @mech.post('https://swww.scotiaitrade.com/NASApp/SignOnCtx/SignOnAuthServlet', {
        'actionType' => 'mfaQAChallenge',
        q['for'] => answer,
        'Submit' => 'Submit',
        'Submit.x' => 22,
        'Submit.y' => 14
      }).body
    end
  end
end

