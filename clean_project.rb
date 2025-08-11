#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = 'NimbblSampleApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'NimbblSampleApp' }

# Remove manual framework references
target.frameworks_build_phase.files.each do |file|
  if file.file_ref && file.file_ref.path && file.file_ref.path.include?('nimbbl_mobile_kit_ios_webview_sdk.framework')
    puts "Removing manual framework reference: #{file.file_ref.path}"
    target.frameworks_build_phase.remove_file_reference(file.file_ref)
  end
end

# Remove embed frameworks phase if it only contains the manual framework
target.copy_files_build_phases.each do |phase|
  if phase.name == 'Embed Frameworks'
    phase.files.each do |file|
      if file.file_ref && file.file_ref.path && file.file_ref.path.include?('nimbbl_mobile_kit_ios_webview_sdk.framework')
        puts "Removing embed framework reference: #{file.file_ref.path}"
        phase.remove_file_reference(file.file_ref)
      end
    end
  end
end

# Remove the framework file reference from the project
project.files.each do |file|
  if file.path && file.path.include?('nimbbl_mobile_kit_ios_webview_sdk.framework')
    puts "Removing framework file reference: #{file.path}"
    file.remove_from_project
  end
end

# Save the project
project.save
puts "Project cleaned successfully!"
