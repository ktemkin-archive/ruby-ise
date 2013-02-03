
require 'ise'

module ISE

  #
  # Module which handles manipulating the ISE Project Navigator.
  #
  module ProjectNavigator
    extend self

    RecentProjectsPath = 'Project Navigator/Recent Project List1'

    #
    # Sets the path of the preference file to look for.
    #
    def set_preference_file(preference_file=nil)
      @preference_file = preference_file
    end

    #
    # Loads preferences.
    # By default, preferences are only loaded once.
    #
    def load_preferences(force_reload=false)
      @preferences = nil if force_reload
      @preferences ||= PreferenceFile.load(@preference_file)
    end

    #
    # Returns the current ISE version.
    #
    def version
      load_preferences
      @preferences.sections.last
    end

    #
    # 
    #
    def preferences
      load_preferencers
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
    # TODO: When more than one ISE version is loaded, parse _all_ of the recent projects,
    # and then return the project with the latest timestamp.
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
      path = most_recent_project_path
      path ? Project.load(path) : nil
    end

  end
end
