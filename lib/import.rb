class Magpie::Import < ActiveRecord::Base
  validates_presence_of :feed_file_path
  attr_accessible :feed_file_path, :start_time, :end_time, :state, :log, :feed_provider, :collector_info

  state_machine initial: :pending do
    state :pending, value: 'pending'
    state :running, value: 'running'
    state :aborted, value: 'aborted'
    state :ended, value: 'ended'
    state :failed, value: 'failed'

    event :start do
      transition :pending => :running
    end

    event :stop do
      transition [:pending, :running] => :aborted
    end

    event :success do
      transition :running => :ended
    end

    event :failure do
      transition :running => :failed
    end

    after_transition any => :running do |import, transition|
      import.update_attributes!(start_time: DateTime.now)
      import._run(transition.args.first)
    end

    after_transition any => [:aborted, :ended, :failed] do |import, transition|
      import.update_attributes!(end_time: DateTime.now, log: transition.args.first)
    end
  end

  def _run(data = nil)
    data ||= File.read(feed_file_path)
    actions = nil
    begin
      feed = Magpie::Feed.from_hash(JSON.parse(data))
      importer = Magpie::Importer.new(feed)
      actions = importer.run!
    rescue Exception => e
      failure "Failed to process feed: #{feed_file_path} - #{e}"
      return
    end

    self.success actions.to_json
    actions
  end
end
