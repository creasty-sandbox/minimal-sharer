require 'fileutils'
require 'shellwords'

on_sprite_saved do |filename|
	filebase = File.basename filename

	growlnotify filebase, :title => 'Compass Sprite Saved', :name => 'Compass'
end

on_stylesheet_saved do |filename|
	filebase = File.basename filename

	growlnotify filebase, :title => 'Compass Updated', :name => 'Compass'
end

on_stylesheet_error do |filename, message|
	_, line, samefile, file, message = */^\(Line (\d+)( of (.+?))?: (.+)$/.match(message)

	filename = file unless samefile.nil?
	filebase = File.basename filename

	growlnotify "#{line} of #{filebase}:\n#{message}", :title => 'Compass Error', :name => 'Compass'
end

def growlnotify(message, option = {})
	args = ['growlnotify']

	unless message.nil?
		args.push '-m', Shellwords.escape(message)
	end

	unless option[:sticky].nil?
		args.push '-s'
	end

	unless option[:name].nil?
		args.push '-n', Shellwords.escape(option[:name])
	end

	unless option[:title].nil?
		args.push '-t', Shellwords.escape(option[:title])
	end

	exec args.join(' ')
end