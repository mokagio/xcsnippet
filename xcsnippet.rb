require "plist"
require "fileutils"

@title_key = "IDECodeSnippetTitle"
@content_key = "IDECodeSnippetContents"
@identifier_key = "IDECodeSnippetIdentifier"

snippets_path = Dir.home + "/Library/Developer/Xcode/UserData/CodeSnippets"

def rename_snippet(path)
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

  new_path = File.dirname(path) + "/" + file_name + ".codesnippet"
  snippet[@identifier_key] = file_name

  Plist::Emit::save_plist snippet, path
  
  FileUtils.mv path, new_path
end

should_quit = false
while not should_quit
  puts "Available snippets:"
  snippets = Dir[snippets_path + "/*.codesnippet"]
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
