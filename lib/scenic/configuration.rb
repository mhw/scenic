module Scenic
  class Configuration
    attr_writer :database

    def initialize
      @database = nil
      @adapter_map = Hash.new { |h, name| h[name] = Scenic::Adapters::Null.new }
      add_adapter(name: "postgresql", instance: Scenic::Adapters::Postgres.new)
    end

    def add_adapter(name:, instance:)
      @adapter_map[name] = instance
    end

    # The Scenic database adapter instance to use when executing SQL.
    #
    # Defaults to an instance of {Adapters::Postgres}
    # @return Scenic adapter
    def database
      return @database if @database
      current_db_config = ActiveRecord::Base.connection_config
      adapter = current_db_config[:adapter]
      @adapter_map[adapter]
    end
  end

  # @return [Scenic::Configuration] Scenic's current configuration
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Set Scenic's configuration
  #
  # @param config [Scenic::Configuration]
  def self.configuration=(config)
    @configuration = config
  end

  # Modify Scenic's current configuration
  #
  # @yieldparam [Scenic::Configuration] config current Scenic config
  # ```
  # Scenic.configure do |config|
  #   config.database = Scenic::Adapters::Postgres.new
  # end
  # ```
  def self.configure
    yield configuration
  end
end
