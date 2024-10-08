# frozen_string_literal: true

module DiscourseEvents
  class EventSerializer < BasicEventSerializer
    has_many :topics, serializer: BasicTopicSerializer, embed: :objects
    has_many :sources, serializer: SourceSerializer, embed: :objects
  end
end
