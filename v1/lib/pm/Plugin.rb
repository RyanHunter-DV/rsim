"""
# Object description:
Plugin, An object that been created while the global flow API is called by user
plugin files, such as buildflow, compileflow ...
"""
require 'lib/pm/FlowBase.rb'
require 'lib/pm/FlowStep.rb'
class Plugin ##{{{
	attr :options; # options required to call different actions.
end ##}}}