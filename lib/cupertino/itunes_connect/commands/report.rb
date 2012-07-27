require 'itc_autoingest'
require 'security'

command :'itc:salessummaryreport' do |c|
  c.syntax = 'ios itc:salessummaryreport <vendorid> <Daily|Weekly> <date_yyyymmdd> [output file]'
  c.summary = 'Retrieves the sales summary report for the given app and date'
  c.description = ''

  c.action do |args, options|
    ipw = Security::InternetPassword.find(:server => Cupertino::ITC_HOSTNAME)
    username, password = ipw.attributes['acct'], ipw.password if ipw

    say_error "Missing arguments, expected <vendorid> <Daily|Weekly> <date_yyyymmdd> [output file]" and abort if args.nil? or args.length < 3

    username ||= ask "Username:"
    password ||= pw "Password:"

    itca = ITCAutoingest::ITCAutoingest.new(username, password, args[0])
    if args.length == 4
      File.open(args[3], 'w') do |f| 
        f.write(itca.send("#{args[1].downcase}_sales_summary_raw", args[2]))
      end
    else
      report = itca.send("#{args[1].downcase}_sales_summary_report", args[2])

      if report[:error].nil?
        if report[:report].size == 0
          puts "Nothing to report."
        else
          puts hasharray_to_table(report[:report], "Sales Summary Report")
        end
      else
        say_error report[:error]
      end
    end
  end
end

command :'itc:salesoptinreport' do |c|
  c.syntax = 'ios itc:salesoptinreport <vendorid> <Daily|Weekly> <date_yyyymmdd> [output file]'
  c.summary = 'Retrieves the sales opt-in report for the given app and date'
  c.description = ''

  c.action do |args, options|
    ipw = Security::InternetPassword.find(:server => Cupertino::ITC_HOSTNAME)
    username, password = ipw.attributes['acct'], ipw.password if ipw

    say_error "Missing arguments, expected <vendorid> <Daily|Weekly> <date_yyyymmdd> [output file]" and abort if args.nil? or args.length < 3

    username ||= ask "Username:"
    password ||= pw "Password:"

    itca = ITCAutoingest::ITCAutoingest.new(username, password, args[0])
    if args.length == 4
      File.open(args[3], 'w') do |f| 
        f.write(itca.send("#{args[1].downcase}_sales_optin_raw", args[2]))
      end
    else
      report = itca.send("#{args[1].downcase}_sales_optin_report", args[2])

      if report[:error].nil?
        if report[:report].size == 0
          puts "Nothing to report."
        else
          puts hasharray_to_table(report[:report], "Sales Opt-In Report")
        end
      else
        say_error report[:error]
      end
    end
  end
end
