require 'itc_autoingest'
require 'security'

command :'itc:salessummaryreport' do |c|
  c.syntax = 'ios itc:salessummaryreport <vendorid> <Daily|Weekly> <date_yyyymmdd>'
  c.summary = 'Retrieves the sales summary report for the given app and date'
  c.description = ''

  c.action do |args, options|
    ipw = Security::InternetPassword.find(:server => Cupertino::ITC_HOSTNAME)
    username, password = ipw.attributes['acct'], ipw.password if ipw

    say_error "Missing arguments, expected <vendorid> <Daily|Weekly> <date_yyyymmdd>" and abort if args.nil? or args.length < 3

    username ||= ask "Username:"
    password ||= pw "Password:"

    itca = ITCAutoingest::ITCAutoingest.new(username, password, args[0])
    report = itca.send("#{args[1].downcase}_sales_summary_report", args[2])

    if report[:error].nil?
      if report[:report].size == 0
        puts "Nothing to report."
      else
        table = Terminal::Table.new :title => "Sales Summary Report" do |t|
          headers = []
          report[:report][0].keys.each do |header|
            headers << "#{header}"
          end
          t << headers
          t << :separator

          report[:report].each do |rv|
            row = []
            rv.values.each do |cv|
              row << "#{cv}"
            end
            t << row
          end
        end

        puts table
      end
    else
      say_error report[:error]
    end
  end
end
