
require 'ise'

module ISE

  #
  # Module which handles manipulating the ISE Project Navigator.
  #
  module ProjectNavigator
    extend self

    RecentProjectsPath = 'Project Navigator/Recent Project List1'

    #
    # Loads preferences.
    # By default, preferences are only loaded once.
    #
    def load_preferences(force_reload=false)
      @preferences = nil if force_reload
      @preferences ||= PreferenceFile.load
    end

    #
    # Returns the current ISE version.
    #
    def version
      load_preferences
      @preferences.sections.first
    end

    #
    # 
    #
    def preferences
      load_preferences
      return @preferences[version]
    end

    #
    # Returns the preference with the given path.
    #
    def preference(path, prefix="#{version}/")
      return @preferences.get_by_path(prefix + path)
    end


    #
    # Returns most recently open project. If Project Navigator has a project open,
    # that project will be used. This function re-loads the preferences file upon each call,
    # to ensure we don't have stale data.
    #
    def most_recent_project_path

      #Re-load the preference file, so we have the most recent project.
      @preferences = PreferenceFile.load

      #And retrieve the first project in the recent projects list.
      project = preference(RecentProjectsPath).split(', ').first

      #If the project exists, return it; otherwise, return nil.
      File::exists?(project) ? project : nil

    end

    #
    # Returns a project object representing the most recently open project.
    #
    def most_recent_project
      Project.load(most_recent_project_path)
    end

  end
end
