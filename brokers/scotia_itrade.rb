require 'brokers/base'

module Brokers
  class ScotiaITrade < Base
    def to_s
      "Scotia iTrade"
    end
  
    def login!
      read_credentials!(:scotiaitrade)

      login_url = 'https://www2.scotiaonline.scotiabank.com/online/authentication/authenticationITrade.bns'


      @mech.get(login_url)
       
      p = @mech.post(login_url, {
                   'signon_form:userName' => @credentials.username,
                   'signon_form:password_0' => @credentials.password,
                   'signon_form:enter_sol.x' =>  15,
                   'signon_form:enter_sol.y' => 13,
                   'signon_form' => 'signon_form',
                   'javax.faces.ViewState' => 'j_id1'
                 })
      p = @mech.get(nil)

      p = answer_challenge(p.body)
      @mech.get(nil)
    end
  
    def logout!
      #@mech.get('https://swww.scotiaitrade.com/NASApp/doLogout')
    end
  
    def get_positions
      positions = []
    
      @credentials.accounts.each do |account|
        pos_html = Nokogiri::HTML(fetch_positions(account))
        
        fetch_time = now_string
        
        pos = {}
        pos[:type] = :cash
        pos[:currency] = :CAD
        pos[:account] = account
        pos[:broker] = to_s
        #pos[:value] = as_f(pos_html.xpath('//td/b[contains(text(),"Trade Cash")]/../../following-sibling::tr/td/font').first.text)
        
        #puts pos_html
        pos[:value] = as_f((pos_html.xpath('//table[@summary="summary balance"]/tbody/tr/td').last > 'div').text)
        pos[:time] = fetch_time
        positions << pos
        
        pos_html.xpath('//table[@summary="Canadian Account Positions"]//th[@scope="row" and not(@colspan)]').each do |th|
          cells = th.parent > 'td'
      
          pos = {}
          pos[:type] = :stock
          ticker = (cells[1] > 'div').first.text

          cur = :USD
          # FIXME: need a better way to detect US vs CAD positions
          #if ticker_data[2] == 'CDN'
            # FIXME: need a better way to figure out whether the ticker is for TSX or Venture Exchange
            if ticker == 'GWG'
              ticker << '.VN'
              cur = :CAD
            elsif ticker == 'AZD'
              ticker << '.TO'
              cur = :CAD
            else
              puts "WARNING: not sure about currency for #{ticker}!"
            end
          #end

          

          pos[:ticker] = ticker
          pos[:qty] = as_i((cells[2] > 'div').first.text)
          pos[:book] = as_f((cells[5] > 'div').first.text)
          pos[:cost] = as_f((cells[3] > 'div').first.text)
          pos[:price] = as_f((cells[4] > 'div').first.text)
          pos[:value] = as_f((cells[6] > 'div').first.text)
          
          pos[:profit_loss] = as_f((cells[7] > 'div').first.text)
          pos[:profit_loss_perc] = as_f((cells[8] > 'div').first.text)
          
          pos[:currency] = cur
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
      url = "https://www2.scotiaonline.scotiabank.com/online/views/accounts/accountDetails/accountDetailsBrk.bns?acctId=#{account}&tabId=acctDet"
      @mech.get(url).body
    end
    
    def answer_challenge(challenge_html)
      challenge = Nokogiri::HTML(challenge_html)
      
      q = challenge.xpath('//label[@for="question1"]/../following-sibling::td').first
      submit = challenge.xpath('//input[@title="Continue"]').first
      
      puts "CHALLENGE: #{q.text.to_s.inspect}"
      if @credentials[:challenges] && @credentials[:challenges][q.text.to_s]
        answer = (@credentials[:challenges] && @credentials[:challenges][q.text.to_s]).strip
        puts answer
      else
        answer = gets.strip
      end
      
      return @mech.post('https://www2.scotiaonline.scotiabank.com/online/authentication/mfaAuthentication.bns', {
        'javax.faces.ViewState' => 'j_id2',
        'mfaAuth_form:answer_0' => answer,
        'mfaAuth_form' => 'mfaAuth_form',
        submit.attr(:name) => 'Continue',
        'mfaAuth_form:register' => '0'
      })
    end
  end
end

