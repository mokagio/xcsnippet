require "plist"
require "fileutils"

def rename_snippet(path)
  snippet = Plist::parse_xml path
  title = snippet["IDECodeSnippetTitle"]
  content = snippet["IDECodeSnippetContents"]
  puts "Snippet #{File.basename path}"
  puts "Title: #{title}"
  puts "Content:\n#{content}"

  puts "\nNew name: "
  user_input = $stdin.gets.chomp!

  new_path = File.dirname(path) + "/" + user_input + ".codesnippet"
  snippet["IDECodeSnippetIdentifier"] = user_input

  Plist::Emit::save_plist snippet, path
  
  FileUtils.mv path, new_path
end

path = "."
should_quit = false
while not should_quit
  puts "Available snippets:"
  snippets = Dir[path + "/**/*.codesnippet"]
  snippets.each_with_index do |snippet_file, index|
    snippet = Plist::parse_xml snippet_file
    puts "#{index + 1}) #{File.basename snippet_file} ( #{snippet["IDECodeSnippetTitle"]} )"
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
