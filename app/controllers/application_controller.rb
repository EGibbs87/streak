class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def index
  end
  
  def matches_spreadsheet
    spreadsheet = Spreadsheet::Workbook.new
    
    page = spreadsheet.create_worksheet :name => "Match History"
    
    ####### ROW/CELL FORMATS ########
    header_format = Spreadsheet::Format.new :weight => :bold, :border => :thin, :horizontal_align => :center, :pattern_fg_color => :lime, :pattern => 1, :size => 9, :text_wrap => true, :vertical_align => :top
    default_format = Spreadsheet::Format.new :border => :thin, :horizontal_align => :center, :size => 9, :text_wrap => true, :vertical_align => :top
    date_format = Spreadsheet::Format.new :number_format => 'YYYY-MM-DD'

    # set headers
    page.row(0).push "Date", "Sport", "Description", "First Option", "Second Option", "Winner", "Heat", "First Option Chosen", "Second Option Chosen", "First Final", "Second Final", "Comments Count"
    12.times do |i|
      page.row(0).set_format(i, header_format)
    end
    
    matches = Match.all
    matches.each_with_index do |ti, i|
      page.row(i+1).push ti.symbol, ti.exchange, ti.company, ti.position, ti.pos_type, ti.op_type, ti.op_strike, ti.op_expiration, ti.quantity, ti.active, "", ti.date_acq, ti.paid, ti.rec_action_o, ti.total_score_o, ti.total_score_pct_o, ti.nsi_score_o, ti.ra_score_o, ti.noas_score_o, ti.ag_score_o, ti.aita_score_o, ti.l52wp_score_o, ti.pp_score_o, ti.rq_score_o, ti.dt2_score_o, ti.prev_ed_o, ti.next_ed_o, ti.mkt_cap_o, ti.lq_revenue_o, "", ti.active ? "N/A" : ti.date_sold.strftime("%Y-%m-%d"), ti.last, ti.rec_action_c, ti.total_score_c, ti.total_score_pct_c, ti.nsi_score_c, ti.ra_score_c, ti.noas_score_c, ti.ag_score_c, ti.aita_score_c, ti.l52wp_score_c, ti.pp_score_c, ti.rq_score_c, ti.dt2_score_c, ti.prev_ed_c, ti.next_ed_c, ti.mkt_cap_c, ti.lq_revenue_c
      page.row(i+1).set_format(1, date_format)
    end
    
    summary = StringIO.new
    spreadsheet.write summary
    file = "Historical Match Data #{Date.today.strftime("%Y.%m.%d")}.xls"
    send_data summary.string, :filename => "#{file}", :type=>"application/excel", :disposition=>'attachment'
  end

end
