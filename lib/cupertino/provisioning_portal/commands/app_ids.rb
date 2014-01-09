COLORS_BY_PROPERTY_VALUES = {
  "Enabled" => :green,
  "Configurable" => :yellow,
  "Unavailable" => :underline
}

command :'app_ids:list' do |c|
  c.syntax = 'ios app_ids:list'
  c.summary = 'Lists the App IDs'
  c.description = ''

  c.action do |args, options|
    app_ids = try{agent.list_app_ids}

    title = "Legend: #{COLORS_BY_PROPERTY_VALUES.collect{|k, v| k.send(v)}.join(', ')}"
    table = Terminal::Table.new :title => title do |t|
      t << ["Bundle Seed ID", "Description", "Development", "Distribution"]
      app_ids.each do |app_id|
        t << :separator

        row = [app_id.bundle_seed_id, app_id.description]
        [app_id.development_properties, app_id.distribution_properties].each do |properties|
          values = []
          properties.each do |property|
            key,value = property.split(":")
            color = COLORS_BY_PROPERTY_VALUES[value] || :reset
            values << key.sub(/\:$/, "").send(color)
          end
          row << values.join("\n")
        end
        t << row
      end
    end

    puts table
  end
end

alias_command :app_ids, :'app_ids:list'
