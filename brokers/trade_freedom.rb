require 'brokers/base'

module Brokers
  class TradeFreedom < Base
    def to_s
      "TradeFreedom"
    end
  
    def login!
      read_credentials!(:tradefreedom)
      
      @mech.post('https://www.pentrader.net/scotia/loginUser.nexa', {
        'loginId' => @credentials[:username],
        'password' => @credentials[:password],
        'expireTime' => 30,
        'productDir' => 'pentrader/Scotia',
        'language' => 1,
        'firm' => 85,
        'firmCode' => 'SCBK',
        'subscribe' => 0,
        'x' => 63,
        'y' => 17
      })
    end
  
    def logout!
      @mech.get('https://www.pentrader.net/scotia/logoutUser.nexa?&page=0&language=1&product=pentrader/Scotia')
    end
  
    def get_positions
      positions = []
    
      @credentials[:accounts].each do |account|
        pos_html = Nokogiri::HTML(fetch_positions(account))
        
        fetch_time = now_string
        
        pos_html.xpath('//tr').select{|tr| td = (tr > 'td[align=center]').first; td && td.text =~ /^\s*[A-Z]{1,4}(\.[A-Z]{2})?\s*$/}.each do |tr|
          cells = tr > 'td'
      
          pos = {}
          pos[:type] = :stock
          pos[:ticker] = cells[0].text
          pos[:qty] = as_i(cells[2].text)
          pos[:cost] = as_f(cells[3].text)
          pos[:price] = as_f(cells[4].text)
          pos[:profit_loss] = as_f(cells[5].text)
          pos[:profit_loss_perc] = as_f(cells[6].text)
          pos[:value] = as_f(cells[7].text)
          pos[:currency] = (pos[:ticker] =~ /\.(VN|TO)$/) ? :CAD : :USD
          pos[:account] = account
          pos[:broker] = to_s
          pos[:time] = fetch_time
      
          positions << pos
        end
      
        bal_html = Nokogiri::HTML(fetch_balances(account))
        fetch_time = now_string
        bal_html.xpath('//tr').select{|tr| td = (tr > 'td').first; td && td.text == 'Buying Power'}.each do |tr|
          cells = tr > 'td'
        
          pos = {}
          pos[:type] = :cash
          pos[:currency] = :CAD
          pos[:account] = account
          pos[:broker] = to_s
          pos[:time] = fetch_time
      
          if cells.size == 3
            pos[:value] = as_f(cells[-1].text)
          else
            pos[:value] = as_f(cells[-2].text)
          end
          
          positions << pos
        end
      end
    
      positions
    end
  
    private  
    def fetch_positions(account)
      html = @mech.post('https://www.pentrader.net/scotia/getPositions.nexa?stylesheet=positions&useLastPrice=0', {
        'sort' => 2,
        'flag' => 0,
        'orderid' => 0,
        'styleSheet' => 'positions',
        'selectedAccount' => account
      }).body
      html.gsub!('charset=utf-16','')
      html
    end
  
    def fetch_balances(account)
      html = @mech.post('https://www.pentrader.net/scotia/getUserInfo.nexa?stylesheet=balances', {
        'styleSheet' => 'balances',
        'selectedAccount' => account
      }).body
      html.gsub!('charset=utf-16','')
      html
    end
  end
end


