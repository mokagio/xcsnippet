require "plist"
require "fileutils"

@title_key = "IDECodeSnippetTitle"
@content_key = "IDECodeSnippetContents"
@identifier_key = "IDECodeSnippetIdentifier"

@snippets_path = Dir.home + "/Library/Developer/Xcode/UserData/CodeSnippets"

@snippets_extension = ".codesnippet"

def clear_screen
  system "clear"
end

def rename_snippet(path)
  clear_screen()

  snippet = Plist::parse_xml path
  title = snippet[@title_key]
  content = snippet[@content_key]
  puts "Snippet #{File.basename path}"
  puts "Title: #{title}"
  puts "Content:\n#{content}"

  suggested_name = title.downcase.rstrip.gsub(" ", "-")

  puts "\nNew name: [#{suggested_name}]"
  user_input = $stdin.gets.chomp!

  file_name = ""
  if user_input != ""
    file_name = user_input
  else
    file_name = suggested_name
  end

  new_path = File.dirname(path) + "/" + file_name + @snippets_extension
  snippet[@identifier_key] = file_name

  Plist::Emit::save_plist snippet, path

  FileUtils.mv path, new_path
end

def edit_snippets
  should_quit = false
  while not should_quit
    clear_screen()

    puts "Available snippets:"
    snippets = Dir[@snippets_path + "/*.codesnippet"]
    snippets.each_with_index do |snippet_file, index|
      snippet = Plist::parse_xml snippet_file
      puts "#{index + 1}) #{File.basename snippet_file} ( #{snippet[@identifier_key]} )"
    end

    puts "\nType the number of the snippet you want to edit or all to edit all the snippet wiht an Xcode generated name: "
    user_input = $stdin.gets.chomp!
    if user_input =~ /^\d+$/
      user_input = Integer(user_input)
    end

    case user_input
    when "all"
      matching = []
      regexp = Regexp.new /(\w|\d){8}(-)((\w|\d){4}(-)){3}(\w|\d){12}/
      snippets.each do |snippet|
        if regexp.match snippet
          matching.push snippet
        end
      end

      matching.each do |snippet|
        rename_snippet snippet
      end
      should_quit = true
    when 1..snippets.length
      rename_snippet snippets[user_input - 1]
    else
      puts "Invalid input."
      should_quit = true
    end

    puts
  end
end

def copy_snippets
  clear_screen()

  pwd = Dir.pwd
  puts "Enter source folder absolute path [#{pwd}]"
  source = $stdin.gets.chomp!
  if source == ""
    source = pwd
  end

  if !Dir.exists? source
    puts "The folder doesn't exist"
    return -1
  end

  clear_screen()
  puts "Copying all snippets from #{source} to #{@snippets_path}"

  unless Dir.exists? @snippets_path
    FileUtils.mkdir @snippets_path
    puts "I just made an Xcode user snippets folder for you ;)"
  end

  Dir[source + "/*" + @snippets_extension].each do |snippet_path|
    # check for snippet in default folder
    snippet_name = File.basename snippet_path
    new_snippet_path = @snippets_path + "/" + snippet_name
    if File.exists? new_snippet_path
      puts "Snippet name #{snippet_name} exists already"
    else
      FileUtils.cp snippet_path, new_snippet_path
      puts "Added #{snippet_name} to your Xcode snippets"
    end
  end

  puts "All snippets copied. Restart Xcode an enjoy."
end

puts "Welcome to xcsnippet :)"
puts "What do you whish to do?"
puts "\n1) Edit snippets"
puts "2) Copy snippets"

user_input = $stdin.gets.chomp!
if user_input =~ /^\d+$/
  user_input = Integer(user_input)
end

case user_input
when 1
  edit_snippets()
when 2
  copy_snippets()
else
  puts "Bye bye"
end
