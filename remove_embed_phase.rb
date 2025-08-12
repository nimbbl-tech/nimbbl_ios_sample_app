#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = 'NimbblSampleApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'NimbblSampleApp' }

if target
  puts "Found target: #{target.name}"
  
  # Find and remove the embed phase
  embed_phase = target.build_phases.find { |phase| phase.display_name == '[CP] Embed Pods Frameworks' }
  
  if embed_phase
    puts "Removing embed phase: #{embed_phase.display_name}"
    target.build_phases.delete(embed_phase)
    project.save
    puts "Embed phase removed successfully!"
  else
    puts "No embed phase found"
  end
else
  puts "Target 'NimbblSampleApp' not found"
end
