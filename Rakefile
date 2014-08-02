desc "Resets the Xcode snippets folder, removing the custom snippets added during development"
task :reset do
  Dir["./example-snippets/*.codesnippet"].each do |snip|
    path = Dir.home + "/Library/Developer/Xcode/UserData/CodeSnippets/" + File.basename(snip)
    `rm #{path}`
  end
end
