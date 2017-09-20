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
    matches.each_with_index do |m, i|
      page.row(i+1).push m.date, m.sport, m.description, m.first_option, m.second_option, m.winner, m.heat, m.first_option_chosen, m.second_option_chosen, m.first_final, m.second_final, m.comments_count
    end
    
    summary = StringIO.new
    spreadsheet.write summary
    file = "Historical Match Data #{Date.today.strftime("%Y.%m.%d")}.xls"
    send_data summary.string, :filename => "#{file}", :type=>"application/excel", :disposition=>'attachment'
  end

end
