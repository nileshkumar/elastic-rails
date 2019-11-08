require 'elasticsearch/model'
class Post < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # index_name Rails.application.class.parent_name.underscore
  # document_type self.name.downcase

  settings index: { number_of_shards: 3} do
    mappings dynamic: 'false' do
      indexes :title, analyzer: 'english'
      indexes :body, analyzer: 'english'
    end
  end

  def as_indexed_json(options = {})
   self.as_json(
     only: [:title, :body]
   )
 end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title^10', 'body']
          }
        },
        highlight: {
          pre_tags: ['<em>'],
          post_tags: ['</em>'],
          fields: {
            title: {},
            body: {}
          }
        }
      }
    )
  end
end
